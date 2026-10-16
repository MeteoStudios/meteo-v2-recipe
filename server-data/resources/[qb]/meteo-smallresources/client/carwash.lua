local QBCore = exports['qb-core']:GetCoreObject()
local washingVeh = false
local showingKeybind = false

local function washVehicle()
    if washingVeh then return end

    local veh = cache.vehicle
    if not veh or veh == 0 then return end
    if GetPedInVehicleSeat(veh, -1) ~= cache.ped then return end

    local dirtLevel = GetVehicleDirtLevel(veh)
    if dirtLevel <= Config.CarWash.dirtLevel then
        QBCore.Functions.Notify(locale('wash.dirty'), 'error')
        return
    end

    washingVeh = true
    exports[Rename.prefix .. 'keybinddisplay']:hide()
    showingKeybind = false

    local success = lib.callback.await('qb-carwash:server:washCar', false)
    if not success then
        washingVeh = false
        return
    end

    QBCore.Functions.Progressbar('carwash_progress', locale('wash.in_progress'), math.random(4000, 8000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        SetVehicleDirtLevel(veh, 0.0)
        SetVehicleUndriveable(veh, false)
        WashDecalsFromVehicle(veh, 1.0)
        washingVeh = false
    end, function()
        QBCore.Functions.Notify(locale('wash.cancel'), 'error')
        washingVeh = false
    end)
end

CreateThread(function()
    for _, location in ipairs(Config.CarWash.locations) do
        local point = lib.points.new({
            coords = vec3(location.x, location.y, location.z),
            distance = Config.CarWash.pointDistance,
        })

        function point:onEnter()
            if not washingVeh and cache.vehicle and GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped then
                exports[Rename.prefix .. 'keybinddisplay']:show({
                    { keys = 'E', label = locale('wash.wash_vehicle_target') },
                })
                showingKeybind = true
            end
        end

        function point:onExit()
            if showingKeybind then
                exports[Rename.prefix .. 'keybinddisplay']:hide()
                showingKeybind = false
            end
        end

        function point:nearby()
            if washingVeh then return end

            local isDriver = cache.vehicle and GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped

            if isDriver then
                if not showingKeybind then
                    exports[Rename.prefix .. 'keybinddisplay']:show({
                        { keys = 'E', label = locale('wash.wash_vehicle_target') },
                    })
                    showingKeybind = true
                end

                if IsControlJustPressed(0, 38) then
                    washVehicle()
                end
            elseif showingKeybind then
                exports[Rename.prefix .. 'keybinddisplay']:hide()
                showingKeybind = false
            end
        end
    end
end)

-- Blips
CreateThread(function()
    for _, location in ipairs(Config.CarWash.locations) do
        local carWash = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(carWash, 100)
        SetBlipDisplay(carWash, 4)
        SetBlipScale(carWash, 0.75)
        SetBlipAsShortRange(carWash, true)
        SetBlipColour(carWash, 37)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Hands Free Carwash')
        EndTextCommandSetBlipName(carWash)
    end
end)
