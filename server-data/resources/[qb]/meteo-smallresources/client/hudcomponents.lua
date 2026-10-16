local disableHudComponents = Config.Disable.hudComponents
local disableControls = Config.Disable.controls
local displayAmmo = Config.Disable.displayAmmo

-- Backward compatibility: registers exports under both meteo-smallresources and qb-smallresources
local function exportHandler(exportName, func)
    exports(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format('qb-smallresources', exportName), function(setCB)
        setCB(func)
    end)
end

local function decorSet(Type, Value)
    if Type == 'parked' then
        Config.Density.parked = Value
    elseif Type == 'vehicle' then
        Config.Density.vehicle = Value
    elseif Type == 'multiplier' then
        Config.Density.multiplier = Value
    elseif Type == 'peds' then
        Config.Density.peds = Value
    elseif Type == 'scenario' then
        Config.Density.scenario = Value
    end
end

exportHandler('DecorSet', decorSet)

local hudCount = #disableHudComponents
local controlCount = #disableControls

CreateThread(function()
    while true do
        for i = 1, hudCount do
            HideHudComponentThisFrame(disableHudComponents[i])
        end

        for i = 1, controlCount do
            DisableControlAction(2, disableControls[i], true)
        end

        if displayAmmo then
            DisplayAmmoThisFrame(true)
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        SetParkedVehicleDensityMultiplierThisFrame(Config.Density.parked)
        SetVehicleDensityMultiplierThisFrame(Config.Density.vehicle)
        SetRandomVehicleDensityMultiplierThisFrame(Config.Density.multiplier)
        SetPedDensityMultiplierThisFrame(Config.Density.peds)
        SetScenarioPedDensityMultiplierThisFrame(Config.Density.scenario, Config.Density.scenario)
        Wait(100)
    end
end)

exportHandler('addDisableHudComponents', function(hudComponents)
    local hudComponentsType = type(hudComponents)
    if hudComponentsType == 'number' then
        hudCount = hudCount + 1
        disableHudComponents[hudCount] = hudComponents
    elseif hudComponentsType == 'table' and table.type(hudComponents) == "array" then
        for i = 1, #hudComponents do
            hudCount = hudCount + 1
            disableHudComponents[hudCount] = hudComponents[i]
        end
    end
end)

exportHandler('removeDisableHudComponents', function(hudComponents)
    local hudComponentsType = type(hudComponents)
    if hudComponentsType == 'number' then
        for i = 1, #disableHudComponents do
            if disableHudComponents[i] == hudComponents then
                table.remove(disableHudComponents, i)
                hudCount = hudCount - 1
                break
            end
        end
    elseif hudComponentsType == 'table' and table.type(hudComponents) == "array" then
        for i = #disableHudComponents, 1, -1 do
            for i2 = 1, #hudComponents do
                if disableHudComponents[i] == hudComponents[i2] then
                    table.remove(disableHudComponents, i)
                    hudCount = hudCount - 1
                    break
                end
            end
        end
    end
end)

exportHandler('getDisableHudComponents', function() return disableHudComponents end)

exportHandler('addDisableControls', function(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        controlCount = controlCount + 1
        disableControls[controlCount] = controls
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = 1, #controls do
            controlCount = controlCount + 1
            disableControls[controlCount] = controls[i]
        end
    end
end)

exportHandler('removeDisableControls', function(controls)
    local controlsType = type(controls)
    if controlsType == 'number' then
        for i = 1, #disableControls do
            if disableControls[i] == controls then
                table.remove(disableControls, i)
                controlCount = controlCount - 1
                break
            end
        end
    elseif controlsType == 'table' and table.type(controls) == "array" then
        for i = #disableControls, 1, -1 do
            for i2 = 1, #controls do
                if disableControls[i] == controls[i2] then
                    table.remove(disableControls, i)
                    controlCount = controlCount - 1
                    break
                end
            end
        end
    end
end)

exportHandler('getDisableControls', function() return disableControls end)

exportHandler('setDisplayAmmo', function(bool) displayAmmo = bool end)

exportHandler('getDisplayAmmo', function() return displayAmmo end)