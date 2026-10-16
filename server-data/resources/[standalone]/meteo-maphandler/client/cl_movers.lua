-- Spawns lifts and doors near you and plays whatever the server decides

local QBCore = exports['qb-core']:GetCoreObject()

local active = {} -- [mapId] = { [moverId] = entry }

---@param model string
---@return integer?
local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return end
    RequestModel(hash)
    local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then return end
        Wait(0)
    end
    return hash
end

---@param dict string
---@return boolean
local function loadDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 10000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then return false end
        Wait(0)
    end
    return true
end

---@param mapId string
---@param moverId string
---@return table?
local function stateOf(mapId, moverId)
    local states = GlobalState[MoverKey(mapId)]
    return states and states[moverId]
end

-- Bone heights before an animation
---@param prop integer
---@return number[]
local function boneHeights(prop)
    local heights = {}
    for i = 0, GetEntityBoneCount(prop) - 1 do
        heights[i + 1] = GetWorldPositionOfEntityBone(prop, i).z
    end
    return heights
end

-- How far the moving bone travelled
---@param prop integer
---@param rest number[]
---@return number?
local function boneRise(prop, rest)
    local best
    for i, z in ipairs(rest) do
        local rise = GetWorldPositionOfEntityBone(prop, i - 1).z - z
        if not best or math.abs(rise) > math.abs(best) then best = rise end
    end
    if best and math.abs(best) > 0.005 then return best end
end

---@param entry table
---@param at vector3
local function placeCollision(entry, at)
    SetEntityCoords(entry.collision, at.x, at.y, at.z, false, false, false, false)
end

-- Our vehicles resting on the lift
---@param entry table
---@param baseZ number platform height now
---@return table[]
local function liftVehicles(entry, baseZ)
    local cars = {}
    local center = entry.mover.coords.xy
    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if NetworkGetEntityOwner(vehicle) == PlayerId() then
            local pos = GetEntityCoords(vehicle)
            if #(pos.xy - center) <= entry.kind.carryRadius and pos.z > baseZ - 1.0 and pos.z < baseZ + 3.0 then
                FreezeEntityPosition(vehicle, true)
                cars[#cars + 1] = { handle = vehicle, from = pos }
            end
        end
    end
    return cars
end

-- Collision follows the prop
---@param entry table
---@param open boolean
---@param animate boolean
---@param rest number[]? bone heights, follow them
local function slide(entry, open, animate, rest)
    local mover, kind = entry.mover, entry.kind
    local origin, target = mover.from, mover.to
    if not open then origin, target = target, origin end

    entry.slide = (entry.slide or 0) + 1
    local token = entry.slide

    if not animate then return placeCollision(entry, target) end

    local low, high = math.min(origin.z, target.z), math.max(origin.z, target.z)

    CreateThread(function()
        local start = GetGameTimer()
        local followed = false
        local cars = kind.carry and liftVehicles(entry, origin.z) or {}

        -- collision and cars together
        local function move(at)
            placeCollision(entry, at)
            local lift = at.z - origin.z
            for _, car in ipairs(cars) do
                if DoesEntityExist(car.handle) then
                    SetEntityCoordsNoOffset(car.handle, car.from.x, car.from.y, car.from.z + lift, false, false, false)
                end
            end
        end

        while GetGameTimer() - start < kind.duration do
            if entry.slide ~= token or not DoesEntityExist(entry.collision) then return end
            local elapsed = GetGameTimer() - start

            local rise = rest and boneRise(entry.prop, rest)
            if rise then
                followed = true
                move(vec3(origin.x, origin.y, math.min(math.max(origin.z + rise, low), high)))
            elseif not followed then
                -- no moving bone, timed
                local t = math.min(math.max((elapsed - (open and kind.delay or 0)) / kind.moveTime, 0.0), 1.0)
                move(origin + (target - origin) * (t * t * (3.0 - 2.0 * t)))
            end
            Wait(0)
        end

        if entry.slide == token and DoesEntityExist(entry.collision) then move(target) end
        -- held up, free once down
        if not open then
            for _, car in ipairs(cars) do
                if DoesEntityExist(car.handle) then FreezeEntityPosition(car.handle, false) end
            end
        end
    end)
end

-- Animate, or jump to the end
---@param entry table
---@param open boolean
---@param animate boolean
local function pose(entry, open, animate)
    local kind, prop = entry.kind, entry.prop
    if not prop or not DoesEntityExist(prop) then return end

    local rest = animate and kind.follow and boneHeights(prop) or nil

    if animate then
        PlayEntityAnim(prop, open and kind.open or kind.close, kind.dict, 1000.0, false, true, false, 0.0, 0)
    elseif open then
        PlayEntityAnim(prop, kind.open, kind.dict, 1000.0, false, true, false, 1.0, 0)
        SetEntityAnimCurrentTime(prop, kind.dict, kind.open, 1.0)
    else
        PlayEntityAnim(prop, kind.static, kind.dict, 1000.0, false, true, false, 0.0, 0)
    end

    if entry.collision then slide(entry, open, animate, rest) end
end

-- Which of the two options shows
---@param entry table
---@param second boolean
---@return boolean
local function canSee(entry, second)
    local state = stateOf(entry.mapId, entry.moverId)
    if not state then return false end
    if not HasJob(QBCore.Functions.GetPlayerData().job, Config.maps[entry.mapId].jobs) then return false end

    local flag
    if entry.kind.autoOpen then flag = not state.locked else flag = state.open end
    return flag == second
end

---@param entry table
local function addZone(entry)
    local target = GetTarget()
    if not target then return DebugPrint('No target resource for', entry.zoneId) end

    local kind, mover = entry.kind, entry.mover
    local icons = kind.autoOpen and { 'fas fa-lock-open', 'fas fa-lock' } or { 'fas fa-arrow-up', 'fas fa-arrow-down' }
    local function use()
        TriggerServerEvent('meteo-maphandler:server:useMover', entry.mapId, entry.moverId)
    end

    local options = {}
    for i = 1, 2 do
        options[i] = {
            name = entry.zoneId .. '_' .. i,
            icon = icons[i],
            label = locale(kind.labels[i]),
            onSelect = use,
            canInteract = function() return canSee(entry, i == 2) end,
        }
    end

    if target == 'ox_target' then
        exports.ox_target:addBoxZone({
            name = entry.zoneId,
            coords = mover.zone,
            size = kind.size,
            rotation = mover.heading,
            debug = Config.debug,
            options = options,
        })
    else
        local qbOptions = {}
        for i, option in ipairs(options) do
            qbOptions[i] = { label = option.label, icon = option.icon, action = option.onSelect, canInteract = option.canInteract }
        end
        exports['qb-target']:AddBoxZone(entry.zoneId, mover.zone, kind.size.x, kind.size.y, {
            name = entry.zoneId,
            heading = mover.heading,
            debugPoly = Config.debug,
            minZ = mover.zone.z - kind.size.z,
            maxZ = mover.zone.z + kind.size.z,
        }, { options = qbOptions, distance = 2.5 })
    end
    entry.hasZone = true
end

---@param entry table
local function removeZone(entry)
    if not entry.hasZone then return end
    local target = GetTarget()
    pcall(function()
        if target == 'ox_target' then
            exports.ox_target:removeZone(entry.zoneId)
        elseif target == 'qb-target' then
            exports['qb-target']:RemoveZone(entry.zoneId)
        end
    end)
    entry.hasZone = nil
end

---@param handle integer?
local function deleteObject(handle)
    if handle and DoesEntityExist(handle) then DeleteEntity(handle) end
end

---@param entry table
local function spawn(entry)
    entry.token = entry.token + 1
    local token = entry.token
    local mover, kind = entry.mover, entry.kind

    local propHash = loadModel(kind.model)
    local collisionHash = loadModel(kind.collision)
    if not loadDict(kind.dict) then DebugPrint('Missing anim dict', kind.dict) end
    if entry.token ~= token then return end
    if not propHash then return DebugPrint('Missing model', kind.model) end

    entry.prop = CreateObjectNoOffset(propHash, mover.coords.x, mover.coords.y, mover.coords.z, false, false, false)
    SetEntityHeading(entry.prop, mover.heading)
    FreezeEntityPosition(entry.prop, true)
    SetModelAsNoLongerNeeded(propHash)

    if collisionHash then
        -- dynamic, or vehicles fall through
        entry.collision = CreateObjectNoOffset(collisionHash, mover.from.x, mover.from.y, mover.from.z, false, false, true)
        SetEntityRotation(entry.collision, 0.0, 0.0, 0.0, 2, true)
        FreezeEntityPosition(entry.collision, true)
        SetEntityCollision(entry.collision, true, true)
        -- placeholder texture, collision only
        SetEntityVisible(entry.collision, false, false)
        SetModelAsNoLongerNeeded(collisionHash)
    end

    local state = stateOf(entry.mapId, entry.moverId)
    entry.open = state and state.open or false
    pose(entry, entry.open, false)
    addZone(entry)
end

---@param entry table
local function despawn(entry)
    entry.token = entry.token + 1
    entry.slide = (entry.slide or 0) + 1
    removeZone(entry)
    deleteObject(entry.prop)
    deleteObject(entry.collision)
    entry.prop, entry.collision = nil, nil
end

---@param mapId string
function StartMovers(mapId)
    local map = Config.maps[mapId]
    if not map.movers or active[mapId] then return end
    local entries = {}

    for moverId, mover in pairs(map.movers) do
        local kind = Config.moverKinds[mover.kind]
        local entry = {
            mapId = mapId, moverId = moverId, mover = mover, kind = kind,
            zoneId = ('meteo_maphandler_%s_%s'):format(mapId, moverId),
            token = 0, points = {},
        }

        local point = lib.points.new({ coords = mover.coords, distance = Config.moverRadius })
        function point:onEnter() CreateThread(function() spawn(entry) end) end
        function point:onExit() despawn(entry) end
        entry.points[1] = point

        if kind.autoOpen then
            local nearPoint = lib.points.new({ coords = mover.zone, distance = kind.autoRadius })
            function nearPoint:onEnter()
                entry.inside = true
                TriggerServerEvent('meteo-maphandler:server:nearMover', mapId, moverId, true)
            end
            function nearPoint:onExit()
                entry.inside = nil
                TriggerServerEvent('meteo-maphandler:server:nearMover', mapId, moverId, false)
            end
            entry.points[2] = nearPoint
        end

        entries[moverId] = entry
    end

    active[mapId] = entries
end

---@param mapId string
function StopMovers(mapId)
    for moverId, entry in pairs(active[mapId] or {}) do
        for _, point in ipairs(entry.points) do point:remove() end
        if entry.inside then TriggerServerEvent('meteo-maphandler:server:nearMover', mapId, moverId, false) end
        despawn(entry)
    end
    active[mapId] = nil
end

-- Replay changes for movers in range
for mapId, map in pairs(Config.maps) do
    if map.movers then
        AddStateBagChangeHandler(MoverKey(mapId), 'global', function(_, _, value)
            if not value then return end
            for moverId, entry in pairs(active[mapId] or {}) do
                local state = value[moverId]
                if state and entry.prop and state.open ~= entry.open then
                    entry.open = state.open
                    pose(entry, state.open, true)
                end
            end
        end)
    end
end
