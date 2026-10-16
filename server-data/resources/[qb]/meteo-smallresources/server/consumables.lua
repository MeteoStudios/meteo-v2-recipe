local QBCore = exports['qb-core']:GetCoreObject()

-- Backward compatibility: registers exports under both meteo-smallresources and qb-smallresources
local function exportHandler(exportName, func)
    exports(exportName, func)
    AddEventHandler(('__cfx_export_%s_%s'):format('qb-smallresources', exportName), function(setCB)
        setCB(func)
    end)
end

----------- / alcohol

for k, _ in pairs(Config.Consumables.alcohol) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        TriggerClientEvent('consumables:client:DrinkAlcohol', source, item.name)
        LogConsumable(source, item.name, 'alcohol')
    end)
end

----------- / Eat

for k, _ in pairs(Config.Consumables.eat) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end
        TriggerClientEvent('consumables:client:Eat', source, item.name)
        LogConsumable(source, item.name, 'eat')
    end)
end

----------- / Drink
for k, _ in pairs(Config.Consumables.drink) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end
        TriggerClientEvent('consumables:client:Drink', source, item.name)
        LogConsumable(source, item.name, 'drink')
    end)
end

----------- / Custom
for k, _ in pairs(Config.Consumables.custom) do
    QBCore.Functions.CreateUseableItem(k, function(source, item)
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end
        TriggerClientEvent('consumables:client:Custom', source, item.name)
        LogConsumable(source, item.name, 'custom')
    end)
end

local function createItem(name, type)
    QBCore.Functions.CreateUseableItem(name, function(source, item)
        if not exports.ox_inventory:RemoveItem(source, item.name, 1, nil, item.slot) then return end
        TriggerClientEvent('consumables:client:' .. type, source, item.name)
    end)
end
----------- / Drug

-- QBCore.Functions.CreateUseableItem('joint', function(source, item)
--     if not exports['qb-inventory']:RemoveItem(source, item.name, 1, item.slot, 'qb-smallresources:joint') then return end
--     TriggerClientEvent('consumables:client:UseJoint', source)
-- end)

-- QBCore.Functions.CreateUseableItem('cokebaggy', function(source)
--     TriggerClientEvent('consumables:client:Cokebaggy', source)
-- end)

-- QBCore.Functions.CreateUseableItem('crack_baggy', function(source)
--     TriggerClientEvent('consumables:client:Crackbaggy', source)
-- end)

-- QBCore.Functions.CreateUseableItem('xtcbaggy', function(source)
--     TriggerClientEvent('consumables:client:EcstasyBaggy', source)
-- end)

-- QBCore.Functions.CreateUseableItem('oxy', function(source)
--     TriggerClientEvent('consumables:client:oxy', source)
-- end)

-- QBCore.Functions.CreateUseableItem('meth', function(source)
--     TriggerClientEvent('consumables:client:meth', source)
-- end)

----------- / Tools

-- QBCore.Functions.CreateUseableItem('armor', function(source)
--     TriggerClientEvent('consumables:client:UseArmor', source)
-- end)

-- QBCore.Functions.CreateUseableItem('heavyarmor', function(source)
--     TriggerClientEvent('consumables:client:UseHeavyArmor', source)
-- end)

-- QBCore.Commands.Add('resetarmor', 'Resets Vest (Police Only)', {}, false, function(source)
--     local Player = QBCore.Functions.GetPlayer(source)
--     if Player.PlayerData.job.name == 'police' then
--         TriggerClientEvent('consumables:client:ResetArmor', source)
--     else
--         TriggerClientEvent('QBCore:Notify', source, locale('server.police_only'), 'error')
--     end
-- end)

QBCore.Functions.CreateUseableItem('binoculars', function(source)
    TriggerClientEvent('binoculars:Toggle', source)
end)

-- QBCore.Functions.CreateUseableItem('parachute', function(source, item)
--     if not exports['qb-inventory']:RemoveItem(source, item.name, 1, item.slot, 'qb-smallresources:parachute') then return end
--     TriggerClientEvent('consumables:client:UseParachute', source)
-- end)

-- QBCore.Commands.Add('resetparachute', 'Resets Parachute', {}, false, function(source)
--     TriggerClientEvent('consumables:client:ResetParachute', source)
-- end)

----------- / Firework

for _, v in pairs(Config.Fireworks.items) do
    QBCore.Functions.CreateUseableItem(v, function(source, item)
        local src = source
        TriggerClientEvent('fireworks:client:UseFirework', src, item.name, 'proj_indep_firework')
    end)
end

----------- / Lockpicking

QBCore.Functions.CreateUseableItem('lockpick', function(source, item)
    TriggerClientEvent('lockpicks:UseLockpick', source, false, item.slot)
    LogLockpick(source, false)
end)

QBCore.Functions.CreateUseableItem('advancedlockpick', function(source, item)
    TriggerClientEvent('lockpicks:UseLockpick', source, true, item.slot)
    LogLockpick(source, true)
end)

-- Events for adding and removing specific items to fix some exploits

RegisterNetEvent('consumables:server:AddParachute', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    exports.ox_inventory:AddItem(source, 'parachute', 1)
end)

RegisterNetEvent('consumables:server:resetArmor', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    exports.ox_inventory:AddItem(source, 'heavyarmor', 1)
end)

RegisterNetEvent('consumables:server:useHeavyArmor', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not exports.ox_inventory:RemoveItem(source, 'heavyarmor', 1) then return end
    TriggerClientEvent('hospital:server:SetArmor', source, 100)
    SetPedArmour(GetPlayerPed(source), 100)
end)

RegisterNetEvent('consumables:server:useArmor', function()
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not exports.ox_inventory:RemoveItem(source, 'armor', 1) then return end
    TriggerClientEvent('hospital:server:SetArmor', source, 75)
    SetPedArmour(GetPlayerPed(source), 75)
end)

-- RegisterNetEvent('consumables:server:useMeth', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     exports['qb-inventory']:RemoveItem(source, 'meth', 1, false, 'consumables:server:useMeth')
-- end)

-- RegisterNetEvent('consumables:server:useOxy', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     exports['qb-inventory']:RemoveItem(source, 'oxy', 1, false, 'consumables:server:useOxy')
-- end)

-- RegisterNetEvent('consumables:server:useXTCBaggy', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     exports['qb-inventory']:RemoveItem(source, 'xtcbaggy', 1, false, 'consumables:server:useXTCBaggy')
-- end)

-- RegisterNetEvent('consumables:server:useCrackBaggy', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     exports['qb-inventory']:RemoveItem(source, 'crack_baggy', 1, false, 'consumables:server:useCrackBaggy')
-- end)

-- RegisterNetEvent('consumables:server:useCokeBaggy', function()
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     exports['qb-inventory']:RemoveItem(source, 'cokebaggy', 1, false, 'consumables:server:useCokeBaggy')
-- end)

-- RegisterNetEvent('consumables:server:drinkAlcohol', function(item)
--     local Player = QBCore.Functions.GetPlayer(source)
--     if not Player then return end
--     local foundItem = nil

--     for k in pairs(Config.Consumables.alcohol) do
--         if k == item then
--             foundItem = k
--             break
--         end
--     end

--     if not foundItem then return end
--     exports['qb-inventory']:RemoveItem(source, foundItem, 1, false, 'consumables:server:drinkAlcohol')
-- end)

RegisterNetEvent('consumables:server:UseFirework', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local foundItem = nil

    for i = 1, #Config.Fireworks.items do
        if Config.Fireworks.items[i] == item then
            foundItem = Config.Fireworks.items[i]
            break
        end
    end

    if not foundItem then return end
    exports.ox_inventory:RemoveItem(src, foundItem, 1)
    LogConsumable(src, foundItem, 'firework')
end)

RegisterNetEvent('consumables:server:addThirst', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('thirst', amount)
    TriggerClientEvent('hud:client:UpdateNeeds', source, Player.PlayerData.metadata.hunger, amount)
end)

RegisterNetEvent('consumables:server:addHunger', function(amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.SetMetaData('hunger', amount)
    TriggerClientEvent('hud:client:UpdateNeeds', source, amount, Player.PlayerData.metadata.thirst)
end)

QBCore.Functions.CreateCallback('consumables:itemdata', function(_, cb, itemName)
    cb(Config.Consumables.custom[itemName])
end)

---Checks if item already exists in the table. If not, it creates it.
---@param drinkName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addDrink(drinkName, replenish)
    if Config.Consumables.drink[drinkName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.drink[drinkName] = replenish
        createItem(drinkName, 'Drink')
        return true, 'success'
    end
end

exportHandler('AddDrink', addDrink)

---Checks if item already exists in the table. If not, it creates it.
---@param foodName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addFood(foodName, replenish)
    if Config.Consumables.eat[foodName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.eat[foodName] = replenish
        createItem(foodName, 'Eat')
        return true, 'success'
    end
end

exportHandler('AddFood', addFood)

---Checks if item already exists in the table. If not, it creates it.
---@param alcoholName string name of item
---@param replenish number amount it replenishes
---@return boolean, string
local function addAlcohol(alcoholName, replenish)
    if Config.Consumables.alcohol[alcoholName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.alcohol[alcoholName] = replenish
        createItem(alcoholName, 'DrinkAlcohol')
        return true, 'success'
    end
end

exportHandler('AddAlcohol', addAlcohol)

---Checks if item already exists in the table. If not, it creates it.
---@param itemName string name of item
---@param data number amount it replenishes
---@return boolean, string
local function addCustom(itemName, data)
    if Config.Consumables.custom[itemName] ~= nil then
        return false, 'already added'
    else
        Config.Consumables.custom[itemName] = data
        createItem(itemName, 'Custom')
        return true, 'success'
    end
end

exportHandler('AddCustom', addCustom)
