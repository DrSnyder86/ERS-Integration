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

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(10000) -- 10 seconds delay

        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-97',
            codeName = 'enroute',
            title = "En-Route",
            icon = 'fas fa-car',
            priority = 2,
            message = ("911 Dispatch"),
            alertTime = 10,
            information = ("%s-%s is responding to the latest 911 Call."):format(lastName, callsign),
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            coords = coords,
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

    CreateThread(function()
        Wait(10000) 

        TriggerClientEvent('ps-dispatch:client:onscene', src, '10-23')
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

    local label = calloutData.label or "911 Call"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()

        Wait(6000)
        TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')

        Wait(10000)
        Player.Functions.AddMoney('bank', 5000, 'callout-complete')

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'BONUS PAY!',
            description = ('%s (%s) cleared the callout: %s. You received a $5000 bonus.'):format(lastName, callsign, label),
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

    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.plate or "Unknown"

    TriggerClientEvent('custom:client:radarFrontLock', src)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Radar Plate Lock',
        description = ('%s (%s) locked plate [%s]'):format(lastName, callsign, plate),
        type = 'inform'
    })

    CreateThread(function()
        Wait(10000)
        TriggerClientEvent('ps-dispatch:client:trafficstop', src, '10-97')
    end)
end)

--------------------------------------
-- Pullover Conclude
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))


    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.plate or "Traffic"

    CreateThread(function()
        Wait(8000)

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Code-4',
            codeName = 'codefour',
            title = "Code 4",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'leo', 'ems' },
            information = ("%s (%s). Code-4 from my last %s."):format(lastName, callsign, plate),

        })
    end)
end)

--------------------------------------
-- Pursuit Start
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData, vehicleData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))


    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.plate or "Traffic"

    CreateThread(function()
        Wait(8000)

        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-80',
            codeName = 'trafficstop',
            title = "Pursuit",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            priority = 1,
            alertTime = 15,
            jobs = {  'leo', 'ems' },
            information = ("%s-%s Show me in a %s."):format(lastName, callsign, plate),

        })
    end)
end)

--------------------------------------
-- Pursuit Conclude
--------------------------------------
-- RegisterNetEvent('ErsIntegration::OnPursuitEnded', function(pedData, vehicleData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"
--     local plate = vehicleData and vehicleData.plate or "Unknown"

--     -- Run asynchronously with short delay
--     CreateThread(function()
--         Wait(8000) -- 8 seconds

--         TriggerEvent('ps-dispatch:server:notify', {
--             code = 'Code-4',
--             title = "Code 4",
--             message = ("%s (%s) is Code 4 from pursuit [%s]."):format(lastName, callsign, plate),
--             coords = coords,
--             jobs = { 'police', 'sheriff' }
--         })

--         -- Optionally trigger local client event if you want blip removal or cleanup
--         -- TriggerClientEvent('ps-dispatch:client:codefour', src, 'Code-4')
--     end)
-- end)

--------------------------------------------------------------------------------------------------
-- Request EVENTS
--------------------------------------------------------------------------------------------------
RegisterNetEvent('ErsIntegration:server:OnCoronerRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000) 

        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-72', 
            codeName = 'dispatch',
            title = "Coroner Request",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            alertTime = 10,
            priority = 1,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised local Coroner is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
            coords = coords,
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnMechanicRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-51',
            codeName = 'dispatch',
            title = "Mechanic Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Auto Mechanic is confirmed 10-97 to your location nearest Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnTowRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-51',
            codeName = 'dispatch',
            title = "Tow Truck Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Tow Truck Service is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnTaxiRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-62',
            codeName = 'dispatch',
            title = "Taxi Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Taxi Service has been dispatched and is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnPoliceRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-32',
            codeName = 'dispatch',
            title = "Police Transport Arriving",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Police Transport has been dispatched and is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAnimalRescueRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-11B',
            codeName = 'dispatch',
            title = "Animal Rescue Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Animal Control Supervisor has been dispatched and is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAmbulanceRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-52',
            codeName = 'dispatch',
            title = "Ambulance Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            priority = 1,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Paramedic has been dispatched and is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnFireRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000)
        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-53',
            codeName = 'dispatch',
            title = "Fire Department Responding",
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised Fire Rescue has been dispatched and is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnRoadServiceRequested', function(postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(8000) 

        TriggerEvent('ps-dispatch:server:notify', {
            code = '10-60', 
            codeName = 'dispatch',
            title = 'Road Service Responding',
            icon = 'fas fa-car',
            message = ("911 Dispatch"),
            coords = coords,
            alertTime = 10,
            jobs = { 'mechanic', 'tow', 'police', 'ems' },
            information = ("Dispatch to %s (%s). Be advised a Road Service Crew is confirmed 10-97 to your location nearest Postal %s."):format(lastName, callsign, postal or 'Unknown'),
        })
    end)
end)

