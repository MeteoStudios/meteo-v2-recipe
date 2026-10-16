local QBCore = exports['qb-core']:GetCoreObject()
local playerState = LocalPlayer.state

local statePlayer
local function setInvBusy(value)
    statePlayer = statePlayer or lib.player:new(cache.serverId)
    statePlayer:setr('invBusy', value)
end

local speedMultiplier = Config.Seatbelt.useKMH and 3.6 or 2.237
local speedThresholds = {
    unbuckled = Config.Seatbelt.minSpeedUnbuckled / speedMultiplier,  -- config is mph/kmh, GetEntitySpeed is m/s
    buckled = Config.Seatbelt.minSpeedBuckled / speedMultiplier,
    harness = Config.Seatbelt.minSpeedHarness / speedMultiplier
}

local seatbeltOn = false
local harnessOn = false
local harnessHp = Config.HarnessUses
local harnessData = {}
local seatbeltActive = false

local function syncHudSeatbelt()
    TriggerEvent("seatbelt:client:ToggleSeatbelt", seatbeltOn)
end

local function playBeltSound(buckled)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5.0, buckled and "seatbelt" or "seatbeltoff", 0.25)
end

local function ejectFromVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then return end

    local velocity = GetEntityVelocity(vehicle)
    local coords = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)

    SetEntityCoords(ped, coords.x + forwardVector.x, coords.y + forwardVector.y, coords.z - 0.2, true, true, true, false)
    Wait(1)

    SetEntityVelocity(ped, velocity.x, velocity.y, velocity.z)
    SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
end

local function toggleSeatbelt()
    if harnessOn then
        QBCore.Functions.Notify(locale('seatbelt.harness_on'), 'error')
        return
    end

    seatbeltOn = not seatbeltOn
    playerState.seatbelt = seatbeltOn
    syncHudSeatbelt()
    playBeltSound(seatbeltOn)
end

local function toggleHarness()
    harnessOn = not harnessOn
    playerState.harness = harnessOn

    if not harnessOn then
        playBeltSound(false)
        return
    end

    -- force-set instead of calling toggleSeatbelt(), which would flip it back off if already on
    if not seatbeltOn then
        seatbeltOn = true
        playerState.seatbelt = true
        syncHudSeatbelt()
    end
    playBeltSound(true)
end

local function seatbeltLoop()
    CreateThread(function()
        while seatbeltActive do
            local ped = PlayerPedId()

            if not IsPedInAnyVehicle(ped, false) then
                seatbeltActive = false
                seatbeltOn = false
                harnessOn = false
                playerState.seatbelt = false
                playerState.harness = false
                syncHudSeatbelt()
                break
            end

            if seatbeltOn or harnessOn then
                DisableControlAction(0, 75, true)  -- F (exit vehicle)
                DisableControlAction(27, 75, true)
                Wait(0)
            else
                Wait(100)
            end
        end
    end)

    CreateThread(function()
        local speedHistory = {}
        local velocityHistory = {}

        while seatbeltActive do
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            if vehicle ~= 0 then
                speedHistory[2] = speedHistory[1]
                speedHistory[1] = GetEntitySpeed(vehicle)

                velocityHistory[2] = velocityHistory[1]
                velocityHistory[1] = GetEntityVelocity(vehicle)

                local threshold = seatbeltOn and speedThresholds.buckled or speedThresholds.unbuckled

                if speedHistory[2] ~= nil and speedHistory[2] > threshold then
                    local speedVector = GetEntitySpeedVector(vehicle, true)

                    if speedVector.y > 0.8 and speedHistory[1] <= threshold then
                        local speedDifference = speedHistory[2] - speedHistory[1]
                        local halfSpeed = speedHistory[1] * 0.5

                        if speedDifference > halfSpeed then
                            if harnessOn then
                                if not Config.Seatbelt.harnessDisableEjection and speedHistory[2] > speedThresholds.harness then
                                    ejectFromVehicle()
                                else
                                    harnessHp = harnessHp - 1
                                    TriggerServerEvent('seatbelt:DoHarnessDamage', harnessHp, harnessData)
                                    TriggerEvent('hud:client:UpdateHarness', harnessHp)

                                    if harnessHp <= 0 then
                                        harnessOn = false
                                        seatbeltOn = false
                                        playerState.harness = false
                                        playerState.seatbelt = false
                                        syncHudSeatbelt()
                                        QBCore.Functions.Notify(locale('seatbelt.harness_broken'), 'error')
                                    end
                                end
                            elseif seatbeltOn then
                            else
                                ejectFromVehicle()
                            end

                            Wait(500)
                        end
                    end
                end

                Wait(100)
            else
                Wait(500)
            end
        end
    end)
end

function GetEntityForwardVector(entity)
    local heading = GetEntityHeading(entity) + 90.0
    if heading < 0.0 then heading = 360.0 + heading end
    local radians = heading * 0.0174533
    return vector3(math.cos(radians) * 2.0, math.sin(radians) * 2.0, 0.0)
end

local function exportHandler(exportName, func)
    exports(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format('qb-smallresources', exportName), function(setCB)
        setCB(func)
    end)
end

local function hasHarness()
    return harnessOn
end

exportHandler("HasHarness", hasHarness)

local function hasSeatbeltOn()
    return seatbeltOn
end

exportHandler("HasSeatbeltOn", hasSeatbeltOn)

RegisterNetEvent('QBCore:Client:EnteredVehicle', function()
    local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))

    if Config.Seatbelt.disabledVehicleClasses[class] then
        return
    end

    seatbeltOn = false
    harnessOn = false
    playerState.seatbelt = false
    playerState.harness = false
    seatbeltActive = true
    syncHudSeatbelt()

    seatbeltLoop()
end)

RegisterNetEvent('QBCore:Client:ExitVehicle', function()
    seatbeltActive = false
    seatbeltOn = false
    harnessOn = false
    playerState.seatbelt = false
    playerState.harness = false
    syncHudSeatbelt()
end)

RegisterNetEvent('seatbelt:client:UseHarness', function(ItemData)
    local ped = PlayerPedId()
    local inVeh = IsPedInAnyVehicle(ped, false)
    local class = GetVehicleClass(GetVehiclePedIsUsing(ped))

    if not inVeh or Config.Seatbelt.disabledVehicleClasses[class] then
        QBCore.Functions.Notify(locale('seatbelt.no_car'), 'error')
        return
    end

    if not harnessOn then
        setInvBusy(true)
        QBCore.Functions.Progressbar("harness_equip", locale('seatbelt.use_harness_progress'), 5000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            setInvBusy(false)
            harnessHp = ItemData.info.uses
            harnessData = ItemData
            toggleHarness()
            TriggerServerEvent('equip:harness', ItemData)
            TriggerEvent('hud:client:UpdateHarness', harnessHp)
        end)
    else
        setInvBusy(true)
        QBCore.Functions.Progressbar("harness_remove", locale('seatbelt.remove_harness_progress'), 5000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function()
            setInvBusy(false)
            toggleHarness()
        end)
    end
end)

RegisterCommand('toggleseatbelt', function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) or IsPauseMenuActive() then return end
    local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))
    if Config.Seatbelt.disabledVehicleClasses[class] then return end
    toggleSeatbelt()
end, false)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')