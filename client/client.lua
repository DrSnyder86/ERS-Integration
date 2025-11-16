local QBCore = exports['qb-core']:GetCoreObject()

Config = Config or {}

-----------------------------------
-- TARGET DUTY 
-----------------------------------
Config.DutyConfig = {
    police = { icon = "user-shield", label = "Toggle ERS Police Duty", event = "ers:server:TogglePoliceShift" },
    ambulance = { icon = "briefcase-medical", label = "Toggle ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
    fire = { icon = "fire-extinguisher", label = "Toggle ERS Fire Duty", event = "ers:server:ToggleFireShift" },
    tow = { icon = "truck", label = "Toggle ERS Tow Duty", event = "ers:server:ToggleTowShift" },
}
-- END CONFIG --
--=================================================================================================
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
-- Custom Calls
--------------------------------------
-- RegisterNetEvent('autoems:request', function() ExecuteCommand('autoems') end)
RegisterNetEvent('custom:speedzone', function() ExecuteCommand('speedzones') end)
RegisterNetEvent('custom:broom', function() ExecuteCommand('broom') end)
RegisterNetEvent('custom:client:radarFrontLock', function() ExecuteCommand('radar_fr_cam') end)
RegisterNetEvent('custom:client:useMDTTablet', function() ExecuteCommand('mdt') end)
RegisterNetEvent('mdt:toggle', function() ExecuteCommand('mdt') end)
RegisterNetEvent('tcs:toggle', function() ExecuteCommand('tsc') end)
RegisterNetEvent('callout:request', function() ExecuteCommand('requestcallout') end)
RegisterNetEvent('shift:toggle', function() ExecuteCommand('toggleshift') end)
RegisterNetEvent('callouts:toggle', function() ExecuteCommand('togglecallouts') end)
RegisterNetEvent('multijob:toggle', function() ExecuteCommand('multijob') end)
RegisterNetEvent('escort:toggle', function() ExecuteCommand('escort') end)
RegisterNetEvent('emote:toggle', function() ExecuteCommand('emotemenu') end)

--------------------------------------
-- Cancel Requests
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

----------------------
-- Postal Requests and functions
----------------------
local function sendPostalAndTrigger(event, cmd)
    ExecuteCommand(cmd)
    local postal = exports['nearest-postal']:getPostal()
    TriggerServerEvent(event, postal)
end

RegisterNetEvent('call:coroner',       function() sendPostalAndTrigger('ErsIntegration:server:OnCoronerRequested', 'requestcoroner') end)
RegisterNetEvent('call:mechanic',      function() sendPostalAndTrigger('ErsIntegration:server:OnMechanicRequested', 'requestmechanic') end)
RegisterNetEvent('call:tow',           function() sendPostalAndTrigger('ErsIntegration:server:OnTowRequested', 'requesttow') end)
RegisterNetEvent('call:taxi',          function() sendPostalAndTrigger('ErsIntegration:server:OnTaxiRequested', 'requesttaxi') end)
RegisterNetEvent('call:police',        function() sendPostalAndTrigger('ErsIntegration:server:OnPoliceRequested', 'requestpolice') end)
RegisterNetEvent('call:animalrescue',  function() sendPostalAndTrigger('ErsIntegration:server:OnAnimalRescueRequested', 'requestanimalrescue') end)
RegisterNetEvent('call:ambulance',     function() sendPostalAndTrigger('ErsIntegration:server:OnAmbulanceRequested', 'requestambulance') end)
RegisterNetEvent('custom:requestfire', function() sendPostalAndTrigger('ErsIntegration:server:OnFireRequested', 'requestfire') end)
RegisterNetEvent('call:roadservice',   function() sendPostalAndTrigger('ErsIntegration:server:OnRoadServiceRequested', 'requestroadservice') end)



