-- ERS_INTEGRATION CONTEXT MENU
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
RegisterNetEvent('ersi:client:openVehicleDetail', function(v)
    lib.registerContext({
        id = 'vehicle_detail_menu',
        title = 'Vehicle Details',
        menu = 'vehicle_list_menu',
        options = {
            { title = 'Owner: ' .. (v.owner_name or 'N/A'), icon = 'user' },
            { title = 'Plate: ' .. (v.license_plate or 'N/A'), icon = 'car' },
            { title = 'Vehicle: ' .. (v.make or 'N/A') .. ' ' .. (v.model or ''), icon = 'car-side' },
            { title = 'Insurance: ' .. tostring(v.insurance), icon = 'shield' },
            { title = 'Stolen: ' .. tostring(v.stolen), icon = 'skull' },
            { title = 'BOLO: ' .. tostring(v.bolo), icon = 'triangle-exclamation' }
        }
    })

    lib.showContext('vehicle_detail_menu')
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

RegisterNetEvent('ersi:client:openPedDetail', function(p)
    lib.registerContext({
        id = 'ped_detail_menu',
        title = 'ID Details',
        menu = 'ped_list_menu',
        options = {
            { title = 'Name: ' .. (p.FirstName or 'N/A') .. ' ' .. (p.LastName or ''), icon = 'user' },
            { title = 'DOB: ' .. (p.DOB or 'N/A'), icon = 'calendar' },
            { title = 'Address: ' .. (p.Address or 'N/A'), icon = 'house' },
            { title = 'Location: ' .. (p.City or '') .. ', ' .. (p.State or ''), icon = 'map' },
            { title = 'Warrant: ' .. tostring(p.Wanted_Person), icon = 'gavel' }
        }
    })

    lib.showContext('ped_detail_menu')
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
                title = 'Caller: ' .. (c.callFirstName or 'N/A') .. ' ' .. (c.callLastName or ''),
                icon = 'user'
            },
            {
                title = 'Location: ' .. (c.callPostal or '') .. ' ' .. (c.callStreet or ''),
                icon = 'location-dot'
            },
            {
                title = 'Description: ' .. (c.callDesc or 'N/A'),
                icon = 'file-lines'
            },
            {
                title = 'Units Requested: ' .. (c.callUnits or 'N/A'),
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

RegisterNetEvent('ersi:client:openPlayerCallouts', function(callouts, playerName)
    local options = {}

    for i = 1, #callouts do
        local c = callouts[i]

        table.insert(options, {
            title = c.callName or 'Call',
            description = c.location or '',
            icon = 'bullhorn',
            onSelect = function()
                TriggerEvent('ersi:client:openCalloutDetailERS', c, playerName)
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
    lib.registerContext({
        id = 'ers_call_detail',
        title = playerName,
        menu = 'ers_callouts',
        options = {
            { title = 'Call: ' .. (c.callName or 'N/A'), icon = 'bullhorn' },
            { title = 'Location: ' .. (c.location or 'N/A'), icon = 'location-dot' },
            { title = 'Description: ' .. (c.desc or 'N/A'), icon = 'file-lines' },
            { title = 'Vehicle: ' .. (c.vehicle or 'N/A'), icon = 'car' },
            { title = 'Time: ' .. (c.time or 'N/A'), icon = 'clock' }
        }
    })

    lib.showContext('ers_call_detail')
end)

