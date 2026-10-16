local QBCore = exports['qb-core']:GetCoreObject()

-- Bank money goes through meteo-banking so it shows in the bank history.
-- Cash, or bank while banking is not running, goes straight to the core.
local function useBanking(account)
    return account == 'bank' and GetResourceState(Rename.prefix .. 'banking') == 'started'
end

local function RemoveAccountMoney(source, account, amount, tx)
    if useBanking(account) then
        return exports[Rename.prefix .. 'banking']:RemoveMoney(source, amount, tx) == true
    end
    local player = QBCore.Functions.GetPlayer(source)
    return player ~= nil and player.Functions.RemoveMoney(account, amount, tx.reason) == true
end

RegisterNetEvent('tackle:server:TacklePlayer', function(playerId)
    TriggerClientEvent('tackle:client:GetTackled', playerId)
    LogTackle(source, playerId)
end)

QBCore.Commands.Add('id', 'Check Your ID #', {}, false, function(source)
    TriggerClientEvent('QBCore:Notify', source, 'ID: ' .. source)
end)

QBCore.Functions.CreateUseableItem('harness', function(source, item)
    TriggerClientEvent('seatbelt:client:UseHarness', source, item)
end)

RegisterNetEvent('equip:harness', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local slotData = exports.ox_inventory:GetSlot(src, item.slot)
    if not slotData then return end
    local md = slotData.metadata or {}

    if not md.uses then
        md.uses = Config.HarnessUses - 1
        exports.ox_inventory:SetMetadata(src, item.slot, md)
    elseif md.uses == 1 then
        exports.ox_inventory:RemoveItem(src, 'harness', 1, nil, item.slot)
    else
        md.uses = md.uses - 1
        exports.ox_inventory:SetMetadata(src, item.slot, md)
    end
end)

RegisterNetEvent('seatbelt:DoHarnessDamage', function(hp, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if hp == 0 then
        exports.ox_inventory:RemoveItem(src, 'harness', 1, nil, data.slot)
    else
        local slotData = exports.ox_inventory:GetSlot(src, data.slot)
        if not slotData then return end
        local md = slotData.metadata or {}
        md.uses = (md.uses or Config.HarnessUses) - 1
        exports.ox_inventory:SetMetadata(src, data.slot, md)
    end
end)

lib.callback.register('qb-carwash:server:washCar', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    if Player.Functions.RemoveMoney('cash', Config.CarWash.defaultPrice, 'car-washed') then
        LogCarWash(source, Config.CarWash.defaultPrice, 'cash')
        return true
    elseif RemoveAccountMoney(source, 'bank', Config.CarWash.defaultPrice, {
        category = 'payment', title = 'Car wash', actor = source, reason = 'car-washed',
    }) then
        LogCarWash(source, Config.CarWash.defaultPrice, 'bank')
        return true
    end

    TriggerClientEvent('QBCore:Notify', source, locale('wash.no_money'), 'error')
    return false
end)

QBCore.Functions.CreateCallback('smallresources:server:GetCurrentPlayers', function(_, cb)
    cb(#GetPlayers())
end)
