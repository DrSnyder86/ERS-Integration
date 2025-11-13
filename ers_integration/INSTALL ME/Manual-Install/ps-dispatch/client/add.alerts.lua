local function TrafficStop()
    local coords = GetEntityCoords(cache.ped)
	local vehicle = GetVehicleData(vehicle)
    local postal = exports['nearest-postal']:getPostal() or "N/A"


    local infoMessage = string.format(
        "%s\nPostal: %s",
        customText or "Show me on a Traffic Stop Nearest",
        postal
    )
	
    local dispatchData = {
        message = locale('911 Dispatch'),
        codeName = 'trafficstop',
        code = '10-11',
        icon = 'fas fa-car',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        vehicle = vehicle.name,
        plate = vehicle.plate,
        color = vehicle.color,
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        information = infoMessage,
        alertTime = 10,
        jobs = { 'ems', 'leo' },
        postal = postal
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('TrafficStop', TrafficStop)

RegisterNetEvent("ps-dispatch:client:trafficstop", function() TrafficStop() end)

local function CodeFour()
    local coords = GetEntityCoords(cache.ped)
    local postal = exports['nearest-postal']:getPostal() or "N/A"


    local infoMessage = string.format(
        "%s\nPostal: %s",
        customText or "Scene is all clear Nearest",
        postal
    )
    
	
    local dispatchData = {
        message = locale('911 Dispatch'),
        codeName = 'codefour',
        code = 'Code-4',
        icon = 'fas fa-car',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        information = infoMessage,
        alertTime = 10,
        jobs = { 'ems', 'leo', 'tow' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('CodeFour', CodeFour)

RegisterNetEvent("ps-dispatch:client:codefour", function() CodeFour() end)

local function OnScene()
    local coords = GetEntityCoords(cache.ped)
    local postal = exports['nearest-postal']:getPostal() or "N/A"


    local infoMessage = string.format(
        "%s\nPostal: %s",
        customText or "Officers arriving on scene 911 call. Nearest",
        postal
    )
	
    local dispatchData = {
        message = locale('911 Dispatch'),
        codeName = 'onscene',
        code = '10-23',
        icon = 'fas fa-car',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        information = infoMessage,
        alertTime = 6,
        jobs = { 'ems', 'leo', 'tow' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('OnScene', OnScene)

RegisterNetEvent("ps-dispatch:client:onscene", function() OnScene() end)

local function EnRoute()
    local coords = GetEntityCoords(cache.ped)
    	
    local dispatchData = {
        message = locale('911 Dispatch'),
        codeName = 'enroute',
        code = '10-97',
        icon = 'fas fa-car',
        coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        alertTime = 6,
        jobs = { 'ems', 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('EnRoute', EnRoute)

RegisterNetEvent("ps-dispatch:client:enroute", function() EnRoute() end)

local function FireCall()
    local coords = GetEntityCoords(cache.ped)

    local dispatchData = {
        message = locale('Fire Call'),
        codeName = 'firecall',
        code = '10-67',
        icon = 'fas fa-fire',
        priority = 1,
        coords = coords,
        street = GetStreetAndZone(coords),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        alertTime = 10,
        jobs = { 'ems', 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('FireCall', FireCall)

RegisterNetEvent("ps-dispatch:client:firecall", function() FireCall() end)
