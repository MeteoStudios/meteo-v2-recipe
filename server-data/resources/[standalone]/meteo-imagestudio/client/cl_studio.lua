local studioActive = false
local savedPlayer = nil
local subject = nil
local shotColor = nil       -- backdrop colour forced during a capture

-- both windings so the quad shows from either side
local function drawQuad(a, b, c, d, col)
    DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, col.r, col.g, col.b, 255)
    DrawPoly(c.x, c.y, c.z, d.x, d.y, d.z, a.x, a.y, a.z, col.r, col.g, col.b, 255)
    DrawPoly(c.x, c.y, c.z, b.x, b.y, b.z, a.x, a.y, a.z, col.r, col.g, col.b, 255)
    DrawPoly(a.x, a.y, a.z, d.x, d.y, d.z, c.x, c.y, c.z, col.r, col.g, col.b, 255)
end

local function applyTime()
    local h = Config.studio.hour
    NetworkOverrideClockTime(math.floor(h) % 24, math.floor((h % 1) * 60), 0)
    NetworkOverrideClockMillisecondsPerGameMinute(999999999)
end

local function applyWeather()
    local w = Config.studio.weather
    SetRainLevel(0.0)
    SetWeatherTypePersist(w)
    SetWeatherTypeNow(w)
    SetWeatherTypeNowPersist(w)
    -- plants sway in the wind and would move between the dark and light shots
    SetWind(0.0)
    SetWindSpeed(0.0)
end

local function studioLoop()
    local tick = 0
    local strength = Float(Config.studio.lightStrength)
    while studioActive do
        Wait(0)
        CameraKeepAlive()
        local col = shotColor or Config.studio.backdrop
        local a, b, c, d = CameraBackdrop()
        if a then drawQuad(a, b, c, d, col) end
        if subject and DoesEntityExist(subject) and GetEntityType(subject) == 1 then
            -- peds stream their HD textures only when the game thinks you stand close
            OverrideLodscaleThisFrame(1.0)
        end
        if subject and DoesEntityExist(subject) then
            local pos = GetEntityCoords(subject)
            for _, light in ipairs(Config.studio.lights) do
                local p = pos + light.offset
                DrawLightWithRange(p.x, p.y, p.z, 255, 255, 255, Float(light.range), Float(light.intensity) * strength)
            end
        end
        -- weather sync scripts push server time and weather every game minute
        applyTime()
        tick = tick + 1
        if tick % 60 == 0 then applyWeather() end
    end
end

-- World heading of the whole setup; subject faces it, the camera orbit follows
function StudioHeading()
    return Float(Config.studio.sunAngle)
end

-- nil restores the working backdrop colour
function StudioShotColor(color)
    shotColor = color
end

function StudioSetSubject(entity)
    subject = entity
end


function StudioEnter()
    if studioActive then return end
    studioActive = true

    local ped = PlayerPedId()
    savedPlayer = { coords = GetEntityCoords(ped), heading = GetEntityHeading(ped) }

    local loc = Config.studio.location
    -- parked well away from where subjects spawn; a campfire set the player alight
    SetEntityCoords(ped, loc.x, loc.y, loc.z - 25.0, false, false, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)
    SetEntityInvincible(ped, true)
    SetEntityProofs(ped, true, true, true, true, true, true, true, true)
    SetFocusPosAndVel(loc.x, loc.y, loc.z, 0.0, 0.0, 0.0)
    DisableIdleCamera(true)
    DisplayHud(false)
    applyWeather()
    applyTime()

    CreateThread(studioLoop)
end

function StudioExit()
    if not studioActive then return end
    studioActive = false

    local ped = PlayerPedId()
    if savedPlayer then
        SetEntityCoords(ped, savedPlayer.coords.x, savedPlayer.coords.y, savedPlayer.coords.z, false, false, false, false)
        SetEntityHeading(ped, savedPlayer.heading)
    end
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, true)
    SetEntityInvincible(ped, false)
    SetEntityProofs(ped, false, false, false, false, false, false, false, false)
    ClearFocus()
    DisableIdleCamera(false)
    DisplayHud(true)

    ClearWeatherTypePersist()
    NetworkOverrideClockMillisecondsPerGameMinute(2000)
    -- hand the clock and sky back to the weather sync right away
    pcall(function()
        local t = GlobalState.currentTime
        if type(t) == 'table' and t.hour then NetworkOverrideClockTime(t.hour, t.minute or 0, 0) end
        local w = GlobalState.weather
        local name = type(w) == 'table' and w.weather or w
        if type(name) == 'string' then
            SetWeatherTypePersist(name)
            SetWeatherTypeNowPersist(name)
        end
    end)

    ClearHdArea()
    -- negative hands the wind back to the weather
    SetWind(-1.0)
    SetWindSpeed(-1.0)
    savedPlayer = nil
    subject = nil
    shotColor = nil
end
