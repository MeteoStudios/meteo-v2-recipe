-- Decides which maps we load and deals with scripts that would fight us
-- Map files are only read, never changed

-- Their config file, read in a sandbox
---@param resource string
---@param file string
---@param path string dot path, e.g. 'Standalone.enabled'
---@return any
local function readFlag(resource, file, path)
    local code = LoadResourceFile(resource, file)
    if not code then return nil end

    -- own Config, or theirs lands in ours
    local env = setmetatable({ Config = {} }, { __index = _G })
    local chunk = load(code, ('@@%s/%s'):format(resource, file), 't', env)
    if not chunk or not pcall(chunk) then return nil end

    local node = env.Config
    for part in path:gmatch('[^%.]+') do
        if type(node) ~= 'table' then return nil end
        node = node[part]
    end
    return node
end

---@param state string
local function running(state)
    return state == 'started' or state == 'starting'
end

---@param map table
local function handleConflicts(map)
    for _, resource in ipairs(map.conflicts or {}) do
        if running(GetResourceState(resource)) then
            if Config.stopConflicts then
                StopResource(resource)
                Warn(('Stopped %s, meteo-maphandler runs %s instead. Remove it from your server.cfg.'):format(resource, map.label))
            else
                Warn(('%s is running and fights meteo-maphandler over %s. Stop it or remove it from your server.cfg.'):format(resource, map.label))
            end
        end
    end
end

-- Ours only when the map's own loader is off
---@param map table
---@return boolean
local function takesOver(map)
    if not map.ownLoader then return true end

    local loader = map.ownLoader
    local flag = readFlag(map.resource, loader.file, loader.key)
    if loader.empty then
        if type(flag) == 'table' and next(flag) == nil then return true end
    elseif flag == false then
        return true
    end

    if flag == nil then
        Warn(('Could not read %s in %s/%s, so %s is left to it.'):format(loader.key, map.resource, loader.file, map.label))
    else
        Warn(('%s still loads itself. Set Config.%s = %s in %s/%s to hand it to meteo-maphandler.'):format(map.label, loader.key, loader.empty and '{}' or 'false', map.resource, loader.file))
    end
    return false
end

local function evaluate()
    local active = {}

    for id, map in pairs(Config.maps) do
        if running(GetResourceState(map.resource)) and takesOver(map) then
            active[id] = true
            handleConflicts(map)
        else
            active[id] = false
        end
        DebugPrint(map.label, active[id] and 'handled here' or 'not handled')
    end

    GlobalState[StateKey] = active
end

-- Resources this cares about
local watched = {}
for _, map in pairs(Config.maps) do
    watched[map.resource] = true
    for _, resource in ipairs(map.conflicts or {}) do watched[resource] = true end
end

CreateThread(evaluate)

-- Late starts and restarts
AddEventHandler('onResourceStart', function(resource)
    if watched[resource] then SetTimeout(500, evaluate) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        GlobalState[StateKey] = nil
        return
    end
    if watched[resource] then SetTimeout(500, evaluate) end
end)
