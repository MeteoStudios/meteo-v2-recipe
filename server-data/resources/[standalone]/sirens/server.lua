-- Validates client siren/horn/light writes (sv_stateBagStrictMode is on).
local function isDriverOf(payload)
    local entity = payload.entityId
    if entity == 0 then return false end

    local ped = GetPlayerPed(payload.playerId)
    if ped ~= 0 and GetVehiclePedIsIn(ped, false) == entity then
        return true
    end

    if (not payload.value or payload.value == 0) and GetPedInVehicleSeat(entity, -1) == 0 then
        return true
    end

    return false
end

for _, key in ipairs({ 'sirenMode', 'horn', 'lightsOn' }) do
    lib.registerHook('ox_lib:setEntityState', isDriverOf, { key = key })
end

RegisterNetEvent('Renewed-Sirensync:server:SyncState', function(vehNet)
    local veh = NetworkGetEntityFromNetworkId(vehNet)

    if veh == 0 or not DoesEntityExist(veh) then return end

    local state = Entity(veh).state

	if state.stateEnsured then  return end

	state:set('stateEnsured', true, true)
	state:set('sirenMode', 0, true)
	state:set('horn', false, true)
	state:set('lightsOn', false, true)
end)