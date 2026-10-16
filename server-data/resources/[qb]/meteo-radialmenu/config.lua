Config = {}

-- GENERAL SETTINGS
Config.Keybind = 'F1'           -- FiveM Keyboard keybinding (changeable in keybindings)
Config.Toggle = false           -- Use toggle mode (false = hold key)
Config.UseWhilstWalking = false -- Allow usage while walking
Config.Fliptime = 15000         -- Time for vehicle flip (ms)

-- STRETCHER
Config.Stretcher = {
    model = `prop_ld_binbag_01`,  -- streamed stretcher model
    jobs = { 'ambulance' },       -- can take, push, load patients and store
    vehicles = { 'ambulance' },   -- take it out from the back of these
    interactDistance = 2.5,
    zoneRadius = 1.2,             -- target zone on a parked stretcher
    rearDoors = { 2, 3 },         -- opened on take and store
    doorCloseDelay = 2500,        -- ms
    pushAttach = {                -- stretcher on the pusher
        bone = 28422,
        offset = vec3(0.0, -1.0, -0.5),
        rotation = vec3(195.0, 180.0, 180.0),
    },
    layAttach = {                 -- patient on the stretcher
        offset = vec3(0.0, 0.0, 1.0),
        rotation = vec3(0.0, 0.0, 180.0),
    },
}

-- MAIN MENU ITEMS
Config.MenuItems = {
    -- -- PERKS MENu
    -- {
    --     id = 'meteoperks',
    --     title = 'Perks',
    --     icon = 'bolt',
    --     type = 'client',
    --     event = 'meteo-perks:client:openMenu',
    --     shouldClose = true
    -- },

    -- -- CHARACTER STATS
    -- {
    --     id = 'characterstats',
    --     title = 'Character Stats',
    --     icon = 'analytics',
    --     type = 'client',
    --     event = 'meteo-gym:client:openStats',
    --     shouldClose = true
    -- },
}

-- JOB-SPECIFIC INTERACTIONS
Config.JobInteractions = {
    -- POLICE JOB
    ['police'] = {
        {
            id = 'panic-1078',
            title = '10-78 Need Backup',
            icon = 'support',
            type = 'command',
            event = '10-78',
            shouldClose = true,
        },
        {
            id = 'togglepolradar',
            title = 'Toggle Radar',
            icon = 'radar',
            type = 'client',
            event = 'meteo-policeradar:client:ToggleRadar',
            shouldClose = true,
            canOpen = function() return cache.vehicle and true or false end -- vehicle only
        },
    }
}
