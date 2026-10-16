Kinds = Kinds or {}

local current = nil

Kinds.furnishing = {
    folder = 'furnishing',
    fitPasses = 1,
    skipEmpty = true,

    -- the catalog is a server export of meteo-furnishing, fetched through our server
    list = function()
        local props = lib.callback.await('meteo-imagestudio:server:getFurnishingProps', false)
        if type(props) ~= 'table' then
            DebugPrint('furnishing catalog unavailable')
            return {}
        end

        local items, seen = {}, {}
        for _, p in ipairs(props) do
            local id = type(p.model) == 'string' and p.model or nil
            -- the same prop can sit in several categories; one image covers them all
            if id and not seen[id] and IsModelInCdimage(joaat(id)) then
                seen[id] = true
                items[#items + 1] = {
                    id = id,
                    label = p.label or id,
                    brand = p.categoryLabel or '',
                    group = p.categoryId or 'other',
                    groupLabel = p.categoryLabel,
                }
            end
        end
        return items
    end,

    preload = function(id)
        local hash = joaat(id)
        if IsModelInCdimage(hash) then RequestModel(hash) end
    end,

    shot = function(id)
        local cam = Config.furnishing.camera
        -- a small prop only fills as much of the frame as its texture can hold
        local min, max = GetModelDimensions(joaat(id))
        local size = math.max(max.x - min.x, max.y - min.y, max.z - min.z)
        local _, screenH = GetActiveScreenResolution()
        local fill = math.max(0.15, math.min(Float(cam.fill), size * Config.furnishing.pixelsPerMetre / screenH))
        return { angle = Config.furnishing.angles[id] or cam.angle, pitch = cam.pitch, fov = cam.fov, fill = fill + 0.0 }
    end,

    -- the new prop streams in while the old one is still on screen, then swaps
    apply = function(id)
        local hash = joaat(id)
        if not IsModelInCdimage(hash) then return nil end
        RequestModel(hash)
        if not WaitFor(function() return HasModelLoaded(hash) or nil end, 8000) then return nil end

        local loc = Config.studio.location
        local obj = CreateObject(hash, loc.x, loc.y, loc.z + 5.0, false, false, false)
        SetModelAsNoLongerNeeded(hash)
        if not DoesEntityExist(obj) then return nil end

        SetEntityHeading(obj, StudioHeading())
        FreezeEntityPosition(obj, true)
        SetEntityCollision(obj, false, false)
        SetEntityLodDist(obj, 0xFFFF)

        if current and DoesEntityExist(current) then DeleteEntity(current) end
        current = obj
        Wait(Config.furnishing.settle)
        return obj
    end,

    release = function()
        if current and DoesEntityExist(current) then DeleteEntity(current) end
        current = nil
    end,
}
