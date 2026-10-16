local cam = nil
local aim = vector3(0.0, 0.0, 0.0)
local distance = 40.0
local lastBox = nil      -- where the subject sits on screen, 0..1
local view, right, up = nil, nil, nil
local shot = Config.camera
local fov = Float(Config.camera.fov)   -- the lens in use; narrower than the shot's for small subjects

local function dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

local function lens()
    local tanV = math.tan(math.rad(fov) * 0.5)
    return tanV * GetAspectRatio(false), tanV
end

-- view, right and up for the shot angle around a subject facing the studio heading
local function basis()
    local a = math.rad(Float(shot.angle))
    local p = math.rad(Float(shot.pitch))
    local h = math.rad(StudioHeading())
    local lx, ly = math.sin(a), math.cos(a)
    local ox = lx * math.cos(h) - ly * math.sin(h)
    local oy = lx * math.sin(h) + ly * math.cos(h)
    local flat = vector3(-ox, -oy, 0.0)
    right = vector3(flat.y, -flat.x, 0.0)
    view = flat * math.cos(p) - vector3(0.0, 0.0, math.sin(p))
    up = flat * math.sin(p) + vector3(0.0, 0.0, math.cos(p))
end

local function boxCorners(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local corners = {}
    for _, x in ipairs({ min.x, max.x }) do
        for _, y in ipairs({ min.y, max.y }) do
            for _, z in ipairs({ min.z, max.z }) do
                corners[#corners + 1] = GetOffsetFromEntityInWorldCoords(entity, x, y, z)
            end
        end
    end
    local center = (min + max) * 0.5
    return corners, GetOffsetFromEntityInWorldCoords(entity, center.x, center.y, center.z)
end

local function cubeCorners(center, size)
    local h = size * 0.5
    local corners = {}
    for _, x in ipairs({ -h, h }) do
        for _, y in ipairs({ -h, h }) do
            for _, z in ipairs({ -h, h }) do
                corners[#corners + 1] = center + vector3(x, y, z)
            end
        end
    end
    return corners, center
end

local function place()
    if not cam then return end
    local pos = aim - view * distance
    SetCamCoord(cam, pos.x, pos.y, pos.z)
    PointCamAtCoord(cam, aim.x, aim.y, aim.z)
    SetCamFov(cam, fov)
end
-- One framing pass with the current lens: distance from the corners, aim centred
local function solvePass(corners)
    local tanH, tanV = lens()
    local fill = Float(shot.fill)
    for _ = 1, 3 do
        local d = 0.05
        for _, c in ipairs(corners) do
            local rel = c - aim
            local depth = dot(rel, view)
            d = math.max(d,
                math.abs(dot(rel, right)) / (tanH * fill) - depth,
                math.abs(dot(rel, up)) / (tanV * fill) - depth)
        end
        distance = d

        local minX, maxX, minY, maxY = 1e9, -1e9, 1e9, -1e9
        for _, c in ipairs(corners) do
            local rel = c - aim
            local depth = math.max(0.1, distance + dot(rel, view))
            local px = dot(rel, right) / (depth * tanH)
            local py = dot(rel, up) / (depth * tanV)
            minX, maxX = math.min(minX, px), math.max(maxX, px)
            minY, maxY = math.min(minY, py), math.max(maxY, py)
        end
        lastBox = { x = 0.5 + minX * 0.5, y = 0.5 - maxY * 0.5, w = (maxX - minX) * 0.5, h = (maxY - minY) * 0.5 }

        local cx, cy = (minX + maxX) * 0.5, (minY + maxY) * 0.5
        if math.abs(cx) < 0.002 and math.abs(cy) < 0.002 then break end
        aim = aim + right * (cx * tanH * distance) + up * (cy * tanV * distance)
    end
end

-- Keeps the camera at least minCameraDistance away by narrowing the lens:
-- same framing, nothing clipped in front of the lens
local function keepDistance()
    local minDist = Float(Config.studio.minCameraDistance)
    if distance >= minDist then return false end
    local tanV = math.tan(math.rad(fov) * 0.5) * distance / minDist
    fov = math.max(0.5, math.deg(math.atan(tanV)) * 2.0)
    distance = minDist
    return true
end

-- Distance so every corner sits inside the fill share, aim slid so the
-- projected box is centred. Pure maths, no frames needed.
local function solve(corners, center)
    basis()
    fov = Float(shot.fov)
    aim = center
    solvePass(corners)
    -- a small subject put the camera too close: narrower lens, frame again
    if keepDistance() then
        aim = center
        solvePass(corners)
    end
end

local function activate()
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)
end

-- Camera and backdrop exist before the first subject, aimed at the spawn spot
function CameraInit(newShot)
    CameraStop()
    shot = newShot or Config.camera
    fov = Float(shot.fov)
    basis()
    local loc = Config.studio.location
    aim = vector3(loc.x, loc.y, loc.z + 5.0)
    distance = 40.0
    lastBox = nil
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    place()
    activate()
end

function CameraFrame(entity, newShot)
    if not cam then return end
    shot = newShot or Config.camera
    solve(boxCorners(entity))
    place()
    activate()
end

-- Frames a cube of `size` metres around a world point (a bone), for small items
function CameraFrameAround(center, size, newShot)
    if not cam then return end
    shot = newShot or Config.camera
    solve(cubeCorners(center, Float(size)))
    place()
    activate()
end

function CameraStop()
    if not cam then return end
    RenderScriptCams(false, false, 0, true, true)
    DestroyCam(cam, true)
    cam = nil
    view = nil
    lastBox = nil
end

-- True when the engine draws through our cam and not some other view
function CameraIsRendering()
    if not cam then return false end
    return DoesCamExist(cam) and IsCamRendering(cam) and math.abs(GetFinalRenderedCamFov() - fov) < 0.5
end

-- Every frame: other scripts destroy or stop scripted cams now and then
function CameraKeepAlive()
    if not cam or not view then return end
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        place()
        activate()
        DebugPrint('camera was destroyed, recreated')
    elseif not IsCamRendering(cam) then
        activate()
    end
end

-- Moves the camera so a measured silhouette box lands centred with its longer
-- side spanning the fill share, and predicts where it ends up
function CameraNudge(box)
    if not cam or not view then return end
    local tanH, tanV = lens()
    local cx = box.x + box.w * 0.5 - 0.5
    local cy = box.y + box.h * 0.5 - 0.5
    aim = aim + right * (cx * 2.0 * tanH * distance) - up * (cy * 2.0 * tanV * distance)
    local scale = math.max(box.w, box.h) / Float(shot.fill)
    distance = distance * scale
    keepDistance()
    place()
    local w, h = box.w / scale, box.h / scale
    lastBox = { x = 0.5 - w * 0.5, y = 0.5 - h * 0.5, w = w, h = h }
end

-- Pulls back when the silhouette runs off screen (rotors, wings)
function CameraBackOff(factor)
    if not cam or not view then return end
    distance = distance * factor
    place()
end

function CameraFill()
    return Float(shot.fill)
end

function CameraSetBox(box)
    lastBox = box
end

-- Flat backdrop behind the aim point, square to the camera, covering the frame
function CameraBackdrop()
    if not view then return nil end
    local back = Float(Config.studio.backdropDistance)
    local tanH, tanV = lens()
    local s = (distance + back) * math.max(tanH, tanV) * 1.5
    local q = aim + view * back
    local rs, us = right * s, up * s
    return q - rs - us, q + rs - us, q + rs + us, q - rs + us
end

-- Screen share the page should read for the shot
function CameraRegion()
    local box = lastBox
    if not box then return { x = 0.0, y = 0.0, w = 1.0, h = 1.0 } end
    local m = Float(Config.capture.regionMargin)
    local x = math.max(0.0, box.x - m)
    local y = math.max(0.0, box.y - m)
    return { x = x, y = y, w = math.min(1.0, box.x + box.w + m) - x, h = math.min(1.0, box.y + box.h + m) - y }
end
