lib.locale()

local uiReady = false
local localeSent = false
---@class StudioSession
---@field kind string
---@field entity? integer
---@field subject? string
---@field wanted? string
---@field loading? boolean
---@field run? { stop: boolean }
---@field safe? boolean

---@type StudioSession?
local session = nil
local pending = {}
local inFlight = 0          -- shots the page has not finished keying yet
local retryList = {}

-- English is in the bundle, so only translated players need the push
local function pushLocale()
    if localeSent or not uiReady or lib.getLocaleKey() == 'en' then return end
    SendNUIMessage({ action = 'locale', data = lib.getLocales() })
    localeSent = true
end

RegisterNUICallback('uiReady', function(_, cb)
    uiReady = true
    pushLocale()
    cb({})
end)

AddEventHandler('ox_lib:setLocale', function()
    localeSent = false
    pushLocale()
end)

-- Request/reply to sv_files.js; uploads go latent so big images never kick
local function serverCall(name, data, latent)
    local id = NextId()
    pending[id] = { done = false }
    local event = 'meteo-imagestudio:server:request'
    if latent then
        TriggerLatentServerEvent(event, Config.capture.uploadRate, id, name, data or {})
    else
        TriggerServerEvent(event, id, name, data or {})
    end
    local p = pending[id]
    WaitFor(function() return p.done or nil end, latent and 60000 or 10000)
    pending[id] = nil
    return p.result
end

RegisterNetEvent('meteo-imagestudio:client:reply', function(id, result)
    local p = pending[id]
    if p then
        p.result = result
        p.done = true
    end
end)

local function busy(on)
    SendNUIMessage({ action = 'busy', on = on })
end

local function markEmpty(id)
    local kind = Kinds[(session --[[@as StudioSession]]).kind]
    CreateThread(function()
        serverCall('empty', { kind = kind.folder, id = id })
    end)
    SendNUIMessage({ action = 'empty', item = id })
end

-- Puts the subject in front of the camera and frames it from its real outline,
-- or with `quick` in the kind's fixed box (the page then spots empties itself).
-- Returns true, false (could not load) or 'empty' (keys to nothing, skipped).
local function loadSubject(id, quick)
    local s = session --[[@as StudioSession]]
    local kind = Kinds[s.kind]
    busy(true)
    local entity = kind.apply(id)
    if not entity then
        busy(false)
        SendNUIMessage({ action = 'subject', id = id, ok = false })
        return false
    end
    s.entity, s.subject = entity, id
    StudioSetSubject(entity)
    CaptureIsolate(kind.isolate and function(on) kind.isolate(entity, id, on) end or nil)
    if quick and kind.quickFrame then
        local center, size = kind.quickFrame(entity, id)
        if center then
            CameraFrameAround(center, size, kind.shot(id))
            busy(false)
            SendNUIMessage({ action = 'subject', id = id, ok = true })
            return true
        end
    end
    local function frame()
        local center, size
        if kind.focus then center, size = kind.focus(entity, id) end
        if center then CameraFrameAround(center, size, kind.shot(id)) else CameraFrame(entity, kind.shot(id)) end
    end
    frame()
    local fit = FitOutline(kind.fitPasses or 1)
    if fit == 'empty' and kind.skipEmpty then
        -- a slow texture stream looks empty too; one more look before giving up
        Wait(300)
        frame()
        fit = FitOutline(kind.fitPasses or 1)
    end
    busy(false)
    if fit == 'empty' and kind.skipEmpty then
        markEmpty(id)
        SendNUIMessage({ action = 'subject', id = id, ok = true, empty = true })
        return 'empty'
    end
    SendNUIMessage({ action = 'subject', id = id, ok = true })
    return true
end

-- One load at a time; the newest click wins when they come fast
local function requestLoad(id)
    local s = session --[[@as StudioSession]]
    s.wanted = id
    if s.loading then return end
    s.loading = true
    CreateThread(function()
        while session == s and s.wanted and s.wanted ~= s.subject and not s.run do
            local want = s.wanted
            if not loadSubject(want) then s.wanted = nil end
        end
        s.wanted = nil
        s.loading = false
    end)
end

local function speedFor(name)
    return Config.capture.speeds[name] or Config.capture.speeds[Config.capture.defaultSpeed]
end

-- Loads, frames and shoots one subject, then hands the frames to the page.
-- Returns true, false or 'empty'.
local function shootOne(id, attempt, maxAttempts, speed, careful)
    local s = session --[[@as StudioSession]]
    local kind = Kinds[s.kind]
    -- first shots use the kind's fixed box; a re-shoot gets the full outline fit
    local loaded = loadSubject(id, not careful)
    if loaded ~= true then return loaded end
    Wait(careful and Config.capture.speeds.quality.settle * 2 or (kind.settle or speed.settle))
    local grabs, region, base = Shoot(careful and Config.capture.speeds.quality or speed)
    if not grabs then return false end
    DebugPrint(('%s shot, isolated: %s'):format(id, tostring(base ~= nil)))
    inFlight = inFlight + 1
    SendNUIMessage({
        action = 'job',
        id = NextId(),
        item = id,
        grabs = grabs,
        base = base,
        region = region,
        glass = kind.glass and kind.glass(s.entity) or {},
        attempt = attempt,
        final = attempt >= maxAttempts,
    })
    return true
end

local function runCapture(ids, speedName)
    local s = session --[[@as StudioSession]]
    local speed = speedFor(speedName)
    local kind = Kinds[s.kind]
    local maxAttempts = 1 + (Config.capture.retries or 0)
    s.run = { stop = false }
    inFlight = 0
    retryList = {}

    SendNUIMessage({ action = 'run', running = true, total = #ids })
    for i, id in ipairs(ids) do
        if s.run.stop or session ~= s then break end
        SendNUIMessage({ action = 'progress', current = i, total = #ids, item = id })
        -- the page keys on its main thread; let it catch up
        WaitFor(function() return inFlight < 2 or nil end, 30000)
        for ahead = 1, Config.capture.preload do
            if ids[i + ahead] then kind.preload(ids[i + ahead]) end
        end
        local started = GetGameTimer()
        local result = shootOne(id, 1, maxAttempts, speed, false)
        if result == true then
            DebugPrint(('%s shot in %d ms'):format(id, GetGameTimer() - started))
        elseif result == false then
            SendNUIMessage({ action = 'jobFailed', item = id })
        end
    end

    -- re-shoot the glitched ones once the page has judged every capture
    while not s.run.stop and session == s do
        WaitFor(function() return inFlight == 0 or nil end, 60000)
        if #retryList == 0 then break end
        local list = retryList
        retryList = {}
        for n, job in ipairs(list) do
            if s.run.stop or session ~= s then break end
            SendNUIMessage({ action = 'retrying', item = job.id, attempt = job.attempt, current = n, total = #list })
            WaitFor(function() return inFlight < 2 or nil end, 30000)
            if shootOne(job.id, job.attempt, maxAttempts, speed, true) == false then
                SendNUIMessage({ action = 'jobFailed', item = job.id })
            end
        end
    end

    WaitFor(function() return inFlight == 0 or nil end, 60000)
    s.run = nil
    SendNUIMessage({ action = 'run', running = false })
end

local function closeStudio()
    local s = session --[[@as StudioSession]]
    if not s then return end
    session = nil
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    CameraStop()
    Kinds[s.kind].release()
    CaptureIsolate(nil)
    StudioExit()
end

-- Sends a kind's list and what is on disk for it, then loads its first item
local function showKind(s, first)
    local kind = Kinds[s.kind]
    busy(true)
    local items = kind.list()
    local listed = serverCall('list', { kind = kind.folder }) or {}
    SendNUIMessage({
        action = 'kind',
        kind = s.kind,
        folder = kind.folder,
        items = items,
        images = listed.items or {},
    })
    busy(false)
    local start = first or (items[1] and items[1].id)
    if start then requestLoad(start) end
end

local function openStudio(first, safe)
    if session then
        TriggerEvent('QBCore:Notify', locale('already_open'), 'error')
        return
    end
    local s = { kind = 'vehicles', safe = safe } --[[@as StudioSession]]
    session = s

    CreateThread(function()
        WaitFor(function() return uiReady or nil end, 5000)
        StudioEnter()
        CameraInit()
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            safeMode = safe,
            output = Config.output,
            capture = {
                edgeCut = Config.capture.edgeCut,
                speeds = { 'quality', 'balanced', 'fast' },
                defaultSpeed = Config.capture.defaultSpeed,
            },
        })
        showKind(s, first)
    end)
end

-- NUI callbacks -----------------------------------------------------------------

RegisterNUICallback('close', function(_, cb)
    if session and session.run then session.run.stop = true end
    closeStudio()
    cb({})
end)

RegisterNUICallback('kind', function(data, cb)
    local s = session --[[@as StudioSession]]
    if not s or s.run or s.loading or not Kinds[data.kind] or data.kind == s.kind then return cb({ ok = false }) end
    Kinds[s.kind].release()
    s.kind, s.entity, s.subject = data.kind, nil, nil
    StudioSetSubject(nil)
    CreateThread(function() showKind(s, nil) end)
    cb({ ok = true })
end)

RegisterNUICallback('select', function(data, cb)
    local s = session --[[@as StudioSession]]
    if not s or s.run or type(data.id) ~= 'string' then return cb({ ok = false }) end
    requestLoad(data.id)
    cb({ ok = true })
end)

RegisterNUICallback('run', function(data, cb)
    local s = session --[[@as StudioSession]]
    if not s or s.safe or s.run or s.loading or type(data.ids) ~= 'table' or #data.ids == 0 then return cb({ ok = false }) end
    local ids = {}
    for _, id in ipairs(data.ids) do
        if type(id) == 'string' then ids[#ids + 1] = id end
    end
    CreateThread(function() runCapture(ids, data.speed) end)
    cb({ ok = true })
end)

RegisterNUICallback('cancel', function(_, cb)
    if session and session.run then session.run.stop = true end
    cb({})
end)

RegisterNUICallback('jobDone', function(data, cb)
    inFlight = math.max(0, inFlight - 1)
    if data.empty and type(data.item) == 'string' and session then
        markEmpty(data.item)
    elseif data.retry and type(data.item) == 'string' then
        retryList[#retryList + 1] = { id = data.item, attempt = (tonumber(data.attempt) or 1) + 1 }
    end
    cb({})
end)

RegisterNUICallback('save', function(data, cb)
    local s = session --[[@as StudioSession]]
    if not s then return cb({ ok = false }) end
    CreateThread(function()
        local reply = serverCall('save', {
            kind = Kinds[s.kind].folder,
            id = data.item,
            image = data.image,
            issues = data.issues,
        }, true) or { ok = false }
        cb(reply)
    end)
end)

-- Opening -------------------------------------------------------------------------

RegisterNetEvent('meteo-imagestudio:client:open', function(first, safe)
    openStudio(type(first) == 'string' and first:lower() or nil, safe == true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeStudio()
end)

-- CreateThread(function()
--     TriggerEvent('chat:addSuggestion', '/' .. Config.command, locale('command_help'), {
--         { name = 'model', help = locale('command_arg_model') },
--     })
-- end)
