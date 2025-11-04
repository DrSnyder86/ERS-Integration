local QBCore = exports['qb-core']:GetCoreObject()


--------------------------------------
-- Callout Offered
--------------------------------------
-- RegisterNetEvent('ErsIntegration::OnIsOfferedCallout', function(calloutData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end
--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local label = calloutData.label or "911 Call"

--     TriggerEvent('ps-dispatch:server:notify', {
--         code = '10-20',
--         title = "911 Call",
--         message = ("%s was offered a callout: %s"):format(Player.PlayerData.charinfo.firstname, label),
--         coords = coords,
--         jobs = { 'police', 'sheriff' }
--     })
-- end)

--------------------------------------
-- Callout Accepted
--------------------------------------
RegisterNetEvent('ErsIntegration::OnAcceptedCalloutOffer', function(calloutData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local label = calloutData.label or "911 Call"

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(10000)

    TriggerEvent('ps-dispatch:server:notify', {
        code = '10-97',
        title = "On Scene",
        message = ("%s is Responding %s"):format(Player.PlayerData.charinfo.firstname, label),
        coords = coords,
        jobs = { 'police', 'sheriff' }
    })

    -- Client: clear persistent call
    -- TriggerClientEvent('ps-dispatch:client:enroute', src, '10-97')
    
end)

--------------------------------------
-- Callout Arrived
--------------------------------------
RegisterNetEvent('ErsIntegration::OnArrivedAtCallout', function(calloutData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local label = calloutData.label or "911 Call"

    -- TriggerEvent('ps-dispatch:server:notify', {
    --     code = '10-23',
    --     title = "On Scene",
    --     message = ("%s is on scene: %s"):format(Player.PlayerData.charinfo.firstname, label),
    --     coords = coords,
    --     jobs = { 'police', 'sheriff' }
    -- })

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(10000)

    -- Client: clear persistent call
    TriggerClientEvent('ps-dispatch:client:onscene', src, '10-23')


end)



-- ------------------------------------
-- Callout Completed before
-- ------------------------------------
-- RegisterNetEvent('ErsIntegration::OnEndedACallout', function(calloutData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end
--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local label = calloutData.label or "911 Call"
--     local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
--     local citizenid = Player.PlayerData.citizenid

--     -- Add delay before dispatch (5000 = 5 seconds)
--     Citizen.Wait(10000)

--     --Dispatch Notification (Code 4)
--     TriggerEvent('ps-dispatch:server:notify', {
--         code = '10-98',
--         title = "Code-4",
--         message = ("%s Scene is Code 4."):format(name, label),
--         coords = coords,
--         jobs = { 'police', 'sheriff' }
--     })

-- end)

--------------------------------------
-- Callout Completed Succesfully
--------------------------------------
RegisterNetEvent('ErsIntegration::OnCalloutCompletedSuccesfully', function(calloutData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local label = calloutData.label or "911 Call"
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local citizenid = Player.PlayerData.citizenid

    -- Dispatch Notification (Code 4)
    -- TriggerEvent('ps-dispatch:server:notify', {
    --     code = '10-98',
    --     title = "Code-4",
    --     message = ("%s completed duties: %s. Scene is Code 4."):format(name, label),
    --     coords = coords,
    --     jobs = { 'police', 'sheriff' }
    -- })

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(10000)

    -- Client: clear persistent call
    TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')


    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(10000)

    -- Reward the player via QBox or economy
    Player.Functions.AddMoney('bank', 5000, 'callout-complete')

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'BONUS PAY!',
        description = 'You received a $5000 bonus for clearing the scene.',
        type = 'success',
        duration = 8000
    })

end)

--------------------------------------
-- Pullover
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPullover', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local coords = GetEntityCoords(GetPlayerPed(src))
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local plate = vehicleData and vehicleData.plate or "Unknown"

    -- TriggerEvent('ps-dispatch:server:notify', {
    --     code = '10-11',
    --     title = "Traffic Stop",
    --     message = ("%s is on a traffic stop [%s]."):format(name, plate),
    --     coords = coords,
    --     jobs = { 'police', 'sheriff' }
    -- })

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(10000)

    TriggerClientEvent('ps-dispatch:client:trafficstop', src, '10-97')

end)

--pullover conclude

RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local plate = vehicleData and vehicleData.plate or "Traffic/Pursuit"

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(8000)

    TriggerEvent('ps-dispatch:server:notify', {
        code = 'Code-4',
        title = "code4",
        message = ("%s is Code-4 [%s]."):format(name, plate),
        coords = coords,
        jobs = { 'police', 'sheriff' }
    })

    -- TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')

end)


--pursuit start

RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local plate = vehicleData and vehicleData.plate or "911 Call"

    -- Add delay before dispatch (5000 = 5 seconds)
    Citizen.Wait(8000)

    TriggerEvent('ps-dispatch:server:notify', {
        code = '10-99',
        title = "Pursuit",
        message = ("%s is in pursuit [%s]."):format(name, plate),
        coords = coords,
        jobs = { 'police', 'sheriff' }
    })

    -- TriggerClientEvent('ps-dispatch:client:officerbackup', src, '10-99')

end)

--pursuit conclude

-- RegisterNetEvent('ErsIntegration::OnPursuitEnded', function(pedData, vehicleData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
--     local plate = vehicleData and vehicleData.plate or "911"

    -- TriggerEvent('ps-dispatch:server:notify', {
    --     code = 'Code-4',
    --     title = "Code-4",
    --     message = ("%s is Code-4 from pursuit [%s]."):format(name, plate),
    --     coords = coords,
    --     jobs = { 'police', 'sheriff' }
    -- })

--     TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')

-- end)

