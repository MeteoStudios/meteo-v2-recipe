local cfg = Config.Stretcher
local policeJob = Rename.prefix .. 'policejob'
local pushDict, pushAnim = 'anim@heists@box_carry@', 'idle'
local layDict, layAnim = 'anim@gangops@morgue@table@', 'ko_front'

local pushing -- netId we are pushing
local lyingOn -- netId we are lying on
local releaseKey, getOffKey

local function notify(key, type)
    lib.notify({ description = locale(key), type = type or 'inform' })
end

local function isOnDutyEms()
    local job = QBX.PlayerData.job
    if not job or not job.onduty then return false end
    return exports.qbx_core:HasGroup(cfg.jobs)
end

local function isDowned()
    local state = LocalPlayer.state
    return state.isDead or state.isKnockedDown or IsEntityDead(cache.ped)
end

local function getEntity(netId)
    if not netId or not NetworkDoesNetworkIdExist(netId) then return 0 end
    return NetworkGetEntityFromNetworkId(netId)
end

-- same truth as vehiclekeys
local function isLocked(vehicle)
    local state = Entity(vehicle).state.doorslockstate
    if state then return state == 2 end
    return GetVehicleDoorLockStatus(vehicle) >= 2
end

local function isBehind(vehicle)
    return GetOffsetFromEntityGivenWorldCoords(vehicle, GetEntityCoords(cache.ped)).y < -2.0
end

local function isStretcher(entity)
    return Entity(entity).state.meteoStretcher == true
end

-- stale pusher flag if nothing holds it
local function isPushed(entity)
    return Entity(entity).state.stretcherPusher ~= nil and IsEntityAttached(entity)
end

-- Pushing

local function stopPushing()
    if not pushing then return end
    local netId = pushing
    pushing = nil

    local entity = getEntity(netId)
    if entity ~= 0 and IsEntityAttachedToEntity(entity, cache.ped) then
        DetachEntity(entity, true, true)
        -- drop the hand bone rotation
        local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 1.2, 0.0)
        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityRotation(entity, 0.0, 0.0, GetEntityHeading(cache.ped), 2, true)
        PlaceObjectOnGroundProperly(entity)
        FreezeEntityPosition(entity, true)
    end

    StopAnimTask(cache.ped, pushDict, pushAnim, 1.0)
    releaseKey:disable(true)
    lib.hideTextUI()
    TriggerServerEvent('meteo-radialmenu:server:releaseStretcher', netId, entity ~= 0 and GetEntityCoords(entity) or nil)
end

local function pushGuard()
    while pushing do
        local ped = cache.ped
        if getEntity(pushing) == 0 or isDowned() or IsPedRagdoll(ped) or IsPedInAnyVehicle(ped, false)
            or IsPedShooting(ped) or IsPlayerFreeAiming(cache.playerId) or IsPedInMeleeCombat(ped) then
            stopPushing()
            break
        end
        if not IsEntityPlayingAnim(ped, pushDict, pushAnim, 3) then
            TaskPlayAnim(ped, pushDict, pushAnim, 8.0, 8.0, -1, 50, 0, false, false, false)
        end
        Wait(250)
    end
end

local function startPushing(netId)
    local ok, entity = pcall(lib.waitFor, function()
        local e = getEntity(netId)
        if e ~= 0 then return e end
    end, nil, 2000)

    -- attaching needs ownership
    if ok then
        NetworkRequestControlOfEntity(entity)
        ok = pcall(lib.waitFor, function() return NetworkHasControlOfEntity(entity) or nil end, nil, 2000)
    end

    if not ok then
        TriggerServerEvent('meteo-radialmenu:server:releaseStretcher', netId)
        return notify('stretcher_failed', 'error')
    end

    local ped = cache.ped
    local a = cfg.pushAttach
    lib.requestAnimDict(pushDict)
    FreezeEntityPosition(entity, false)
    TaskPlayAnim(ped, pushDict, pushAnim, 8.0, 8.0, -1, 50, 0, false, false, false)
    AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, a.bone), a.offset.x, a.offset.y, a.offset.z,
        a.rotation.x, a.rotation.y, a.rotation.z, false, false, false, true, 0, true)
    RemoveAnimDict(pushDict)

    pushing = netId
    releaseKey:disable(false)
    lib.showTextUI(locale('stretcher_push_hint', releaseKey:getCurrentKey()))
    CreateThread(pushGuard)
end

-- Lying

local function getOff(tellServer)
    if not lyingOn then return end
    local netId = lyingOn
    lyingOn = nil

    local ped = cache.ped
    local entity = getEntity(netId)
    DetachEntity(ped, true, true)
    StopAnimTask(ped, layDict, layAnim, 1.0)
    if entity ~= 0 then
        local coords = GetOffsetFromEntityInWorldCoords(entity, 0.85, 0.0, 0.0)
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end

    getOffKey:disable(true)
    lib.hideTextUI()
    if tellServer then
        TriggerServerEvent('meteo-radialmenu:server:leaveStretcher', netId)
    end
end

local function layGuard()
    while lyingOn do
        local ped = cache.ped
        if getEntity(lyingOn) == 0 then
            getOff(true)
            break
        end
        -- other scripts may clear our tasks
        if not IsEntityPlayingAnim(ped, layDict, layAnim, 3) then
            lib.requestAnimDict(layDict)
            TaskPlayAnim(ped, layDict, layAnim, 8.0, 8.0, -1, 1, 0, false, false, false)
        end
        Wait(500)
    end
end

local function layOn(netId)
    local entity = getEntity(netId)
    if entity == 0 then
        return TriggerServerEvent('meteo-radialmenu:server:leaveStretcher', netId)
    end

    local ped = cache.ped
    local a = cfg.layAttach
    lib.requestAnimDict(layDict)
    AttachEntityToEntity(ped, entity, 0, a.offset.x, a.offset.y, a.offset.z,
        a.rotation.x, a.rotation.y, a.rotation.z, false, false, false, false, 2, true)
    TaskPlayAnim(ped, layDict, layAnim, 8.0, 8.0, -1, 1, 0, false, false, false)

    lyingOn = netId
    if not isDowned() then
        getOffKey:disable(false)
        lib.showTextUI(locale('stretcher_get_off_hint', getOffKey:getCurrentKey()))
    end
    CreateThread(layGuard)
end

-- Patient pick: escorted player first, else closest
local function getPatientCandidate(entity)
    if GetResourceState(policeJob) == 'started' and exports[policeJob]:IsEscorting() then
        return exports[policeJob]:GetEscortedPlayerId(), true
    end

    local playerId, playerPed = lib.getClosestPlayer(GetEntityCoords(entity), cfg.interactDistance, false)
    if not playerId or IsPedInAnyVehicle(playerPed, false) or IsEntityAttached(playerPed) then return end
    return GetPlayerServerId(playerId), false
end

-- Keybinds

releaseKey = lib.addKeybind({
    name = 'meteo_stretcher_release',
    description = locale('stretcher_keybind_release'),
    defaultKey = 'E',
    disabled = true,
    onPressed = stopPushing,
})

getOffKey = lib.addKeybind({
    name = 'meteo_stretcher_get_off',
    description = locale('stretcher_keybind_get_off'),
    defaultKey = 'G',
    disabled = true,
    onPressed = function()
        if not isDowned() then getOff(true) end
    end,
})

-- Targets

exports.ox_target:addModel(cfg.vehicles, {
    {
        name = 'meteo_stretcher_take',
        icon = 'fas fa-bed-pulse',
        label = locale('stretcher_take'),
        distance = 3.0,
        canInteract = function(entity)
            return not pushing and not lyingOn and isOnDutyEms() and isBehind(entity) and not isLocked(entity)
        end,
        onSelect = function(data)
            local netId, err = lib.callback.await('meteo-radialmenu:server:takeStretcher', false, VehToNet(data.entity))
            if not netId then return notify(err or 'stretcher_failed', 'error') end
            startPushing(netId)
        end,
    },
    {
        name = 'meteo_stretcher_store',
        icon = 'fas fa-box-archive',
        label = locale('stretcher_store'),
        distance = 3.0,
        canInteract = function(entity)
            if not pushing or not isOnDutyEms() or not isBehind(entity) or isLocked(entity) then return false end
            local stretcher = getEntity(pushing)
            return stretcher ~= 0 and not Entity(stretcher).state.stretcherPatient
        end,
        onSelect = function(data)
            local ok, err = lib.callback.await('meteo-radialmenu:server:storeStretcher', false, pushing, VehToNet(data.entity))
            if not ok then return notify(err or 'stretcher_failed', 'error') end
            stopPushing()
        end,
    },
})

-- Zones, the model collision is too small to raycast
local zones = {} -- [netId] = zone id

local function stretcherOptions(netId)
    local function stretcher()
        local entity = getEntity(netId)
        if entity ~= 0 and isStretcher(entity) then return entity end
    end

    return {
        {
            name = 'meteo_stretcher_push',
            icon = 'fas fa-hand',
            label = locale('stretcher_push'),
            distance = cfg.interactDistance,
            canInteract = function()
                local entity = stretcher()
                return entity and not isPushed(entity) and not pushing and not lyingOn and isOnDutyEms()
            end,
            onSelect = function()
                local ok, err = lib.callback.await('meteo-radialmenu:server:pushStretcher', false, netId)
                if not ok then return notify(err or 'stretcher_failed', 'error') end
                startPushing(netId)
            end,
        },
        {
            name = 'meteo_stretcher_place_patient',
            icon = 'fas fa-user-injured',
            label = locale('stretcher_place_patient'),
            distance = cfg.interactDistance,
            canInteract = function()
                local entity = stretcher()
                return entity and not Entity(entity).state.stretcherPatient and not pushing and not lyingOn
                    and isOnDutyEms() and getPatientCandidate(entity) ~= nil
            end,
            onSelect = function()
                local entity = stretcher()
                if not entity then return end
                local target, escorted = getPatientCandidate(entity)
                if not target then return notify('no_people_nearby', 'error') end
                if escorted and not exports[policeJob]:StopEscorting() then
                    return notify('stretcher_failed', 'error')
                end

                local ok, err = lib.callback.await('meteo-radialmenu:server:placePatient', false, netId, target)
                if not ok then notify(err or 'stretcher_failed', 'error') end
            end,
        },
        {
            name = 'meteo_stretcher_remove_patient',
            icon = 'fas fa-person-walking-arrow-right',
            label = locale('stretcher_remove_patient'),
            distance = cfg.interactDistance,
            canInteract = function()
                local entity = stretcher()
                return entity and Entity(entity).state.stretcherPatient and not lyingOn and isOnDutyEms()
            end,
            onSelect = function()
                local ok, err = lib.callback.await('meteo-radialmenu:server:removePatient', false, netId)
                if not ok then notify(err or 'stretcher_failed', 'error') end
            end,
        },
        {
            name = 'meteo_stretcher_lay',
            icon = 'fas fa-bed',
            label = locale('stretcher_lay'),
            distance = cfg.interactDistance,
            canInteract = function()
                local entity = stretcher()
                return entity and not Entity(entity).state.stretcherPatient and not isPushed(entity)
                    and not pushing and not lyingOn and not isDowned()
            end,
            onSelect = function()
                local ok, err = lib.callback.await('meteo-radialmenu:server:layDown', false, netId)
                if not ok then return notify(err or 'stretcher_failed', 'error') end
                layOn(netId)
            end,
        },
    }
end

local function refreshZones(list)
    list = list or {}
    for key, zoneId in pairs(zones) do
        exports.ox_target:removeZone(zoneId)
        zones[key] = nil
    end
    for key, coords in pairs(list) do
        zones[key] = exports.ox_target:addSphereZone({
            coords = coords,
            radius = cfg.zoneRadius,
            options = stretcherOptions(tonumber(key)),
        })
    end
end

AddStateBagChangeHandler('meteoStretchers', 'global', function(_, _, value)
    refreshZones(value)
end)

CreateThread(function()
    refreshZones(GlobalState.meteoStretchers)
end)

-- Server driven

RegisterNetEvent('meteo-radialmenu:client:layOnStretcher', function(netId)
    if lyingOn then getOff(true) end
    layOn(netId)
end)

RegisterNetEvent('meteo-radialmenu:client:swingRearDoors', function(vehNetId)
    if not NetworkDoesNetworkIdExist(vehNetId) then return end
    local vehicle = NetToVeh(vehNetId)
    for _, door in ipairs(cfg.rearDoors) do
        SetVehicleDoorOpen(vehicle, door, false, false)
    end

    SetTimeout(cfg.doorCloseDelay, function()
        if not DoesEntityExist(vehicle) then return end
        for _, door in ipairs(cfg.rearDoors) do
            SetVehicleDoorShut(vehicle, door, false)
        end
    end)
end)

RegisterNetEvent('meteo-radialmenu:client:getOffStretcher', function()
    getOff(false)
end)

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    stopPushing()
    getOff(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if pushing or lyingOn then
        DetachEntity(cache.ped, true, true)
        ClearPedTasks(cache.ped)
        lib.hideTextUI()
    end
end)
