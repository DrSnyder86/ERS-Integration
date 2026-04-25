---------------------------------------
---- Weapon Flashlight Persistence ---
---------------------------------------
if Config.EnableAll and Config.EnableFlashlightWhileMoving then
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
end

---------------------------------------
---- Radar Zoom ---
---------------------------------------

if Config.EnableAll and Config.EnableRadarZoom then
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
end

---------------------------------------
---- Crosshair ---
---------------------------------------
if Config.EnableAll and Config.EnableCrosshair then
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
end