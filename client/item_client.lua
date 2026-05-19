local phoneProp

local function stopDatabasePhone()
    local ped = PlayerPedId()

    ClearPedSecondaryTask(ped)

    if phoneProp and DoesEntityExist(phoneProp) then
        DeleteEntity(phoneProp)
        phoneProp = nil
    end
end

local function startDatabasePhone()
    local ped = PlayerPedId()

    stopDatabasePhone()

    local model = `prop_npc_phone_02`
    lib.requestModel(model)

    phoneProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, false)

    AttachEntityToEntity(
        phoneProp,
        ped,
        GetPedBoneIndex(ped, 28422),
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        true, true, false, true, 1, true
    )

    lib.playAnim(
        ped,
        'cellphone@',
        'cellphone_text_read_base',
        3.0,
        3.0,
        -1,
        49,
        0,
        false,
        false,
        false
    )

    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('ersi:client:openPoliceDatabaseItem', function()
    startDatabasePhone()

    lib.registerContext({
        id = 'police_main_menu',
        title = 'DATABASE',
        onExit = function()
            stopDatabasePhone()
        end,
        options = {
            {
                title = 'Plate Check History',
                icon = 'car',
                onSelect = function()
                    stopDatabasePhone()
                    TriggerServerEvent('ersi:server:getVehicleMenuData')
                end
            },
            {
                title = 'ID Check History',
                icon = 'id-card',
                onSelect = function()
                    stopDatabasePhone()
                    TriggerServerEvent('ersi:server:getPedMenuData')
                end
            },
            {
                title = 'Callout History',
                icon = 'bullhorn',
                onSelect = function()
                    stopDatabasePhone()
                    TriggerServerEvent('ersi:server:getCalloutMenuData')
                end
            },
            {
                title = 'ERS Personnel',
                icon = 'users',
                onSelect = function()
                    stopDatabasePhone()
                    TriggerServerEvent('ersi:server:getERSPlayers')
                end
            },
        }
    })

    lib.showContext('police_main_menu')
end)