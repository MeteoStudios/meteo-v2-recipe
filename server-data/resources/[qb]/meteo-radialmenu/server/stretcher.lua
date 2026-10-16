local cfg = Config.Stretcher
local stretchers = {} -- [netId] = { entity, owner }
local parked = {} -- [tostring(netId)] = coords, synced for target zones
local allowedVehicles = {}

for i = 1, #cfg.vehicles do
    allowedVehicles[joaat(cfg.vehicles[i])] = true
end

local function isOnDutyEms(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player or not player.PlayerData.job.onduty then return false end
    return exports.qbx_core:HasGroup(src, cfg.jobs)
end

local function isDowned(src)
    local state = Player(src).state
    return state.isDead or state.isKnockedDown
end

local function getStretcher(netId)
    local data = stretchers[netId]
    if not data then return end
    if not DoesEntityExist(data.entity) then
        stretchers[netId] = nil
        return
    end
    return data.entity
end

-- same truth as vehiclekeys
local function isLocked(vehicle)
    local state = Entity(vehicle).state.doorslockstate
    if state then return state == 2 end
    return GetVehicleDoorLockStatus(vehicle) >= 2
end

local function getAmbulance(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId or 0)
    if vehicle == 0 or not allowedVehicles[GetEntityModel(vehicle)] then return end
    return vehicle
end

-- doors only sync from the owner
local function swingRearDoors(vehicle)
    local owner = NetworkGetEntityOwner(vehicle)
    if owner and owner > 0 then
        TriggerClientEvent('meteo-radialmenu:client:swingRearDoors', owner, NetworkGetNetworkIdFromEntity(vehicle))
    end
end

local function setParked(netId, coords)
    parked[tostring(netId)] = coords
    GlobalState.meteoStretchers = parked
end

local function isNear(src, entity, maxDist)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end
    return #(GetEntityCoords(ped) - GetEntityCoords(entity)) <= maxDist
end

-- stale pusher flag if nothing holds it
local function getPusher(netId, entity)
    local pusher = Entity(entity).state.stretcherPusher
    if pusher and GetEntityAttachedTo(entity) == 0 then
        Entity(entity).state:set('stretcherPusher', nil, true)
        setParked(netId, GetEntityCoords(entity))
        return nil
    end
    return pusher
end

local function ownsStretcher(src)
    for _, data in pairs(stretchers) do
        if data.owner == src then return true end
    end
    return false
end

local function isPatientAnywhere(src)
    for _, data in pairs(stretchers) do
        if DoesEntityExist(data.entity) and Entity(data.entity).state.stretcherPatient == src then return true end
    end
    return false
end

local function deleteStretcher(netId)
    local data = stretchers[netId]
    if not data then return end
    stretchers[netId] = nil
    setParked(netId, nil)
    if not DoesEntityExist(data.entity) then return end

    local patient = Entity(data.entity).state.stretcherPatient
    if patient then
        TriggerClientEvent('meteo-radialmenu:client:getOffStretcher', patient)
    end
    DeleteEntity(data.entity)
end

-- pushing/lying/owned stretchers of a leaving player
local function cleanupPlayer(src)
    for netId, data in pairs(stretchers) do
        if data.owner == src then
            deleteStretcher(netId)
        elseif DoesEntityExist(data.entity) then
            local state = Entity(data.entity).state
            if state.stretcherPusher == src then
                state:set('stretcherPusher', nil, true)
                -- let the detach land first
                SetTimeout(500, function()
                    if DoesEntityExist(data.entity) then setParked(netId, GetEntityCoords(data.entity)) end
                end)
            end
            if state.stretcherPatient == src then state:set('stretcherPatient', nil, true) end
        end
    end
end

lib.callback.register('meteo-radialmenu:server:takeStretcher', function(source, vehNetId)
    if not isOnDutyEms(source) then return false end
    if ownsStretcher(source) then return false, 'stretcher_already_out' end

    local vehicle = getAmbulance(vehNetId)
    if not vehicle then return false end
    if not isNear(source, vehicle, 8.0) then return false, 'far_away' end
    if isLocked(vehicle) then return false, 'stretcher_vehicle_locked' end

    local coords = GetEntityCoords(GetPlayerPed(source))
    local entity = CreateObjectNoOffset(cfg.model, coords.x, coords.y, coords.z - 1.0, true, true, false)

    local timeout = GetGameTimer() + 2000
    while not DoesEntityExist(entity) do
        if GetGameTimer() > timeout then return false, 'stretcher_failed' end
        Wait(10)
    end

    SetEntityHeading(entity, GetEntityHeading(vehicle))
    swingRearDoors(vehicle)
    local netId = NetworkGetNetworkIdFromEntity(entity)
    local state = Entity(entity).state
    state:set('meteoStretcher', true, true)
    state:set('stretcherPusher', source, true)
    stretchers[netId] = { entity = entity, owner = source }

    return netId
end)

lib.callback.register('meteo-radialmenu:server:pushStretcher', function(source, netId)
    local entity = getStretcher(netId)
    if not entity or not isOnDutyEms(source) then return false end
    if not isNear(source, entity, cfg.interactDistance + 1.5) then return false, 'far_away' end

    if getPusher(netId, entity) then return false, 'stretcher_in_use' end
    Entity(entity).state:set('stretcherPusher', source, true)
    setParked(netId, nil)
    return true
end)

RegisterNetEvent('meteo-radialmenu:server:releaseStretcher', function(netId, coords)
    local entity = getStretcher(netId)
    if not entity then return end
    local state = Entity(entity).state
    if state.stretcherPusher ~= source then return end

    state:set('stretcherPusher', nil, true)
    -- client coords are fresher, server copy may lag
    local serverCoords = GetEntityCoords(entity)
    if type(coords) ~= 'vector3' or #(coords - serverCoords) > 5.0 then coords = serverCoords end
    setParked(netId, coords)
end)

lib.callback.register('meteo-radialmenu:server:placePatient', function(source, netId, target)
    local entity = getStretcher(netId)
    if not entity or not isOnDutyEms(source) then return false end
    if type(target) ~= 'number' or target == source or GetPlayerPed(target) == 0 then return false end
    if not isNear(source, entity, cfg.interactDistance + 1.5) or not isNear(target, entity, 5.0) then
        return false, 'far_away'
    end
    if GetVehiclePedIsIn(GetPlayerPed(target), false) ~= 0 then return false end

    local state = Entity(entity).state
    if state.stretcherPatient or isPatientAnywhere(target) then return false, 'stretcher_in_use' end

    state:set('stretcherPatient', target, true)
    TriggerClientEvent('meteo-radialmenu:client:layOnStretcher', target, netId)
    return true
end)

lib.callback.register('meteo-radialmenu:server:removePatient', function(source, netId)
    local entity = getStretcher(netId)
    if not entity or not isOnDutyEms(source) then return false end
    if not isNear(source, entity, cfg.interactDistance + 1.5) then return false, 'far_away' end

    local state = Entity(entity).state
    local patient = state.stretcherPatient
    if not patient then return false end

    state:set('stretcherPatient', nil, true)
    TriggerClientEvent('meteo-radialmenu:client:getOffStretcher', patient)
    return true
end)

lib.callback.register('meteo-radialmenu:server:layDown', function(source, netId)
    local entity = getStretcher(netId)
    if not entity then return false end
    if not isNear(source, entity, cfg.interactDistance + 1.5) then return false, 'far_away' end

    local state = Entity(entity).state
    if isDowned(source) then return false end
    if state.stretcherPatient or state.stretcherPusher == source or isPatientAnywhere(source) then
        return false, 'stretcher_in_use'
    end

    state:set('stretcherPatient', source, true)
    return true
end)

RegisterNetEvent('meteo-radialmenu:server:leaveStretcher', function(netId)
    local entity = getStretcher(netId)
    if not entity then return end
    local state = Entity(entity).state
    if state.stretcherPatient == source then
        state:set('stretcherPatient', nil, true)
    end
end)

lib.callback.register('meteo-radialmenu:server:storeStretcher', function(source, netId, vehNetId)
    local entity = getStretcher(netId)
    local vehicle = getAmbulance(vehNetId)
    if not entity or not vehicle or not isOnDutyEms(source) then return false end
    if not isNear(source, vehicle, 8.0) or #(GetEntityCoords(entity) - GetEntityCoords(vehicle)) > 8.0 then
        return false, 'far_away'
    end
    if isLocked(vehicle) then return false, 'stretcher_vehicle_locked' end

    local state = Entity(entity).state
    if state.stretcherPatient then return false, 'stretcher_has_patient' end
    local pusher = getPusher(netId, entity)
    if pusher and pusher ~= source then return false, 'stretcher_in_use' end

    deleteStretcher(netId)
    swingRearDoors(vehicle)
    return true
end)

AddEventHandler('playerDropped', function()
    cleanupPlayer(source)
end)

AddEventHandler('qbx_core:server:playerLoggedOut', function(src)
    cleanupPlayer(src)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, data in pairs(stretchers) do
        if DoesEntityExist(data.entity) then DeleteEntity(data.entity) end
    end
    GlobalState.meteoStretchers = nil
end)
