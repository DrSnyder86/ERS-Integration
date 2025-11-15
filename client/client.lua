local QBCore = exports['qb-core']:GetCoreObject()

Config = Config or {}
-----------------------------------
-- RADIAL MENU
-----------------------------------
Config.ERSMenus = {
    duty = {
        id = "ers_duty",
        icon = "clipboard-list",
        label = "ERS Duty",
        items = {
            { id = "toggle_police", icon = "user-shield", label = "Toggle Police Duty", server = "ers:server:TogglePoliceShift" },
            { id = "toggle_ambulance", icon = "briefcase-medical", label = "Toggle Ambulance Duty", server = "ers:server:ToggleAmbulanceShift" },
            { id = "toggle_fire", icon = "fire-extinguisher", label = "Toggle Fire Duty", server = "ers:server:ToggleFireShift" },
            { id = "toggle_tow", icon = "truck", label = "Toggle Tow Duty", server = "ers:server:ToggleTowShift" },
        }
    },

    utilities = {
        id = "ers_utilities",
        icon = "list-check",
        label = "ERS Utilities",
        items = {
            { id = "request_callout", icon = "bell", label = "Request 911 Call", event = "callout:request" },
            { id = "toggle_shift", icon = "user-clock", label = "Toggle Shift", event = "shift:toggle" },
            { id = "toggle_callouts", icon = "clipboard-list", label = "Toggle 911 Dispatch", event = "callouts:toggle" },
            { id = "wraith", icon = "car-side", label = "Wraith Radar", event = "wk:openRemote" },
            { id = "mdt_toggle", icon = "tablet-alt", label = "MDT Tablet", event = "mdt:toggle" },
            { id = "speedzone", icon = "triangle-exclamation", label = "Traffic Control", event = "custom:speedzone" },
        }
    },

    -- CANCEL REQUESTS CATEGORY
    cancel_requests = {
        icon = 'triangle-exclamation',
        label = 'Cancel Requests',
        items = {
            { id = 'cancel_ambulance',       icon = 'ambulance',        label = 'Cancel Ambulance',        event = 'call:cancelambulance' },
            { id = 'cancel_fire',            icon = 'truck',            label = 'Cancel Fire Unit',        event = 'call:cancelfire' },
            { id = 'cancel_police',          icon = 'shield-alt',       label = 'Cancel Police',           event = 'call:cancelpolice' },
            { id = 'cancel_coroner',         icon = 'skull-crossbones', label = 'Cancel Coroner',          event = 'call:cancelcoroner' },
            { id = 'cancel_taxi',            icon = 'taxi',             label = 'Cancel Taxi',             event = 'call:canceltaxi' },
            { id = 'cancel_tow',             icon = 'truck',            label = 'Cancel Tow',              event = 'call:canceltow' },
            { id = 'cancel_mechanic',        icon = 'wrench',           label = 'Cancel Mechanic',         event = 'call:cancelmechanic' },
            { id = 'cancel_animal_rescue',   icon = 'paw',              label = 'Cancel Animal Rescue',    event = 'call:cancelanimalrescue' },
            { id = 'cancel_roadservice',     icon = 'truck',            label = 'Cancel Road Service',     event = 'call:cancelroadservice' },
        }
    },

    -- SERVICE REQUESTS CATEGORY
    ersservices = {
        icon = 'clipboard-list',
        label = 'ERS Services',
        items = {
            { id = 'request_ambulance',     icon = 'ambulance',        label = 'Ambulance',      event = 'call:ambulance' },
            { id = 'request_police',        icon = 'shield-alt',       label = 'PD Transport',   event = 'call:police' },
            { id = 'request_tow',           icon = 'truck',            label = 'Tow',            event = 'call:tow' },
            { id = 'requestfire',           icon = 'truck',            label = 'Fire Unit',      event = 'custom:requestfire' },
            { id = 'request_coroner',       icon = 'skull-crossbones', label = 'Coroner',        event = 'call:coroner' },
            { id = 'request_mechanic',      icon = 'wrench',           label = 'Mechanic',       event = 'call:mechanic' },
            { id = 'request_roadservice',   icon = 'truck',            label = 'Road Service',   event = 'call:roadservice' },
            { id = 'request_taxi',          icon = 'taxi',             label = 'Taxi',           event = 'call:taxi' },
            { id = 'request_animal_rescue', icon = 'paw',              label = 'Animal Rescue',  event = 'call:animalrescue' },
        }
    },

    -- STATE DISPATCH CATEGORY
    dispatch = {
        icon = 'list-check',
        label = 'State Dispatch',
        items = {
            { id = 'trafficStop',      icon = 'car-side', label = '10-11',  event = 'ps-dispatch:client:trafficstop' },
            { id = 'emergencyButton',  icon = 'bell',     label = '10-99',  event = 'ps-dispatch:client:officerbackup' },
            { id = 'fireCall',         icon = 'bell',     label = 'FIRE',   event = 'ps-dispatch:client:firecall' },
            { id = 'enroute',          icon = 'bell',     label = '10-97',  event = 'ps-dispatch:client:enroute' },
            { id = 'onscene',          icon = 'bell',     label = '10-23',  event = 'ps-dispatch:client:onscene' },
            { id = 'codefour',         icon = 'bell',     label = 'Code-4', event = 'ps-dispatch:client:codefour' },
        }
    },

}
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


