Config = {}

Config.debug = false

Config.target = 'auto' -- 'auto', 'ox_target', 'qb-target'

-- IPLs load within this, unload past it
Config.loadRadius = 120.0

-- Stop map scripts listed under conflicts
Config.stopConflicts = true

-- Lifts and doors spawn within this
Config.moverRadius = 80.0

-- Auto doors start locked on boot
Config.startLocked = true

-- Auto doors close after everyone leaves
Config.autoCloseDelay = 3000

--[[
    Animated props, shared by every mover of that kind.
    dict, open, close, static - entity animations on the prop
    collision                 - invisible model that slides between from and to
    duration                  - animation length, nothing can be used again before it ends
    follow                    - collision rides the prop's moving bone, so it matches the animation exactly
    carry / carryRadius       - vehicles within this of the lift centre ride it, whatever their size
    moveTime / delay          - how long the collision slides, and the wait before it goes up, when not following
    size                      - interaction box
    autoOpen                  - the job locks and unlocks it, unlocked means open
    autoClose                 - unlocked only opens for anyone nearby and closes when they leave
    autoRadius                - how close counts as nearby
    labels                    - locale keys for the two interactions (closed, open)
--]]
Config.moverKinds = {
    lift = {
        model = 'prompt_sandy_is_lift_2',
        collision = 'prompt_sandy_is_lift_col_2',
        dict = 'prompt_sandy_is_lift_new_new',
        open = 'prompt_sandy_is_lift_opened',
        close = 'prompt_sandy_is_lift_closed',
        static = 'prompt_sandy_is_lift_static',
        duration = 5000,
        follow = true,
        carry = true,
        carryRadius = 2.5,
        moveTime = 4500,
        delay = 300,
        size = vec3(2.0, 2.0, 2.0),
        autoOpen = false,
        labels = { 'target_lift_raise', 'target_lift_lower' },
    },
    rollup = {
        model = 'prompt_sandy_is_garage_rollup_2',
        collision = 'prompt_sandy_is_garage_rollup_col_2',
        dict = 'anim@prompt_sandy_is_lift_new',
        open = 'prompt_sandy_is_garage_rollup',
        close = 'prompt_sandy_is_garage_rollup_closing',
        static = 'prompt_sandy_is_garage_rollup_static',
        duration = 5000,
        moveTime = 5000,
        delay = 0,
        size = vec3(4.5, 3.0, 3.0),
        autoOpen = true,
        autoClose = false,
        autoRadius = 4.0,
        labels = { 'target_door_unlock', 'target_door_lock' },
    },
}

--[[
    One entry per map we take over.
    resource    - the map resource, nothing loads unless it runs
    ownLoader   - setting in one of its files that must be false (or an empty table with empty = true), so the two never both load it
    conflicts   - resources stopped (or warned about) while this runs
    ipls        - loaded while a player is near the probe
    sets        - interior sets: active is switched on, the other options off. false hides them all
    jobs        - job names or job types allowed to use the movers, empty for everyone
    movers      - animated props: kind, prop spot and heading, collision from (closed) and to (open), interaction zone
--]]
Config.maps = {
    mrpd = {
        label = 'Prompt MRPD',
        resource = 'prompt_mrpd',
        ownLoader = { file = 'config.lua', key = 'Standalone.enabled' },
        conflicts = { 'prompt_mrpd_scripts' },
        ipls = {
            { ipl = 'prompt_mrpd_milo_', probe = vec3(455.907745, -999.011841, 27.4721947) },
            { ipl = 'tuco_mrpd_int', probe = vec3(442.90274, -991.2584, 40.315834) },
        },
        sets = {
            -- briefing room: desks or chairs
            { probe = vec3(455.907745, -999.011841, 27.4721947), options = { 'briefingroomdesks', 'briefingroomchairs' }, active = 'briefingroomdesks' },
            -- gym furniture
            { probe = vec3(449.8008, -988.727051, 26.10148), options = { 'gym' }, active = 'gym' },
            -- training: killhouse or cqb
            { probe = vec3(449.8008, -988.727051, 26.10148), options = { 'solo_train', 'team_train' }, active = 'solo_train' },
            -- static elevators
            { probe = vec3(444.900818, -990.149963, 31.2896633), options = { 'lifts' }, active = 'lifts' },
        },
    },

    sandy = {
        label = 'Prompt Sandy Mechanic',
        resource = 'prompt_sandy_mechanic',
        ownLoader = { file = 'config.lua', key = 'Props', empty = true },
        jobs = { 'mechanic' },
        sets = {
            -- static lifts and doors, ours replace them
            { probe = vec3(1705.4022, 3690.8555, 34.5232), options = { 'default' }, active = false },
        },
        movers = {
            lift_2 = {
                kind = 'lift',
                coords = vec3(1708.439, 3692.678, 34.249), heading = 0.0,
                from = vec3(1708.439, 3692.678, 33.4975), to = vec3(1708.439, 3692.678, 35.4),
                zone = vec3(1707.439, 3693.778, 34.249),
            },
            lift_3 = {
                kind = 'lift',
                coords = vec3(1705.495, 3697.778, 34.2498), heading = 0.0,
                from = vec3(1705.495, 3697.778, 33.4973), to = vec3(1705.495, 3697.778, 35.4),
                zone = vec3(1704.495, 3698.778, 34.2498),
            },
            lift_4 = {
                kind = 'lift',
                coords = vec3(1711.326, 3687.679, 34.2498), heading = 0.0,
                from = vec3(1711.326, 3687.679, 33.4973), to = vec3(1711.326, 3687.679, 35.4),
                zone = vec3(1710.326, 3688.679, 34.2498),
            },
            door_1 = {
                kind = 'rollup',
                coords = vec3(1714.93091, 3689.38037, 33.22947), heading = 30.0,
                from = vec3(1714.885, 3689.190, 35.724), to = vec3(1714.885, 3689.190, 39.059),
                zone = vec3(1714.93091, 3689.38037, 33.22947),
            },
            door_2 = {
                kind = 'rollup',
                coords = vec3(1712.00476, 3694.44873, 33.22947), heading = 30.0,
                from = vec3(1711.945, 3694.260, 35.724), to = vec3(1711.945, 3694.260, 39.059),
                zone = vec3(1711.872, 3694.372, 33.22947),
            },
            door_3 = {
                kind = 'rollup',
                coords = vec3(1709.12146, 3699.44287, 33.22947), heading = 30.0,
                from = vec3(1709.065, 3699.260, 35.724), to = vec3(1709.065, 3699.260, 39.059),
                zone = vec3(1708.996, 3699.302, 33.22947),
            },
            door_4 = {
                kind = 'rollup',
                coords = vec3(1706.1272, 3704.629, 33.22947), heading = 30.0,
                from = vec3(1706.065, 3704.450, 35.724), to = vec3(1706.065, 3704.450, 39.059),
                zone = vec3(1706.1272, 3704.629, 33.22947),
            },
            door_5 = {
                kind = 'rollup',
                coords = vec3(1703.093, 3709.88428, 33.22947), heading = 30.0,
                from = vec3(1703.035, 3709.690, 35.724), to = vec3(1703.035, 3709.690, 39.059),
                zone = vec3(1703.093, 3709.88428, 33.22947),
            },
        },
    },
}
