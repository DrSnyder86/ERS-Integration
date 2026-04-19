local QBCore = exports['qb-core']:GetCoreObject()
local cache = { ped = PlayerPedId() }
local PlayerData = QBCore.Functions.GetPlayerData()
local lastCalloutData = nil
local currentCalloutData = nil
local lastPedData = nil

Config = Config or {}


RegisterNetEvent("ErsIntegration:OnAcceptedCalloutOffer", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration::OnAcceptedCalloutOffer", function(data)
    CalloutData = data
end)

RegisterNetEvent("ErsIntegration::OnCalloutCompletedSuccesfully", function(data)
    CalloutData = data
end)

-- RegisterNetEvent("ErsIntegration::OnPulloverStarted", function(data)
--     CalloutData = data
-- end)

RegisterNetEvent("ErsIntegration:client:SetPedData", function(data)
    PedData = data
end)

RegisterNetEvent("ErsIntegration:client:SetCalloutData", function(data)
    CalloutData = data
end)

--------------------------------------
---- ERS Stuff    --------------------
--------------------------------------

RegisterNetEvent('ersi:broom', function() ExecuteCommand('broom') end)
RegisterNetEvent('ersi:firehose', function() ExecuteCommand('hose') end)
RegisterNetEvent('ersi:stretcher', function() ExecuteCommand('stretcher') end)
RegisterNetEvent('ersi:client:radarFrontLock', function() ExecuteCommand('radar_fr_cam') end)
--RegisterNetEvent('ersi:client:useMDTTablet', function() ExecuteCommand('mdt') end)
RegisterNetEvent('ersi:mdt:toggle', function() ExecuteCommand('mdt') end)
RegisterNetEvent('ersi:dispatch:open', function() ExecuteCommand('dispatch') end)
RegisterNetEvent('ersi:callout:request', function() ExecuteCommand('requestcallout') end)
RegisterNetEvent('ersi:shift:toggle', function() ExecuteCommand('toggleshift') end)
RegisterNetEvent('ersi:callouts:toggle', function() ExecuteCommand('togglecallouts') end)
RegisterNetEvent('ersi:speedzone', function() ExecuteCommand('speedzones') end)
RegisterNetEvent('ersi:placeobjects', function() ExecuteCommand('placeobjects') end)

-- EXTRAS
-- RegisterNetEvent('autoems:request', function() ExecuteCommand('autoems') end)
RegisterNetEvent('ersi:tcs:toggle', function() ExecuteCommand('tcs') end)
RegisterNetEvent('ersi:multijob:toggle', function() ExecuteCommand('multijob') end)
RegisterNetEvent('ersi:escort:toggle', function() ExecuteCommand('escort') end)
RegisterNetEvent('ersi:emote:toggle', function() ExecuteCommand('emotemenu') end)
RegisterNetEvent('ersi:extra:menu', function() ExecuteCommand('extrasmenu') end)
RegisterNetEvent('ersi:crosshair:toggle', function() ExecuteCommand('togglecrosshair') end)

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


----------------------------------------
---- Get street and postal for pullover 
----------------------------------------
RegisterNetEvent('ErsIntegration:client:GetStreetAndPostal', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash or 0)

    local postal = exports['nearest-postal']:getPostal(coords)

    TriggerServerEvent('ErsIntegration:server:ReceiveStreetAndPostal', streetName, postal)
end)

----------------------------------------
---- Get street and postal for pullover end
----------------------------------------
RegisterNetEvent('ErsIntegration:client:GetStreetAndPostalEnd', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash or 0)
    local postal = exports['nearest-postal']:getPostal(coords)

    TriggerServerEvent('ErsIntegration:server:ReceiveStreetAndPostalEnd', streetName, postal)
end)
----------------------------------------
---- Get street and postal for pursuit
----------------------------------------
RegisterNetEvent('ErsIntegration:client:GetStreetAndPostalPursuit', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local streetName = GetStreetNameFromHashKey(streetHash or 0)
    local postal = exports['nearest-postal']:getPostal(coords)

    TriggerServerEvent('ErsIntegration:server:ReceiveStreetAndPostalPursuit', streetName, postal)
end)

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
---- PURSUIT BACKUP - WIP--------------
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

---------------------------------------
---- Weapon Flashlight Persistence ---
---------------------------------------
CreateThread(function()
    local lastState = nil

    while true do
        Wait(1000) 

        if Config.EnableFlashlightWhileMoving ~= lastState then
            SetFlashLightKeepOnWhileMoving(Config.EnableFlashlightWhileMoving)
            lastState = Config.EnableFlashlightWhileMoving
        end
    end
end)

---------------------------------------
---- Radar Zoom ---
---------------------------------------

if not Config.EnableRadarZoom then return end

local function UpdateRadarZoom()
    local ped = PlayerPedId()
    local zoom = IsPedInAnyVehicle(ped, false) and 1200 or 1000
    SetRadarZoom(zoom)
    return zoom
end

SetMapZoomDataLevel(0, 1.8, 0.9, 0.08, 0.0, 0.0)

local lastZoom = UpdateRadarZoom()

AddEventHandler('playerSpawned', function()
    lastZoom = UpdateRadarZoom()
end)

CreateThread(function()
    while true do
        Wait(500)
        local targetZoom = UpdateRadarZoom()
        if targetZoom ~= lastZoom then
            lastZoom = targetZoom
            SetRadarZoom(targetZoom)
        end
    end
end)

---------------------------------------
---- Crosshair ---
---------------------------------------
if not Config.EnableCrosshair then
    return
end

local crosshairEnabled = true

CreateThread(function()
    while true do
        local sleep = 500

        if crosshairEnabled and IsAimCamActive() then
            sleep = 0
            HideHudComponentThisFrame(14)
            drawCrosshair()
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('cl:update_c', function(bool)
    crosshairEnabled = bool
end)

RegisterCommand('togglecrosshair', function()
    crosshairEnabled = not crosshairEnabled

    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = false,
        args = {"Crosshair", crosshairEnabled and "Enabled" or "Disabled"}
    })
end, false)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/togglecrosshair', 'Toggle crosshair on or off')
end)

function drawCrosshair()
    DrawRect(0.5, 0.5, 0.001, 0.001, 255, 255, 255, 255)
end

---------------------------------------
---- Notifications and Animations ---
---------------------------------------
RegisterNetEvent('ersi:client:NotifyRadioTalk', function(message)
    local ped = PlayerPedId()

    -- Play radio animation
    lib.playAnim(ped, 'random@arrests', 'generic_radio_enter', 3.0, 3.0, 2000, 49)
    --lib.playAnim(ped, 'amb@code_human_police_investigate@idle_a', 'idle_b', 3.0, 3.0, 3000, 49)

    -- Show notification
    TriggerEvent('QBCore:Notify', message, 'success', 4000)
end)

RegisterNetEvent('ersi:client:NotifyRadioListen', function(message)
    local ped = PlayerPedId()

    -- Play radio animation
    lib.playAnim(ped, 'random@arrests', 'generic_radio_chatter', 3.0, 3.0, 2000, 49)

    -- Show notification
    TriggerEvent('QBCore:Notify', message, 'success', 4000)
end)

RegisterNetEvent('ersi:client:PlayRadioAnim', function()
    local ped = PlayerPedId()
    lib.playAnim(ped, 'random@arrests', 'generic_radio_chatter', 3.0, 3.0, 2000, 49)
end)
RegisterNetEvent('ersi:client:PlayRadioAnimPhoneText', function()
    local ped = PlayerPedId()
    lib.playAnim(ped, 'cellphone@', 'cellphone_text_read_base', 3.0, 3.0, 3000, 49)
end)
RegisterNetEvent('ersi:client:PlayRadioAnimPhoneTalk', function()
    local ped = PlayerPedId()
    lib.playAnim(ped, 'cellphone@', 'cellphone_call_listen_base', 3.0, 3.0, 3000, 49)
end)