lib.locale()

local MANAGE_RESOURCE = Rename.prefix .. 'manage'
local PERMISSION = 'use_imagestudio'

-- meteo-manage decides; no menu, no access
local function canUse(source)
    if GetResourceState(MANAGE_RESOURCE) ~= 'started' then return false end
    local ok, allowed = pcall(function()
        return exports[MANAGE_RESOURCE]:HasPermission(source, PERMISSION)
    end)
    return ok and allowed == true
end

local function openFor(source, first)
    source = tonumber(source)
    if not source or source <= 0 then return false end
    if not canUse(source) then
        TriggerClientEvent('QBCore:Notify', source, locale('no_permission'), 'error')
        return false
    end
    TriggerEvent('meteo-imagestudio:server:authorize', source, MANAGE_RESOURCE, PERMISSION)
    TriggerClientEvent('meteo-imagestudio:client:open', source, first, SafeMode())
    return true
end

-- gated in openFor, not by ACE
lib.addCommand(Config.command, {
    help = locale('command_help'),
    params = {
        { name = 'model', type = 'string', help = locale('command_arg_model'), optional = true },
    },
    restricted = false,
}, function(source, args)
    openFor(source, args.model)
end)

-- Admin Menu hand-off
exports('OpenStudio', function(source)
    return openFor(source)
end)

-- meteo-furnishing's catalog; GetAllProps is a server export
lib.callback.register('meteo-imagestudio:server:getFurnishingProps', function(source)
    if not canUse(source) then return nil end
    local resource = Rename.prefix .. 'furnishing'
    if GetResourceState(resource) ~= 'started' then return nil end
    local ok, props = pcall(function() return exports[resource]:GetAllProps() end)
    if not ok then
        DebugPrint('GetAllProps failed', props)
        return nil
    end
    return props
end)

AddEventHandler('playerDropped', function()
    TriggerEvent('meteo-imagestudio:server:revoke', source)
end)
