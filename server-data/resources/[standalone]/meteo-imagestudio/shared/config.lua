Config = {}

Config.debug = false

Config.command = 'imagestudio'   -- gated by meteo-manage use_imagestudio

Config.imageCdn = ''

-- Empty spot high above the map; nothing else renders around the subject
Config.studio = {
    location = vector3(870.1714, 556.3516, 1022.2179),
    backdropDistance = 12.0,          -- metres behind the subject
    -- the camera never comes closer than this; a small subject gets a narrower
    -- lens instead, because the game clips geometry right in front of the lens
    minCameraDistance = 3.0,
    backdrop = { r = 200, g = 200, b = 200 },   -- what you see while working, never in the image
    hour = 11,
    weather = 'CLEAR',
    sunAngle = 180.0,                 -- world heading of the setup; 180 puts the midday sun behind the camera
    lightStrength = 0.8,
    lights = {
        { offset = vector3(0.0, 8.0, 3.0), range = 20.0, intensity = 1.5 },
        { offset = vector3(-8.0, 0.0, 3.0), range = 15.0, intensity = 1.2 },
        { offset = vector3(8.0, 0.0, 3.0), range = 15.0, intensity = 1.2 },
        { offset = vector3(0.0, -8.0, 3.0), range = 20.0, intensity = 1.5 },
    },
}

-- The proven catalog shot. Distance is solved per subject, never set.
Config.camera = {
    angle = 317.3,      -- 0 front, 90 passenger side, 180 rear, 270 driver side
    pitch = 7.6,
    fov = 10.0,         -- narrow lens far away = flat catalog perspective
    fill = 0.78,        -- share of the frame the subject spans
}

Config.vehicle = {
    colorCombo = 0,
    windowTint = 0,
    plate = 'METEO',
}

Config.clothing = {
    peds = { male = 'mp_m_freemode_01', female = 'mp_f_freemode_01' },
    hide = {},
    -- arms-down pose held still, so breathing never moves the item between frames
    pose = { dict = 'anim@heists@heist_corona@team_idles@male_a', name = 'idle', time = 0.2 },
    preloadTimeout = 1500,  -- ms to wait for a drawable's textures to stream
    applyWait = 60,         -- ms after dressing before the shot
    settle = 40,            -- textures are preloaded per drawable, so little settle is needed
    propWait = 250,         -- ms after a prop reports attached; props attach over several frames
    fov = 15.0,
    fill = 0.82,
    categories = {
        {
            name = 'mask', component = 1, angle = 0.0, pitch = 0.0, skip = { 0 },
            focus = { bone = 31086, size = 0.6 },
            frame = { bones = { 31086 }, offset = vector3(0.0, 0.0, 0.03), size = 0.5 },
        },
        {
            name = 'top', component = 11, angle = 0.0, pitch = 4.0,
            frame = { bones = { 24818 }, offset = vector3(0.0, 0.0, -0.15), size = 1.15 },  -- room for hoods
        },
        {
            name = 'legs', component = 4, angle = 0.0, pitch = 4.0,
            frame = { bones = { 11816 }, offset = vector3(0.0, 0.0, -0.35), size = 1.45 },  -- room for overalls
        },
        {
            name = 'shoes', component = 6, angle = 25.0, pitch = 18.0,
            frame = { bones = { 14201, 52301 }, offset = vector3(0.0, 0.0, 0.02), size = 0.55 },
        },
        {
            name = 'bag', component = 5, angle = 180.0, pitch = 4.0, skip = { 0 },
            frame = { bones = { 24818 }, offset = vector3(0.0, 0.0, -0.1), size = 0.95 },
        },
    },
}

Config.furnishing = {
    settle = 150,       -- ms after the prop spawns, for its textures to stream
    camera = {
        angle = 215.0,  -- three-quarter front view; GTA furniture models face the other way to vehicles
        pitch = 18.0,
        fov = 15.0,
        fill = 0.82,
    },
    -- props that still show their back: model = angle, e.g. ['prop_bench_01a'] = 35.0
    angles = {},
    -- a small prop has a small texture; filling the frame with it only blurs it.
    -- It fills at most this many screen pixels per metre of its size.
    pixelsPerMetre = 1500,
}

Config.output = {
    quality = 80,
    lossless = false,
    maxSize = 1600,     -- longest edge; the image is cropped to the subject, smaller ones keep native pixels
    padding = 0,        -- percent of empty border
    sharpen = 30,
    glass = {
        enabled = true,     -- see-through windows get a smoked tint instead of a hole
        color = '#1c2229',
        opacity = 35,
    },
}

Config.capture = {
    timeout = 8000,
    uploadRate = 4000000,   -- bytes/sec for image uploads to the server
    preload = 3,            -- models streamed ahead during a run
    retries = 2,            -- a capture failing the quality checks is re-shot this many times
    edgeCut = 0.4,          -- faint anti-aliasing halo below this alpha is cut
    regionMargin = 0.08,    -- screen share read around the subject; room for antennas and rotor tips
    -- not pure black/white: no bloom, less exposure swing
    dark = { r = 30, g = 30, b = 30 },
    light = { r = 220, g = 220, b = 220 },
    -- ms after spawn, frames after a backdrop switch (TAA forgets the old
    -- colour), frames averaged per shot (cancels TAA jitter)
    speeds = {
        quality = { settle = 250, settleFrames = 4, averageFrames = 4 },
        balanced = { settle = 150, settleFrames = 3, averageFrames = 2 },
        fast = { settle = 60, settleFrames = 2, averageFrames = 1 },
    },
    defaultSpeed = 'balanced',
}
