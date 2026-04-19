local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}

local vehicleCache = {}
local pedCache = {}
-- Crosshair
local on = true

RegisterCommand('global_ctoggle', function()

	if on then
		on = false
	elseif not on then
		on = true
	end
	TriggerClientEvent('cl:update_c', -1, on)
end)

-- ===========================================
-- Save Steering Angle 
-- ===========================================
-- RegisterNetEvent("savedSteering:syncAngle", function(netId, angle)
--     local vehicle = NetworkGetEntityFromNetworkId(netId)
--     if vehicle and DoesEntityExist(vehicle) then
--         Entity(vehicle).state:set("savedSteeringAngle", angle, true)
--     end
-- end)

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

-- Target plate check
-- lib.callback.register('police:server:vinCheck', function(source, plate)

--     local result = MySQL.single.await(
--         'SELECT citizenid, plate, vehicle FROM player_vehicles WHERE plate = ?',
--         {plate}
--     )

--     if not result then return nil end

--     local player = MySQL.single.await(
--         'SELECT charinfo FROM players WHERE citizenid = ?',
--         {result.citizenid}
--     )

--     local owner = "Unknown"

--     if player then
--         local charinfo = json.decode(player.charinfo)
--         owner = charinfo.firstname .. " " .. charinfo.lastname
--     end

--     return {
--         owner = owner,
--         plate = result.plate,
--         vehicle = result.vehicle
--     }

-- end)
-- RegisterNetEvent('ersi:server:getVehicleOwner', function(plate)
--     local src = source

--     plate = plate:match("^%s*(.-)%s*$")

--     exports.oxmysql:single([[
--         SELECT p.charinfo
--         FROM player_vehicles v
--         JOIN players p ON p.citizenid = v.citizenid
--         WHERE v.plate = ?
--     ]], { plate }, function(result)

--         if result and result.charinfo then
--             local charinfo = json.decode(result.charinfo)

--             TriggerClientEvent('chat:addMessage', src, {
--                 color = { 0, 150, 255 },
--                 multiline = true,
--                 args = {
--                     'DISPATCH',
--                     ('Owner: %s %s | Plate: %s')
--                         :format(charinfo.firstname, charinfo.lastname, plate)
--                 }
--             })
--         else
--             TriggerClientEvent('chat:addMessage', src, {
--                 color = { 255, 0, 0 },
--                 args = {
--                     'DISPATCH',
--                     ('No owner found for plate: %s'):format(plate)
--                 }
--             })
--         end
--     end)
-- end)
---------------------------
-- Plate check
---------------------------
RegisterServerEvent("ErsIntegration::OnFirstVehicleInteraction")
AddEventHandler("ErsIntegration::OnFirstVehicleInteraction", function(src, vehicleData, context)
    if context ~= "on_pullover" then return end

    vehicleCache[src] = vehicleCache[src] or {}

    local exists = false

    for _, v in ipairs(vehicleCache[src]) do
        if v.license_plate == vehicleData.license_plate then
            exists = true
            break
        end
    end

    if not exists then
        table.insert(vehicleCache[src], vehicleData)

        -- keep only last 10
        if #vehicleCache[src] > 10 then
            table.remove(vehicleCache[src], 1)
        end
    end
    TriggerClientEvent('ersi:client:recordAddedTextUI', src, {
        message = ('DATABASE ENTRY: %s'):format(vehicleData.license_plate or 'UNKNOWN'),
        icon = 'car'
    })

    if not Config.ShowPlateInChat then return end

    CreateThread(function()
        Wait(5000)

        local info = ("Vehicle Check:\n" ..
            "Owner: %s\n" ..
            "Plate: %s\n" ..
            "Vehicle: %s %s\n" ..
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

    pedCache[src] = pedCache[src] or {}

    local exists = false

    for _, p in ipairs(pedCache[src]) do
        if p.FirstName == pedData.FirstName and p.LastName == pedData.LastName then
            exists = true
            break
        end
    end

    if not exists then
        table.insert(pedCache[src], pedData)

        -- keep only last 10
        if #pedCache[src] > 10 then
            table.remove(pedCache[src], 1)
        end
    end

    TriggerClientEvent('ersi:client:recordAddedTextUI', src, {
        message = ('DATABASE ENTRY: %s %s'):format(
            pedData.FirstName or 'N/A',
            pedData.LastName or ''
        ),
        icon = 'user'
    })

    if not Config.ShowLicenseInChat then return end

    CreateThread(function()
        Wait(5000)

        local info = ("ID CHECK:\n" ..
            "Name: %s %s\n" ..
            "DOB: %s\n" ..
            "Address: %s\n" ..
            "%s, %s %s\n" ..
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

RegisterNetEvent('ersi:server:getVehicleMenuData', function()
    local src = source
    local data = vehicleCache[src] or {}

    table.sort(data, function(a, b)
        return (a.license_plate or '') < (b.license_plate or '')
    end)

    TriggerClientEvent('ersi:client:openVehicleListMenu', src, data)
end)

RegisterNetEvent('ersi:server:getPedMenuData', function()
    local src = source
    local data = pedCache[src] or {}

    table.sort(data, function(a, b)
        local nameA = (a.FirstName or '') .. (a.LastName or '')
        local nameB = (b.FirstName or '') .. (b.LastName or '')
        return nameA < nameB
    end)

    TriggerClientEvent('ersi:client:openPedListMenu', src, data)
end)

--------------------------------------
-- Callout Offered
--------------------------------------
RegisterNetEvent('ErsIntegration::OnIsOfferedCallout', function(calloutData)
    --if not Config.EnableCalloutOffer then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"


    local infoOptions = {
        ("%s | Requesting: %s"):format(callDesc, callUnits),
        ("%s | Requesting: %s"):format(callDesc, callUnits),
        ("%s | Requesting: %s"):format(callDesc, callUnits)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnimPhoneText', src)
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:incomingCallTextUI', src, 'Incoming 911 Call')
        end

        if Config.ShowCallInChat then
            local info = ("INCOMING 911 CALL:\n" ..
                "Caller: %s %s\n" ..
                "Call: %s\n" ..
                "%s %s\n" ..
                "Report: %s"
            ):format(
                callFirstName,
                callLastName,
                callName,
                callPostal,
                callStreet,
                callDesc
            )

            TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end

        Wait(Config.WaitTimes.CalloutOffer)
        
        if Config.EnableCalloutOffer then
            TriggerEvent('ps-dispatch:server:notify', {
                code = '911',
                codeName = 'dispatch',
                title = "EnRoute",
                icon = 'fas fa-bullhorn',
                priority = 2,
                message = ("%s"):format(callName),
                alertTime = 10,
                street = ("%s %s"):format(
                    callPostal,
                    callStreet
                ),
                name = ("%s %s"):format(
                    callFirstName,
                    callLastName
                ),
                information = randomInfo,
                jobs = Config.Dispatch.CallOffer,
                coords = coords,
            })
        end

    end)
end)

--------------------------------------
-- Callout Accepted
--------------------------------------
RegisterNetEvent('ErsIntegration::OnAcceptedCalloutOffer', function(calloutData)
    --if not Config.EnableCalloutAccept then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local job = Player.PlayerData.job.grade.name or ""

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"

    local infoOptions = {
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits),
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits),
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        if Config.ShowCalloutInChat then
            local info = ("911 CALL:\n" ..
                "Caller: %s %s\n" ..
                "Call: %s\n" ..
                "%s %s\n" ..
                "Report: %s"
            ):format(
                callFirstName,
                callLastName,
                callName,
                callPostal,
                callStreet,
                callDesc
            )

            TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                    title = '911 Call',
                    description = ('%s | %s %s')
                        :format(
                        callName,
                        callPostal,
                        callStreet
                    ),
                    type = 'success',
                    duration = 8000,
                    icon = 'bullhorn'
                })
        end

        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:911CallTextUI', src, '911 Call')
        end

        Wait(Config.WaitTimes.CalloutAccepted)

        if Config.EnableCalloutAccept then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'enroute',
                title = "EnRoute",
                icon = 'fas fa-route',
                priority = 2,
                message = ("%s"):format(callName),
                alertTime = 10,
                street = ("%s %s"):format(callPostal, callStreet),
                name = ("%s %s (%s) | %s"):format(
                    firstName,
                    lastName,
                    callsign,
                    job),
                information = randomInfo,
                jobs = Config.Dispatch.CallAccept,
                coords = coords,
            })
        end

    end)
end)

--------------------------------------
-- Callout Arrived
--------------------------------------
RegisterNetEvent('ErsIntegration::OnArrivedAtCallout', function(calloutData)
    --if not Config.EnableCalloutArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local job = Player.PlayerData.job.grade.name or ""

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"

    local infoOptions = {
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        Wait(Config.WaitTimes.Updates)
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Dispatch',
                    description = ('%s (%s)| On Scene %s %s')
                        :format(
                        lastName,
                        callsign,
                        callPostal,
                        callStreet
                    ),
                    type = 'success',
                    duration = 8000,
                    icon = 'map-pin'
                })
        end
        if Config.ShowTextUI then
            -- trigger text UI on client
            TriggerClientEvent('ersi:client:CallArriveTextUI', src, 'On Scene')
        end
        Wait(Config.WaitTimes.CalloutArrived) 

        if Config.EnableCalloutArrive then
            if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
        end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'onscene',
                title = "On Scene",
                icon = 'fas fa-map-marker-alt',
                priority = 2,
                message = ("%s (%s) | On-Scene"):format(     
                    lastName,
                    callsign),
                alertTime = 10,
                street = ("%s %s"):format(callPostal, callStreet),
                name = ("%s %s (%s) | %s"):format(
                    firstName,
                    lastName,
                    callsign,
                    job),
                information = randomInfo,
                jobs = Config.Dispatch.CallArrive,
                coords = coords,
            })
        end
        if Config.EnableBonusPayCallArrive then
            Wait(5000)

            Player.Functions.AddMoney(Config.BonusPayDepositType, Config.BonusPayAmountCallArrive, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) arrived at the call. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end
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
    --if not Config.EnableCalloutComplete then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local job = Player.PlayerData.job.grade.name or ""

    local infoOptions = {
        ("%s (%s) Code-4 from my last Call"):format(lastName, callsign),
        ("%s (%s) Show me Code-4 from my last Call"):format(lastName, callsign),
        ("%s (%s) Show me 10-8"):format(lastName, callsign)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch',
                description = ('%s (%s) to Dispatch. Code 4 at %s %s.')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'radio'
            })
        end
        if Config.ShowTextUI then
            -- trigger text UI on client
            TriggerClientEvent('ersi:client:CallCompleteTextUI', src, 'Call Complete')
        end
        Wait(Config.WaitTimes.CalloutCompleted)

        

        if Config.EnableCalloutComplete then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'codefour',
                title = "CodeFour",
                icon = 'fas fa-clock',
                priority = 2,
                message = ("%s (%s) | Code-4"):format(lastName, callsign),
                alertTime = 10,
                name = ("%s %s (%s) | %s"):format(firstName, lastName, callsign, job),
                information = randomInfo,
                jobs = Config.Dispatch.CallComplete,
                coords = coords,
            })
        end

        if Config.EnableBonusPayCallComplete then
            Wait(5000)

            Player.Functions.AddMoney('bank', Config.BonusPayAmountCallComplete, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) cleared the call. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end

    end)
end)

--------------------------------------
-- Pullover
--------------------------------------
PendingPullover = {}

RegisterNetEvent('ErsIntegration::OnPullover', function(pedData, vehicleData)
    local src = source
    PendingPullover[src] = { pedData = pedData, vehicleData = vehicleData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostal', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostal', function(streetName, postal)
    local src = source
    local data = PendingPullover[src]
    if not data then return end

    local pedData = data.pedData
    local vehicleData = data.vehicleData
    PendingPullover[src] = nil

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local pedPlate = vehicleData.license_plate or "N/A"
    local pedMake = vehicleData.make or "N/A"
    local pedModel = vehicleData.model or "N/A"
    local pedColor = vehicleData.color or "N/A"
    local pedColor2 = vehicleData.color_secondary or "N/A"
    local pedClass = vehicleData.vehicle_class or "N/A"
    local pedOwner = vehicleData.owner_name or "N/A"
    local pedInsurance = vehicleData.insurance and "true" or "false"
    local pedBolo = vehicleData.bolo and "true" or "false"
    local pedStolen = vehicleData.stolen and "true" or "false"

    -- Thread for notifications
    CreateThread(function()
        if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnim', src)
            end
        if Config.ShowlibNotify then
            
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Traffic Stop',
                description = ('%s (%s) to Dispatch. Traffic stop at %s %s with a %s %s. Plate: %s')
                    :format(lastName, callsign, postal, streetName, pedColor, pedModel, pedPlate),
                type = 'success',
                duration = 4000,
                icon = 'car'
            })
        end

        if Config.EnableRadarLock then
            Wait(1000)
            TriggerClientEvent('ersi:client:radarFrontLock', src)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'ALPR Lock',
                description = ('%s (%s) Locked Plate: %s')
                    :format(lastName, callsign, pedPlate),
                type = 'primary',
                duration = 5000,
                icon = 'car'
            })
        end
        if Config.ShowTextUI then
            -- trigger text UI on client
            TriggerClientEvent('ersi:client:PulloverTextUI', src, 'Traffic Stop')
        end

        Wait(Config.WaitTimes.PulloverNotify)

        if Config.EnablePulloverNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'trafficstop',
                title = "TrafficStop",
                icon = 'fa-solid fa-car-on',
                priority = 2,
                message = ("%s (%s) | Traffic"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                vehicle = ("%s %s"):format(pedMake, pedModel),
                plate = pedPlate,
                color = ("%s, %s"):format(pedColor, pedColor2),
                class = pedClass,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Show me on a Traffic Stop. - PLATE CHECK - Owner: %s | Insurance: %s | BOLO: %s | Stolen: %s |"):format(
                    lastName, callsign, pedOwner, pedInsurance, pedBolo, pedStolen)
            })
        end

        if Config.EnableBonusPayTrafficStop then
            Wait(5000)

            Player.Functions.AddMoney('bank', Config.BonusPayAmountTrafficStop, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) initiated a traffic stop. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end
    end)
end)

--------------------------------------
-- Pullover Conclude
--------------------------------------
PendingPulloverEnd = {}

RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    local src = source
    PendingPulloverEnd[src] = { pedData = pedData, vehicleData = vehicleData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostalEnd', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostalEnd', function(streetName, postal)
    local src = source
    local data = PendingPulloverEnd[src]
    if not data then return end

    local pedData = data.pedData
    local vehicleData = data.vehicleData
    PendingPulloverEnd[src] = nil -- clear pending data

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local pedPlate = vehicleData.license_plate or "N/A"
    local pedMake = vehicleData.make or "N/A"
    local pedModel = vehicleData.model or "N/A"
    local pedColor = vehicleData.color or "N/A"
    local pedColor2 = vehicleData.color_secondary or "N/A"
    local pedClass = vehicleData.vehicle_class or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.PulloverEnd)

        if Config.EnablePulloverCode4 then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'codefour',
                title = "Code4",
                icon = 'fas fa-car-side',
                priority = 2,
                message = ("%s (%s) | Code-4"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Code-4 from my last Traffic"):format(lastName, callsign),
            })
        end
    end)
end)

-- RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
--     --if not Config.EnablePulloverNotify then return end

--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     local pedPlate = vehicleData.license_plate or "N/A"
--     local pedMake = vehicleData.make or "N/A"
--     local pedModel = vehicleData.model or "N/A"
--     local pedColor = vehicleData.color or "N/A"
--     local pedColor2 = vehicleData.color_secondary or "N/A"
--     local pedClass = vehicleData.vehicle_class or "N/A"

--     CreateThread(function()
--         Wait(Config.WaitTimes.PulloverEnd)

--         if Config.EnablePulloverCode4 then
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'codefour',
--                 title = "Code4",
--                 icon = 'fas fa-car-side',
--                 priority = 2,
--                 message = ("%s (%s) | Code-4"):format(     
--                     lastName,
--                     callsign),
--                 name = ("%s %s (%s)"):format(
--                     firstName,
--                     lastName,
--                     callsign),
--                 coords = coords,
--                 alertTime = 10,
--                 -- vehicle = ("%s %s"):format(pedMake, pedModel),
--                 -- plate = ("%s"):format(pedPlate),
--                 -- color = ("%s, %s"):format(pedColor, pedColor2),
--                 -- class = ("%s"):format(pedClass),
--                 jobs = Config.Dispatch.TrafficStop,
--                 information = ("%s (%s). Code-4 from my last Traffic"):format(
--                     lastName, 
--                     callsign),

--             })
--         end

--     end)
-- end)

--------------------------------------
-- Pursuit Start
--------------------------------------
PendingPursuit = {}

RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData)
    local src = source
    PendingPursuit[src] = { pedData = pedData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostalPursuit', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostalPursuit', function(streetName, postal)
    local src = source
    local data = PendingPursuit[src]
    if not data then return end

    local pedData = data.pedData
    PendingPursuit[src] = nil 

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "N/A"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.ShowlibNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerClientEvent('QBCore:Notify', src,
                    ('%s (%s) to Dispatch. Show me in Active Pursuit @ %s %s')
                        :format(lastName, callsign, postal, streetName),
                    'success',
                    4000
                )
        end
        Wait(Config.WaitTimes.PursuitStart)

        if Config.EnablePursuitNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "Pursuit",
                icon = 'fa-solid fa-car-on',
                priority = 2,
                message = ("%s (%s) | Pursuit"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Show me in an Active Pursuit"):format(lastName, callsign)
            })
        end
    end)
end)


-- RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData)
--     --if not Config.EnablePursuitNotify then return end

--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         Wait(Config.WaitTimes.PursuitStart)

--         if Config.EnablePursuitNotify then
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'codefour',
--                 title = "Pursuit",
--                 icon = 'fas fa-car',
--                 priority = 2,
--                 message = ("%s (%s) | Pursuit"):format(     
--                     lastName,
--                     callsign),
--                 name = ("%s %s (%s)"):format(
--                     firstName,
--                     lastName,
--                     callsign),
--                 coords = coords,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.TrafficStop,
--                 information = ("%s (%s). Show me in a Active Pursuit"):format(
--                     lastName, 
--                     callsign 
--                 ),
--             })
--         end

--     end)
-- end)


--------------------------------------
-- Pursuit Conclude
--------------------------------------
-- RegisterNetEvent('ErsIntegration::OnPursuitEnded', function(pedData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     Citizen.CreateThread(function()
--         Wait(Config.WaitTimes.PursuitStart)

--         if Config.EnablePursuitCode4 then
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'codefour',
--                 title = "Pursuit",
--                 icon = 'fas fa-car',
--                 priority = 2,
--                 message = ("%s (%s) | Code"):format(     
--                     lastName,
--                     callsign),
--                 name = ("%s %s (%s)"):format(
--                     firstName,
--                     lastName,
--                     callsign),
--                 coords = coords,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.TrafficStop,
--                 information = ("%s (%s). Show me in a Active Pursuit"):format(
--                     lastName, 
--                     callsign 
--                 ),
--             })
--         end

--     end)
-- end)

--------------------------------------------------------------------------------------------------
-- Request EVENTS
--------------------------------------------------------------------------------------------------
RegisterNetEvent('ErsIntegration:server:OnCoronerRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"



    CreateThread(function()
        if Config.EnableCoronerRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Coroner Request',
                description = ('%s (%s) requesting coroner services @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-skull-crossbones'
            })
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Coroner services requested',
                icon = 'fas fa-skull-crossbones',
                color = '#8b0000',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents) 
        
        if Config.EnableCoronerArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch', 
                codeName = 'dispatch',
                title = "Coroner",
                icon = 'fas fa-skull-crossbones',
                message = ("Coroner On Scene | %s"):format(
                    postal),
                name = ("Coroner Service"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                alertTime = 10,
                priority = 1,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised local Coroner is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),          
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnMechanicRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableMechanicRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Mechanic Request',
                description = ('%s (%s) requesting mechanic services @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-tools'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Mechanic requested',
                icon = 'fas fa-tools',
                color = '#f39c12',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableMechanicArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "MechanicResponding",
                icon = 'fas fa-tools',
                message = ("Roadside Assistance On Scene | %s"):format(
                    postal),
                name = ("Mechanic Service"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                alertTime = 10,
                priority = 2,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Auto Mechanic is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnTowRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    -- local coords = GetEntityCoords(GetPlayerPed(src))


    CreateThread(function()
        if Config.EnableTowRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Tow Request',
                description = ('%s (%s) requesting tow truck @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-truck-pickup'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Tow Truck Requested',
                icon = 'fas fa-truck-pickup',
                color = '#f39c12',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableTowArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "TowTruck",
                icon = 'fas fa-truck-pickup',
                message = ("Tow Service On Scene | %s"):format(
                    postal),
                name = ("Towing Service"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 2,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Tow Truck Service is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)


RegisterNetEvent('ErsIntegration:server:OnTaxiRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableTaxiRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Taxi Request',
                description = ('%s (%s) requesting taxi service @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fa-solid fa-taxi'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Taxi Requested',
                icon = 'fa-solid fa-taxi',
                color = '#f39c12',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableTaxiArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "TaxiResponding",
                icon = 'fa-solid fa-taxi',
                message = ("Taxi Service On Scene | %s"):format(
                    postal),
                name = ("Taxi Service"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 2,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Taxi Service has been dispatched and is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnPoliceRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableTransportRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Transport Request',
                description = ('%s (%s) to Dispatch. Send a Police Transport to %s %s for a individual.')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fa-solid fa-car-on'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Police Transport Requested',
                icon = 'fa-solid fa-car-on',
                color = '#2c3e50',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableTransportArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "PoliceTransport",
                icon = 'fa-solid fa-car-on',
                message = ("PD Transport On Scene | %s"):format(
                    postal),
                name = ("Police Transport"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 2,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Police Transport Officer has been dispatched and is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAnimalRescueRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableAnimalRescueRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Animal Rescue',
                description = ('%s (%s) to Dispatch. Animal Rescue is needed immediately @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fa-solid fa-paw'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Animal Rescue Requested',
                icon = 'fa-solid fa-paw',
                color = '#f39c12',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableAnimalRescueArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "AnimalRescue",
                icon = 'fa-solid fa-paw',
                message = ("Animal Control On Scene | %s"):format(
                    postal),
                name = ("Animal Rescue"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 2,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Animal Control Supervisor has been dispatched and is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnAmbulanceRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableAmbulanceRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - EMS Request',
                description = ('%s (%s) to Dispatch. EMS needed immediately @ %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-ambulance'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'EMS Requested',
                icon = 'fas fa-ambulance',
                color = '#1e90ff',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableAmbulanceArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "Ambulance",
                icon = 'fas fa-ambulance',
                message = ("Paramedic Arriving | %s"):format(
                    postal),
                name = ("Ambulance Service"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 1,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Paramedic has been dispatched and is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnFireRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

   CreateThread(function()
        if Config.EnableFireRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Fire Rescue',
                description = ('%s (%s) to Dispatch. Send Fire Rescue to %s %s')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-fire-flame-curved'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Fire Rescue Requested',
                icon = 'fas fa-fire-flame-curved',
                color = '#f31212',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents)
        if Config.EnableFireArrive then 
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end       
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "FireRescue",
                icon = 'fas fa-fire-flame-curved',
                message = ("Fire Rescue On Scene | %s"):format(
                    postal),
                name = ("Fire Rescue"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 1,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised Fire Rescue has been dispatched and is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

RegisterNetEvent('ErsIntegration:server:OnRoadServiceRequested', function(postal, streetName)
    if not Config.EnableServiceRequestandArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.EnableRoadServiceRequest then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Road Crew',
                description = ('%s (%s) to Dispatch. I need a Road Crew @ %s %s. We got a mess!')
                    :format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = 'fas fa-broom'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = 'Road Service Requested',
                icon = 'fas fa-broom',
                color = '#f39c12',
                duration = 8000
            })
        end
        Wait(Config.WaitTimes.RequestEvents) 
        if Config.EnableRoadServiceArrive then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch', 
                codeName = 'dispatch',
                title = 'RoadService',
                icon = 'fas fa-broom',
                message = ("Road Service On Scene | %s"):format(
                    postal),
                name = ("Road Service Crew"),
                coords = coords,
                street = ("%s %s"):format(
                    postal,
                    streetName or "Unknown"),
                priority = 2,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = ("Dispatch to %s (%s). Be advised a Road Service Crew is confirmed 10-97 to your location."):format(
                    lastName, 
                    callsign),
            })
        end
    end)
end)

