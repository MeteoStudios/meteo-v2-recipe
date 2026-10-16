Config = {}

Config.PauseMapText = GetConvar('meteo:name', 'Meteo Studios') -- DO NOT CHANGE THIS. ONLY CHANGE FROM SERVER.CFG
Config.HarnessUses = 20

Config.Seatbelt = {
    useKMH = false,
    minSpeedUnbuckled = 50.0,
    minSpeedBuckled = 250.0,
    harnessDisableEjection = true,
    minSpeedHarness = 400.0,
    disabledVehicleClasses = {
        [8] = true,
        [13] = true,
        [14] = true,
        [15] = true,
        [16] = true
    }
}

-- Hands up moved to meteo-animations (client/cl_handsup.lua)

Config.Binoculars = {
    zoomSpeed = 10.0,
    storeBinocularsKey = 177
}

Config.AIResponse = {
    wantedLevels = false, -- if true, you will recieve wanted levels
    dispatchServices = {  -- AI dispatch services
        [1] = false,      -- Police Vehicles
        [2] = false,      -- Police Helicopters
        [3] = false,      -- Fire Department Vehicles
        [4] = false,      -- Swat Vehicles
        [5] = false,      -- Ambulance Vehicles
        [6] = false,      -- Police Motorcycles
        [7] = false,      -- Police Backup
        [8] = false,      -- Police Roadblocks
        [9] = false,      -- PoliceAutomobileWaitPulledOver
        [10] = false,     -- PoliceAutomobileWaitCruising
        [11] = false,     -- Gang Members
        [12] = false,     -- Swat Helicopters
        [13] = false,     -- Police Boats
        [14] = false,     -- Army Vehicles
        [15] = false      -- Biker Backup
    }
}

-- Config.Discord = {
--     isEnabled = false,
--     applicationId = '00000000000000000',
--     iconLarge = 'logo_name',
--     iconLargeHoverText = 'This is a Large icon with text',
--     iconSmall = 'small_logo_name',
--     iconSmallHoverText = 'This is a Small icon with text',
--     updateRate = 60000,
--     showPlayerCount = true,
--     maxPlayers = 48,
--     buttons = {
--         {
--             text = 'First Button!',
--             url = 'fivem://connect/localhost:30120'
--         },
--         {
--             text = 'Second Button!',
--             url = 'fivem://connect/localhost:30120'
--         }
--     }
-- }

Config.Density = {
    parked = 0.8,
    vehicle = 0.1,
    multiplier = 0.3,
    peds = 0.8,
    scenario = 0.1
}

Config.Disable = {
    hudComponents = { 1, 2, 3, 4, 7, 9, 13, 14, 19, 20, 21, 22, 8, 6 },
    controls = { 37 },
    displayAmmo = false,
    ambience = true,
    idleCamera = true,
    vestDrawable = false,
    pistolWhipping = true,
    driveby = false,
    distantSirens = true,
    policeScanner = true,
}

Config.RelieveWeedStress = math.random(15, 20)

Config.Consumables = {
    eat = {
        -- ['sandwich'] = math.random(5, 10),
        -- ['tosti'] = math.random(4, 14),
        -- ['twerks_candy'] = math.random(5, 14),
        -- ['snikkel_candy'] = math.random(3, 15)
    },
    drink = {
        -- ['water_bottle'] = math.random(20, 40),
        -- ['kurkakola'] = math.random(10, 30),
        -- ['coffee'] = math.random(10, 20)
    },
    alcohol = {
        -- ['whiskey'] = math.random(20, 30),
        -- ['beer'] = math.random(30, 40),
        -- ['vodka'] = math.random(20, 40),
    },
    custom = {}
}

Config.Fireworks = {
    delay = 5,
    items = {
        'firework1',
        'firework2',
        'firework3',
        'firework4'
    }
}

Config.BlacklistedScenarios = {
    types = {
        'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
        'WORLD_VEHICLE_MILITARY_PLANES_BIG',
        'WORLD_VEHICLE_AMBULANCE',
        'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
        'WORLD_VEHICLE_POLICE_CAR',
        'WORLD_VEHICLE_POLICE_BIKE'
    },
    groups = {
        2017590552,
        2141866469,
        1409640232,
        `ng_planes`
    }
}

Config.BlacklistedVehs = {
    [`shamal`] = true,
    [`luxor`] = true,
    [`luxor2`] = true,
    [`jet`] = true,
    [`lazer`] = true,
    [`buzzard`] = true,
    [`buzzard2`] = true,
    [`annihilator`] = true,
    [`savage`] = true,
    [`titan`] = true,
    [`rhino`] = true,
    [`firetruck`] = true,
    [`mule`] = true,
    [`blimp`] = true,
    [`airtug`] = true,
    [`camper`] = true,
    [`hydra`] = true,
    [`oppressor`] = true,
    [`technical3`] = true,
    [`insurgent3`] = true,
    [`apc`] = true,
    [`tampa3`] = true,
    [`trailersmall2`] = true,
    [`halftrack`] = true,
    [`hunter`] = true,
    [`vigilante`] = true,
    [`akula`] = true,
    [`barrage`] = true,
    [`khanjali`] = true,
    [`caracara`] = true,
    [`blimp3`] = true,
    [`menacer`] = true,
    [`oppressor2`] = true,
    [`scramjet`] = true,
    [`strikeforce`] = true,
    [`cerberus`] = true,
    [`cerberus2`] = true,
    [`cerberus3`] = true,
    [`scarab`] = true,
    [`scarab2`] = true,
    [`scarab3`] = true,
    [`rrocket`] = true,
    [`ruiner2`] = true,
    [`deluxo`] = true,
    [`cargoplane2`] = true,
    [`voltic2`] = true
}

Config.BlacklistedWeapons = {
    [`WEAPON_RAILGUN`] = true,
}

Config.BlacklistedPeds = {
    [`s_m_m_prisguard_01`] = true,
    [`s_m_y_ranger_01`] = true,
    [`s_m_y_sheriff_01`] = true,
    [`s_m_y_cop_01`] = true,
    [`s_f_y_sheriff_01`] = true,
    [`s_f_y_cop_01`] = true,
    [`s_m_y_hwaycop_01`] = true
}

Config.Objects = {
    { coords = vector3(266.09, -349.35, 44.74), heading = 0, length = 200, width = 200, model = 'prop_sec_barier_02b' },
    { coords = vector3(285.28, -355.78, 45.13), heading = 0, length = 200, width = 200, model = 'prop_sec_barier_02a' },
}

-- Config.Teleports = {
--     [1] = {
--         [1] = {
--             poly = { coords = vector3(3540.74, 3675.59, 20.99), heading = 167.5, length = 2, width = 2 },
--             allowVeh = false,
--             label = false
--         },
--         [2] = {
--             poly = { coords = vector3(3540.74, 3675.59, 28.11), heading = 172.5, length = 2, width = 2 },
--             allowVeh = false,
--             label = false
--         }
--     },
--     [2] = {
--         [1] = {
--             poly = { coords = vector3(909.49, -1589.22, 30.51), heading = 92.24, length = 2, width = 2 },
--             allowVeh = false,
--             label = '[E] Enter Coke Processing'
--         },
--         [2] = {
--             poly = { coords = vector3(1088.81, -3187.57, -38.99), heading = 181.7, length = 2, width = 2 },
--             allowVeh = false,
--             label = '[E] Leave'
--         }
--     }
-- }

Config.CarWash = {
    dirtLevel = 0.1,
    defaultPrice = 20,
    pointDistance = 8.0,
    locations = {
        vec4(174.81, -1736.77, 28.87, 359.0),
        vec4(25.2, -1391.98, 28.91, 0.0),
        vec4(-74.27, 6427.72, 31.02, 315.0),
        -- vec4(1362.69, 3591.81, 34.5, 21.0), -- sandy
        vec4(-699.84, -932.68, 18.59, 0.0),
    }
}