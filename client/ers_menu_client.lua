-- -- ERS_INTEGRATION TABLET & CONTEXT MENU --
local DispatchAlerts = {}
local MAX_ALERTS = 15
-- Animations
local tabletProp = nil
local tabletOpen = false

local decodeVehicleCache = {}
local activeDecodeSoundId = nil

local function getVehicleDisplayName(vehicle)
    local model = GetEntityModel(vehicle)
    local display = GetDisplayNameFromVehicleModel(model)
    local label = GetLabelText(display)

    if label == 'NULL' or not label then
        label = display
    end

    return label or 'Vehicle'
end

RegisterNUICallback('getNearbyDecodeVehicles', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    decodeVehicleCache = {}

    local vehicles = GetGamePool('CVehicle')
    local results = {}

    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehCoords = GetEntityCoords(vehicle)
            local dist = #(coords - vehCoords)

            if dist <= 12.0 then
                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local plate = GetVehicleNumberPlateText(vehicle)

                decodeVehicleCache[netId] = vehicle

                results[#results + 1] = {
                    netId = netId,
                    plate = plate,
                    label = getVehicleDisplayName(vehicle),
                    distance = math.floor(dist + 0.5)
                }
            end
        end
    end

    table.sort(results, function(a, b)
        return a.distance < b.distance
    end)

    SendNUIMessage({
        action = 'receiveNearbyDecodeVehicles',
        vehicles = results
    })

    cb(true)
end)



local function playDecodeHorn(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    StartVehicleHorn(vehicle, 120, `HELDDOWN`, false)
    Wait(180)
    StartVehicleHorn(vehicle, 120, `HELDDOWN`, false)
end

local decodeLoopActive = false

local function startDecodeSound(vehicle)
    if decodeLoopActive then return end

    decodeLoopActive = true

    CreateThread(function()
        while decodeLoopActive do
            PlaySoundFrontend(-1, 'ATM_WINDOW', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
            Wait(650)
        end
    end)
end

local function stopDecodeSound()
    decodeLoopActive = false

    if activeDecodeSoundId then
        StopSound(activeDecodeSoundId)
        ReleaseSoundId(activeDecodeSoundId)
        activeDecodeSoundId = nil
    end
end

local function startDecodeAlarm(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, 6000)
    StartVehicleAlarm(vehicle)
end

local function giveDecodedVehicleKeys(vehicle, plate)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    plate = plate or GetVehicleNumberPlateText(vehicle)

    -- qbx_vehiclekeys support
    if GetResourceState('qbx_vehiclekeys') == 'started' then
        pcall(function()
            exports.qbx_vehiclekeys:GiveKeys(vehicle)
        end)
    end

    -- qb-vehiclekeys support
    if GetResourceState('qb-vehiclekeys') == 'started' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    end
end

RegisterNUICallback('startVehicleDecode', function(data, cb)
    local netId = tonumber(data.netId)

    if not netId then
        SendNUIMessage({
            action = 'decodeFinished',
            success = false,
            message = 'Invalid vehicle selected'
        })

        cb(true)
        return
    end

    CreateThread(function()
        local vehicle = NetworkGetEntityFromNetworkId(netId)

        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
            SendNUIMessage({
                action = 'decodeFinished',
                success = false,
                message = 'Vehicle no longer nearby'
            })

            return
        end

        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        local vehCoords = GetEntityCoords(vehicle)
        local dist = #(playerCoords - vehCoords)

        if dist > 15.0 then
            SendNUIMessage({
                action = 'decodeFinished',
                success = false,
                message = 'Vehicle is too far away'
            })

            return
        end

        local plate = data.plate or GetVehicleNumberPlateText(vehicle)

        -- Start decode effects
        playDecodeHorn(vehicle)
        startDecodeSound(vehicle)

        -- Start alarm right after decode begins
        Wait(250)
        startDecodeAlarm(vehicle)

        Wait(4000)

        stopDecodeSound()

        vehicle = NetworkGetEntityFromNetworkId(netId)

        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
            SendNUIMessage({
                action = 'decodeFinished',
                success = false,
                message = 'Vehicle no longer nearby'
            })

            return
        end

        -- Unlock vehicle
        TriggerServerEvent('qb-vehiclekeys:server:setVehLockState', netId, 1)
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleDoorsLockedForAllPlayers(vehicle, false)

        -- Give vehicle keys
        giveDecodedVehicleKeys(vehicle, plate)

        -- Success feedback
        playDecodeHorn(vehicle)

        SetVehicleLights(vehicle, 2)
        Wait(250)
        SetVehicleLights(vehicle, 1)
        Wait(200)
        SetVehicleLights(vehicle, 0)

        if exports.qbx_core then
            exports.qbx_core:Notify('Decode Successful! Vehicle fob data acquired', 'success')
        else
            TriggerEvent('QBCore:Notify', 'Decode Successful! Vehicle fob data acquired', 'success')
        end

        SendNUIMessage({
            action = 'decodeFinished',
            success = true,
            message = ('%s unlocked / keys acquired'):format(plate or 'Vehicle')
        })
    end)

    cb(true)
end)

RegisterNUICallback('cancelVehicleDecodeSound', function(data, cb)
    stopDecodeSound()
    cb(true)
end)

RegisterNetEvent('ps-dispatch:client:notify', function(data)
    if not data then return end

    local alert = {
        title = data.title or "Dispatch",
        message = data.message or "",
        code = data.code or "",
        street = data.street or "Unknown",
        priority = data.priority or 1,
    }

    table.insert(DispatchAlerts, 1, alert)

    if #DispatchAlerts > MAX_ALERTS then
        table.remove(DispatchAlerts)
    end
end)



local function stopTabletAnim()
    tabletOpen = false

    local ped = PlayerPedId()

    if tabletProp and DoesEntityExist(tabletProp) then
        DetachEntity(tabletProp, true, true)
        DeleteEntity(tabletProp)
        tabletProp = nil
    end

    ClearPedSecondaryTask(ped)
    ClearPedTasks(ped)
end

local function startTabletAnim()
    stopTabletAnim()

    tabletOpen = true

    local ped = PlayerPedId()
    local dict = 'amb@code_human_in_bus_passenger_idles@female@tablet@base'
    local anim = 'base'
    local model = `prop_cs_tablet`

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) end

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local coords = GetEntityCoords(ped)
    tabletProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)

    AttachEntityToEntity(
        tabletProp,
        ped,
        GetPedBoneIndex(ped, 28422),
        -0.025, 0.005, -0.065,
        10.0, 160.0, 0.0,
        true, true, false, true, 1, true
    )

    TaskPlayAnim(ped, dict, anim, 3.0, 3.0, -1, 49, 0, false, false, false)
end

-- RegisterNUICallback('playSound', function(data, cb)
--     local sound = data.sound or 'click'

--     if sound == 'open' then
--         PlaySoundFrontend(-1, 'ATM_WINDOW', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
--     elseif sound == 'close' then
--         PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
--     else
--         PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
--     end

--     cb(true)
-- end)

RegisterNetEvent('ersi:client:useDatabaseTablet', function()
    TriggerServerEvent('ersi:server:getDatabaseUIData')
end)

RegisterNUICallback('playTabletSound', function(data, cb)
    local audioName = data.audioName or 'NAV_UP_DOWN'
    local audioRef = data.audioRef or 'HUD_FRONTEND_DEFAULT_SOUNDSET'

    PlaySoundFrontend(-1, audioName, audioRef, true)

    cb(true)
end)

RegisterNUICallback('triggerServiceEvent', function(data, cb)
    if data and data.event then
        TriggerEvent(data.event)
    end

    cb('ok')
end)

RegisterNUICallback('updateReport', function(data, cb)
    TriggerServerEvent('ersi:server:updateReport', data.reportId, data.report)
    cb(true)
end)

RegisterNUICallback('updateTabletBackground', function(data, cb)
    TriggerServerEvent('ersi:server:updateTabletBackground', data)
    cb(true)
end)

RegisterNUICallback('saveTabletBackground', function(data, cb)
    TriggerServerEvent('ersi:server:updateTabletBackground', data)
    cb(true)
end)

RegisterNUICallback('tabletAction', function(data, cb)
    local action = data.action

    local actions = {
        completeCallout = function()
            TriggerEvent('ersi:callouts:complete')
        end,

        dutyPolice = function()
            TriggerServerEvent('ers:server:TogglePoliceShift')
        end,

        dispatch = function()
            TriggerEvent('ersi:dispatch:open')
        end,

        acceptCallout = function()
            TriggerEvent('ersi:callouts:accept')
        end,

        requestCallout = function()
            TriggerEvent('ersi:callout:request')
        end,

        toggleCallouts = function()
            TriggerEvent('ersi:callouts:toggle')
        end,

        speedzone = function()
            TriggerEvent('ersi:speedzone')
        end,

        placeobjects = function()
            TriggerEvent('ersi:placeobjects')
        end,

        requestPolice = function()
            TriggerEvent('ersi:call:police')
        end,

        requestAmbulance = function()
            TriggerEvent('ersi:call:ambulance')
        end,

        requestFire = function()
            TriggerEvent('ersi:call:requestfire')
        end,

        requestTow = function()
            TriggerEvent('ersi:call:tow')
        end,

        requestTaxi = function()
            TriggerEvent('ersi:call:taxi')
        end,

        requestMechanic = function()
            TriggerEvent('ersi:call:mechanic')
        end,

        requestCoroner = function()
            TriggerEvent('ersi:call:coroner')
        end,

        requestAnimalRescue = function()
            TriggerEvent('ersi:call:animalrescue')
        end,

        requestRoadService = function()
            TriggerEvent('ersi:call:roadservice')
        end,

        cancelPolice = function()
            TriggerEvent('ersi:call:cancelpolice')
        end,

        cancelAmbulance = function()
            TriggerEvent('ersi:call:cancelambulance')
        end,

        cancelFire = function()
            TriggerEvent('ersi:call:cancelfire')
        end,

        cancelTow = function()
            TriggerEvent('ersi:call:canceltow')
        end,

        cancelTaxi = function()
            TriggerEvent('ersi:call:canceltaxi')
        end,

        cancelMechanic = function()
            TriggerEvent('ersi:call:cancelmechanic')
        end,

        cancelCoroner = function()
            TriggerEvent('ersi:call:cancelcoroner')
        end,

        cancelAnimalRescue = function()
            TriggerEvent('ersi:call:cancelanimalrescue')
        end,

        cancelRoadService = function()
            TriggerEvent('ersi:call:cancelroadservice')
        end
    }

    if actions[action] then
        actions[action]()
    end

    cb(true)
end)

RegisterNUICallback('updateProfilePicture', function(data, cb)
    TriggerServerEvent('ersi:server:updateProfilePicture', data)
    cb(true)
end)

RegisterNUICallback('refreshDatabase', function(_, cb)
    TriggerServerEvent('ersi:server:getDatabaseUIData')
    cb(true)
end)

RegisterNUICallback('setUnitStatus', function(data, cb)
    TriggerServerEvent('ersi:server:setUnitStatus', data.status)
    cb(true)
end)

RegisterNetEvent('ersi:client:openVehicleListMenu', function(vehicleList)
    local options = {}

    for i = 1, #vehicleList do
        local v = vehicleList[i]

        table.insert(options, {
            title = (v.license_plate or 'UNKNOWN'),
            description = (v.make or 'N/A') .. ' ' .. (v.model or ''),
            icon = 'car',
            onSelect = function()
                TriggerEvent('ersi:client:openVehicleDetail', v)
            end
        })
    end

    lib.registerContext({
        id = 'vehicle_list_menu',
        title = 'Vehicle Records',
        menu = 'police_main_menu',
        options = options
    })

    lib.showContext('vehicle_list_menu')
end)

-- RegisterNetEvent('ersi:client:openVehicleDetail', function(v)
--     lib.registerContext({
--         id = 'vehicle_detail_menu',
--         title = 'Vehicle Details',
--         menu = 'vehicle_list_menu',
--         options = {
--             { title = 'Owner: ' .. (v.owner_name or 'N/A'), icon = 'user' },
--             { title = 'Plate: ' .. (v.license_plate or 'N/A'), icon = 'car' },
--             { title = 'Vehicle: ' .. (v.make or 'N/A') .. ' ' .. (v.model or ''), icon = 'car-side' },
--             { title = 'Insurance: ' .. tostring(v.insurance), icon = 'shield' },
--             { title = 'Stolen: ' .. tostring(v.stolen), icon = 'skull' },
--             { title = 'BOLO: ' .. tostring(v.bolo), icon = 'triangle-exclamation' }
--         }
--     })

--     lib.showContext('vehicle_detail_menu')
-- end)

local function yesNo(value)
    return value and 'Yes' or 'No'
end

RegisterNetEvent('ersi:client:openVehicleDetail', function(v)
    lib.registerContext({
        id = 'vehicle_detail_menu',
        title = 'Vehicle Details',
        menu = 'vehicle_list_menu',
        options = {
            {
                title = 'Owner Info',
                description = v.owner_name or 'N/A',
                icon = 'user',
                onSelect = function()
                    TriggerEvent('ersi:client:openVehicleOwnerInfo', v)
                end
            },
            {
                title = 'Vehicle Info',
                description = (v.make or 'N/A') .. ' ' .. (v.model or ''),
                icon = 'car-side',
                onSelect = function()
                    TriggerEvent('ersi:client:openVehicleInfo', v)
                end
            },
            {
                title = 'Registration / Status',
                description = 'Insurance, MOT, tax, stolen, BOLO',
                icon = 'clipboard-check',
                onSelect = function()
                    TriggerEvent('ersi:client:openVehicleStatus', v)
                end
            },
            {
                title = 'Driver Info',
                description = v.vehicle_has_driver and 'Driver detected' or 'No driver detected',
                icon = 'person',
                onSelect = function()
                    TriggerEvent('ersi:client:openVehicleDriverInfo', v)
                end
            },
            {
                title = 'Technical Info',
                description = 'Net ID, Unique ID, model hash',
                icon = 'gear',
                onSelect = function()
                    TriggerEvent('ersi:client:openVehicleTechnicalInfo', v)
                end
            }
        }
    })

    lib.showContext('vehicle_detail_menu')
end)

RegisterNetEvent('ersi:client:openVehicleOwnerInfo', function(v)
    lib.registerContext({
        id = 'vehicle_owner_info_menu',
        title = 'Owner Info',
        menu = 'vehicle_detail_menu',
        options = {
            {
                title = 'Owner',
                description = v.owner_name or 'N/A',
                icon = 'user'
            },
            {
                title = 'Plate',
                description = v.license_plate or 'N/A',
                icon = 'id-card'
            }
        }
    })

    lib.showContext('vehicle_owner_info_menu')
end)

RegisterNetEvent('ersi:client:openVehicleInfo', function(v)
    lib.registerContext({
        id = 'vehicle_info_menu',
        title = 'Vehicle Info',
        menu = 'vehicle_detail_menu',
        options = {
            {
                title = 'Make',
                description = v.make or 'N/A',
                icon = 'industry'
            },
            {
                title = 'Model',
                description = v.model or 'N/A',
                icon = 'car'
            },
            {
                title = 'Class Name',
                description = v.vehicle_class_from_name or 'Unknown',
                icon = 'tags'
            },
            {
                title = 'Vehicle Class',
                description = tostring(v.vehicle_class or 'Unknown'),
                icon = 'layer-group'
            },
            {
                title = 'Primary Color',
                description = v.color or 'Unknown',
                icon = 'palette'
            },
            {
                title = 'Secondary Color',
                description = v.color_secondary or 'Unknown',
                icon = 'palette'
            },
            {
                title = 'Vehicle Picture',
                description = v.vehicle_picture_url or 'N/A',
                icon = 'image'
            }
        }
    })

    lib.showContext('vehicle_info_menu')
end)

RegisterNetEvent('ersi:client:openVehicleStatus', function(v)
    lib.registerContext({
        id = 'vehicle_status_menu',
        title = 'Registration / Status',
        menu = 'vehicle_detail_menu',
        options = {
            {
                title = 'Insurance',
                description = yesNo(v.insurance),
                icon = 'shield',
                iconColor = v.insurance and 'green' or 'red'
            },
            {
                title = 'MOT',
                description = yesNo(v.mot),
                icon = 'clipboard-check',
                iconColor = v.mot and 'green' or 'red'
            },
            {
                title = 'Tax',
                description = yesNo(v.tax),
                icon = 'file-invoice-dollar',
                iconColor = v.tax and 'green' or 'red'
            },
            {
                title = 'Stolen',
                description = yesNo(v.stolen),
                icon = 'skull',
                iconColor = v.stolen and 'red' or 'green'
            },
            {
                title = 'BOLO',
                description = yesNo(v.bolo),
                icon = 'triangle-exclamation',
                iconColor = v.bolo and 'red' or 'green'
            },
            {
                title = 'BOLO Description',
                description = v.bolo_description or 'Unknown',
                icon = 'file-lines'
            }
        }
    })

    lib.showContext('vehicle_status_menu')
end)

RegisterNetEvent('ersi:client:openVehicleDriverInfo', function(v)
    lib.registerContext({
        id = 'vehicle_driver_info_menu',
        title = 'Driver Info',
        menu = 'vehicle_detail_menu',
        options = {
            {
                title = 'Has Driver',
                description = tostring(v.vehicle_has_driver or 'Unknown'),
                icon = 'person'
            },
            {
                title = 'Driver Ped',
                description = tostring(v.driverPed or 'N/A'),
                icon = 'user'
            },
            {
                title = 'Driver Ped Model',
                description = tostring(v.driverPedModel or 'N/A'),
                icon = 'person-rays'
            }
        }
    })

    lib.showContext('vehicle_driver_info_menu')
end)

RegisterNetEvent('ersi:client:openVehicleTechnicalInfo', function(v)
    lib.registerContext({
        id = 'vehicle_technical_info_menu',
        title = 'Technical Info',
        menu = 'vehicle_detail_menu',
        options = {
            {
                title = 'Vehicle Net ID',
                description = tostring(v.vehNetID or 'N/A'),
                icon = 'network-wired'
            },
            {
                title = 'Unique ID',
                description = tostring(v.uniqueID or 'N/A'),
                icon = 'fingerprint'
            },
            {
                title = 'Model Hash',
                description = tostring(v.vehicleModelHash or 'Unknown'),
                icon = 'hashtag'
            }
        }
    })

    lib.showContext('vehicle_technical_info_menu')
end)


RegisterNetEvent('ersi:client:openPedListMenu', function(pedList)
    local options = {}

    for i = 1, #pedList do
        local p = pedList[i]

        table.insert(options, {
            title = (p.FirstName or 'N/A') .. ' ' .. (p.LastName or ''),
            description = p.DOB or 'No DOB',
            icon = 'user',
            onSelect = function()
                TriggerEvent('ersi:client:openPedDetail', p)
            end
        })
    end

    lib.registerContext({
        id = 'ped_list_menu',
        title = 'Ped Records',
        menu = 'police_main_menu',
        options = options
    })

    lib.showContext('ped_list_menu')
end)


local function cleanFaIcon(icon, fallback)
    if not icon or icon == 'N/A' then return fallback end
    return icon:gsub('fa[srb]? fa%-', '')
end

local function yesNo(value)
    return value and 'Yes' or 'No'
end

RegisterNetEvent('ersi:client:openPedDetail', function(p)
    local flags = p.FlagsOrMarkers or {}

    lib.registerContext({
        id = 'ped_detail_menu',
        title = 'ID Details',
        menu = 'ped_list_menu',
        options = {
            {
                title = 'Personal Info',
                description = (p.FirstName or 'N/A') .. ' ' .. (p.LastName or ''),
                icon = 'user',
                onSelect = function()
                    TriggerEvent('ersi:client:openPedPersonalInfo', p)
                end
            },
            {
                title = 'Contact Info',
                description = (p.City or 'N/A') .. ', ' .. (p.State or 'N/A'),
                icon = 'address-card',
                onSelect = function()
                    TriggerEvent('ersi:client:openPedContactInfo', p)
                end
            },
            {
                title = 'Licenses',
                description = 'View license status',
                icon = 'id-card',
                onSelect = function()
                    TriggerEvent('ersi:client:openPedLicenses', p)
                end
            },
            {
                title = 'Flags / Markers',
                description = (flags.wanted_person or flags.active_warrant or p.Wanted_Person) and 'Active alerts found' or 'No major alerts',
                icon = 'triangle-exclamation',
                iconColor = (flags.wanted_person or flags.active_warrant or p.Wanted_Person) and 'red' or 'green',
                onSelect = function()
                    TriggerEvent('ersi:client:openPedFlags', p)
                end
            },
            {
                title = 'Technical Info',
                description = 'Model, Unique ID, Net ID',
                icon = 'gear',
                onSelect = function()
                    TriggerEvent('ersi:client:openPedTechnicalInfo', p)
                end
            }
        }
    })

    lib.showContext('ped_detail_menu')
end)

RegisterNetEvent('ersi:client:openPedPersonalInfo', function(p)
    lib.registerContext({
        id = 'ped_personal_info_menu',
        title = 'Personal Info',
        menu = 'ped_detail_menu',
        options = {
            {
                title = 'Name',
                description = (p.FirstName or 'N/A') .. ' ' .. (p.LastName or ''),
                icon = 'user'
            },
            {
                title = 'DOB',
                description = p.DOB or 'N/A',
                icon = 'calendar'
            },
            {
                title = 'Gender',
                description = p.Gender or 'N/A',
                icon = 'venus-mars'
            },
            {
                title = 'Nationality',
                description = p.Nationality or 'N/A',
                icon = 'flag'
            },
            {
                title = 'Unique ID',
                description = tostring(p.uniqueID or 'N/A'),
                icon = 'fingerprint'
            },
            {
                title = 'Profile Picture',
                description = p.ProfilePicture or 'N/A',
                icon = 'image'
            }
        }
    })

    lib.showContext('ped_personal_info_menu')
end)

RegisterNetEvent('ersi:client:openPedContactInfo', function(p)
    lib.registerContext({
        id = 'ped_contact_info_menu',
        title = 'Contact Info',
        menu = 'ped_detail_menu',
        options = {
            {
                title = 'Phone Number',
                description = p.PhoneNumber or 'N/A',
                icon = 'phone'
            },
            {
                title = 'Email',
                description = p.Email or 'N/A',
                icon = 'envelope'
            },
            {
                title = 'Address',
                description = p.Address or 'N/A',
                icon = 'house'
            },
            {
                title = 'Address Type',
                description = p.AddressType or 'N/A',
                icon = 'building'
            },
            {
                title = 'City',
                description = p.City or 'N/A',
                icon = 'city'
            },
            {
                title = 'State',
                description = p.State or 'N/A',
                icon = 'map'
            },
            {
                title = 'Postal Code',
                description = p.PostalCode or 'N/A',
                icon = 'location-dot'
            }
        }
    })

    lib.showContext('ped_contact_info_menu')
end)

RegisterNetEvent('ersi:client:openPedLicenses', function(p)
    lib.registerContext({
        id = 'ped_licenses_menu',
        title = 'Licenses',
        menu = 'ped_detail_menu',
        options = {
            {
                title = 'Car License',
                description = p.License_Car or 'N/A',
                icon = cleanFaIcon(p.License_Car_Icon, 'car'),
                iconColor = p.License_Car_Colour
            },
            {
                title = 'Motorcycle License',
                description = p.License_Bike or yesNo(p.License_Bike_Is_Valid),
                icon = cleanFaIcon(p.License_Bike_Icon, 'motorcycle'),
                iconColor = p.License_Bike_Colour
            },
            {
                title = 'Pilot License',
                description = p.License_Pilot or 'N/A',
                icon = cleanFaIcon(p.License_Pilot_Icon, 'plane'),
                iconColor = p.License_Pilot_Colour
            },
            {
                title = 'CDL License',
                description = p.License_Truck or 'N/A',
                icon = cleanFaIcon(p.License_Truck_Icon, 'truck'),
                iconColor = p.License_Truck_Colour
            },
            {
                title = 'Boat License',
                description = p.License_Boat or yesNo(p.License_Boat_Is_Valid),
                icon = cleanFaIcon(p.License_Boat_Icon, 'ship')
            }
        }
    })

    lib.showContext('ped_licenses_menu')
end)

RegisterNetEvent('ersi:client:openPedFlags', function(p)
    local flags = p.FlagsOrMarkers or {}
    local options = {}

    local function addFlag(enabled, label, icon)
        if enabled then
            options[#options + 1] = {
                title = label,
                description = 'Active',
                icon = icon or 'triangle-exclamation',
                iconColor = 'red'
            }
        end
    end

    addFlag(flags.wanted_person or p.Wanted_Person, 'Wanted Person', 'user-slash')
    addFlag(flags.active_warrant, 'Active Warrant', 'gavel')
    addFlag(flags.armed_and_dangerous, 'Armed and Dangerous', 'gun')
    addFlag(flags.traffic_violation, 'Traffic Violation', 'car-burst')
    addFlag(flags.drug_related, 'Drug Related', 'pills')
    addFlag(flags.gang_affiliation, 'Gang Affiliation', 'users')
    addFlag(flags.theft, 'Theft', 'mask')
    addFlag(flags.burglary, 'Burglary', 'house-lock')
    addFlag(flags.assault, 'Assault', 'hand-fist')
    addFlag(flags.kidnapping, 'Kidnapping', 'person-circle-exclamation')
    addFlag(flags.homicide, 'Homicide', 'skull')
    addFlag(flags.terrorism, 'Terrorism', 'bomb')
    addFlag(flags.sex_offense, 'Sex Offense', 'triangle-exclamation')
    addFlag(flags.mental_health_issues, 'Mental Health Issues', 'brain')
    addFlag(flags.other, 'Other Flag', 'circle-exclamation')

    if #options == 0 then
        options[#options + 1] = {
            title = 'No Active Flags',
            description = 'No markers found for this person',
            icon = 'circle-check',
            iconColor = 'green',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'ped_flags_menu',
        title = 'Flags / Markers',
        menu = 'ped_detail_menu',
        options = options
    })

    lib.showContext('ped_flags_menu')
end)

RegisterNetEvent('ersi:client:openPedTechnicalInfo', function(p)
    lib.registerContext({
        id = 'ped_technical_info_menu',
        title = 'Technical Info',
        menu = 'ped_detail_menu',
        options = {
            {
                title = 'Entity Model',
                description = tostring(p.entityModel or 'N/A'),
                icon = 'cube'
            },
            {
                title = 'Unique ID',
                description = tostring(p.uniqueID or 'N/A'),
                icon = 'fingerprint'
            },
            {
                title = 'Ped Net ID',
                description = tostring(p.PedNetId or 'N/A'),
                icon = 'network-wired'
            }
        }
    })

    lib.showContext('ped_technical_info_menu')
end)

RegisterNetEvent('ersi:client:openCalloutListMenu', function(callList)
    local options = {}

    for i = 1, #callList do
        local c = callList[i]

        table.insert(options, {
            title = c.callName or '911 Call',
            description = (c.callPostal or '') .. ' ' .. (c.callStreet or ''),
            icon = 'bullhorn',
            onSelect = function()
                TriggerEvent('ersi:client:openCalloutDetail', c)
            end
        })
    end

    lib.registerContext({
        id = 'callout_list_menu',
        title = 'Callout History',
        menu = 'police_main_menu', 
        options = options
    })

    lib.showContext('callout_list_menu')
end)

RegisterNetEvent('ersi:client:openCalloutDetail', function(c)
    lib.registerContext({
        id = 'callout_detail_menu',
        title = c.callName or 'Call Details',
        menu = 'callout_list_menu',
        options = {
            {
                title = 'Caller',
                description = (c.callFirstName or 'N/A') .. ' ' .. (c.callLastName or ''),
                icon = 'user'
            },
            {
                title = 'Call Type',
                description = c.callName or 'N/A',
                icon = 'bullhorn'
            },
            {
                title = 'Location',
                description = ((c.callPostal or '') .. ' ' .. (c.callStreet or '')):gsub('^%s*(.-)%s*$', '%1'),
                icon = 'location-dot'
            },
            {
                title = 'Description',
                description = c.callDesc or 'N/A',
                icon = 'file-lines'
            },
            {
                title = 'Units Requested',
                description = c.callUnits or 'N/A',
                icon = 'users'
            }
        }
    })

    lib.showContext('callout_detail_menu')
end)

local recordTextActive = false

RegisterNetEvent('ersi:client:recordAddedTextUI', function(data)
    if recordTextActive then
        lib.hideTextUI()
    end

    recordTextActive = true

    lib.showTextUI(data.message, {
        icon = data.icon or 'database',
        style = {
            backgroundColor = '#141517',
            color = '#4caf50'
        }
    })

    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

    SetTimeout(8000, function()
        if recordTextActive then
            lib.hideTextUI()
            recordTextActive = false
        end
    end)
end)

RegisterNUICallback('searchCharges', function(data, cb)
    TriggerServerEvent('ersi:server:searchCharges', data.search or '')
    cb(true)
end)

RegisterNUICallback('saveReport', function(data, cb)
    TriggerServerEvent('ersi:server:saveReport', data)
    cb(true)
end)

RegisterNUICallback('getReports', function(_, cb)
    TriggerServerEvent('ersi:server:getReports')
    cb(true)
end)

RegisterNUICallback('getReportDetails', function(data, cb)
    TriggerServerEvent('ersi:server:getReportDetails', data.reportId)
    cb(true)
end)

RegisterNUICallback('getPedPreviousReports', function(data, cb)
    TriggerServerEvent('ersi:server:getPedPreviousReports', data.ped_identifier)
    cb(true)
end)

RegisterNetEvent('ersi:client:receiveReports', function(reports)
    SendNUIMessage({
        action = 'reportsList',
        reports = reports
    })
end)

RegisterNetEvent('ersi:client:receiveReportDetails', function(details)
    SendNUIMessage({
        action = 'reportDetails',
        details = details
    })
end)

RegisterNetEvent('ersi:client:receivePedPreviousReports', function(pedIdentifier, reports)
    SendNUIMessage({
        action = 'pedPreviousReports',
        ped_identifier = pedIdentifier,
        reports = reports
    })
end)

RegisterNetEvent('ersi:client:receiveChargeResults', function(charges)
    SendNUIMessage({
        action = 'chargeResults',
        charges = charges
    })
end)

RegisterNetEvent('ersi:client:openPoliceDatabaseMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = 'DATABASE',
            isMenuHeader = true
        },
        {
            header = '🚗 Plate Check History',
            icon = 'fa-solid fa-car',
            params = {
                event = 'ersi:client:plateCheckHistory'
            }
        },
        {
            header = '🪪 ID Check History',
            icon = 'fa-solid fa-id-card',
            params = {
                event = 'ersi:client:idCheckHistory'
            }
        },
        {
            header = '📢 Callout History',
            icon = 'fa-solid fa-bullhorn',
            params = {
                event = 'ersi:client:calloutHistory'
            }
        },
        {
            header = '👥 ERS Personnel',
            icon = 'fa-solid fa-users',
            params = {
                event = 'ersi:client:ersPersonnel'
            }
        }
    })
end)

RegisterNetEvent('ersi:client:plateCheckHistory', function()
    TriggerServerEvent('ersi:server:getVehicleMenuData')
end)

RegisterNetEvent('ersi:client:idCheckHistory', function()
    TriggerServerEvent('ersi:server:getPedMenuData')
end)

RegisterNetEvent('ersi:client:calloutHistory', function()
    TriggerServerEvent('ersi:server:getCalloutMenuData')
end)

RegisterNetEvent('ersi:client:ersPersonnel', function()
    TriggerServerEvent('ersi:server:getERSPlayers')
end)


RegisterNetEvent('ersi:client:openERSPlayerList', function(players)
    local options = {}

    for i = 1, #players do
        local p = players[i]

        table.insert(options, {
            title = p.name,
            description = (p.job or 'Unknown') .. (p.active and ' (On Duty)' or ' (Off Duty)'),
            icon = 'user',
            onSelect = function()
                TriggerServerEvent('ersi:server:getPlayerCallouts', p.id)
            end
        })
    end

    lib.registerContext({
        id = 'ers_player_list',
        title = 'ERS Personnel',
        menu = 'police_main_menu',
        options = options
    })

    lib.showContext('ers_player_list')
end)

RegisterNUICallback('getPersonnelDatabase', function(_, cb)
    TriggerServerEvent('ersi:server:getERSPersonnelDatabase')
    cb(true)
end)

RegisterNetEvent('ersi:client:receiveERSPersonnelDatabase', function(players)
    SendNUIMessage({
        action = 'personnelDatabase',
        personnel = players
    })
end)

RegisterNetEvent('ersi:client:tabletCallAlert', function(data)
    SendNUIMessage({
        action = 'tabletCallAlert',
        data = data
    })
end)

RegisterNetEvent('ersi:client:openPlayerCallouts', function(callouts, playerName)
    local options = {}

    for i = #callouts, 1, -1 do
        local c = callouts[i]

        table.insert(options, {
        title = (c.callName or 'Call') .. ' [' .. (c.time or '') .. ']',
        description = (c.location or '') .. ' | ' .. (c.vehicle or 'On Foot'),
        icon = 'bullhorn',
        onSelect = function()
            TriggerEvent('ersi:client:openCalloutDetailERS', c, displayName)
        end
    })
    end

    lib.registerContext({
        id = 'ers_callouts',
        title = playerName .. "'s Calls",
        menu = 'ers_player_list',
        options = options
    })

    lib.showContext('ers_callouts')
end)

RegisterNetEvent('ersi:client:openCalloutDetailERS', function(c, playerName)
    local displayName = (playerName and playerName ~= "") and playerName or "Officer"

    lib.registerContext({
        id = 'ers_call_detail',
        title = displayName .. " - Call Details",
        menu = 'ers_callouts',
        options = {
            {
                title = 'Call',
                description = c.callName or 'N/A',
                icon = 'bullhorn'
            },
            {
                title = 'Location',
                description = c.location or 'N/A',
                icon = 'location-dot'
            },
            {
                title = 'Description',
                description = c.desc or 'N/A',
                icon = 'file-lines'
            },
            {
                title = 'Vehicle',
                description = c.vehicle or 'On Foot',
                icon = 'car'
            },
            {
                title = 'Time',
                description = c.time or 'N/A',
                icon = 'clock'
            }
        }
    })

    lib.showContext('ers_call_detail')
end)

RegisterNetEvent('ersi:client:openFullDatabaseUI', function()
    TriggerServerEvent('ersi:server:getDatabaseUIData')
end)

RegisterNetEvent('ersi:client:openDatabaseUI', function(data)
    startTabletAnim()

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'openDatabase',
        data = data,
        dispatch = DispatchAlerts
    })
end)

RegisterNUICallback('closeDatabase', function(_, cb)
    SetNuiFocus(false, false)

    SendNUIMessage({
        action = 'closeDatabase'
    })

    stopTabletAnim()

    cb(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    stopTabletAnim()
end)
