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

local phoneProp = nil

RegisterNetEvent('ersi:client:PlayRadioAnimPhoneText', function()
    local ped = PlayerPedId()

    if phoneProp and DoesEntityExist(phoneProp) then
        DetachEntity(phoneProp, true, true)
        DeleteEntity(phoneProp)
        phoneProp = nil
    end

    -- Load anim
    local dict = 'cellphone@'
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    -- Load model
    local model = `prop_npc_phone_02`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    -- Create object
    local coords = GetEntityCoords(ped)
    phoneProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

    -- Attach to hand
    local bone = GetPedBoneIndex(ped, 28422)

    AttachEntityToEntity(
        phoneProp,
        ped,
        bone,
        0.02, 0.02, 0.0,   
        0.0, 0.0, 0.0,
        true, true, false, true, 1, true
    )

    TaskPlayAnim(ped, dict, 'cellphone_text_read_base', 3.0, 3.0, 3000, 49, 0, false, false, false)

    Wait(3000)

    if phoneProp and DoesEntityExist(phoneProp) then
        DetachEntity(phoneProp, true, true)
        DeleteEntity(phoneProp)
        phoneProp = nil
    end

    ClearPedTasks(ped)
end)

-- RegisterNetEvent('ersi:client:PlayRadioAnimPhoneTalk', function()
--     local ped = PlayerPedId()

--     -- Load anim
--     local dict = 'cellphone@'
--     RequestAnimDict(dict)
--     while not HasAnimDictLoaded(dict) do Wait(0) end

--     -- Load phone model
--     local model = `prop_npc_phone_02`
--     RequestModel(model)
--     while not HasModelLoaded(model) do Wait(0) end

--     -- Create phone
--     local coords = GetEntityCoords(ped)
--     local phone = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

--     -- Attach to right hand
--     local bone = GetPedBoneIndex(ped, 28422)

--     AttachEntityToEntity(
--         phone,
--         ped,
--         bone,
--         0.10, 0.03, 0.0,
--         -80.0, 0.0, 0.0,
--         true, true, false, true, 1, true
--     )

--     -- Play call animation (phone to ear)
--     TaskPlayAnim(ped, dict, 'cellphone_call_listen_base', 3.0, 3.0, 3000, 49, 0, false, false, false)

--     -- Cleanup
--     Wait(3000)

--     DeleteObject(phone)
--     ClearPedTasks(ped)
-- end)

RegisterNetEvent('ersi:client:PlayRadioAnimPhoneTalk', function()
    local ped = PlayerPedId()
    lib.playAnim(ped, 'cellphone@', 'cellphone_call_listen_base', 3.0, 3.0, 3000, 49)
end)

local textActive = false

RegisterNetEvent('ersi:client:incomingCallTextUI', function(message)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(message, {
        icon = 'phone',
        style = {
            backgroundColor = '#141517',
            color = '#ff4d4d'
        }
    })

    SetTimeout(8000, function()
        lib.hideTextUI()
    end)
end)
RegisterNetEvent('ersi:client:911CallTextUI', function(message)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(message, {
        icon = 'bullhorn',
        style = {
            backgroundColor = '#141517',
            color = '#ff4d4d'
        }
    })

    SetTimeout(8000, function()
        lib.hideTextUI()
    end)
end)
RegisterNetEvent('ersi:client:CallArriveTextUI', function(message)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(message, {
        icon = 'map-pin',
        style = {
            backgroundColor = '#141517',
            color = '#e8ad09'
        }
    })

    SetTimeout(8000, function()
        lib.hideTextUI()
    end)
end)
RegisterNetEvent('ersi:client:CallCompleteTextUI', function(message)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(message, {
        icon = 'map-pin',
        style = {
            backgroundColor = '#141517',
            color = '#e8ad09'
        }
    })

    SetTimeout(8000, function()
        lib.hideTextUI()
    end)
end)
RegisterNetEvent('ersi:client:PulloverTextUI', function(message)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(message, {
        icon = 'car',
        style = {
            backgroundColor = '#141517',
            color = '#e8ad09'
        }
    })

    SetTimeout(8000, function()
        lib.hideTextUI()
    end)
end)
-- Service Requests
RegisterNetEvent('ersi:client:TextUI:ServiceRequest', function(data)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    lib.showTextUI(data.message, {
        icon = data.icon or 'bell',
        style = {
            backgroundColor = data.color or '#141517',
            color = '#ffffff'
        }
    })

    if data.duration then
        SetTimeout(data.duration, function()
            lib.hideTextUI()
        end)
    end
end)


