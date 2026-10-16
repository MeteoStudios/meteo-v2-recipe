if not lib then print('^1ox_lib must be started before this resource.^0') return end
lib.locale()

local QBCore = exports['qb-core']:GetCoreObject()

local useables = {
    cleaningkit = 'wash',
    tirerepairkit = 'tirerepairkit',
    repairkit = 'smallkit',
    advancedrepairkit = 'bigkit',
}

local pendingUse = {}

for item, action in pairs(useables) do
    QBCore.Functions.CreateUseableItem(item, function(source, used)
        pendingUse[source] = { item = item, slot = used and used.slot }
        TriggerClientEvent('vehiclehandler:client:useitem', source, item, pendingUse[source].slot, action)
    end)
end

lib.callback.register('vehiclehandler:consume', function(source)
    local pending = pendingUse[source]
    pendingUse[source] = nil
    if not pending then return false end
    return exports.ox_inventory:RemoveItem(source, pending.item, 1, nil, pending.slot)
end)

AddEventHandler('playerDropped', function()
    pendingUse[source] = nil
end)

lib.callback.register('vehiclehandler:sync', function()
    return true
end)

lib.addCommand('fix', {
    help = locale('commands.fix.help'),
    restricted = 'group.admin'
}, function(source)
    lib.callback('vehiclehandler:adminfix', source, function() end)
end)

lib.addCommand('wash', {
    help = locale('commands.wash.help'),
    restricted = 'group.admin'
}, function(source)
    lib.callback('vehiclehandler:adminwash', source, function() end)
end)

lib.addCommand('setfuel', {
    help = locale('commands.setfuel.help'),
    params = {
        {
            name = locale('commands.setfuel.params.name'),
            type = locale('commands.setfuel.params.type'),
            help = locale('commands.setfuel.params.help'),
        },
    },
    restricted = 'group.admin'
}, function(source, args)
    local level = args.level

    if level then
        lib.callback('vehiclehandler:adminfuel', source, function() end, level)
    end
end)