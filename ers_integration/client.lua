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
