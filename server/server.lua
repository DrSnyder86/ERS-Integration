local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}

-- ===========================================
-- TARGET DUTY Toggle 
-- ===========================================
local function toggleShift(src, shiftType, displayName)
    local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
    local activeType = exports['night_ers']:getPlayerActiveServiceType(src)

    if isOnShift and activeType == shiftType then
        -- End the shift
        exports['night_ers']:toggleShift(src, shiftType)
        TriggerClientEvent('QBCore:Notify', src, displayName .. " duty ended!", "success")
        return
    end

    exports['night_ers']:toggleShift(src, shiftType)
    TriggerClientEvent('QBCore:Notify', src, displayName .. " duty started!", "success")
end

-- ===========================================
-- RADIAL DUTY TOGGLE
-- ===========================================
RegisterNetEvent('ers:server:TogglePoliceShift', function()
    local src = source
    local shiftType = "police"  

    exports['night_ers']:toggleShift(src, shiftType)
end)

RegisterNetEvent('ers:server:ToggleAmbulanceShift', function()
    local src = source
    local shiftType = "ambulance"  

    exports['night_ers']:toggleShift(src, shiftType)
end)

RegisterNetEvent('ers:server:ToggleFireShift', function()
    local src = source
    local shiftType = "fire"  

    exports['night_ers']:toggleShift(src, shiftType)
end)

RegisterNetEvent('ers:server:ToggleTowShift', function()
    local src = source
    local shiftType = "tow"  

    exports['night_ers']:toggleShift(src, shiftType)
end)

---------------------------
-- Plate check
---------------------------
RegisterServerEvent("ErsIntegration::OnFirstVehicleInteraction")
AddEventHandler("ErsIntegration::OnFirstVehicleInteraction", function(src, vehicleData, context)

    -- Only run for traffic stop (pullover)
    if context ~= "on_pullover" then return end

    if not Config.ShowPlateInChat then return end

    CreateThread(function()
        Wait(5000)
        local info = ("Vehicle Check:\n" ..
            "Owner: %s\n" ..
            "Plate: %s\n" ..
            "Vehicle %s %s\n" ..
            "Insurance: %s\n" ..
            "Stolen: %s\n" ..
            "BOLO: %s"
        ):format(
            vehicleData.owner_name or "N/A",
            vehicleData.license_plate or "N/A",
            vehicleData.make or "N/A",
            vehicleData.model or "N/A",
            vehicleData.insurance and "true" or "false",
            vehicleData.stolen and "true" or "false",
            vehicleData.bolo and "true" or "false"
        )

        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
    end)
end)
------------------------
-- ID Check
------------------------
RegisterServerEvent("ErsIntegration::OnFirstNPCInteraction")
AddEventHandler("ErsIntegration::OnFirstNPCInteraction", function(src, pedData, context)

    --if context ~= "on_interaction" then return end

    if not Config.ShowLicenseInChat then return end

    CreateThread(function()
        Wait(5000)
        local info = ("ID CHECK:\n" ..
            "Name: %s %s\n" ..
            --"Last Name: %s\n" ..
            "DOB: %s\n" ..
            "Address: %s\n" ..
            "%s, %s %s\n" ..
            --"State: %s\n" ..
            --"Postal Code: %s\n" ..
            "Active Warrant: %s"
        ):format(
            pedData.FirstName or "N/A",
            pedData.LastName or "N/A",
            pedData.DOB or "N/A",
            pedData.Address or "N/A",
            pedData.City or "N/A",
            pedData.State or "N/A",
            pedData.PostalCode or "N/A",
            pedData.Wanted_Person and "true" or "false"
        )

        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
    end)
end)
--------------------------------------
-- Callout Offered
--------------------------------------
RegisterNetEvent('ErsIntegration::OnIsOfferedCallout', function(calloutData)
    if not Config.EnableCalloutOffer then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local infoOptions = {
    ("%s"):format(calloutData.Description or "Unknown"),
    ("%s"):format(calloutData.Description or "Unknown"),
    ("%s"):format(calloutData.Description or "Unknown")
}

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        Wait(Config.WaitTimes.CalloutOffer)

        TriggerEvent('ps-dispatch:server:notify', {
            code = '911',
            codeName = 'enroute',
            title = "EnRoute",
            icon = 'fas fa-phone',
            priority = 2,
            message = ("%s"):format(calloutData.CalloutName or "Unknown"),
            alertTime = 10,
            street = ("%s %s"):format(calloutData.Postal or "Unknown", calloutData.StreetName or "Unknown"),
            name = ("%s %s"):format(calloutData.FirstName or "Unknown", calloutData.LastName or "Unknown"),
            information = randomInfo,
            jobs = Config.Dispatch.CallOffer,
            coords = coords,
        })

        local info = ("INCOMING 911 CALL:\n" ..
            "Caller: %s %s\n" ..
            "Call: %s\n" ..
            "%s %s\n" ..
            "Report: %s"
        ):format(
            calloutData.FirstName or "Unknown",
            calloutData.LastName or "Unknown",
            calloutData.CalloutName or "Unknown",
            calloutData.Postal or "Unknown", 
            calloutData.StreetName or "Unknown",                    
            calloutData.Description or "Unknown"
        )

        -- Print to server console for debugging
        --print("911 Call\n" .. info)
        --Wait(2000)
        -- Send to player chat
        if Config.Show911CallInChat then
        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end
    end)
end)

--------------------------------------
-- Callout Accepted
--------------------------------------
RegisterNetEvent('ErsIntegration::OnAcceptedCalloutOffer', function(calloutData)
    if not Config.EnableCalloutAccept then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.plate or "Traffic"
    local job = Player.PlayerData.job.name or "N/A"
    local units = calloutData.CalloutUnitsRequired.description or "N/A"

    local infoOptions = {
    ("(Caller: %s %s) %s Requesting %s"):format(calloutData.FirstName or "Unknown", calloutData.LastName or "Unknown", calloutData.Description or "Unknown", units),
    ("(Caller: %s %s) %s Requesting %s"):format(calloutData.FirstName or "Unknown", calloutData.LastName or "Unknown", calloutData.Description or "Unknown", units),
    ("(Caller: %s %s) %s Requesting %s"):format(calloutData.FirstName or "Unknown", calloutData.LastName or "Unknown", calloutData.Description or "Unknown", units)
}

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        Wait(Config.WaitTimes.CalloutAccepted)

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'enroute',
            title = "EnRoute",
            icon = 'fas fa-phone',
            priority = 2,
            message = ("%s"):format(calloutData.CalloutName or "Unknown"),
            alertTime = 10,
            street = ("%s %s"):format(calloutData.Postal or "Unknown", calloutData.StreetName or "Unknown"),
            name = ("%s %s (%s) (%s)"):format(
                firstName,
                lastName,
                callsign,
                job),
            information = randomInfo,
            jobs = Config.Dispatch.CallAccept,
            coords = coords,
        })

        local info = ("911 CALL:\n" ..
            "Caller: %s %s\n" ..
            "Call: %s\n" ..
            "%s %s\n" ..
            "Report: %s"
        ):format(
            calloutData.FirstName or "Unknown",
            calloutData.LastName or "Unknown",
            calloutData.CalloutName or "Unknown",
            calloutData.Postal or "Unknown", 
            calloutData.StreetName or "Unknown",                    
            calloutData.Description or "Unknown"
        )

        -- Print to server console for debugging
        --print("911 Call\n" .. info)
        Wait(2000)
        -- Send to player chat
        if Config.ShowCalloutInChat then
        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end
    end)
end)




--------------------------------------
-- Callout Arrived
--------------------------------------
RegisterNetEvent('ErsIntegration::OnArrivedAtCallout', function(calloutData)
    if not Config.EnableCalloutArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    --local plate = vehicleData and vehicleData.plate or "Traffic"

    local infoOptions = {
    ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown", calloutData.Description or "Unknown"),
    ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown", calloutData.Description or "Unknown"),
    ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown", calloutData.Description or "Unknown")
}

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        Wait(Config.WaitTimes.CalloutArrived) 

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'onscene',
            title = "OnsScene",
            icon = 'fas fa-map-marker-alt',
            priority = 2,
            message = ("%s (%s) On-Scene"):format(     
                lastName,
                callsign),
            alertTime = 10,
            street = ("%s %s"):format(calloutData.Postal or "Unknown", calloutData.StreetName or "Unknown"),
            --name = ("%s %s"):format(calloutData.FirstName or "Unknown", calloutData.LastName or "Unknown"),
            name = ("%s %s (%s)"):format(
                firstName,
                lastName,
                callsign),
            information = randomInfo,
            jobs = Config.Dispatch.CallArrive,
            coords = coords,
        })
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
    if not Config.EnableCalloutComplete then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    --local plate = vehicleData and vehicleData.plate or "Traffic"

    local infoOptions = {
    ("%s (%s) Code-4 from my last Call %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown"),
    ("%s (%s) Code-4 from my last Call %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown"),
    ("%s (%s) Code-4 from my last Call %s"):format(lastName, callsign, calloutData.CalloutName or "Unknown")
}

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()

        Wait(Config.WaitTimes.CalloutCompleted)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'codefour',
            title = "CodeFour",
            icon = 'fas fa-clock',
            priority = 2,
            message = ("%s (%s) Code-4"):format(     
                lastName,
                callsign),
            alertTime = 10,
            street = ("%s %s"):format(calloutData.Postal or "Unknown", calloutData.StreetName or "Unknown"),
            name = ("%s %s (%s)"):format(
                firstName,
                lastName,
                callsign),
            information = randomInfo,
            jobs = Config.Dispatch.CallComplete,
            coords = coords,
        })

        Wait(5000)
        Player.Functions.AddMoney('bank', Config.BonusPay, 'callout-complete')

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'BONUS PAY!',
            description = ('%s (%s) cleared the callout: %s. You received a bonus.'):format(
                lastName, 
                callsign, 
                calloutData.CalloutName or "Unknown"),
            type = 'success',
            duration = 8000
        })
    end)
end)

--------------------------------------
-- Pullover
--------------------------------------

RegisterNetEvent('ErsIntegration::OnPullover', function(pedData, vehicleData)
    if not Config.EnablePulloverNotifications then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.license_plate or "Traffic"

    if Config.EnableRadarLock then
        TriggerClientEvent('ersi:client:radarFrontLock', src)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'ALPR LOCK',
            description = ('%s (%s) locked plate [ %s ]'):format(lastName, callsign, vehicleData.license_plate or "Unknown"),
            type = 'inform',
            duration = 4000
        })
    end
    
    CreateThread(function()
        Wait(Config.WaitTimes.PulloverNotify)

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'trafficstop',
            title = "TrafficStop",
            icon = 'fas fa-car-side',
            priority = 2,
            message = ("%s (%s) Traffic"):format(     
                lastName,
                callsign),
            name = ("%s %s (%s)"):format(
                firstName,
                lastName,
                callsign),
            coords = coords,
            alertTime = 10,
            vehicle = ("%s"):format(vehicleData.model or "N/A"),
            plate = ("%s"):format(vehicleData.license_plate or "N/A"),
            color = ("%s"):format(vehicleData.color or "N/A"),
            jobs = Config.Dispatch.TrafficStop,
            information = ("%s (%s). Show me on a traffic stop. (PLATE: %s) (Vehicle: %s %s) (Reg. Owner: %s) (ID: %s %s)"):format(
                lastName, 
                callsign, 
                vehicleData.license_plate or "N/A",
                vehicleData.make or "N/A",
                vehicleData.model or "N/A",
                vehicleData.owner_name or "N/A",                
                pedData.FirstName or "N/A",
                pedData.LastName or "N/A"),
        })
        -- Wait(2000)

        -- local info = ("VEHICLE CHECK:\n" ..
        --     "Owner: %s\n" ..
        --     "Plate: %s\n" ..
        --     "Make: %s\n" ..
        --     "Model: %s\n" ..
        --     "Stolen: %s\n" ..
        --     "Insurance: %s\n" ..
        --     "BOLO: %s"
        -- ):format(
        --     vehicleData.owner_name or "Unknown",
        --     vehicleData.license_plate or "Unknown",
        --     vehicleData.make or "Unknown",
        --     vehicleData.model or "Unknown",
        --     vehicleData.stolen and "true" or "false",
        --     vehicleData.insurance and "true" or "false",
        --     vehicleData.bolo and "true" or "false"
        -- )
    end)
end)

--------------------------------------
-- Pullover Conclude
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    if not Config.EnablePulloverNotifications then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.license_plate or "Traffic"

    CreateThread(function()
        Wait(Config.WaitTimes.PulloverEnd)

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'codefour',
            title = "Code4",
            icon = 'fas fa-car-side',
            priority = 2,
            message = ("%s (%s) Code-4"):format(     
                lastName,
                callsign),
            name = ("%s %s (%s)"):format(
                firstName,
                lastName,
                callsign),
            coords = coords,
            alertTime = 10,
            vehicle = ("%s"):format(vehicleData.model or "N/A"),
            plate = ("%s"):format(vehicleData.license_plate or "N/A"),
            color = ("%s"):format(vehicleData.color or "N/A"),
            jobs = Config.Dispatch.TrafficStop,
            information = ("%s (%s). Code-4 from my last Traffic: (PLATE: %s) (Reg. Owner: %s) (Vehicle: %s %s) (ID: %s %s)"):format(
                lastName, 
                callsign, 
                vehicleData.license_plate or "N/A",
                vehicleData.owner_name or "N/A",
                vehicleData.make or "N/A",
                vehicleData.model or "N/A",
                pedData.FirstName or "N/A",
                pedData.LastName or "N/A"),

        })
    end)
end)

--------------------------------------
-- Pursuit Start
--------------------------------------
RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData, vehicleData)
    if not Config.EnablePursuitNotifications then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local plate = vehicleData and vehicleData.license_plate or "Active Pursuit"

    CreateThread(function()
        Wait(Config.WaitTimes.PursuitStart)

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'codefour',
            title = "Pursuit",
            icon = 'fas fa-car',
            priority = 2,
            message = ("%s (%s) Pursuit"):format(     
                lastName,
                callsign),
            name = ("%s %s (%s)"):format(
                firstName,
                lastName,
                callsign),
            coords = coords,
            alertTime = 10,
            jobs = Config.Dispatch.TrafficStop,
            information = ("%s (%s). Show me in a Active Pursuit: (PLATE: %s) (Registered Owner: %s) (Vehicle: %s %s)"):format(
                lastName, 
                callsign, 
                vehicleData.license_plate or "Unknown",
                vehicleData.owner_name or "Unknown",
                vehicleData.make or "Unknown",
                vehicleData.model or "Unknown"),

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
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents) 

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch', 
            codeName = 'dispatch',
            title = "Coroner",
            icon = 'fas fa-skull-crossbones',
            message = ("Coroner On Scene %s"):format(
                postal),
            name = ("Coroner Service"),
            coords = coords,
            alertTime = 10,
            priority = 1,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised local Coroner is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),          
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnMechanicRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "MechanicResponding",
            icon = 'fas fa-tools',
            message = ("Roadside Assistance On Scene %s"):format(
                postal),
            name = ("Mechanic Service"),
            coords = coords,
            alertTime = 10,
            priority = 2,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Auto Mechanic is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnTowRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    -- local coords = GetEntityCoords(GetPlayerPed(src))


    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "TowTruck",
            icon = 'fas fa-truck-pickup',
            message = ("Tow Service On Scene %s"):format(
                postal),
            name = ("Towing Service"),
            coords = coords,
            priority = 2,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Tow Truck Service is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnTaxiRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "TaxiResponding",
            icon = 'fa-solid fa-taxi',
            message = ("Taxi Service On Scene %s"):format(
                postal),
            name = ("Taxi Service"),
            coords = coords,
            priority = 2,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Taxi Service has been dispatched and is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnPoliceRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "PoliceTransport",
            icon = 'fa-solid fa-car-on',
            message = ("PD Transport On Scene %s"):format(
                postal),
            name = ("Police Transport"),
            coords = coords,
            priority = 2,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Police Transport Officer has been dispatched and is confirmed 10-97 to your location  Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAnimalRescueRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "AnimalRescue",
            icon = 'fa-solid fa-paw',
            message = ("Animal Control On Scene %s"):format(
                postal),
            name = ("Animal Rescue"),
            coords = coords,
            priority = 2,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Animal Control Supervisor has been dispatched and is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAmbulanceRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "Ambulance",
            icon = 'fas fa-ambulance',
            message = ("Paramedic Arriving %s"):format(
                postal),
            name = ("Ambulance Service"),
            coords = coords,
            priority = 1,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Paramedic has been dispatched and is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnFireRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents)
        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch',
            codeName = 'dispatch',
            title = "FireRescue",
            icon = 'fas fa-fire-flame-curved',
            message = ("Fire Rescue On Scene %s"):format(
                postal),
            name = ("Fire Rescue"),
            coords = coords,
            priority = 1,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised Fire Rescue has been dispatched and is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnRoadServiceRequested', function(postal)
    if not Config.EnableServiceRequest then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.RequestEvents) 

        TriggerEvent('ps-dispatch:server:notify', {
            code = 'Dispatch', 
            codeName = 'dispatch',
            title = 'RoadService',
            icon = 'fas fa-triangle-exclamation',
            message = ("Road Service On Scene %s"):format(
                postal),
            name = ("Road Service Crew"),
            coords = coords,
            priority = 2,
            alertTime = 10,
            jobs = Config.Dispatch.ServiceRequest,
            information = ("Dispatch to %s (%s). Be advised a Road Service Crew is confirmed 10-97 to your location Postal %s."):format(
                lastName, 
                callsign, 
                postal or 'Unknown'),
        })
    end)
end)


