return {
    statusIntervalSeconds = 5, -- how often to check hunger/thirst status to remove health if 0.
    loadingModelsTimeout = 30000, -- Waiting time for ox_lib to load the models before throws an error, for low specs pc
    pauseMapText = '', -- refer to meteo docs. DO NOT MODIFY THIS

    characters = { -- refer to meteo-multichar. DO NOT MODIFY THIS
        useExternalCharacters = true, -- Whether you have an external character management resource. (If true, disables the character management inside the core)
        enableDeleteButton = true, -- Whether players should be able to delete characters themselves.
        startingApartment = true, -- If set to false, skips apartment choice in the beginning (requires qbx_spawn if true)

        dateFormat = 'YYYY-MM-DD',
        dateMin = '1900-01-01', -- Has to be in the same format as the dateFormat config
        dateMax = '2006-12-31', -- Has to be in the same format as the dateFormat config

        limitNationalities = true, -- Setting this to false will allow people to enter whatever they want in the nationality field (To edit the list of nationalities, head to data/nationalities.lua)

        profanityWords = {
            ['bad word'] = true
        },

        locations = { -- Spawn locations for multichar, these are chosen randomly
            {
                pedCoords = vec4(969.25, 72.61, 116.18, 276.55),
                camCoords = vec4(972.2, 72.9, 116.68, 97.27),
            },
        },
    },

    discord = { -- refer to meteo docs. DO NOT MODIFY THIS
        enabled = false,

        appId = '1024981890798731345',

        largeIcon = {
            icon = 'duck',
            text = 'Qbox Ducky',
        },

        smallIcon = {
            icon = 'logo_name',
            text = 'This is a small icon with text',
        },

        firstButton = {
            text = 'Qbox Discord',
            link = 'https://discord.gg/Z6Whda5hHA',
        },

        secondButton = {
            text = 'Main Website',
            link = 'https://www.qbox.re/',
        }
    },

    --- Only used by QB bridge
    hasKeys = function(plate, vehicle)
        return GetResourceState('qbx_vehiclekeys') ~= 'started' or exports.qbx_vehiclekeys:HasKeys(vehicle)
    end,

    teleport = {
        fadeDuration = 650, -- Screen fade duration in milliseconds when teleporting
        groundSearchMaxZ = 850.0, -- Maximum Z height to search for ground when teleporting
        groundSearchStartZ = 950.0, -- Starting Z height for ground search loop
        groundSearchStep = -25.0, -- Z increment step for ground search loop
        loadSceneRadius = 50.0, -- Radius to load the scene around the teleport destination
        timeout = 1000, -- Timeout in milliseconds for scene loading and collision checks
    },

    getVehiclesInRadius = {
        defaultRadius = 5, -- Default search radius when retrieving nearby vehicles
    },

    meCommand = {
        distance = 25, -- Maximum distance at which players can see each other's /me text
        displayTime = 5000, -- Duration in milliseconds the /me text remains visible
    },

    setVehicleProperties = {
        timeout = 1000, -- Timeout in milliseconds when attempting to set vehicle properties
        waitInterval = 50, -- Wait time in milliseconds between property set attempts
    },

    initVehicle = {
        seats = {-1, 0}, -- List of seat indices to clear when initializing a vehicle
    },
}
