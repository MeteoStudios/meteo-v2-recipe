-- Admin Menu (Script Settings) registration, action-only
local MANAGE_RESOURCE = Rename.prefix .. 'manage'

local schema = {
    api = 1,
    -- DB id, folder-name independent
    id = 'meteo_imagestudio',
    label = locale('settings_title'),
    icon = 'camera',
    sections = {
        {
            id = 'studio', icon = 'camera',
            label = locale('settings_section_studio'),
            description = locale('settings_section_studio_desc'),
            fields = {},
            actions = {
                {
                    key = 'openStudio', export = 'OpenStudio', closeUi = true, icon = 'camera',
                    label = locale('settings_action_studio'),
                },
            },
        },
    },
}

local function register()
    if GetResourceState(MANAGE_RESOURCE) ~= 'started' then return end
    pcall(function()
        exports[MANAGE_RESOURCE]:RegisterSettings(GetCurrentResourceName(), schema, Config)
    end)
end

CreateThread(function()
    local waited = 0
    while GetResourceState(MANAGE_RESOURCE) ~= 'started' do
        Wait(500)
        waited = waited + 500
        if waited >= 30000 then return end -- no Admin Menu
    end
    Wait(250)
    register()
end)

-- manage restarted, re-register
AddEventHandler('onResourceStart', function(res)
    if res == MANAGE_RESOURCE then
        CreateThread(function()
            Wait(500)
            register()
        end)
    end
end)
