local QBCore = exports['qb-core']:GetCoreObject()
local loggerType = GetConvar('meteo:logger', 'discord')

-- Discord Webhook Configuration
DiscordWebhook = {
    webhook = "", -- Set your Discord webhook URL here
    botName = GetConvar('meteo:name', 'Meteo Studios'),
    botIcon = GetConvar('meteo:logo', 'https://r2.fivemanage.com/ND1ABtrhOCiEbMgp1LFCW/182349304.png'),
    embedColor = 3447003,
    footer = {
        text = GetConvar('meteo:name', 'Meteo Studios') .. " • " .. os.date("%Y"),
        icon_url = GetConvar('meteo:logo', 'https://r2.fivemanage.com/ND1ABtrhOCiEbMgp1LFCW/182349304.png')
    }
}

local function GetPlayerInfo(src)
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return nil end
    return {
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        citizenid = player.PlayerData.citizenid
    }
end

local function SendDiscordLog(title, description, color, fields)
    if DiscordWebhook.webhook == "" then return end

    local embed = {
        {
            title = title,
            description = description,
            color = color or DiscordWebhook.embedColor,
            fields = fields or {},
            footer = {
                text = DiscordWebhook.footer.text,
                icon_url = DiscordWebhook.footer.icon_url
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(DiscordWebhook.webhook, function(err, text, headers) end, 'POST', json.encode({
        username = DiscordWebhook.botName,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

local Colors = {
    RED = 15548997,
    GREEN = 5763719,
    ORANGE = 15105570,
    BLUE = 3447003,
    YELLOW = 16776960,
    PURPLE = 10181046,
    WHITE = 16777215
}

-----------------------------------------------------------
-- Player Connect / Disconnect
-----------------------------------------------------------

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        identifiers[#identifiers + 1] = GetPlayerIdentifier(src, i)
    end
    local allIdentifiers = json.encode(identifiers)

    if loggerType == 'oxlib' then
        lib.logger(src, 'PlayerConnecting', string.format('%s connecting | Identifiers: %s', playerName, allIdentifiers), 'joinleave', 'connecting')
        return
    end

    local fields = {
        {name = ":bust_in_silhouette: Player", value = "**" .. playerName .. "**", inline = true},
        {name = ":id: Server ID", value = tostring(src), inline = true},
        {name = ":globe_with_meridians: All Identifiers", value = "```json\n" .. allIdentifiers .. "\n```", inline = false}
    }
    SendDiscordLog(":green_circle: Player Connecting", "**" .. playerName .. "** is connecting to the server", Colors.GREEN, fields)
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    local playerName = GetPlayerName(src) or 'Unknown'
    local player = GetPlayerInfo(src)
    local citizenid = player and player.citizenid or 'N/A'
    local charName = player and player.name or playerName
    local identifiers = {}
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        identifiers[#identifiers + 1] = GetPlayerIdentifier(src, i)
    end
    local allIdentifiers = json.encode(identifiers)

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local coordsStr = "N/A"
    if coords and coords.x then
        coordsStr = string.format("X: %.2f, Y: %.2f, Z: %.2f", coords.x, coords.y, coords.z)
    end

    if loggerType == 'oxlib' then
        lib.logger(src, 'PlayerDropped', string.format('%s (%s) disconnected | Reason: %s | Coords: %s | Identifiers: %s', charName, playerName, reason or 'Unknown', coordsStr, allIdentifiers), 'joinleave', 'dropped', 'citizenid:' .. citizenid)
        return
    end

    local fields = {
        {name = ":bust_in_silhouette: Character", value = "**" .. charName .. "**", inline = true},
        {name = ":video_game: Nickname", value = playerName, inline = true},
        {name = ":id: Citizen ID", value = citizenid, inline = true},
        {name = ":1234: Server ID", value = tostring(src), inline = true},
        {name = ":round_pushpin: Coordinates", value = coordsStr, inline = true},
        {name = ":door: Reason", value = reason or "Unknown", inline = false},
        {name = ":globe_with_meridians: All Identifiers", value = "```json\n" .. allIdentifiers .. "\n```", inline = false}
    }
    SendDiscordLog(":red_circle: Player Disconnected", "**" .. charName .. "** (" .. playerName .. ") left the server", Colors.RED, fields)
end)

-----------------------------------------------------------
-- Tackle
-----------------------------------------------------------

function LogTackle(src, targetId)
    local player = GetPlayerInfo(src)
    local target = GetPlayerInfo(targetId)
    if not player then return end

    local targetName = target and target.name or (GetPlayerName(targetId) or 'Unknown')
    local targetCid = target and target.citizenid or 'N/A'

    if loggerType == 'oxlib' then
        lib.logger(src, 'Tackle', string.format('%s tackled %s', player.name, targetName), 'interaction', 'tackle', 'target:' .. targetCid, 'citizenid:' .. player.citizenid)
        return
    end

    local fields = {
        {name = ":bust_in_silhouette: Player", value = "**" .. player.name .. "**\n(" .. player.citizenid .. ")", inline = true},
        {name = ":person_running: Target", value = "**" .. targetName .. "**\n(" .. targetCid .. ")", inline = true},
        {name = ":clock1: Time", value = os.date("%H:%M:%S"), inline = true}
    }
    SendDiscordLog(":wrestling: Tackle", "**" .. player.name .. "** tackled **" .. targetName .. "**", Colors.ORANGE, fields)
end

-----------------------------------------------------------
-- Car Wash
-----------------------------------------------------------

function LogCarWash(src, price, paymentMethod)
    local player = GetPlayerInfo(src)
    if not player then return end

    if loggerType == 'oxlib' then
        lib.logger(src, 'CarWash', string.format('%s washed car | Price: $%s (%s)', player.name, price, paymentMethod), 'carwash', 'wash', 'amount:' .. tostring(price), 'citizenid:' .. player.citizenid)
        return
    end

    local fields = {
        {name = ":bust_in_silhouette: Player", value = "**" .. player.name .. "**\n(" .. player.citizenid .. ")", inline = true},
        {name = ":id: Citizen ID", value = player.citizenid, inline = true},
        {name = ":moneybag: Price", value = "$" .. price .. " (" .. paymentMethod .. ")", inline = true}
    }
    SendDiscordLog(":droplet: Car Wash", "**" .. player.name .. "** washed their vehicle", Colors.BLUE, fields)
end

-----------------------------------------------------------
-- Consumables
-----------------------------------------------------------

function LogConsumable(src, itemName, consumableType)
    local player = GetPlayerInfo(src)
    if not player then return end

    if loggerType == 'oxlib' then
        lib.logger(src, 'Consumable', string.format('%s used %s (%s)', player.name, itemName, consumableType), 'consumable', consumableType, 'item:' .. itemName, 'citizenid:' .. player.citizenid)
        return
    end

    local typeEmoji = ":package:"
    if consumableType == 'eat' then typeEmoji = ":hamburger:"
    elseif consumableType == 'drink' then typeEmoji = ":cup_with_straw:"
    elseif consumableType == 'alcohol' then typeEmoji = ":wine_glass:"
    elseif consumableType == 'firework' then typeEmoji = ":fireworks:"
    end

    local fields = {
        {name = ":bust_in_silhouette: Player", value = "**" .. player.name .. "**\n(" .. player.citizenid .. ")", inline = true},
        {name = ":id: Citizen ID", value = player.citizenid, inline = true},
        {name = typeEmoji .. " Item", value = "**" .. itemName .. "**", inline = true},
        {name = ":label: Type", value = consumableType, inline = true}
    }
    SendDiscordLog(typeEmoji .. " Consumable Used", "**" .. player.name .. "** used **" .. itemName .. "**", Colors.GREEN, fields)
end

-----------------------------------------------------------
-- Weapon Drop (lockpick usage)
-----------------------------------------------------------

function LogLockpick(src, isAdvanced)
    local player = GetPlayerInfo(src)
    if not player then return end

    local pickType = isAdvanced and "Advanced Lockpick" or "Lockpick"

    if loggerType == 'oxlib' then
        lib.logger(src, 'Lockpick', string.format('%s used %s', player.name, pickType), 'interaction', 'lockpick', 'type:' .. pickType, 'citizenid:' .. player.citizenid)
        return
    end

    local fields = {
        {name = ":bust_in_silhouette: Player", value = "**" .. player.name .. "**\n(" .. player.citizenid .. ")", inline = true},
        {name = ":id: Citizen ID", value = player.citizenid, inline = true},
        {name = ":key: Type", value = pickType, inline = true}
    }
    SendDiscordLog(":key: Lockpick Used", "**" .. player.name .. "** used a **" .. pickType .. "**", Colors.ORANGE, fields)
end

-----------------------------------------------------------
-- Backward compatibility for qb-log events
-----------------------------------------------------------

RegisterNetEvent('qb-log:server:CreateLog', function(name, title, color, message, tagEveryone, imageUrl)
    if loggerType == 'oxlib' then
        local src = source
        local citizenid = nil
        if src and src > 0 then
            local player = QBCore.Functions.GetPlayer(src)
            if player then
                citizenid = player.PlayerData.citizenid
            end
        end
        if citizenid then
            lib.logger(src, name, message, name, 'citizenid:' .. citizenid)
        else
            lib.logger(src or -1, name, message)
        end
        return
    end

    local colorMap = {
        ['default'] = 14423100, ['blue'] = 255, ['red'] = 16711680,
        ['green'] = 65280, ['white'] = 16777215, ['black'] = 0,
        ['orange'] = 16744192, ['yellow'] = 16776960, ['pink'] = 16761035,
        ['lightgreen'] = 65309,
    }

    SendDiscordLog(title, message, colorMap[color] or colorMap['default'], {})
end)
