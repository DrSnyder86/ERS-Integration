--COMMANDS


-- RegisterNetEvent('autoems:request', function()
--     ExecuteCommand('autoems')  -- runs the /autoems command
-- end)

RegisterNetEvent('custom:speedzone', function()
    ExecuteCommand('speedzones')
end)

RegisterNetEvent('custom:client:radarFrontLock', function()
    ExecuteCommand('radar_fr_cam')
end)

RegisterNetEvent('custom:client:useMDTTablet', function()
    ExecuteCommand('mdt')
end)

RegisterNetEvent('mdt:toggle', function()
    ExecuteCommand('mdt')  -- this runs the /mdt command
end)

RegisterNetEvent('tcs:toggle', function()
    ExecuteCommand('tsc')  -- executes the /tsc command
end)

RegisterNetEvent('callout:request', function()
    ExecuteCommand('requestcallout')  -- runs the /requestcallout command
end)

RegisterNetEvent('shift:toggle', function()
    ExecuteCommand('toggleshift')  -- runs the /toggleshift command
end)

RegisterNetEvent('callouts:toggle', function()
    ExecuteCommand('togglecallouts')  -- runs the /togglecallouts command
end)

RegisterNetEvent('multijob:toggle', function()
    ExecuteCommand('multijob')  -- runs the /multijob command
end)

RegisterNetEvent('escort:toggle', function()
    ExecuteCommand('escort')  -- runs the /escort command
end)

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

--------------------------------------
-- Basic client events for cancel requests
--------------------------------------
RegisterNetEvent('call:cancelambulance', function() ExecuteCommand('cancelambulance') end)
RegisterNetEvent('call:cancelfire', function() ExecuteCommand('cancelfire') end)
RegisterNetEvent('call:cancelpolice', function() ExecuteCommand('cancelpolice') end)
RegisterNetEvent('call:canceltaxi', function() ExecuteCommand('canceltaxi') end)
RegisterNetEvent('call:canceltow', function() ExecuteCommand('canceltow') end)
RegisterNetEvent('call:cancelmechanic', function() ExecuteCommand('cancelmechanic') end)
RegisterNetEvent('call:cancelcoroner', function() ExecuteCommand('cancelcoroner') end)
RegisterNetEvent('call:cancelanimalrescue', function() ExecuteCommand('cancelanimalrescue') end)
RegisterNetEvent('call:cancelroadservice', function() ExecuteCommand('cancelroadservice') end)





