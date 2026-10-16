local QBCore = exports['qb-core']:GetCoreObject()
local utils = require 'client.utils'

---@diagnostic disable-next-line: duplicate-set-field
function utils.hasPlayerGotGroup(filter)
    local PlayerData = QBCore.Functions.GetPlayerData()
    
    if not PlayerData then return false end
    
    -- Check if filter is a table (multiple groups) or string (single group)
    if type(filter) == "table" then
        for group, grade in pairs(filter) do
            -- Check job name or type
            if PlayerData.job and (PlayerData.job.name == group or PlayerData.job.type == group) then
                if grade == 0 or PlayerData.job.grade.level >= grade then
                    return true
                end
            end
            -- Check gang
            if PlayerData.gang and PlayerData.gang.name == group then
                if grade == 0 or PlayerData.gang.grade.level >= grade then
                    return true
                end
            end
        end
        return false
    else
        -- Single group check (string)
        return (PlayerData.job and (PlayerData.job.name == filter or PlayerData.job.type == filter)) or
               (PlayerData.gang and PlayerData.gang.name == filter)
    end
end