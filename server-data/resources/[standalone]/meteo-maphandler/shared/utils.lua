StateKey = 'meteoMapHandler'

-- Lift and door states
---@param mapId string
---@return string
function MoverKey(mapId)
    return StateKey .. ':' .. mapId
end

function DebugPrint(...)
    if not Config.debug then return end

    local msg = {}
    for _, v in ipairs({ ... }) do
        msg[#msg + 1] = tostring(v)
    end

    print('^6[METEO MAPHANDLER]^0 ' .. table.concat(msg, ', '))
end

function Warn(message)
    print('^3[METEO MAPHANDLER] ' .. message .. '^0')
end

function GetTarget()
    if Config.target == 'ox_target' or Config.target == 'qb-target' then return Config.target end
    if GetResourceState('ox_target') == 'started' then return 'ox_target' end
    if GetResourceState('qb-target') == 'started' then return 'qb-target' end
    return nil
end

-- Matches job name or type
---@param job table?
---@param jobs string[]?
---@return boolean
function HasJob(job, jobs)
    if not jobs or #jobs == 0 then return true end
    if not job then return false end
    for _, allowed in ipairs(jobs) do
        if job.name == allowed or job.type == allowed then return true end
    end
    return false
end
