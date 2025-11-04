--toggle mdt
RegisterNetEvent('custom:client:useMDTTablet', function()
    ExecuteCommand('mdt')
end)

RegisterNetEvent('mdt:toggle', function()
    ExecuteCommand('mdt')
end)

RegisterNetEvent('tcs:toggle', function()
    ExecuteCommand('tsc')
end)

RegisterNetEvent('callout:request', function()
    ExecuteCommand('requestcallout')
end)

RegisterNetEvent('shift:toggle', function()
    ExecuteCommand('toggleshift')
end)

RegisterNetEvent('callouts:toggle', function()
    ExecuteCommand('togglecallouts')
end)

RegisterNetEvent('multijob:toggle', function()
    ExecuteCommand('multijob')
end)

RegisterNetEvent('escort:toggle', function()
    ExecuteCommand('escort')
end)

--requests
RegisterNetEvent('call:coroner', function()
    ExecuteCommand('requestcoroner')
end)

RegisterNetEvent('call:mechanic', function()
    ExecuteCommand('requestmechanic')
end)

RegisterNetEvent('call:tow', function()
    ExecuteCommand('requesttow')
end)

RegisterNetEvent('call:taxi', function()
    ExecuteCommand('requesttaxi')
end)

RegisterNetEvent('call:police', function()
    ExecuteCommand('requestpolice')
end)

RegisterNetEvent('call:animalrescue', function()
    ExecuteCommand('requestanimalrescue')
end)

RegisterNetEvent('call:ambulance', function()
    ExecuteCommand('requestambulance')
end)

RegisterNetEvent('call:roadservice', function()
    ExecuteCommand('requestroadservice')
end)

RegisterNetEvent('custom:requestfire', function()
    ExecuteCommand('requestfire')
end)

--cancel
RegisterNetEvent('call:cancelambulance', function()
    ExecuteCommand('cancelambulance')
end)

RegisterNetEvent('call:cancelfire', function()
    ExecuteCommand('cancelfire')
end)

RegisterNetEvent('call:cancelpolice', function()
    ExecuteCommand('cancelpolice')
end)

RegisterNetEvent('call:canceltaxi', function()
    ExecuteCommand('canceltaxi')
end)

RegisterNetEvent('call:canceltow', function()
    ExecuteCommand('canceltow')
end)

RegisterNetEvent('call:cancelmechanic', function()
    ExecuteCommand('cancelmechanic')
end)

RegisterNetEvent('call:cancelcoroner', function()
    ExecuteCommand('cancelcoroner')
end)

RegisterNetEvent('call:cancelanimalrescue', function()
    ExecuteCommand('cancelanimalrescue')
end)

RegisterNetEvent('call:cancelroadservice', function()
    ExecuteCommand('cancelroadservice')
end)




RegisterNetEvent('wk:client:TogglePlateReader', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Wraith Radar',
            description = 'You must be in a vehicle.',
            type = 'error'
        })
        return
    end

    TriggerEvent('wk:togglePlateReader')
    lib.notify({
        title = 'Wraith Radar',
        description = 'Toggled Plate Reader',
        type = 'inform'
    })
end)

RegisterNetEvent('wk:client:ToggleRadarDisplay', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Wraith Radar',
            description = 'You must be in a vehicle.',
            type = 'error'
        })
        return
    end

    TriggerEvent('wk:toggleRadar')
    lib.notify({
        title = 'Wraith Radar',
        description = 'Toggled Radar Display',
        type = 'inform'
    })
end)

