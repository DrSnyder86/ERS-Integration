local QBCore = exports['qb-core']:GetCoreObject()
local cache = { ped = PlayerPedId() }
local PlayerData = QBCore.Functions.GetPlayerData()
local lastCalloutData = nil
local currentCalloutData = nil
local lastPedData = nil
Config = Config or {}

Config.DutyConfig = {
    police = { icon = "fa-solid fa-car-on", label = "ERS Police Duty", event = "ers:server:TogglePoliceShift" },
    ambulance = { icon = "fa-solid fa-truck-medical", label = "ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
    fire = { icon = "fa-solid fa-fire", label = "ERS Fire Duty", event = "ers:server:ToggleFireShift" },
    tow = { icon = "fa-solid fa-car-burst", label = "ERS Tow Duty", event = "ers:server:ToggleTowShift" },
}

RegisterNetEvent("ErsIntegration:OnAcceptedCalloutOffer", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration::OnAcceptedCalloutOffer", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration::OnCalloutCompletedSuccesfully", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration::OnPulloverStarted", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration:client:SetPedData", function(data)
    PedData = data
end)

RegisterNetEvent("ErsIntegration:client:SetCalloutData", function(data)
    CalloutData = data
end)

-- target shift
local function CanToggleShift(shiftType)
    local src = PlayerId()
    local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
    local activeType = exports['night_ers']:getPlayerActiveServiceType(src)
    return (not isOnShift) or (activeType == shiftType)
end

-- Register all duty points
for job, points in pairs(Config.DutyPoints) do
    for _, coords in ipairs(points) do
        Citizen.CreateThread(function()
            -- ox_target
            if exports.ox_target and exports.ox_target.addBoxZone then
                exports.ox_target:addBoxZone({
                    coords = coords,
                    size = vec3(1.5, 1.5, 1.0),
                    rotation = 0,
                    debug = false,
                    options = {
                        {
                            name = Config.DutyConfig[job].event,
                            icon = Config.DutyConfig[job].icon,
                            label = Config.DutyConfig[job].label,
                            onSelect = function()
                                TriggerServerEvent(Config.DutyConfig[job].event)
                            end,
                            canInteract = function()
                                return CanToggleShift(job) and #(GetEntityCoords(PlayerPedId()) - coords) < 2.0
                            end
                        }
                    }
                })
            -- qb-target
            elseif exports['qb-target'] then
                exports['qb-target']:AddBoxZone(Config.DutyConfig[job].event, coords, 1.5, 1.5, {
                    name = Config.DutyConfig[job].event,
                    heading = 0,
                    debugPoly = false,
                    minZ = coords.z - 1.0,
                    maxZ = coords.z + 1.0,
                }, {
                    options = {
                        {
                            type = "client",
                            event = Config.DutyConfig[job].event,
                            icon = Config.DutyConfig[job].icon,
                            label = Config.DutyConfig[job].label,
                            canInteract = function()
                                return CanToggleShift(job)
                            end
                        }
                    },
                    distance = 2.0
                })
            end
        end)
    end
end


--------------------------------------
---- Custom Calls --------------------
--------------------------------------

RegisterNetEvent('ersi:broom', function() ExecuteCommand('broom') end)
RegisterNetEvent('ersi:firehose', function() ExecuteCommand('hose') end)
RegisterNetEvent('ersi:stretcher', function() ExecuteCommand('stretcher') end)
RegisterNetEvent('ersi:client:radarFrontLock', function() ExecuteCommand('radar_fr_cam') end)
RegisterNetEvent('ersi:client:useMDTTablet', function() ExecuteCommand('mdt') end)
RegisterNetEvent('ersi:mdt:toggle', function() ExecuteCommand('mdt') end)
RegisterNetEvent('ersi:callout:request', function() ExecuteCommand('requestcallout') end)
RegisterNetEvent('ersi:shift:toggle', function() ExecuteCommand('toggleshift') end)
RegisterNetEvent('ersi:callouts:toggle', function() ExecuteCommand('togglecallouts') end)
RegisterNetEvent('ersi:speedzone', function() ExecuteCommand('speedzones') end)

-- EXTRAS
-- RegisterNetEvent('autoems:request', function() ExecuteCommand('autoems') end)
RegisterNetEvent('ersi:tcs:toggle', function() ExecuteCommand('tsc') end)
RegisterNetEvent('ersi:multijob:toggle', function() ExecuteCommand('multijob') end)
RegisterNetEvent('ersi:escort:toggle', function() ExecuteCommand('escort') end)
RegisterNetEvent('ersi:emote:toggle', function() ExecuteCommand('emotemenu') end)
RegisterNetEvent('ersi:extra:menu', function() ExecuteCommand('extrasmenu') end)

--------------------------------------
---- Cancel Requests -----------------
--------------------------------------
RegisterNetEvent('ersi:call:cancelambulance', function() ExecuteCommand('cancelambulance') end)
RegisterNetEvent('ersi:call:cancelfire', function() ExecuteCommand('cancelfire') end)
RegisterNetEvent('ersi:call:cancelpolice', function() ExecuteCommand('cancelpolice') end)
RegisterNetEvent('ersi:call:canceltaxi', function() ExecuteCommand('canceltaxi') end)
RegisterNetEvent('ersi:call:canceltow', function() ExecuteCommand('canceltow') end)
RegisterNetEvent('ersi:call:cancelmechanic', function() ExecuteCommand('cancelmechanic') end)
RegisterNetEvent('ersi:call:cancelcoroner', function() ExecuteCommand('cancelcoroner') end)
RegisterNetEvent('ersi:call:cancelanimalrescue', function() ExecuteCommand('cancelanimalrescue') end)
RegisterNetEvent('ersi:call:cancelroadservice', function() ExecuteCommand('cancelroadservice') end)

----------------------------------------
---- Postal Requests and functions -----
----------------------------------------
local function sendPostalAndTrigger(event, cmd)
    ExecuteCommand(cmd)

    local postal = exports['nearest-postal']:getPostal()

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash)

    TriggerServerEvent(event, postal, streetName)
end

RegisterNetEvent('ersi:call:coroner',       function() sendPostalAndTrigger('ErsIntegration:server:OnCoronerRequested', 'requestcoroner') end)
RegisterNetEvent('ersi:call:mechanic',      function() sendPostalAndTrigger('ErsIntegration:server:OnMechanicRequested', 'requestmechanic') end)
RegisterNetEvent('ersi:call:tow',           function() sendPostalAndTrigger('ErsIntegration:server:OnTowRequested', 'requesttow') end)
RegisterNetEvent('ersi:call:taxi',          function() sendPostalAndTrigger('ErsIntegration:server:OnTaxiRequested', 'requesttaxi') end)
RegisterNetEvent('ersi:call:police',        function() sendPostalAndTrigger('ErsIntegration:server:OnPoliceRequested', 'requestpolice') end)
RegisterNetEvent('ersi:call:animalrescue',  function() sendPostalAndTrigger('ErsIntegration:server:OnAnimalRescueRequested', 'requestanimalrescue') end)
RegisterNetEvent('ersi:call:ambulance',     function() sendPostalAndTrigger('ErsIntegration:server:OnAmbulanceRequested', 'requestambulance') end)
RegisterNetEvent('ersi:call:requestfire',   function() sendPostalAndTrigger('ErsIntegration:server:OnFireRequested', 'requestfire') end)
RegisterNetEvent('ersi:call:roadservice',   function() sendPostalAndTrigger('ErsIntegration:server:OnRoadServiceRequested', 'requestroadservice') end)

---------------------------------------
---- PED AND PLATE CHECK --------------
---------------------------------------
RegisterNetEvent("ErsIntegration:Server:PrintPedDataToChat", function(info)
    -- Print into chat
    TriggerEvent('chat:addMessage', {
        color = {255, 0, 0},
        multiline = true,
        args = {"DISPATCH", "^1" .. info}
    })
end)

---------------------------------------
---- PURSUIT BACKUP -------------------
---------------------------------------
exports('ERS_RequestLightBackup', function()
    ERS_RequestOrCancelPursuitBackupByType("light")
end)

exports('ERS_RequestMediumBackup', function()
    ERS_RequestOrCancelPursuitBackupByType("medium")
end)

exports('ERS_RequestHeavyBackup', function()
    ERS_RequestOrCancelPursuitBackupByType("heavy")
end)

exports('ERS_RequestAirBackup', function()
    ERS_RequestOrCancelPursuitBackupByType("air")
end)

exports('ERS_RequestArmyBackup', function()
    ERS_RequestOrCancelPursuitBackupByType("army")
end)


