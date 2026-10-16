-- Lifts and doors: the server owns open and locked, clients only animate

local QBCore = exports['qb-core']:GetCoreObject()

local states = {} -- [mapId] = { [moverId] = { open, locked } }
local busyUntil = {} -- [key] = game timer
local near = {} -- [key] = { [src] = true }
local closeToken = {} -- [key] = latest close timer
local pending = {} -- [key] = queued closeNow

---@param mapId string
---@param moverId string
local function keyOf(mapId, moverId)
    return mapId .. ':' .. moverId
end

---@param mapId string
local function push(mapId)
    GlobalState[MoverKey(mapId)] = states[mapId]
end

---@param mapId string
---@param moverId string
---@return table?, table?
local function moverOf(mapId, moverId)
    local map = Config.maps[mapId]
    local mover = map and map.movers and map.movers[moverId]
    if not mover then return end
    return mover, Config.moverKinds[mover.kind]
end

---@param mapId string
---@param moverId string
---@param open boolean
local function setOpen(mapId, moverId, open)
    local state = states[mapId][moverId]
    if state.open == open then return end

    local _, kind = moverOf(mapId, moverId)
    state.open = open
    busyUntil[keyOf(mapId, moverId)] = GetGameTimer() + kind.duration
    push(mapId)
    DebugPrint(mapId, moverId, open and 'open' or 'closed')
end

-- Auto doors follow who is near
---@param mapId string
---@param moverId string
---@param closeNow boolean?
local function settle(mapId, moverId, closeNow)
    local key = keyOf(mapId, moverId)
    local state = states[mapId][moverId]

    local wait = (busyUntil[key] or 0) - GetGameTimer()
    if wait > 0 then
        if pending[key] ~= nil then
            pending[key] = pending[key] or closeNow == true
            return
        end
        pending[key] = closeNow == true
        SetTimeout(wait, function()
            local now = pending[key]
            pending[key] = nil
            settle(mapId, moverId, now)
        end)
        return
    end

    local _, kind = moverOf(mapId, moverId)
    -- stays up unless autoClose
    local want = not state.locked and (not kind.autoClose or next(near[key] or {}) ~= nil)
    if want == state.open then return end

    if want or closeNow then
        setOpen(mapId, moverId, want)
        return
    end

    -- last one out, close later
    local token = (closeToken[key] or 0) + 1
    closeToken[key] = token
    SetTimeout(Config.autoCloseDelay, function()
        if closeToken[key] == token then settle(mapId, moverId, true) end
    end)
end

---@param mapId string
local function isActive(mapId)
    local active = GlobalState[StateKey]
    return active and active[mapId]
end

---@param src integer
---@param coords vector3
---@param range number
local function isNear(src, coords, range)
    local ped = GetPlayerPed(src)
    return ped ~= 0 and #(GetEntityCoords(ped) - coords) <= range
end

---@param src integer
---@param jobs string[]?
local function hasAccess(src, jobs)
    local player = QBCore.Functions.GetPlayer(src)
    return player and HasJob(player.PlayerData.job, jobs)
end

for mapId, map in pairs(Config.maps) do
    if map.movers then
        states[mapId] = {}
        for moverId, mover in pairs(map.movers) do
            states[mapId][moverId] = { open = false, locked = Config.moverKinds[mover.kind].autoOpen and Config.startLocked or false }
        end
        push(mapId)
    end
end

RegisterNetEvent('meteo-maphandler:server:useMover', function(mapId, moverId)
    local src = source
    if not isActive(mapId) then return end
    local mover, kind = moverOf(mapId, moverId)
    if not mover or not isNear(src, mover.zone, 10.0) then return end

    if not hasAccess(src, Config.maps[mapId].jobs) then
        QBCore.Functions.Notify(src, locale('notify_no_access'), 'error')
        return
    end

    local state = states[mapId][moverId]
    if kind.autoOpen then
        state.locked = not state.locked
        push(mapId)
        QBCore.Functions.Notify(src, locale(state.locked and 'notify_locked' or 'notify_unlocked'), 'primary')
        settle(mapId, moverId, state.locked)
        return
    end

    if GetGameTimer() < (busyUntil[keyOf(mapId, moverId)] or 0) then
        QBCore.Functions.Notify(src, locale('notify_busy'), 'error')
        return
    end
    setOpen(mapId, moverId, not state.open)
end)

RegisterNetEvent('meteo-maphandler:server:nearMover', function(mapId, moverId, inside)
    local src = source
    if not isActive(mapId) then return end
    local mover, kind = moverOf(mapId, moverId)
    if not mover or not kind.autoOpen then return end

    local key = keyOf(mapId, moverId)
    near[key] = near[key] or {}
    -- slack for lag on the way in
    if inside and isNear(src, mover.zone, kind.autoRadius + 5.0) then
        near[key][src] = true
    else
        near[key][src] = nil
    end
    settle(mapId, moverId)
end)

AddEventHandler('playerDropped', function()
    local src = source
    for key, players in pairs(near) do
        if players[src] then
            players[src] = nil
            local mapId, moverId = key:match('^(.-):(.+)$')
            settle(mapId, moverId)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for mapId in pairs(states) do GlobalState[MoverKey(mapId)] = nil end
end)
