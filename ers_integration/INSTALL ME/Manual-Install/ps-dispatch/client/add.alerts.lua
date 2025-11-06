--Add these functions to your ps-dispatch/client/alerts.lua

local function TrafficStop()
    local coords = GetEntityCoords(cache.ped)
	local vehicle = GetVehicleData(vehicle)
	
    local dispatchData = {
        message = locale('Traffic Stop Start'),
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
        alertTime = 10,
        jobs = { 'ems', 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('TrafficStop', TrafficStop)

RegisterNetEvent("ps-dispatch:client:trafficstop", function() TrafficStop() end)

local function CodeFour()
    local coords = GetEntityCoords(cache.ped)
	
    local dispatchData = {
        message = locale('Scene Clear'),
        codeName = 'codefour',
        code = 'Code-4',
        icon = 'fas fa-car',
        -- coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        alertTime = 10,
        jobs = { 'ems', 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('CodeFour', CodeFour)

RegisterNetEvent("ps-dispatch:client:codefour", function() CodeFour() end)

local function OnScene()
    local coords = GetEntityCoords(cache.ped)
	
    local dispatchData = {
        message = locale('On Scene 911 Call'),
        codeName = 'onscene',
        code = '10-23',
        icon = 'fas fa-car',
        coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        alertTime = 5,
        jobs = { 'ems', 'leo' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
end
exports('OnScene', OnScene)

RegisterNetEvent("ps-dispatch:client:onscene", function() OnScene() end)

local function EnRoute()
    local coords = GetEntityCoords(cache.ped)
	
    local dispatchData = {
        message = locale('Responding to 911 Call'),
        codeName = 'enroute',
        code = '10-97',
        icon = 'fas fa-car',
        --coords = coords,
        street = GetStreetAndZone(coords),
		heading = GetPlayerHeading(),
        name = PlayerData.charinfo.firstname .. " " .. PlayerData.charinfo.lastname,
        callsign = PlayerData.metadata["callsign"],
        alertTime = nil,
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
        priority = 3,
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