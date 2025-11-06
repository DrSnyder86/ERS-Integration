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

    local label = calloutData.label or "911 Call"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    -- Run dispatch after a short delay without blocking the main event
    CreateThread(function()
        Wait(10000) -- 10 seconds

        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-97',
            title = "En-Route",
            message = ("%s (%s) is Responding %s"):format(lastName, callsign, label),
            jobs = { 'police', 'sheriff' }
        })
    end)
end)


--------------------------------------
-- Callout Arrived
--------------------------------------
RegisterNetEvent('ErsIntegration::OnArrivedAtCallout', function(calloutData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local label = calloutData.label or "911 Call"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    -- Run after a short delay without blocking the event
    CreateThread(function()
        Wait(10000) -- 10 seconds

        -- ps-dispatch handles the details internally
        TriggerClientEvent('ps-dispatch:client:onscene', src, '10-23')

        -- Optional custom log or message (if you want server-side confirmation)
        -- print(("%s (%s) arrived on scene for %s"):format(lastName, callsign, label))
    end)
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
-- Callout Completed
--------------------------------------
RegisterNetEvent('ErsIntegration::OnCalloutCompletedSuccesfully', function(calloutData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local charInfo = Player.PlayerData.charinfo
    local name = ("%s %s"):format(charInfo.firstname, charInfo.lastname)
    local label = calloutData.label or "911 Call"

    -- Run in a separate thread to avoid blocking
    Citizen.CreateThread(function()
        -- Delay before clearing the dispatch
        Wait(10000)
        TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')

        -- Delay before rewarding the player
        Wait(10000)
        Player.Functions.AddMoney('bank', 5000, 'callout-complete')

        -- Notify the player via ox_lib
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'BONUS PAY!',
            description = 'You received a $5000 bonus for clearing the scene.',
            type = 'success',
            duration = 8000
        })
    end)
end)

--------------------------------------
-- Pullover
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPullover', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local charInfo = Player.PlayerData.charinfo
    local name = ("%s %s"):format(charInfo.firstname, charInfo.lastname)
    local plate = vehicleData and vehicleData.plate or "Unknown"

    -- Lock the front radar
    TriggerClientEvent('custom:client:radarFrontLock', src)

    -- OX_Lib notification
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Radar Plate Lock',
        description = ('Plate lock engaged on vehicle [%s]'):format(plate),
        type = 'inform'
    })

    -- Spawn a thread for delayed dispatch update
    Citizen.CreateThread(function()
        Wait(10000) -- 10 seconds delay
        TriggerClientEvent('ps-dispatch:client:trafficstop', src, '10-97')
    end)
end)

--pullover conclude

RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
    local plate = vehicleData and vehicleData.plate or "Traffic"

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

