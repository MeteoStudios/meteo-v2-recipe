QBCore = exports['qb-core']:GetCoreObject()
PlayerData = QBCore.Functions.GetPlayerData() -- Setting this for when you restart the resource in game
local inRadialMenu = false

local jobIndex = nil
local vehicleIndex = nil
local hazardsIndex = nil
local giveKeysIndex = nil
local flipIndex = nil

local DynamicMenuItems = {}
local FinalMenuItems = {}
local controlsToToggle = { 24, 0, 1, 2, 142, 257, 346 } -- if not using toggle

-- Functions

local function deepcopy(orig) -- modified the deep copy function from http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if not orig.canOpen or orig.canOpen() then
            local toRemove = {}
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                if type(orig_value) == 'table' then
                    if not orig_value.canOpen or orig_value.canOpen() then
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    else
                        toRemove[orig_key] = true
                    end
                else
                    copy[deepcopy(orig_key)] = deepcopy(orig_value)
                end
            end
            for i = 1, #toRemove do table.remove(copy, i) --[[ Using this to make sure all indexes get re-indexed and no empty spaces are in the radialmenu ]] end
            if copy and next(copy) then setmetatable(copy, deepcopy(getmetatable(orig))) end
        end
    elseif orig_type ~= 'function' then
        copy = orig
    end
    return copy
end

local function getNearestVeh()
    local pos = GetEntityCoords(PlayerPedId())
    local entityWorld = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 20.0, 0.0)
    -- Flag 2 = vehicles only (not peds, objects, or players)
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 2, PlayerPedId(), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)
    
    -- Double-check it's actually a vehicle
    if vehicleHandle and vehicleHandle ~= 0 and DoesEntityExist(vehicleHandle) and IsEntityAVehicle(vehicleHandle) then
        return vehicleHandle
    end
    
    return 0
end

local function getSeatTitle(seatIndex)
    local titles = {
        [-1] = locale('driver_seat'),
        [0] = locale('passenger_seat'),
        [1] = locale('rear_left_seat'),
        [2] = locale('rear_right_seat'),
    }
    return titles[seatIndex] or locale('other_seats')
end

-- validations
local function IsPlayerAvailable()
    local ped = PlayerPedId()
    if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then return false end

    local metadata = PlayerData and PlayerData.metadata
    if metadata and (metadata.isdead or metadata.ishandcuffed or metadata.inlaststand) then
        return false
    end
    return true
end

-- for /seat command
local function switchToSeat(veh, seatIndex, seatTitle)
    if not IsPlayerAvailable() then
        QBCore.Functions.Notify(locale('player_unavailable'), 'error')
        return
    end
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        QBCore.Functions.Notify(locale('not_in_vehicle'), 'error')
        return
    end
    if exports['qb-smallresources']:HasHarness() then
        QBCore.Functions.Notify(locale('race_harness_on'), 'error')
        return
    end
    if not IsVehicleSeatFree(veh, seatIndex) then
        QBCore.Functions.Notify(locale('seat_occupied'), 'error')
        return
    end
    local kmh = GetEntitySpeed(veh) * 3.6
    if kmh > 100.0 then
        QBCore.Functions.Notify(locale('vehicle_driving_fast'), 'error')
        return
    end
    SetPedIntoVehicle(PlayerPedId(), veh, seatIndex)
    QBCore.Functions.Notify(locale('switched_seats', seatTitle))
end

local nextMenuID = 0

local function AddOption(data, id)
    local menuID = id
    if menuID == nil then
        nextMenuID = nextMenuID + 1
        menuID = nextMenuID
    end
    DynamicMenuItems[menuID] = deepcopy(data)
    DynamicMenuItems[menuID].res = GetInvokingResource()
    return menuID
end

local function RemoveOption(id)
    DynamicMenuItems[id] = nil
end

local function SetupJobMenu()
    local JobInteractionCheck = PlayerData.job.name
    if PlayerData.job.type == 'leo' then JobInteractionCheck = 'police' end
    local JobMenu = {
        id = 'jobinteractions',
        title = 'Work',
        icon = 'work',
        items = {}
    }
    if Config.JobInteractions[JobInteractionCheck] and next(Config.JobInteractions[JobInteractionCheck]) and PlayerData.job.onduty then
        -- dense list, no NUI holes
        for _, item in ipairs(Config.JobInteractions[JobInteractionCheck]) do
            if not item.canOpen or item.canOpen() then
                JobMenu.items[#JobMenu.items + 1] = item
            end
        end
    end

    if #JobMenu.items == 0 then
        if jobIndex then
            RemoveOption(jobIndex)
            jobIndex = nil
        end
    else
        jobIndex = AddOption(JobMenu, jobIndex)
    end
end

-- adds, refreshes or clears one dynamic slot, depending on whether it applies right now
local function syncOption(id, data)
    if not data then
        if id then RemoveOption(id) end
        return nil
    end
    return AddOption(data, id)
end

-- qbx_vehiclekeys is the renamed meteo-vehiclekeys here, and a renamed resource
-- keeps its old exports but not its old GetResourceState name
local function hasVehicleKeys(vehicle)
    local names = { 'meteo-vehiclekeys', 'qbx_vehiclekeys', 'qb-vehiclekeys' }
    for i = 1, #names do
        if GetResourceState(names[i]) == 'started' then
            -- a broken export here would take the whole radial down with it
            local ok, result = pcall(function() return exports[names[i]]:HasKeys(vehicle) end)
            return ok and result == true
        end
    end
    return false
end

-- Doors, windows, seats and the engine all live in meteo-vehiclecontrols now.
-- What is left here is the handful of things that panel does not cover.
local function SetupVehicleMenu()
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local vehicle = GetVehiclePedIsIn(ped)
    if vehicle == 0 then vehicle = getNearestVeh() end

    local controls, hazards, giveKeys, flip

    if vehicle ~= 0 then
        if inVehicle then
            controls = {
                id = 'vehicle-controls',
                title = 'Vehicle',
                icon = 'directions_car',
                type = 'client',
                event = 'meteo-vehiclecontrols:client:openMenu',
                shouldClose = true
            }

            hazards = {
                id = 'vehicle-hazards',
                title = 'Toggle Hazard Lights',
                icon = 'emergency',
                type = 'client',
                event = 'qb-radialmenu:client:toggleHazards',
                shouldClose = false
            }

            if hasVehicleKeys(vehicle) then
                giveKeys = {
                    id = 'vehicle-givekeys',
                    title = 'Give Keys',
                    icon = 'key',
                    type = 'command',
                    event = 'givekeys',
                    shouldClose = true
                }
            end
        elseif not IsVehicleOnAllWheels(vehicle) then
            flip = {
                id = 'vehicle-flip',
                title = 'Flip Vehicle',
                icon = 'build',
                type = 'client',
                event = 'qb-radialmenu:flipVehicle',
                shouldClose = true
            }
        end
    end

    vehicleIndex = syncOption(vehicleIndex, controls)
    hazardsIndex = syncOption(hazardsIndex, hazards)
    giveKeysIndex = syncOption(giveKeysIndex, giveKeys)
    flipIndex = syncOption(flipIndex, flip)
end

local function SetupSubItems()
    SetupJobMenu()
    SetupVehicleMenu()
end

local function selectOption(t, t2)
    for _, v in pairs(t) do
        if v.items then
            local found, hasAction, val = selectOption(v.items, t2)
            if found then return true, hasAction, val end
        else
            if v.id == t2.id and ((v.event and v.event == t2.event) or v.action) and (not v.canOpen or v.canOpen()) then
                return true, v.action, v
            end
        end
    end
    return false
end

local function IsPoliceOrEMS()
    return (PlayerData.job.name == 'police' or PlayerData.job.type == 'leo' or PlayerData.job.name == 'ambulance')
end

local function IsDowned()
    if not PlayerData.metadata then return false end
    return (PlayerData.metadata['isdead'] or PlayerData.metadata['inlaststand'])
end

local function SetupRadialMenu()
    FinalMenuItems = {}
    if (IsDowned() and IsPoliceOrEMS()) then
        FinalMenuItems = {
            [1] = {
                id = 'emergencybutton2',
                title = locale('emergency_button'),
                icon = 'emergency',
                type = 'command',
                event = '10-99',
                shouldClose = true,
            },
        }
    else
        SetupSubItems()
        FinalMenuItems = deepcopy(Config.MenuItems)

        -- Sort dynamic menu items by index to maintain consistent order
        local sortedKeys = {}
        for k in pairs(DynamicMenuItems) do
            table.insert(sortedKeys, k)
        end
        table.sort(sortedKeys)

        -- Add dynamic items in sorted order
        for _, k in ipairs(sortedKeys) do
            FinalMenuItems[#FinalMenuItems + 1] = DynamicMenuItems[k]
        end
    end
end

local function controlToggle(bool)
    for i = 1, #controlsToToggle, 1 do
        if bool then
            exports['qb-smallresources']:addDisableControls(controlsToToggle[i])
        else
            exports['qb-smallresources']:removeDisableControls(controlsToToggle[i])
        end
    end
end


local function setRadialState(bool, sendMessage, delay)
    -- Menuitems have to be added only once
    if Config.UseWhilstWalking then
        if bool then
            TriggerEvent('qb-radialmenu:client:onRadialmenuOpen')
            SetupRadialMenu()
            PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', 1)
            controlToggle(true)
        else
            TriggerEvent('qb-radialmenu:client:onRadialmenuClose')
            controlToggle(false)
        end
        SetNuiFocus(bool, bool)
        SetNuiFocusKeepInput(bool, true)
    else
        if bool then
            TriggerEvent('qb-radialmenu:client:onRadialmenuOpen')
            SetupRadialMenu()
            -- TriggerScreenblurFadeIn(1000)
        else
            TriggerEvent('qb-radialmenu:client:onRadialmenuClose')
            -- TriggerScreenblurFadeOut(1000)
        end
        SetNuiFocus(bool, bool)
    end

    if sendMessage then
        SendNUIMessage({
            action = 'ui',
            radial = bool,
            items = FinalMenuItems,
            toggle = Config.Toggle,
            keybind = Config.Keybind
        })
    end
    if delay then Wait(500) end
    inRadialMenu = bool
end

-- Command

RegisterCommand('radialmenu', function()
    if not PlayerData.metadata then return end
    if ((IsDowned() and IsPoliceOrEMS()) or not IsDowned()) and not PlayerData.metadata['ishandcuffed'] and not IsPauseMenuActive() and not inRadialMenu then
        setRadialState(true, true)
        SetCursorLocation(0.5, 0.5)
    end
end)

RegisterKeyMapping('radialmenu', locale('command_description'), 'keyboard', Config.Keybind)

-- 1=Driver, 2=Passenger, 3=Rear Left, 4=Rear Right
RegisterCommand('seat', function(_, args)
    local id = tonumber(args[1])
    if not id then
        QBCore.Functions.Notify(locale('invalid_seat'), 'error')
        return
    end
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh == 0 then
        QBCore.Functions.Notify(locale('not_in_vehicle'), 'error')
        return
    end
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(veh))
    if id < 1 or id > seats then
        QBCore.Functions.Notify(locale('invalid_seat'), 'error')
        return
    end
    local seatIndex = id - 2
    switchToSeat(veh, seatIndex, getSeatTitle(seatIndex))
end, false)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/seat', locale('seat_command_desc'), {
        { name = 'id', help = locale('seat_arg_help') },
    })
end)

-- 1=Front Left, 2=Front Right, 3=Rear Left, 4=Rear Right
RegisterCommand('window', function(_, args)
    if not IsPlayerAvailable() then
        QBCore.Functions.Notify(locale('player_unavailable'), 'error')
        return
    end
    local id = tonumber(args[1])
    if not id or id < 1 or id > 4 then
        QBCore.Functions.Notify(locale('invalid_window'), 'error')
        return
    end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped) ~= 0 and GetVehiclePedIsIn(ped) or getNearestVeh()
    if veh == 0 then
        QBCore.Functions.Notify(locale('no_vehicle_found'), 'error')
        return
    end
    local window = id - 1
    if IsVehicleWindowIntact(veh, window) then
        RollDownWindow(veh, window)
        QBCore.Functions.Notify(locale('window_rolled_down'), 'success', 2500)
    else
        RollUpWindow(veh, window)
        QBCore.Functions.Notify(locale('window_rolled_up'), 'success', 2500)
    end
end, false)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/window', locale('window_command_desc'), {
        { name = 'id', help = locale('window_arg_help') },
    })
end)

-- Events

-- Sets the metadata when the player spawns
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

-- Sets the playerdata to an empty table when the player has quit or did /logout
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

-- This will update all the PlayerData that doesn't get updated with a specific event other than this like the metadata
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('qb-radialmenu:client:noPlayers', function()
    QBCore.Functions.Notify(locale('no_people_nearby'), 'error', 2500)
end)

RegisterNetEvent('qb-radialmenu:client:toggleHazards', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if veh ~= 0 then
        if GetPedInVehicleSeat(veh, -1) == ped then
            -- Check current state
            local leftIndicator = GetVehicleIndicatorLights(veh) == 1 or GetVehicleIndicatorLights(veh) == 3
            local rightIndicator = GetVehicleIndicatorLights(veh) == 2 or GetVehicleIndicatorLights(veh) == 3

            if leftIndicator and rightIndicator then
                -- Turn off hazards
                SetVehicleIndicatorLights(veh, 0, false)
                SetVehicleIndicatorLights(veh, 1, false)
                QBCore.Functions.Notify(locale('hazards_off'), 'error', 2500)
            else
                -- Turn on hazards
                SetVehicleIndicatorLights(veh, 0, true)
                SetVehicleIndicatorLights(veh, 1, true)
                QBCore.Functions.Notify(locale('hazards_on'), 'success', 2500)
            end
        else
            QBCore.Functions.Notify(locale('not_driver'), 'error', 2500)
        end
    else
        QBCore.Functions.Notify(locale('no_vehicle_found'), 'error', 2500)
    end
end)

RegisterNetEvent('qb-radialmenu:flipVehicle', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    QBCore.Functions.Progressbar('pick_grape', locale('flipping_car'), Config.Fliptime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_ped',
        flags = 1,
    }, {}, {}, function() -- Done
        local vehicle = getNearestVeh()
        SetVehicleOnGroundProperly(vehicle)
        StopAnimTask(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 1.0)
    end, function() -- Cancel
        QBCore.Functions.Notify(locale('cancel_task'), 'error')
        StopAnimTask(PlayerPedId(), 'mini@repair', 'fixing_a_ped', 1.0)
    end)
end)

AddEventHandler('onClientResourceStop', function(resource)
    for k, v in pairs(DynamicMenuItems) do
        if v.res == resource then
            DynamicMenuItems[k] = nil
        end
    end
end)

-- NUI Callbacks

RegisterNUICallback('closeRadial', function(data, cb)
    setRadialState(false, false, data.delay)
    cb('ok')
end)

RegisterNUICallback('selectItem', function(inData, cb)
    local itemData = inData.itemData
    local found, action, data = selectOption(FinalMenuItems, itemData)
    if data and found then
        if action then
            action(data)
        elseif data.type == 'client' then
            TriggerEvent(data.event, data)
        elseif data.type == 'server' then
            TriggerServerEvent(data.event, data)
        elseif data.type == 'command' then
            ExecuteCommand(data.event)
        elseif data.type == 'qbcommand' then
            TriggerServerEvent('QBCore:CallCommand', data.event, data)
        end
    end
    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    PlaySoundFrontend(-1, 'Highlight_Cancel', 'DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    cb('ok')
end)

-- Backward compatibility: registers exports under both meteo-radialmenu and qb-radialmenu
local function exportHandler(exportName, func)
    exports(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format('qb-radialmenu', exportName), function(setCB)
        setCB(func)
    end)
end

exportHandler('AddOption', AddOption)
exportHandler('RemoveOption', RemoveOption)
