function DebugPrint(...)
    if not Config.debug then return end

    local msg = {}
    for _, v in ipairs({ ... }) do
        msg[#msg + 1] = tostring(v)
    end

    print('^6[METEO IMAGESTUDIO]^0 ' .. table.concat(msg, ', '))
end

-- showcase servers: browse only, no captures
function SafeMode()
    return GetConvar('meteo:safemode', 'false') == 'true'
end

function Float(v)
    return (tonumber(v) or 0) + 0.0
end
