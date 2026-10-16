Kinds = Kinds or {}

local C = Config.clothing
local GENDERS = { 'male', 'female' }
local peds = {}         -- [gender] = ped
local dressedFor = {}   -- [gender] = category name the base is set up for
local byName = {}
for _, cat in ipairs(C.categories) do
    byName[cat.name] = cat
    cat.skipSet = {}
    for _, d in ipairs(cat.skip or {}) do cat.skipSet[d] = true end
end

local function parse(id)
    local gender, name, drawable = id:match('^(%a+)_(%a+)_(%d+)$')
    return gender, byName[name], tonumber(drawable)
end

-- arms down and held still: breathing would move the item between the two frames
local function holdPose(ped)
    local dict = C.pose.dict
    RequestAnimDict(dict)
    if not WaitFor(function() return HasAnimDictLoaded(dict) or nil end, 3000) then return end
    TaskPlayAnim(ped, dict, C.pose.name, 8.0, 8.0, -1, 1, 0.0, false, false, false)
    Wait(50)
    SetEntityAnimCurrentTime(ped, dict, C.pose.name, Float(C.pose.time))
    SetEntityAnimSpeed(ped, dict, C.pose.name, 0.0)
    RemoveAnimDict(dict)
end

local function pedFor(gender)
    local ped = peds[gender]
    if ped and DoesEntityExist(ped) then return ped end

    local hash = joaat(C.peds[gender])
    RequestModel(hash)
    if not WaitFor(function() return HasModelLoaded(hash) or nil end, 8000) then return nil end
    local loc = Config.studio.location
    ped = CreatePed(4, hash, loc.x, loc.y, loc.z + 5.0, StudioHeading(), false, false)
    SetModelAsNoLongerNeeded(hash)
    if not DoesEntityExist(ped) then return nil end

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanPlayAmbientAnims(ped, false)
    -- the camera can sit a few metres away, keep the HD ped streamed
    SetEntityLodDist(ped, 0xFFFF)
    SetPedLodMultiplier(ped, 10.0)
    holdPose(ped)

    peds[gender] = ped
    dressedFor[gender] = nil
    return ped
end

-- Everything hidden. The head only goes with `allowEmptyHeadDrawable true` set
-- in F8, on a ped that never had head blend data, after its overlays are cleared
-- (the old clothingcapture's order); otherwise the shot isolation removes it.
local function stripPed(ped)
    ClearAllPedProps(ped)
    for overlay = 0, 12 do SetPedHeadOverlay(ped, overlay, 0, 0.0) end
    for slot = 0, 11 do
        SetPedComponentVariation(ped, slot, C.hide[slot] or -1, 0, 0)
    end
end

-- a prop streams and attaches over several frames; shooting before it shows
-- makes every hat look empty
local function putPropOn(ped, prop, drawable)
    SetPedPropIndex(ped, prop, drawable, 0, true)
    WaitFor(function() return GetPedPropIndex(ped, prop) == drawable or nil end, C.preloadTimeout)
    Wait(C.propWait)
end

local function wear(ped, cat, drawable)
    if cat.component then
        SetPedPreloadVariationData(ped, cat.component, drawable, 0)
        WaitFor(function() return HasPedPreloadVariationDataFinished(ped) or nil end, C.preloadTimeout)
        SetPedComponentVariation(ped, cat.component, drawable, 0, 0)
        ReleasePedPreloadVariationData(ped)
    else
        ClearPedProp(ped, cat.prop)
        SetPedPreloadPropData(ped, cat.prop, drawable, 0)
        WaitFor(function() return HasPedPreloadPropDataFinished(ped) or nil end, C.preloadTimeout)
        putPropOn(ped, cat.prop, drawable)
        ReleasePedPreloadPropData(ped)
    end
end

local function drawableCount(ped, cat)
    if cat.component then return GetNumberOfPedDrawableVariations(ped, cat.component) end
    return GetNumberOfPedPropDrawableVariations(ped, cat.prop)
end

Kinds.clothing = {
    folder = 'clothing',
    fitPasses = 2,
    skipEmpty = true,
    settle = C.settle,

    list = function()
        local items = {}
        for _, gender in ipairs(GENDERS) do
            local ped = pedFor(gender)
            if ped then
                local genderLabel = locale('gender_' .. gender)
                for _, cat in ipairs(C.categories) do
                    local catLabel = locale('cloth_' .. cat.name)
                    for d = 0, drawableCount(ped, cat) - 1 do
                        if not cat.skipSet[d] then items[#items + 1] = {
                            id = ('%s_%s_%d'):format(gender, cat.name, d),
                            label = ('%s %d'):format(catLabel, d),
                            brand = genderLabel,
                            group = gender .. '_' .. cat.name,
                            groupLabel = genderLabel .. ' · ' .. catLabel,
                        } end
                    end
                end
                SetEntityVisible(ped, false, false)
            end
        end
        return items
    end,

    preload = function() end,

    -- the category's fixed box for runs: no measuring, the crop trims to the item
    quickFrame = function(entity, id)
        local _, cat = parse(id)
        if not cat or not cat.frame then return nil end
        local sum = vector3(0.0, 0.0, 0.0)
        for _, bone in ipairs(cat.frame.bones) do sum = sum + GetPedBoneCoords(entity, bone, 0.0, 0.0, 0.0) end
        return sum / #cat.frame.bones + cat.frame.offset, cat.frame.size
    end,

    -- where small items start framed: a cube around a bone
    focus = function(entity, id)
        local _, cat = parse(id)
        if not cat or not cat.focus then return nil end
        return GetPedBoneCoords(entity, cat.focus.bone, 0.0, 0.0, 0.0), cat.focus.size
    end,

    shot = function(id)
        local _, cat = parse(id)
        return {
            angle = cat and cat.angle or 0.0,
            pitch = cat and cat.pitch or 0.0,
            fov = C.fov,
            fill = C.fill,
        }
    end,

    apply = function(id)
        local gender, cat, drawable = parse(id)
        if not cat or not C.peds[gender] then return nil end
        local ped = pedFor(gender)
        if not ped then return nil end
        for g, p in pairs(peds) do
            if DoesEntityExist(p) then SetEntityVisible(p, g == gender, false) end
        end

        -- a full strip only when the category changes; within one only the slot changes
        if dressedFor[gender] ~= cat.name then
            stripPed(ped)
            -- props hang on the head and do not draw without it
            if cat.prop then SetPedComponentVariation(ped, 0, 0, 0, 0) end
            dressedFor[gender] = cat.name
        end
        wear(ped, cat, drawable)
        -- full-res textures, as if the viewer stood next to the ped
        local c = GetEntityCoords(ped)
        SetHdArea(c.x, c.y, c.z, 30.0)
        SetFocusPosAndVel(c.x, c.y, c.z, 0.0, 0.0, 0.0)
        Wait(C.applyWait)
        return ped
    end,

    -- takes the item off and puts it back for the without-item frames; the
    -- textures are already streamed, so it is back on the next frame
    isolate = function(ped, id, on)
        local _, cat, drawable = parse(id)
        if not cat then return end
        if cat.component then
            SetPedComponentVariation(ped, cat.component, on and -1 or drawable, 0, 0)
        elseif on then
            ClearPedProp(ped, cat.prop)
        else
            putPropOn(ped, cat.prop, drawable)
        end
    end,

    release = function()
        for g, p in pairs(peds) do
            if DoesEntityExist(p) then DeleteEntity(p) end
            peds[g] = nil
        end
        dressedFor = {}
    end,
}
