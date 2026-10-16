-- Loads IPLs near their probe and puts each interior's sets in place
-- The server decides which maps are ours through GlobalState

local points = {} -- [mapId] = points
local requested = {} -- [ipl] = true while we hold it

-- Interior id exists once the IPL is in
---@param probe vector3
---@return integer?
local function interiorAt(probe)
    for _ = 1, 50 do
        local interior = GetInteriorAtCoords(probe.x, probe.y, probe.z)
        if interior ~= 0 then return interior end
        Wait(100)
    end
end

---@param map table
local function applySets(map)
    local refresh = {}

    for _, set in ipairs(map.sets or {}) do
        local interior = interiorAt(set.probe)
        if interior then
            for _, name in ipairs(set.options) do
                if name == set.active then
                    ActivateInteriorEntitySet(interior, name)
                else
                    DeactivateInteriorEntitySet(interior, name)
                end
            end
            refresh[interior] = true
        else
            DebugPrint('No interior at', set.probe)
        end
    end

    for interior in pairs(refresh) do RefreshInterior(interior) end
end

---@param id string
local function startMap(id)
    if points[id] then return end
    local map = Config.maps[id]
    local list = {}

    for _, entry in ipairs(map.ipls or {}) do
        local point = lib.points.new({ coords = entry.probe, distance = Config.loadRadius })

        function point:onEnter()
            if not IsIplActive(entry.ipl) then RequestIpl(entry.ipl) end
            requested[entry.ipl] = true
            DebugPrint('Loaded', entry.ipl)
            CreateThread(function() applySets(map) end)
        end

        function point:onExit()
            RemoveIpl(entry.ipl)
            requested[entry.ipl] = nil
            DebugPrint('Unloaded', entry.ipl)
        end

        list[#list + 1] = point
    end

    -- sets on a streamed map
    if not map.ipls and map.sets then
        local point = lib.points.new({ coords = map.sets[1].probe, distance = Config.loadRadius })
        function point:onEnter() CreateThread(function() applySets(map) end) end
        list[#list + 1] = point
    end

    points[id] = list
    StartMovers(id)
end

---@param id string
local function stopMap(id)
    StopMovers(id)
    for _, point in ipairs(points[id] or {}) do point:remove() end
    for _, entry in ipairs(Config.maps[id].ipls or {}) do
        if requested[entry.ipl] then
            RemoveIpl(entry.ipl)
            requested[entry.ipl] = nil
        end
    end
    points[id] = nil
end

---@param active table? [mapId] = boolean
local function apply(active)
    for id in pairs(Config.maps) do
        if active and active[id] then startMap(id) else stopMap(id) end
    end
end

AddStateBagChangeHandler(StateKey, 'global', function(_, _, value)
    apply(value)
end)

CreateThread(function()
    apply(GlobalState[StateKey])
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id in pairs(points) do stopMap(id) end
end)
