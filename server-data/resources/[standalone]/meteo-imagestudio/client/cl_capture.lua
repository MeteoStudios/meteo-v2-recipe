local grabbed = {}
local measured = {}
local nextId = 0

local FULL = { x = 0.0, y = 0.0, w = 1.0, h = 1.0 }
local isolate = nil     -- function(on) that hides the item, set per subject

function WaitFor(getter, timeout)
    local deadline = GetGameTimer() + timeout
    while GetGameTimer() < deadline do
        local v = getter()
        if v ~= nil then return v end
        Wait(0)
    end
    return nil
end

function NextId()
    nextId = nextId + 1
    return nextId
end

RegisterNUICallback('grabbed', function(data, cb)
    if data.id then grabbed[data.id] = data end
    cb({})
end)

RegisterNUICallback('measured', function(data, cb)
    if data.id then measured[data.id] = data end
    cb({})
end)

local function grabOnce(region, scale, expect, settle, frames)
    local id = NextId()
    grabbed[id] = nil
    SendNUIMessage({
        action = 'grab', id = id, region = region, scale = scale,
        expect = expect, settle = settle, frames = frames,
    })
    local r = WaitFor(function() return grabbed[id] end, Config.capture.timeout)
    grabbed[id] = nil
    return (r and r.ok) and id or nil
end

-- Dark then light backdrop, one grab each. `speed` nil means a quick measure grab.
local function grabPair(region, scale, speed)
    local ids = {}
    for _, col in ipairs({ Config.capture.dark, Config.capture.light }) do
        StudioShotColor(col)
        Wait(0)
        local id = speed
            and grabOnce(region, scale, col, speed.settleFrames, speed.averageFrames)
            or grabOnce(region, scale, col, 1, 1)
        if not id then
            ids = nil
            break
        end
        ids[#ids + 1] = id
    end
    StudioShotColor(nil)
    return ids
end

-- Kinds that draw more than the item (clothing on a ped) hand over a toggle;
-- every shot then also grabs a pair without the item, and the page keeps only
-- what changed
function CaptureIsolate(fn)
    isolate = fn
end

local function grabWithBase(region, scale, speed)
    local ids = grabPair(region, scale, speed)
    if not ids or not isolate then return ids, nil end
    isolate(true)
    Wait(0)
    Wait(0)
    Wait(0)
    local base = grabPair(region, scale, speed)
    isolate(false)
    Wait(0)
    Wait(0)
    Wait(0)
    if not base then return nil end
    return ids, base
end

-- The real silhouette box on screen, from a half-size full-frame matte.
-- false means the frames were read but nothing was there (an empty item).
local function measureOutline()
    local ids, base = grabWithBase(FULL, 0.5, nil)
    if not ids then return nil end
    local id = NextId()
    measured[id] = nil
    SendNUIMessage({ action = 'measure', id = id, grabs = ids, base = base, region = FULL })
    local r = WaitFor(function() return measured[id] end, Config.capture.timeout)
    measured[id] = nil
    if not r or not r.ok then return nil end
    return r.box or false
end

-- Frames the subject from its real outline. A box touching the screen edge is
-- cut off, so the camera backs away first. `passes` 2 re-measures to land
-- exactly (small items need it). Returns 'ok', 'empty' or 'fail'.
function FitOutline(passes)
    Wait(0)
    if not CameraIsRendering() then return 'fail' end

    local ok, pass, backoffs = false, 0, 0
    local edge = 0.004
    while pass < passes do
        local box = measureOutline()
        if box == false and not ok then return 'empty' end
        if not box then break end
        if backoffs < 5 and (box.x < edge or box.y < edge or box.x + box.w > 1 - edge or box.y + box.h > 1 - edge) then
            backoffs = backoffs + 1
            CameraBackOff(1.4)
        else
            pass = pass + 1
            ok = true
            local size = math.max(box.w, box.h)
            local cx = math.abs(box.x + box.w * 0.5 - 0.5)
            local cy = math.abs(box.y + box.h * 0.5 - 0.5)
            if math.abs(size - CameraFill()) < 0.01 and cx < 0.005 and cy < 0.005 then
                CameraSetBox(box)
                break
            end
            CameraNudge(box)
        end
        Wait(0)
        Wait(0)
    end
    return ok and 'ok' or 'fail'
end

-- The final shot: dark and light grabs of the subject region at full size.
-- Returns the grab ids, the region and the without-item ids (or nil).
function Shoot(speed)
    local region = CameraRegion()
    local ids, base = grabWithBase(region, 1.0, speed)
    if not ids then return nil end
    return ids, region, base
end
