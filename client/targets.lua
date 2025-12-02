-- target service
local AllowedShiftTypes = {
    police = true,
    ambulance = true,
    tow = true,
    fire = true
}

local function IsOnAllowedERSDuty()
    local src = PlayerId()
    local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
    local activeType = exports['night_ers']:getPlayerActiveServiceType(src)

    return isOnShift and AllowedShiftTypes[activeType] == true
end

--------------------------------------------------------------------------------
--  PED TARGET CALL AMBULANCE 
--------------------------------------------------------------------------------

local function IsPedAllowed(entity)
    if not DoesEntityExist(entity) then return false end
    if not IsEntityAPed(entity) then return false end
    if IsPedAPlayer(entity) then return false end -- block players if you want
    if not IsPedDeadOrDying(entity, true) then return false end -- MUST be downed
    return true
end

CreateThread(function()


    if exports.ox_target and exports.ox_target.addGlobalPed then

        exports.ox_target:addGlobalPed({
            {
                name = "ers_call_ambulance",
                icon = "fa-solid fa-truck-medical",
                label = "Call Ambulance",
                distance = 2.0,

                onSelect = function(data)
                    TriggerEvent("ersi:call:ambulance", data.entity)
                end,

                canInteract = function(entity)
                    return IsOnAllowedERSDuty() and IsPedAllowed(entity)
                end,
            }
        })

    elseif exports['qb-target'] then

        exports['qb-target']:AddTargetType("ped", {
            options = {
                {
                    type = "client",
                    event = "ersi:call:ambulance",
                    icon = "fa-solid fa-truck-medical",
                    label = "Call Ambulance",

                    canInteract = function(entity)
                        return IsOnAllowedERSDuty() and IsPedAllowed(entity)
                    end,
                }
            },
            distance = 2.0
        })

    end
end)

--------------------------------------------------------------------------------
--  PED TARGET CALL CORONER 
--------------------------------------------------------------------------------

local function IsPedAllowed(entity)
    if not DoesEntityExist(entity) then return false end
    if not IsEntityAPed(entity) then return false end
    if IsPedAPlayer(entity) then return false end -- block players if you want
    if not IsPedDeadOrDying(entity, false) then return false end
    return true
end

CreateThread(function()


    if exports.ox_target and exports.ox_target.addGlobalPed then

        exports.ox_target:addGlobalPed({
            {
                name = "ers_call_coroner",
                icon = "fa-solid fa-skull-crossbones",
                label = "Call Coroner",
                distance = 2.0,

                onSelect = function(data)
                    TriggerEvent("ersi:call:coroner", data.entity)
                end,

                canInteract = function(entity)
                    return IsOnAllowedERSDuty() and IsPedAllowed(entity)
                end,
            }
        })

    elseif exports['qb-target'] then

        exports['qb-target']:AddTargetType("ped", {
            options = {
                {
                    type = "client",
                    event = "ersi:call:coroner",
                    icon = "fa-solid fa-skull-crossbones",
                    label = "Call Coroner",

                    canInteract = function(entity)
                        return IsOnAllowedERSDuty() and IsPedAllowed(entity)
                    end,
                }
            },
            distance = 2.0
        })

    end
end)

-- tow service
CreateThread(function()

    -- OX Target
    if exports.ox_target and exports.ox_target.addGlobalVehicle then

        exports.ox_target:addGlobalVehicle({
            {
                name = "ers_cancel_tow",
                icon = "fa-solid fa-car-burst",
                label = "Call Tow",
                distance = 2.0,
                onSelect = function(data)
                    TriggerEvent("ersi:call:tow", data.entity)
                end,
                canInteract = function(entity, distance, coords, name)
                    return IsOnAllowedERSDuty()
                end
            }
        })

    -- QB Target
    elseif exports['qb-target'] then

        exports['qb-target']:AddTargetType("vehicle", {
            options = {
                {
                    type = "client",
                    event = "ersi:call:tow",
                    icon = "fa-solid fa-car-burst",
                    label = "Call Tow",
                    canInteract = function(entity)
                        return IsOnAllowedERSDuty()
                    end
                }
            },
            distance = 2.0
        })

    end
end)

-- mechanic
CreateThread(function()

    -- OX Target
    if exports.ox_target and exports.ox_target.addGlobalVehicle then

        exports.ox_target:addGlobalVehicle({
            {
                name = "ers_cancel_mechanic",
                icon = "fa-solid fa-wrench",
                label = "Call Mechanic",
                distance = 2.0,
                onSelect = function(data)
                    TriggerEvent("ersi:call:mechanic", data.entity)
                end,
                canInteract = function(entity, distance, coords, name)
                    return IsOnAllowedERSDuty()
                end
            }
        })

    -- QB Target
    elseif exports['qb-target'] then

        exports['qb-target']:AddTargetType("vehicle", {
            options = {
                {
                    type = "client",
                    event = "ersi:call:mechanic",
                    icon = "fa-solid fa-wrench",
                    label = "Call Mechanic",
                    canInteract = function(entity)
                        return IsOnAllowedERSDuty()
                    end
                }
            },
            distance = 2.0
        })

    end
end)

-- target shift
local function CanToggleShift(shiftType)
    local src = PlayerId()
    local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
    local activeType = exports['night_ers']:getPlayerActiveServiceType(src)
    return (not isOnShift) or (activeType == shiftType)
end

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