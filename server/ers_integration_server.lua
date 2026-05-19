local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}

local vehicleCache = {}
local pedCache = {}
local callCache = {}
local ERSPlayers = {}

local PendingPullover = {}
local PendingPulloverEnd = {}
local PendingPursuit = {}
local GetPlayerProfiles
local PersonnelLocations = {}

-- Crosshair
local on = true

RegisterCommand('global_ctoggle', function()

	if on then
		on = false
	elseif not on then
		on = true
	end
	TriggerClientEvent('cl:update_c', -1, on)
end)



---------------------------
-- UI
---------------------------

local function HasTabletAccess(src)
    if not Config.TabletJobLock or not Config.TabletJobLock.enabled then
        return true
    end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end

    local jobName = Player.PlayerData.job and Player.PlayerData.job.name
    if not jobName then return false end

    return Config.TabletJobLock.jobs[jobName] == true
end

local function DenyTabletAccess(src)
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Access Denied',
        description = 'You are not authorized to access this tablet.',
        type = 'error',
        icon = 'lock'
    })
end

local function tableExists(tableName)
    local result = exports.oxmysql:single_async([[
        SELECT COUNT(*) AS count
        FROM information_schema.tables
        WHERE table_schema = DATABASE()
        AND table_name = ?
    ]], { tableName })

    return result and result.count and result.count > 0
end

local function GetPlayerPropertyAddress(citizenid)
    -- qbx_properties
    if tableExists('qbx_properties') then
        local qbxProperty = exports.oxmysql:single_async([[
            SELECT label, property_name, street, apartment
            FROM qbx_properties
            WHERE owner = ?
            LIMIT 1
        ]], { citizenid })

        if qbxProperty then
            return qbxProperty.label
                or qbxProperty.property_name
                or qbxProperty.street
                or qbxProperty.apartment
        end
    end

    -- qb-houses fallback
    if tableExists('player_houses') then
        local qbHouse = exports.oxmysql:single_async([[
            SELECT house
            FROM player_houses
            WHERE citizenid = ?
            LIMIT 1
        ]], { citizenid })

        if qbHouse and qbHouse.house then
            return qbHouse.house
        end
    end

    return nil
end

local function safeJsonDecode(value)
    if not value or value == '' then return {} end

    if type(value) == 'table' then
        return value
    end

    local success, decoded = pcall(json.decode, value)

    if success and decoded then
        return decoded
    end

    return {}
end

local function dbQueryAwait(query, params)
    params = params or {}

    if MySQL and MySQL.query and MySQL.query.await then
        return MySQL.query.await(query, params)
    end

    return exports.oxmysql:executeSync(query, params)
end

local function getPlayerProfileAddress(citizenid, metadata)
    if metadata and metadata.address then
        return metadata.address
    end

    if metadata and metadata.property then
        return metadata.property
    end

    return 'N/A'
end

local VehicleColorNames = {
    [0] = 'Black',
    [1] = 'Graphite',
    [2] = 'Black Steel',
    [3] = 'Dark Steel',
    [4] = 'Silver',
    [5] = 'Bluish Silver',
    [6] = 'Rolled Steel',
    [7] = 'Shadow Silver',
    [8] = 'Stone Silver',
    [9] = 'Midnight Silver',
    [10] = 'Cast Iron Silver',
    [11] = 'Anthracite Black',
    [12] = 'Matte Black',
    [13] = 'Matte Gray',
    [14] = 'Light Gray',
    [15] = 'Util Black',
    [16] = 'Util Black Poly',
    [17] = 'Util Dark Silver',
    [18] = 'Util Silver',
    [19] = 'Util Gun Metal',
    [20] = 'Util Shadow Silver',
    [21] = 'Worn Black',
    [22] = 'Worn Graphite',
    [23] = 'Worn Silver Gray',
    [24] = 'Worn Silver',
    [25] = 'Worn Blue Silver',
    [26] = 'Worn Shadow Silver',
    [27] = 'Red',
    [28] = 'Torino Red',
    [29] = 'Formula Red',
    [30] = 'Blaze Red',
    [31] = 'Grace Red',
    [32] = 'Garnet Red',
    [33] = 'Sunset Red',
    [34] = 'Cabernet Red',
    [35] = 'Wine Red',
    [36] = 'Candy Red',
    [37] = 'Hot Pink',
    [38] = 'Pfister Pink',
    [39] = 'Salmon Pink',
    [40] = 'Sunrise Orange',
    [41] = 'Orange',
    [42] = 'Bright Orange',
    [43] = 'Gold',
    [44] = 'Bronze',
    [45] = 'Yellow',
    [46] = 'Race Yellow',
    [47] = 'Dew Yellow',
    [48] = 'Dark Green',
    [49] = 'Racing Green',
    [50] = 'Sea Green',
    [51] = 'Olive Green',
    [52] = 'Bright Green',
    [53] = 'Gasoline Green',
    [54] = 'Lime Green',
    [55] = 'Midnight Blue',
    [56] = 'Galaxy Blue',
    [57] = 'Dark Blue',
    [58] = 'Saxon Blue',
    [59] = 'Blue',
    [60] = 'Mariner Blue',
    [61] = 'Harbor Blue',
    [62] = 'Diamond Blue',
    [63] = 'Surf Blue',
    [64] = 'Nautical Blue',
    [65] = 'Racing Blue',
    [66] = 'Ultra Blue',
    [67] = 'Light Blue',
    [68] = 'Chocolate Brown',
    [69] = 'Bison Brown',
    [70] = 'Creen Brown',
    [71] = 'Feltzer Brown',
    [72] = 'Maple Brown',
    [73] = 'Beechwood Brown',
    [74] = 'Sienna Brown',
    [75] = 'Saddle Brown',
    [76] = 'Moss Brown',
    [77] = 'Woodbeech Brown',
    [78] = 'Straw Brown',
    [79] = 'Sandy Brown',
    [80] = 'Bleached Brown',
    [81] = 'Schafter Purple',
    [82] = 'Spinnaker Purple',
    [83] = 'Midnight Purple',
    [84] = 'Bright Purple',
    [85] = 'Cream',
    [86] = 'Ice White',
    [87] = 'Frost White',
    [88] = 'Worn Honey Beige',
    [89] = 'Worn Brown',
    [90] = 'Worn Dark Brown',
    [91] = 'Worn Straw Beige',
    [92] = 'Brushed Steel',
    [93] = 'Brushed Black Steel',
    [94] = 'Brushed Aluminum',
    [95] = 'Chrome',
    [96] = 'Worn Off White',
    [97] = 'Util Off White',
    [98] = 'Worn Orange',
    [99] = 'Worn Light Orange',
    [100] = 'Securicor Green',
    [101] = 'Worn Taxi Yellow',
    [102] = 'Police Car Blue',
    [103] = 'Matte Green',
    [104] = 'Matte Brown',
    [105] = 'Worn Orange',
    [106] = 'Matte White',
    [107] = 'Worn White',
    [108] = 'Worn Olive Army Green',
    [109] = 'Pure White',
    [110] = 'Hot Pink',
    [111] = 'Salmon Pink',
    [112] = 'Metallic Black',
    [113] = 'Worn Dark Red',
    [114] = 'Worn Red',
    [115] = 'Worn Golden Red',
    [116] = 'Worn Dark Green',
    [117] = 'Worn Green',
    [118] = 'Worn Sea Wash',
    [119] = 'Worn Dark Blue',
    [120] = 'Worn Blue',
    [121] = 'Worn Light Blue',
    [122] = 'Metallic Taxi Yellow',
    [123] = 'Metallic Race Yellow',
    [124] = 'Metallic Bronze',
    [125] = 'Metallic Yellow Bird',
    [126] = 'Metallic Lime',
    [127] = 'Metallic Champagne',
    [128] = 'Metallic Pueblo Beige',
    [129] = 'Metallic Dark Ivory',
    [130] = 'Metallic Choco Brown',
    [131] = 'Metallic Golden Brown',
    [132] = 'Metallic Light Brown',
    [133] = 'Metallic Straw Beige',
    [134] = 'Metallic Moss Brown',
    [135] = 'Metallic Biston Brown',
    [136] = 'Metallic Beechwood',
    [137] = 'Metallic Dark Beechwood',
    [138] = 'Metallic Choco Orange',
    [139] = 'Metallic Beach Sand',
    [140] = 'Metallic Sun Bleeched Sand',
    [141] = 'Metallic Cream',
    [142] = 'Util Brown',
    [143] = 'Util Medium Brown',
    [144] = 'Util Light Brown',
    [145] = 'Metallic White',
    [146] = 'Metallic Frost White',
    [147] = 'Worn Honey Beige',
    [148] = 'Police Car Blue',
    [149] = 'Pure White',
    [150] = 'Hot Pink',
    [151] = 'True Blue',
    [152] = 'Police Blue',
    [153] = 'Dark Blue',
    [154] = 'Light Blue',
    [155] = 'Green',
    [156] = 'Matte Foilage Green',
    [157] = 'Lava Red',
    [158] = 'Epsilon Blue',
    [159] = 'Pure Gold',
    [160] = 'Brushed Gold'
}

local function getVehicleColorName(colorId)
    colorId = tonumber(colorId)

    if not colorId then
        return nil
    end

    return VehicleColorNames[colorId] or ('Color ID ' .. colorId)
end

local function getVehicleColorLabel(mods)
    if not mods then return 'Unknown' end

    local primary =
        mods.color1
        or mods.primaryColor
        or mods.pearlescentColor
        or mods.paintType1

    local secondary =
        mods.color2
        or mods.secondaryColor
        or mods.paintType2

    local primaryName = getVehicleColorName(primary)
    local secondaryName = getVehicleColorName(secondary)

    if primaryName and secondaryName and primaryName ~= secondaryName then
        return primaryName .. ' / ' .. secondaryName
    end

    if primaryName then
        return primaryName
    end

    if secondaryName then
        return secondaryName
    end

    return 'Unknown'
end

local function GetSavedERSVehicles()
    local rows = exports.oxmysql:executeSync([[
        SELECT
            id,
            plate,
            owner_identifier,
            owner_name,
            vehicle_model,
            vehicle_label,
            color,
            type,
            vehicle_data,
            created_at,
            updated_at
        FROM ers_vehicle_database
        ORDER BY updated_at DESC
    ]], {}) or {}

    local vehicles = {}

    for _, row in ipairs(rows) do
        local decoded = safeJsonDecode(row.vehicle_data)

        vehicles[#vehicles + 1] = {
            sourceType = row.type or decoded.sourceType or 'NPC',

            id = row.id,
            plate = row.plate,
            Plate = row.plate,
            license_plate = row.plate,

            owner_identifier = row.owner_identifier,
            citizenid = row.owner_identifier,

            ownerName = row.owner_name or decoded.ownerName or decoded.owner_name or 'Unknown',
            OwnerName = row.owner_name or decoded.OwnerName or decoded.owner_name or 'Unknown',

            make = decoded.make
                or decoded.Make
                or decoded.manufacturer
                or decoded.Manufacturer
                or decoded.brand
                or decoded.Brand
                or 'Unknown',

            model = row.vehicle_model
                or decoded.model
                or decoded.Model
                or decoded.vehicle_model
                or decoded.VehicleModel
                or 'Unknown',

            qbLabel = decoded.qbLabel or decoded.qb_label or row.vehicle_label or decoded.vehicle_label or decoded.label or 'Unknown',
            vehicle_label = row.vehicle_label or decoded.vehicle_label or decoded.label or decoded.qbLabel or 'Unknown',
            label = row.vehicle_label or decoded.label or decoded.qbLabel or row.vehicle_model or 'Unknown',

            color = row.color
                or decoded.color
                or decoded.Color
                or decoded.primaryColor
                or decoded.secondaryColor
                or 'Unknown',

            type = row.type or decoded.type or 'NPC',

            insurance = decoded.insurance == true or decoded.insurance == 'true',
            stolen = decoded.stolen == true or decoded.stolen == 'true',
            bolo = decoded.bolo == true or decoded.bolo == 'true',
            flagged = decoded.flagged == true or decoded.flagged == 'true',
            wanted = decoded.wanted == true or decoded.wanted == 'true',

            created_at = row.created_at,
            updated_at = row.updated_at
        }
    end

    return vehicles
end

local function GetPlayerOwnedVehicles()
    if Config.PlayerVehicles and Config.PlayerVehicles.enabled == false then
        return {}
    end

    local tableName = (Config.PlayerVehicles and Config.PlayerVehicles.vehiclesTable) or 'player_vehicles'

    local rows = exports.oxmysql:executeSync(([[
        SELECT
            pv.citizenid,
            pv.plate,
            pv.vehicle,
            pv.mods,
            pv.garage,
            pv.state,
            pv.stored,
            p.charinfo
        FROM `%s` pv
        LEFT JOIN players p ON p.citizenid = pv.citizenid
        ORDER BY pv.plate ASC
    ]]):format(tableName), {}) or {}

    local vehicles = {}

    for _, row in ipairs(rows) do
        local charinfo = safeJsonDecode(row.charinfo)
        local mods = safeJsonDecode(row.mods)

        local firstName = charinfo.firstname or 'Unknown'
        local lastName = charinfo.lastname or ''
        local ownerName = (firstName .. ' ' .. lastName):gsub('%s+$', '')

        local vehicleName = row.vehicle or 'Unknown'
        local vehicleLabel = vehicleName
        local vehicleMake = 'Unknown'

        if QBCore.Shared
            and QBCore.Shared.Vehicles
            and QBCore.Shared.Vehicles[vehicleName]
        then
            local sharedVeh = QBCore.Shared.Vehicles[vehicleName]

            vehicleLabel =
                sharedVeh.name
                or sharedVeh.label
                or sharedVeh.model
                or vehicleName

            vehicleMake =
                sharedVeh.brand
                or sharedVeh.make
                or sharedVeh.manufacturer
                or 'Unknown'
        end

        local color = getVehicleColorLabel(mods)

        vehicles[#vehicles + 1] = {
            sourceType = 'Player',

            plate = row.plate,
            Plate = row.plate,
            license_plate = row.plate,

            citizenid = row.citizenid,
            owner_identifier = row.citizenid,

            ownerName = ownerName,
            OwnerName = ownerName,
            owner_name = ownerName,

            make = vehicleMake,
            Make = vehicleMake,

            model = vehicleName,
            vehicle_model = vehicleName,

            label = vehicleLabel,
            vehicle_label = vehicleLabel,
            qbLabel = vehicleLabel,
            qb_label = vehicleLabel,

            color = color,
            Color = color,

            insurance = true,
            stolen = false,
            bolo = false,
            flagged = false,
            wanted = false,

            type = 'Player Owned'
        }
    end

    return vehicles
end



local function GetDatabaseVehicles()
    local vehicles = {}

    local savedVehicles = GetSavedERSVehicles()
    local playerVehicles = GetPlayerOwnedVehicles()

    local seenPlates = {}

    for _, veh in ipairs(savedVehicles) do
        local plate = string.upper(tostring(veh.plate or veh.Plate or ''))
        if plate ~= '' then
            seenPlates[plate] = true
        end

        vehicles[#vehicles + 1] = veh
    end

    for _, veh in ipairs(playerVehicles) do
        local plate = string.upper(tostring(veh.plate or veh.Plate or ''))

        -- If same plate exists in ERS saved table, prefer player-owned data but keep one card only.
        if plate == '' or not seenPlates[plate] then
            seenPlates[plate] = true
            vehicles[#vehicles + 1] = veh
        end
    end

    return vehicles
end

function GetPlayerProfiles()
    if Config.PlayerProfiles and Config.PlayerProfiles.enabled == false then
        return {}
    end

    local playersTable = (Config.PlayerProfiles and Config.PlayerProfiles.playersTable) or 'players'

    local rows = dbQueryAwait(([[
        SELECT
            citizenid,
            charinfo,
            metadata,
            job
        FROM %s
        ORDER BY citizenid ASC
    ]]):format(playersTable), {}) or {}

    local profiles = {}

    for _, row in ipairs(rows) do
        local charinfo = safeJsonDecode(row.charinfo)
        local metadata = safeJsonDecode(row.metadata)
        local job = safeJsonDecode(row.job)

        local firstname = charinfo.firstname or charinfo.FirstName or 'Unknown'
        local lastname = charinfo.lastname or charinfo.LastName or 'Unknown'
        local dob = charinfo.birthdate or charinfo.dob or charinfo.DOB or 'N/A'

        local gender = charinfo.gender or charinfo.sex or 'N/A'

        if gender == 0 or gender == '0' then
            gender = 'Male'
        elseif gender == 1 or gender == '1' then
            gender = 'Female'
        end

        local profilePicture =
            metadata.profilepicture
            or metadata.profilePicture
            or metadata.mugshot
            or metadata.MugShot
            or 'N/A'

        local profile = {
            profileType = 'Player',

            citizenid = row.citizenid,
            ped_identifier = ('%s_%s_%s'):format(
                tostring(firstname):lower(),
                tostring(lastname):lower(),
                tostring(dob):lower()
            ),

            FirstName = firstname,
            LastName = lastname,
            DOB = dob,
            Gender = gender,

            Nationality = charinfo.nationality or 'N/A',
            PhoneNumber = charinfo.phone or charinfo.phoneNumber or charinfo.PhoneNumber or 'N/A',
            Email = charinfo.email or metadata.email or 'N/A',

            Address = getPlayerProfileAddress(row.citizenid, metadata),
            AddressType = 'Player Property',
            City = metadata.city or 'San Andreas',
            State = metadata.state or 'SA',
            PostalCode = metadata.postal or '',

            ProfilePicture = profilePicture,
            ProfilePicturePositionX = metadata.profile_picture_position_x or metadata.ProfilePicturePositionX or 50,
            ProfilePicturePositionY = metadata.profile_picture_position_y or metadata.ProfilePicturePositionY or 5,
            ProfilePictureZoom = metadata.profile_picture_zoom or metadata.ProfilePictureZoom or 100,

            Job = job.name or 'unemployed',
            JobLabel = job.label or job.name or 'Unemployed',

            License_Car = true,
            License_Bike = metadata.licences and metadata.licences.bike or false,
            License_Truck = metadata.licences and metadata.licences.truck or false,
            License_Boat = metadata.licences and metadata.licences.boat or false,
            License_Pilot = metadata.licences and metadata.licences.pilot or false,

            FlagsOrMarkers = {
                wanted_person = false,
                active_warrant = false,
                armed_and_dangerous = false
            }
        }

        profiles[#profiles + 1] = profile
    end

    return profiles
end

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostal', function(streetName, postal)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local citizenid = Player.PlayerData.citizenid
    if not citizenid then return end

    streetName = streetName or 'Unknown'
    postal = postal or 'N/A'

    PersonnelLocations[citizenid] = {
        street = streetName,
        postal = postal,
        updated = os.time()
    }
end)

RegisterNetEvent('ersi:server:setUnitStatus', function(status)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local allowed = {
        ['10-7'] = true,
        ['10-8'] = true,
        ['10-6'] = true,
        ['Traffic'] = true,
        ['Signal 11'] = true,
        ['Signal 41'] = true,
        ['Signal 42'] = true
    }

    if not allowed[status] then return end

    local citizenid = Player.PlayerData.citizenid

    exports.oxmysql:update([[
        UPDATE ers_players
        SET unit_status = ?
        WHERE citizenid = ?
    ]], {
        status,
        citizenid
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Unit Status',
        description = ('Status set to %s'):format(status),
        type = 'inform',
        icon = 'radio'
    })
end)

RegisterNetEvent('ersi:server:updateProfilePicture', function(data)
    local src = source
    local profileType = data.profileType or 'NPC'
    local profilePicture = data.profilePicture

    if not profilePicture or profilePicture == '' then return end

    local posX = data.position_x or 50
    local posY = data.position_y or 5
    local zoom = data.zoom or 100

    if profileType == 'Player' and data.citizenid then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end

        if Player.PlayerData.citizenid ~= data.citizenid then return end

        Player.Functions.SetMetaData('profilepicture', profilePicture)
        Player.Functions.SetMetaData('profile_picture_position_x', posX)
        Player.Functions.SetMetaData('profile_picture_position_y', posY)
        Player.Functions.SetMetaData('profile_picture_zoom', zoom)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Profile Picture',
            description = 'Player profile picture updated',
            type = 'success',
            icon = 'image'
        })

        return
    end

    local pedData = data.pedData or {}
    pedData.ProfilePicture = profilePicture
    pedData.ProfilePicturePositionX = posX
    pedData.ProfilePicturePositionY = posY
    pedData.ProfilePictureZoom = zoom

    exports.oxmysql:execute([[
        UPDATE ers_ped_database
        SET
            profile_picture = ?,
            profile_position_x = ?,
            profile_position_y = ?,
            profile_zoom = ?,
            ped_data = ?
        WHERE ped_identifier = ?
    ]], {
        profilePicture,
        posX,
        posY,
        zoom,
        json.encode(pedData),
        data.ped_identifier
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Profile Picture',
        description = 'NPC profile picture updated',
        type = 'success',
        icon = 'image'
    })
end)

RegisterNetEvent('ersi:server:updateTabletBackground', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if type(data) == 'string' then
        data = {
            url = data,
            position_x = 50,
            position_y = 50,
            zoom = 100
        }
    end

    data = data or {}

    local background = data.url or data.background or ''
    local posX = tonumber(data.position_x) or 50
    local posY = tonumber(data.position_y) or 50
    local zoom = tonumber(data.zoom) or 100

    exports.oxmysql:update([[
        UPDATE ers_players
        SET
            tablet_background = ?,
            tablet_background_position_x = ?,
            tablet_background_position_y = ?,
            tablet_background_zoom = ?
        WHERE citizenid = ?
    ]], {
        background,
        posX,
        posY,
        zoom,
        Player.PlayerData.citizenid
    })

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Tablet Background',
        description = 'Background updated',
        type = 'success',
        icon = 'image'
    })
end)



RegisterNetEvent('ersi:server:getDatabaseUIData', function()
    local src = source
        if not HasTabletAccess(src) then
        DenyTabletAccess(src)
        return
    end
    local Player = QBCore.Functions.GetPlayer(src)

    local characterName = 'Unknown'
    local callsign = 'N/A'
    local unitStatus = '10-8'
    local tabletBackground = ''
    local tabletBackgroundPositionX = 50
    local tabletBackgroundPositionY = 50
    local tabletBackgroundZoom = 100

    if Player then
        local bgRow = exports.oxmysql:single_async([[
            SELECT
                tablet_background,
                tablet_background_position_x,
                tablet_background_position_y,
                tablet_background_zoom
            FROM ers_players
            WHERE citizenid = ?
        ]], { Player.PlayerData.citizenid })

        if bgRow and bgRow.tablet_background then
            tabletBackground = bgRow.tablet_background
        end
    end

    if Player then
        characterName = ('%s %s'):format(
            Player.PlayerData.charinfo.firstname or 'Unknown',
            Player.PlayerData.charinfo.lastname or ''
        )

        callsign = Player.PlayerData.metadata.callsign or 'N/A'

        local statusRow = exports.oxmysql:single_async([[
            SELECT unit_status
            FROM ers_players
            WHERE citizenid = ?
            LIMIT 1
        ]], { Player.PlayerData.citizenid })

        if statusRow and statusRow.unit_status then
            unitStatus = statusRow.unit_status
        end
    end

    local onDuty = false
    if GetResourceState('night_ers') == 'started' then
        onDuty = exports['night_ers']:getIsPlayerOnShift(src)
    end

    exports.oxmysql:execute([[
        SELECT ped_data, profile_position_x, profile_position_y, profile_zoom
        FROM ers_ped_database
        ORDER BY updated_at DESC
        LIMIT 50
    ]], {}, function(results)
        local savedPeds = {}

        for _, row in ipairs(results or {}) do
            local decoded = json.decode(row.ped_data or '{}') or {}
            decoded.profileType = decoded.profileType or 'NPC'

            decoded.ProfilePicturePositionX = decoded.ProfilePicturePositionX or row.profile_position_x or 50
            decoded.ProfilePicturePositionY = decoded.ProfilePicturePositionY or row.profile_position_y or 5
            decoded.ProfilePictureZoom = decoded.ProfilePictureZoom or row.profile_zoom or 100

            savedPeds[#savedPeds + 1] = decoded
        end

        local playerProfiles = GetPlayerProfiles()

        for _, profile in ipairs(playerProfiles) do
            savedPeds[#savedPeds + 1] = profile
        end

        TriggerClientEvent('ersi:client:openDatabaseUI', src, {
            peds = savedPeds,
            vehicles = GetDatabaseVehicles(),
            callouts = callCache[src] or {},
            personnel = ERSPlayers or {},
            onDuty = onDuty,
            characterName = characterName,
            callsign = callsign,
            unit_status = unitStatus,
            tablet_background = tabletBackground,
            tablet_background_position_x = tabletBackgroundPositionX,
            tablet_background_position_y = tabletBackgroundPositionY,
            tablet_background_zoom = tabletBackgroundZoom,
        })
    end)
end)

local function getPedIdentifier(pedData)
    local first = (pedData.FirstName or 'unknown'):lower()
    local last = (pedData.LastName or 'unknown'):lower()
    local dob = pedData.DOB or 'nodob'

    -- this keeps it readable but avoids most duplicates
    return ('%s_%s_%s'):format(first, last, dob)
end


local function SavePedToDatabase(pedData)
    local identifier = getPedIdentifier(pedData)

    exports.oxmysql:insert([[
        INSERT INTO ers_ped_database (
            ped_identifier,
            firstname,
            lastname,
            dob,
            gender,
            address,
            phone,
            email,
            profile_picture,
            ped_data
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            firstname = VALUES(firstname),
            lastname = VALUES(lastname),
            dob = VALUES(dob),
            gender = VALUES(gender),
            address = VALUES(address),
            phone = VALUES(phone),
            email = VALUES(email),
            profile_picture = VALUES(profile_picture),
            ped_data = VALUES(ped_data)
    ]], {
        identifier,
        pedData.FirstName or 'N/A',
        pedData.LastName or 'N/A',
        pedData.DOB or 'N/A',
        pedData.Gender or 'N/A',
        pedData.Address or 'N/A',
        pedData.PhoneNumber or 'N/A',
        pedData.Email or 'N/A',
        pedData.ProfilePicture or 'N/A',
        json.encode(pedData)
    })

    return identifier
end

RegisterNetEvent('ersi:server:updateReport', function(reportId, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    reportId = tonumber(reportId)
    if not reportId then return end

    local updatedBy = ('%s %s'):format(
        Player.PlayerData.charinfo.firstname or 'Unknown',
        Player.PlayerData.charinfo.lastname or ''
    )

    exports.oxmysql:update([[
        UPDATE ers_reports
        SET report_type = ?, title = ?, narrative = ?, updated_by = ?, updated_at = NOW()
        WHERE id = ?
    ]], {
        data.type or 'Incident',
        data.title or 'Untitled Report',
        data.narrative or '',
        updatedBy,
        reportId
    }, function()
        exports.oxmysql:execute('DELETE FROM ers_report_officers WHERE report_id = ?', { reportId })
        exports.oxmysql:execute('DELETE FROM ers_report_peds WHERE report_id = ?', { reportId })
        exports.oxmysql:execute('DELETE FROM ers_report_charges WHERE report_id = ?', { reportId })
        exports.oxmysql:execute('DELETE FROM ers_report_photos WHERE report_id = ?', { reportId })

        for _, officer in ipairs(data.officers or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_officers (
                    report_id,
                    officer_name,
                    callsign,
                    job
                ) VALUES (?, ?, ?, ?)
            ]], {
                reportId,
                officer.name or officer.officer_name or 'Unknown',
                officer.callsign or 'N/A',
                officer.job or 'N/A'
            })
        end

        for _, ped in ipairs(data.peds or {}) do
            local firstName = ped.FirstName or ped.firstname or 'N/A'
            local lastName = ped.LastName or ped.lastname or 'N/A'
            local dob = ped.DOB or ped.dob or 'N/A'

            local pedIdentifier
            if ped.ped_identifier then
                pedIdentifier = ped.ped_identifier
            else
                local first = tostring(firstName):lower()
                local last = tostring(lastName):lower()
                local safeDob = tostring(dob):lower()
                pedIdentifier = ('%s_%s_%s'):format(first, last, safeDob)
            end

            exports.oxmysql:insert([[
                INSERT INTO ers_report_peds (
                    report_id,
                    ped_identifier,
                    firstname,
                    lastname,
                    dob,
                    ped_data
                ) VALUES (?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                pedIdentifier,
                firstName,
                lastName,
                dob,
                json.encode(ped)
            })
        end

        for _, charge in ipairs(data.charges or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_charges (
                    report_id,
                    ped_identifier,
                    ped_name,
                    charge_name,
                    count,
                    fine,
                    jail_time
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                charge.ped_identifier or '',
                charge.ped_name or 'Unassigned',
                charge.name or charge.charge_name or 'Charge',
                charge.count or 1,
                charge.fine or 0,
                charge.jail_time or 0
            })
        end

        for _, photo in ipairs(data.photos or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_photos (
                    report_id,
                    url,
                    caption,
                    uploaded_by,
                    position_x,
                    position_y,
                    zoom
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                photo.url or '',
                photo.caption or '',
                updatedBy,
                photo.position_x or 50,
                photo.position_y or 50,
                photo.zoom or 100
            })
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report Updated',
            description = ('Report #%s was updated'):format(reportId),
            type = 'success',
            icon = 'file-pen'
        })
    end)
end)

RegisterNetEvent('ersi:server:searchPedDatabase', function(search)
    local src = source
    search = search or ''

    exports.oxmysql:execute([[
        SELECT *
        FROM ers_ped_database
        WHERE firstname LIKE ?
           OR lastname LIKE ?
           OR dob LIKE ?
           OR address LIKE ?
           OR ped_identifier LIKE ?
        ORDER BY updated_at DESC
        LIMIT 50
    ]], {
        '%' .. search .. '%',
        '%' .. search .. '%',
        '%' .. search .. '%',
        '%' .. search .. '%',
        '%' .. search .. '%'
    }, function(results)
        local peds = {}

        for _, row in ipairs(results or {}) do
            local decoded = json.decode(row.ped_data or '{}') or {}
            decoded.ped_identifier = row.ped_identifier
            peds[#peds + 1] = decoded
        end

        TriggerClientEvent('ersi:client:receivePedDatabaseSearch', src, peds)
    end)
end)
---------------------------
-- Plate check
---------------------------
RegisterNetEvent('ersi:server:saveVehicleRecord', function(vehicleData)
    local src = source

    vehicleData = vehicleData or {}

    local plate = vehicleData.plate or vehicleData.Plate or vehicleData.license_plate
    if not plate or plate == '' then return end

    plate = string.upper(plate)

    local ownerName = vehicleData.ownerName or vehicleData.OwnerName or vehicleData.owner_name or 'Unknown'
    local ownerIdentifier = vehicleData.owner_identifier or vehicleData.ownerIdentifier or vehicleData.citizenid or nil
    local model = vehicleData.model or vehicleData.vehicle_model or vehicleData.VehicleModel or 'Unknown'
    local label = vehicleData.label or vehicleData.vehicle_label or vehicleData.VehicleLabel or model
    local color = vehicleData.color or vehicleData.Color or 'Unknown'
    local vehicleType = vehicleData.type or vehicleData.profileType or 'NPC'

    exports.oxmysql:execute([[
        INSERT INTO ers_vehicle_database (
            plate,
            owner_identifier,
            owner_name,
            vehicle_model,
            vehicle_label,
            color,
            type,
            vehicle_data
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            owner_identifier = VALUES(owner_identifier),
            owner_name = VALUES(owner_name),
            vehicle_model = VALUES(vehicle_model),
            vehicle_label = VALUES(vehicle_label),
            color = VALUES(color),
            type = VALUES(type),
            vehicle_data = VALUES(vehicle_data),
            updated_at = NOW()
    ]], {
        plate,
        ownerIdentifier,
        ownerName,
        model,
        label,
        color,
        vehicleType,
        json.encode(vehicleData)
    })
end)

RegisterServerEvent("ErsIntegration::OnFirstVehicleInteraction")
AddEventHandler("ErsIntegration::OnFirstVehicleInteraction", function(src, vehicleData, context)
    if context ~= "on_pullover" then return end
    if not src then return end
    if not vehicleData then return end

    local plate = vehicleData.license_plate or vehicleData.plate or vehicleData.Plate or 'UNKNOWN'
    plate = string.upper(tostring(plate))

    vehicleCache[src] = vehicleCache[src] or {}

    local exists = false

    for _, v in ipairs(vehicleCache[src]) do
        local cachedPlate = v.license_plate or v.plate or v.Plate or 'UNKNOWN'

        if string.upper(tostring(cachedPlate)) == plate then
            exists = true
            break
        end
    end

    if not exists then
        table.insert(vehicleCache[src], vehicleData)

        if #vehicleCache[src] > 10 then
            table.remove(vehicleCache[src], 1)
        end
    end

    TriggerClientEvent('ersi:client:recordAddedTextUI', src, {
        message = ('VEHICLE DATABASE: %s'):format(plate),
        icon = 'car'
    })

    -- Save vehicle to permanent ERS vehicle database
    TriggerEvent('ersi:server:saveVehicleRecord', {
        plate = plate,
        license_plate = plate,

        ownerName = vehicleData.owner_name or vehicleData.ownerName or vehicleData.OwnerName or 'Unknown',
        owner_name = vehicleData.owner_name or vehicleData.ownerName or vehicleData.OwnerName or 'Unknown',

        owner_identifier = vehicleData.owner_identifier or vehicleData.citizenid or nil,
        citizenid = vehicleData.citizenid or vehicleData.owner_identifier or nil,

        make = vehicleData.make
            or vehicleData.Make
            or vehicleData.manufacturer
            or vehicleData.Manufacturer
            or vehicleData.brand
            or vehicleData.Brand
            or 'Unknown',

        model = vehicleData.model
            or vehicleData.Model
            or vehicleData.vehicle_model
            or vehicleData.VehicleModel
            or 'Unknown',

        qbLabel = vehicleData.qbLabel
            or vehicleData.qb_label
            or vehicleData.vehicle_label
            or vehicleData.VehicleLabel
            or vehicleData.label
            or vehicleData.Label
            or ((vehicleData.make or vehicleData.brand or '') .. ' ' .. (vehicleData.model or '')),

        vehicle_model = vehicleData.model
            or vehicleData.Model
            or vehicleData.vehicle_model
            or vehicleData.VehicleModel
            or 'Unknown',

        vehicle_label = vehicleData.qbLabel
            or vehicleData.qb_label
            or vehicleData.vehicle_label
            or vehicleData.VehicleLabel
            or vehicleData.label
            or vehicleData.Label
            or vehicleData.model
            or 'Unknown',

        color = vehicleData.color or vehicleData.Color or 'Unknown',

        type = 'NPC',
        sourceType = 'NPC',

        insurance = vehicleData.insurance,
        stolen = vehicleData.stolen,
        bolo = vehicleData.bolo,
        flagged = vehicleData.flagged,
        wanted = vehicleData.wanted,

        raw = vehicleData
    })

    if not Config.ShowPlateInChat then return end

    CreateThread(function()
        Wait(5000)

        local info = ("Vehicle Check:\n" ..
            "Owner: %s\n" ..
            "Plate: %s\n" ..
            "Vehicle: %s %s\n" ..
            "Insurance: %s\n" ..
            "Stolen: %s\n" ..
            "BOLO: %s"
        ):format(
            vehicleData.owner_name or vehicleData.ownerName or "N/A",
            plate,
            vehicleData.make or "N/A",
            vehicleData.model or "N/A",
            vehicleData.insurance and "true" or "false",
            vehicleData.stolen and "true" or "false",
            vehicleData.bolo and "true" or "false"
        )

        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
    end)
end)

RegisterNetEvent('ersi:server:searchCharges', function(search)
    local src = source
    search = search or ''

    exports.oxmysql:execute([[
        SELECT 
            id,
            code,
            name,
            category,
            jail_time,
            fine,
            color,
            description
        FROM ers_charges
        WHERE name LIKE ?
           OR code LIKE ?
           OR category LIKE ?
        ORDER BY code ASC
        LIMIT 50
    ]], {
        '%' .. search .. '%',
        '%' .. search .. '%',
        '%' .. search .. '%'
    }, function(results)
        TriggerClientEvent('ersi:client:receiveChargeResults', src, results or {})
    end)
end)

RegisterNetEvent('ersi:server:saveReport', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local createdBy = ('%s %s'):format(
        Player.PlayerData.charinfo.firstname or 'Unknown',
        Player.PlayerData.charinfo.lastname or 'Unknown'
    )

    exports.oxmysql:insert([[
        INSERT INTO ers_reports (report_type, title, narrative, created_by)
        VALUES (?, ?, ?, ?)
    ]], {
        data.type or 'Incident',
        data.title or 'Untitled Report',
        data.narrative or '',
        createdBy
    }, function(reportId)
        if not reportId then return end

        for _, officer in ipairs(data.officers or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_officers (report_id, officer_name, callsign, job)
                VALUES (?, ?, ?, ?)
            ]], {
                reportId,
                officer.name or 'Unknown',
                officer.callsign or 'N/A',
                officer.job or 'Unknown'
            })
        end

        for _, ped in ipairs(data.peds or {}) do
            ped.ped_identifier = getPedIdentifier(ped)

            exports.oxmysql:insert([[
                INSERT INTO ers_report_peds (
                    report_id,
                    ped_identifier,
                    firstname,
                    lastname,
                    dob,
                    ped_data
                ) VALUES (?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                ped.ped_identifier,
                ped.FirstName or 'N/A',
                ped.LastName or 'N/A',
                ped.DOB or 'N/A',
                json.encode(ped)
            })
        end

        for _, charge in ipairs(data.charges or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_charges (
                    report_id,
                    ped_identifier,
                    ped_name,
                    charge_name,
                    fine,
                    jail_time,
                    count
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                charge.ped_identifier or nil,
                charge.ped_name or nil,
                charge.name or 'Unknown',
                charge.fine or 0,
                charge.jail_time or 0,
                charge.count or 1
            })
        end

        for _, photo in ipairs(data.photos or {}) do
            exports.oxmysql:insert([[
                INSERT INTO ers_report_photos (
                    report_id,
                    url,
                    caption,
                    uploaded_by,
                    position_x,
                    position_y,
                    zoom
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
            ]], {
                reportId,
                photo.url or '',
                photo.caption or '',
                createdBy,
                photo.position_x or 50,
                photo.position_y or 50,
                photo.zoom or 100
            })
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Report Saved',
            description = ('Report #%s saved successfully'):format(reportId),
            type = 'success',
            icon = 'file-lines'
        })
    end)
end)

RegisterNetEvent('ersi:server:getReports', function()
    local src = source

    exports.oxmysql:execute([[
        SELECT id, report_type, title, narrative, created_by, created_at
        FROM ers_reports
        ORDER BY created_at DESC
        LIMIT 50
    ]], {}, function(reports)
        TriggerClientEvent('ersi:client:receiveReports', src, reports or {})
    end)
end)

RegisterNetEvent('ersi:server:getReportDetails', function(reportId)
    local src = source

    exports.oxmysql:execute('SELECT * FROM ers_reports WHERE id = ?', { reportId }, function(reportRows)
        local report = reportRows and reportRows[1]
        if not report then return end

        exports.oxmysql:execute('SELECT * FROM ers_report_officers WHERE report_id = ?', { reportId }, function(officers)
            exports.oxmysql:execute('SELECT * FROM ers_report_peds WHERE report_id = ?', { reportId }, function(peds)
                exports.oxmysql:execute('SELECT * FROM ers_report_charges WHERE report_id = ?', { reportId }, function(charges)
                    exports.oxmysql:execute('SELECT * FROM ers_report_photos WHERE report_id = ? ORDER BY created_at DESC', { reportId }, function(photos)
                        TriggerClientEvent('ersi:client:receiveReportDetails', src, {
                            report = report,
                            officers = officers or {},
                            peds = peds or {},
                            charges = charges or {},
                            photos = photos or {}
                        })
                    end)
                end)
            end)
        end)
    end)
end)

RegisterNetEvent('ersi:server:getPedPreviousReports', function(pedIdentifier)
    local src = source

    exports.oxmysql:execute([[
        SELECT r.id, r.report_type, r.title, r.created_by, r.created_at
        FROM ers_reports r
        INNER JOIN ers_report_peds rp ON rp.report_id = r.id
        WHERE rp.ped_identifier = ?
        ORDER BY r.created_at DESC
        LIMIT 25
    ]], { pedIdentifier }, function(results)
        TriggerClientEvent('ersi:client:receivePedPreviousReports', src, pedIdentifier, results or {})
    end)
end)

local activeDutySessions = {}

local function getPlayerIdentity(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return nil end

    return {
        citizenid = Player.PlayerData.citizenid,
        firstname = Player.PlayerData.charinfo.firstname or 'Unknown',
        lastname = Player.PlayerData.charinfo.lastname or 'Unknown',
        callsign = Player.PlayerData.metadata.callsign or 'N/A'
    }
end

local function ensureERSPlayer(src, service, onDuty)
    local info = getPlayerIdentity(src)
    if not info then return nil end

    exports.oxmysql:insert([[
        INSERT INTO ers_players (
            citizenid, firstname, lastname, callsign, last_service, is_on_duty
        ) VALUES (?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            firstname = VALUES(firstname),
            lastname = VALUES(lastname),
            callsign = VALUES(callsign),
            last_service = VALUES(last_service),
            is_on_duty = VALUES(is_on_duty)
    ]], {
        info.citizenid,
        info.firstname,
        info.lastname,
        info.callsign,
        service,
        onDuty and 1 or 0
    })

    exports.oxmysql:insert([[
        INSERT INTO ers_player_service_stats (
            citizenid, service, total_seconds, accepted_callouts, arrived_callouts
        ) VALUES (?, ?, 0, 0, 0)
        ON DUPLICATE KEY UPDATE service = service
    ]], {
        info.citizenid,
        service
    })

    return info
end

local function startDutySession(src, service)
    local info = ensureERSPlayer(src, service, true)
    if not info then return end

    activeDutySessions[src] = {
        citizenid = info.citizenid,
        service = service,
        startTime = os.time()
    }

    exports.oxmysql:insert([[
        INSERT INTO ers_duty_sessions (citizenid, service, started_at)
        VALUES (?, ?, NOW())
    ]], {
        info.citizenid,
        service
    })
end

local function endDutySession(src, service)
    local session = activeDutySessions[src]
    local info = ensureERSPlayer(src, service, false)

    if not session or not info then return end

    local duration = os.time() - session.startTime

    exports.oxmysql:update([[
        UPDATE ers_player_service_stats
        SET total_seconds = total_seconds + ?
        WHERE citizenid = ? AND service = ?
    ]], {
        duration,
        session.citizenid,
        session.service
    })

    exports.oxmysql:update([[
        UPDATE ers_duty_sessions
        SET ended_at = NOW(), duration_seconds = ?
        WHERE citizenid = ? AND service = ? AND ended_at IS NULL
        ORDER BY id DESC
        LIMIT 1
    ]], {
        duration,
        session.citizenid,
        session.service
    })

    activeDutySessions[src] = nil
end

local function toggleShift(src, shiftType, displayName)
    local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
    local activeType = exports['night_ers']:getPlayerActiveServiceType(src)

    -- Ending same shift
    if isOnShift and activeType == shiftType then
        exports['night_ers']:toggleShift(src, shiftType)
        endDutySession(src, shiftType)

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Duty',
            description = displayName .. ' duty ended',
            type = 'success',
            icon = 'user-clock'
        })

        return
    end

    -- If already on another service, close that session first
    if isOnShift and activeType and activeType ~= shiftType then
        endDutySession(src, activeType)
    end

    exports['night_ers']:toggleShift(src, shiftType)
    startDutySession(src, shiftType)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Duty',
        description = displayName .. ' duty started',
        type = 'success',
        icon = 'user-clock'
    })
end
RegisterNetEvent('ers:server:TogglePoliceShift', function()
    toggleShift(source, "police", "Police")
end)
RegisterNetEvent('ers:server:ToggleAmbulanceShift', function()
    toggleShift(source, "ambulance", "Ambulance")
end)
RegisterNetEvent('ers:server:ToggleFireShift', function()
    toggleShift(source, "fire", "Fire")
end)
RegisterNetEvent('ers:server:ToggleTowShift', function()
    toggleShift(source, "tow", "Tow")
end)

local function addAcceptedCallout(src)
    local info = getPlayerIdentity(src)
    if not info then return end

    local service = exports['night_ers']:getPlayerActiveServiceType(src) or 'unknown'
    ensureERSPlayer(src, service, true)

    exports.oxmysql:update([[
        UPDATE ers_player_service_stats
        SET accepted_callouts = accepted_callouts + 1
        WHERE citizenid = ? AND service = ?
    ]], {
        info.citizenid,
        service
    })
end

local function addArrivedCallout(src)
    local info = getPlayerIdentity(src)
    if not info then return end

    local service = exports['night_ers']:getPlayerActiveServiceType(src) or 'unknown'
    ensureERSPlayer(src, service, true)

    exports.oxmysql:update([[
        UPDATE ers_player_service_stats
        SET arrived_callouts = arrived_callouts + 1
        WHERE citizenid = ? AND service = ?
    ]], {
        info.citizenid,
        service
    })
end

RegisterNetEvent('ersi:server:CalloutArrived', function()
    addArrivedCallout(source)
end)

------------------------
-- ID Check
------------------------
RegisterServerEvent("ErsIntegration::OnFirstNPCInteraction")
AddEventHandler("ErsIntegration::OnFirstNPCInteraction", function(src, pedData, context)
    local pedIdentifier = SavePedToDatabase(pedData)
    pedData.ped_identifier = pedIdentifier

    pedCache[src] = pedCache[src] or {}

    local exists = false

    for _, p in ipairs(pedCache[src]) do
        if p.FirstName == pedData.FirstName and p.LastName == pedData.LastName then
            exists = true
            break
        end
    end

    if not exists then
        table.insert(pedCache[src], pedData)

        if #pedCache[src] > 10 then
            table.remove(pedCache[src], 1)
        end
    end

    TriggerClientEvent('ersi:client:recordAddedTextUI', src, {
        message = ('ID DATABASE: %s %s'):format(
            pedData.FirstName or 'N/A',
            pedData.LastName or ''
        ),
        icon = 'user'
    })

    if not Config.ShowLicenseInChat then return end

    CreateThread(function()
        Wait(5000)

        local info = ("ID CHECK:\n" ..
            "Name: %s %s\n" ..
            "DOB: %s\n" ..
            "Address: %s\n" ..
            "%s, %s %s\n" ..
            "Active Warrant: %s"
        ):format(
            pedData.FirstName or "N/A",
            pedData.LastName or "N/A",
            pedData.DOB or "N/A",
            pedData.Address or "N/A",
            pedData.City or "N/A",
            pedData.State or "N/A",
            pedData.PostalCode or "N/A",
            pedData.Wanted_Person and "true" or "false"
        )

        TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
    end)
end)

-- RegisterNetEvent('ersi:server:getNpcCitizenById', function(citizenid)
--     local src = source

--     local result = MySQL.single.await([[
--         SELECT *
--         FROM ers_npc_citizens
--         WHERE citizenid = ?
--     ]], { citizenid })

--     TriggerClientEvent('ersi:client:receiveNpcCitizen', src, result)
-- end)

RegisterNetEvent('ersi:server:getVehicleMenuData', function()
    local src = source
    local data = vehicleCache[src] or {}

    table.sort(data, function(a, b)
        return (a.license_plate or '') < (b.license_plate or '')
    end)

    TriggerClientEvent('ersi:client:openVehicleListMenu', src, data)
end)

RegisterNetEvent('ersi:server:getPedMenuData', function()
    local src = source
    local data = pedCache[src] or {}

    table.sort(data, function(a, b)
        local nameA = (a.FirstName or '') .. (a.LastName or '')
        local nameB = (b.FirstName or '') .. (b.LastName or '')
        return nameA < nameB
    end)

    TriggerClientEvent('ersi:client:openPedListMenu', src, data)
end)


--------------------------------------
-- Callout Offered
--------------------------------------
RegisterNetEvent('ErsIntegration::OnIsOfferedCallout', function(calloutData)
    --if not Config.EnableCalloutOffer then return end

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"

    local infoOptions = {
        ("%s | Requesting: %s"):format(callDesc, callUnits),
        ("%s | Requesting: %s"):format(callDesc, callUnits),
        ("%s | Requesting: %s"):format(callDesc, callUnits)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    callCache[src] = callCache[src] or {}

    local exists = false
    for i, c in ipairs(callCache[src]) do
        if c.callName == callName and c.callPostal == callPostal then
            callCache[src][i] = calloutData -- update existing
            exists = true
            break
        end
    end

    if not exists then
        table.insert(callCache[src], {
            callName = callName,
            callFirstName = callFirstName,
            callLastName = callLastName,
            callPostal = callPostal,
            callStreet = callStreet,
            callDesc = callDesc,
            callUnits = callUnits
        })

        -- keep only last 10
        if #callCache[src] > 10 then
            table.remove(callCache[src], 1)
        end
    end

    CreateThread(function()
        TriggerClientEvent('ersi:client:tabletCallAlert', src, {
            title = 'Incoming 911 Call',
            caller = ("%s %s"):format(callFirstName, callLastName),
            callName = callName,
            location = ("%s %s"):format(callPostal, callStreet)
        })
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnimPhoneText', src)
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:incomingCallTextUI', src, 'Incoming 911 Call')
        end

        if Config.ShowCallInChat then
            local info = ("INCOMING 911 CALL:\n" ..
                "Caller: %s %s\n" ..
                "Call: %s\n" ..
                "%s %s\n" ..
                "Report: %s"
            ):format(
                callFirstName,
                callLastName,
                callName,
                callPostal,
                callStreet,
                callDesc
            )

            TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end

        Wait(Config.WaitTimes.CalloutOffer or 5000)
        
        if Config.EnableCalloutOffer then
            TriggerEvent('ps-dispatch:server:notify', {
                code = '911',
                codeName = 'dispatch',
                title = "EnRoute",
                icon = 'fas fa-bullhorn',
                priority = 2,
                message = ("%s"):format(callName),
                alertTime = 10,
                street = ("%s %s"):format(
                    callPostal,
                    callStreet
                ),
                name = ("%s %s"):format(
                    callFirstName,
                    callLastName
                ),
                information = randomInfo,
                jobs = Config.Dispatch.CallOffer,
                coords = coords,
            })
        end

    end)
end)

RegisterNetEvent('ersi:server:getCalloutMenuData', function()
    local src = source
    local data = callCache[src] or {}

    -- newest first
    local reversed = {}
    for i = #data, 1, -1 do
        table.insert(reversed, data[i])
    end

    TriggerClientEvent('ersi:client:openCalloutListMenu', src, reversed)
end)

--------------------------------------
-- Callout Accepted
--------------------------------------
RegisterNetEvent('ErsIntegration::OnAcceptedCalloutOffer', function(calloutData)
    --if not Config.EnableCalloutAccept then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    addAcceptedCallout(src)

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local job = Player.PlayerData.job.grade.name or ""

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"

    local infoOptions = {
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits),
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits),
        ("Caller: %s %s | %s | Requesting: %s"):format(callFirstName, callLastName, callDesc, callUnits)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    local fullName = "Unknown"
    if Player and Player.PlayerData then
        local char = Player.PlayerData.charinfo
        local callsign = Player.PlayerData.metadata.callsign or "N/A"

        fullName = ("%s %s (%s)"):format(
            char.firstname or "Unknown",
            char.lastname or "Unknown",
            callsign
        )
    end

    ERSPlayers[src] = ERSPlayers[src] or { callouts = {} }

    ERSPlayers[src].name = fullName
    ERSPlayers[src].job = job
    ERSPlayers[src].active = true

    local vehicle = GetVehiclePedIsIn(GetPlayerPed(src), false)
    local vehicleName = "On Foot"

    if vehicle ~= 0 then
        local model = GetEntityModel(vehicle)

        local vehData = QBCore.Shared.Vehicles[model]

        if not vehData then
            for _, v in pairs(QBCore.Shared.Vehicles) do
                if joaat(v.model) == model then
                    vehData = v
                    break
                end
            end
        end

        if vehData then
            vehicleName = (vehData.brand or '') .. ' ' .. (vehData.name or '')
        else
            vehicleName = "Unknown Vehicle"
        end
    end

    table.insert(ERSPlayers[src].callouts, {
        callName = callName,
        caller = ("%s %s"):format(callFirstName, callLastName),
        location = ("%s %s"):format(callPostal, callStreet),
        --description = callDesc,
        desc = callDesc,
        vehicle = vehicleName,
        time = os.date("%H:%M:%S")
    })

    if #ERSPlayers[src].callouts > 10 then
        table.remove(ERSPlayers[src].callouts, 1)
    end

    CreateThread(function()
        if Config.ShowCalloutInChat then
            local info = ("911 CALL:\n" ..
                "Caller: %s %s\n" ..
                "Call: %s\n" ..
                "%s %s\n" ..
                "Report: %s"
            ):format(
                callFirstName,
                callLastName,
                callName,
                callPostal,
                callStreet,
                callDesc
            )

            TriggerClientEvent("ErsIntegration:Server:PrintPedDataToChat", src, info)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                    title = '911 Call',
                    description = ('%s | %s %s')
                        :format(
                        callName,
                        callPostal,
                        callStreet
                    ),
                    type = 'success',
                    duration = 8000,
                    icon = 'bullhorn'
                })
        end

        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:911CallTextUI', src, '911 Call')
        end

        Wait(Config.WaitTimes.CalloutAccepted or 5000)

        if Config.EnableCalloutAccept then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'enroute',
                title = "EnRoute",
                icon = 'fas fa-route',
                priority = 2,
                message = ("%s"):format(callName),
                alertTime = 10,
                street = ("%s %s"):format(callPostal, callStreet),
                name = ("%s %s (%s) | %s"):format(
                    firstName,
                    lastName,
                    callsign,
                    job),
                information = randomInfo,
                jobs = Config.Dispatch.CallAccept,
                coords = coords,
            })
        end

    end)
end)

-- MENU STUFF
RegisterNetEvent('ersi:server:getERSPlayers', function()
    local src = source

    local list = {}

    for playerId, data in pairs(ERSPlayers) do
        table.insert(list, {
            id = playerId,
            name = data.name,
            job = data.job,
            active = data.active
        })
    end

    TriggerClientEvent('ersi:client:openERSPlayerList', src, list)
end)

RegisterNetEvent('ersi:server:getPlayerCallouts', function(targetId)
    local src = source

    local data = ERSPlayers[targetId]

    if not data then return end

    TriggerClientEvent('ersi:client:openPlayerCallouts', src, data.callouts, data.name)
end)

RegisterNetEvent('ersi:server:getERSPersonnelDatabase', function()
    local src = source

    

    exports.oxmysql:execute([[
        SELECT 
            p.citizenid,
            p.firstname,
            p.lastname,
            p.callsign,
            p.last_service,
            p.is_on_duty,
            p.unit_status,
            COALESCE(s.service, p.last_service) AS service,
            COALESCE(s.total_seconds, 0) AS total_seconds,
            COALESCE(s.accepted_callouts, 0) AS accepted_callouts,
            COALESCE(s.arrived_callouts, 0) AS arrived_callouts,
            COALESCE((
                SELECT TIMESTAMPDIFF(SECOND, ds.started_at, NOW())
                FROM ers_duty_sessions ds
                WHERE ds.citizenid = p.citizenid
                  AND ds.service = COALESCE(s.service, p.last_service)
                  AND ds.ended_at IS NULL
                ORDER BY ds.id DESC
                LIMIT 1
            ), 0) AS active_seconds
        FROM ers_players p
        LEFT JOIN ers_player_service_stats s ON s.citizenid = p.citizenid
        ORDER BY p.lastname, p.firstname
    ]], {}, function(rows)
        local players = {}

        for _, row in ipairs(rows or {}) do
            local location = 'Unknown'

            local cachedLocation = PersonnelLocations[row.citizenid]

            if cachedLocation then
                if Config.PersonnelLocation and Config.PersonnelLocation.showPostal then
                    location = ('%s | Postal %s'):format(
                        cachedLocation.street or 'Unknown',
                        cachedLocation.postal or 'N/A'
                    )
                else
                    location = cachedLocation.street or 'Unknown'
                end
            end

            players[row.citizenid] = players[row.citizenid] or {
                citizenid = row.citizenid,
                firstname = row.firstname,
                lastname = row.lastname,
                callsign = row.callsign,
                last_service = row.last_service,
                is_on_duty = row.is_on_duty == 1 or row.is_on_duty == true,
                unit_status = row.unit_status or '10-8',
                location = location,
                services = {}
            }

            if row.service then
                players[row.citizenid].services[#players[row.citizenid].services + 1] = {
                    service = row.service,
                    total_seconds = tonumber(row.total_seconds or 0) + tonumber(row.active_seconds or 0),
                    accepted_callouts = tonumber(row.accepted_callouts or 0),
                    arrived_callouts = tonumber(row.arrived_callouts or 0)
                }
            end
        end

        local list = {}

        for _, data in pairs(players) do
            list[#list + 1] = data
        end

        -- remove this later if you do not want console spam
        print(json.encode(list, { indent = true }))

        TriggerClientEvent('ersi:client:receiveERSPersonnelDatabase', src, list)
    end)
end)

--------------------------------------
-- Callout Arrived
--------------------------------------
RegisterNetEvent('ErsIntegration::OnArrivedAtCallout', function(calloutData)
    --if not Config.EnableCalloutArrive then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    addArrivedCallout(src)

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local job = Player.PlayerData.job.grade.name or ""

    local callUnits = calloutData.CalloutUnitsRequired.description or "N/A"
    local callFirstName = calloutData.FirstName or "Unknown"
    local callLastName = calloutData.LastName or "Unknown"
    local callName = calloutData.CalloutName or "Unknown"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local callDesc = calloutData.Description or "Unknown"

    local infoOptions = {
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
        ("%s (%s) On Scene 911 Call: %s: %s"):format(lastName, callsign, callName, callDesc),
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        Wait(Config.WaitTimes.Updates or 5000)
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                    title = 'Dispatch',
                    description = ('%s (%s)| On Scene %s %s')
                        :format(
                        lastName,
                        callsign,
                        callPostal,
                        callStreet
                    ),
                    type = 'success',
                    duration = 8000,
                    icon = 'map-pin'
                })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:CallArriveTextUI', src, 'On Scene')
        end
        Wait(Config.WaitTimes.CalloutArrived or 5000) 

        if Config.EnableCalloutArrive then
            if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
        end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'onscene',
                title = "On Scene",
                icon = 'fas fa-map-marker-alt',
                priority = 2,
                message = ("%s (%s) | On-Scene"):format(     
                    lastName,
                    callsign),
                alertTime = 10,
                street = ("%s %s"):format(callPostal, callStreet),
                name = ("%s %s (%s) | %s"):format(
                    firstName,
                    lastName,
                    callsign,
                    job),
                information = randomInfo,
                jobs = Config.Dispatch.CallArrive,
                coords = coords,
            })
        end
        if Config.EnableBonusPayCallArrive then
            Wait(5000)

            Player.Functions.AddMoney(Config.BonusPayDepositType, Config.BonusPayAmountCallArrive, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) arrived at the call. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end
    end)
end)

-- ------------------------------------
-- Callout Completed before
-- ------------------------------------
-- RegisterNetEvent('ErsIntegration::OnEndedACallout', function(calloutData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end
--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local label = calloutData.label or "911 Call"
--     local name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
--     local citizenid = Player.PlayerData.citizenid

--     -- Add delay before dispatch (5000 = 5 seconds)
--     Citizen.Wait(10000)

--     --Dispatch Notification (Code 4)
--     TriggerEvent('ps-dispatch:server:notify', {
--         code = '10-98',
--         title = "Code-4",
--         message = ("%s Scene is Code 4."):format(name, label),
--         coords = coords,
--         jobs = { 'police', 'sheriff' }
--     })

-- end)

--------------------------------------
-- Callout Completed
--------------------------------------
RegisterNetEvent('ErsIntegration::OnCalloutCompletedSuccesfully', function(calloutData)
    --if not Config.EnableCalloutComplete then return end
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"
    local callPostal = calloutData.Postal or "Unknown"
    local callStreet = calloutData.StreetName or "Unknown"
    local job = Player.PlayerData.job.grade.name or ""

    local infoOptions = {
        ("%s (%s) Code-4 from my last Call"):format(lastName, callsign),
        ("%s (%s) Show me Code-4 from my last Call"):format(lastName, callsign),
        ("%s (%s) Show me 10-8"):format(lastName, callsign)
    }

    local randomInfo = infoOptions[math.random(#infoOptions)]

    CreateThread(function()
        if Config.EnableRadioAnim then
            TriggerClientEvent('ersi:client:PlayRadioAnim', src)
        end
        if Config.ShowlibNotify then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch',
                description = ('%s (%s) to Dispatch. Code 4 at %s %s.')
                    :format(lastName, callsign, callPostal, callStreet),
                type = 'success',
                duration = 4000,
                icon = 'radio'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:CallCompleteTextUI', src, 'Call Complete')
        end
        Wait(Config.WaitTimes.CalloutCompleted or 5000)

        

        if Config.EnableCalloutComplete then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'codefour',
                title = "CodeFour",
                icon = 'fas fa-clock',
                priority = 2,
                message = ("%s (%s) | Code-4"):format(lastName, callsign),
                alertTime = 10,
                name = ("%s %s (%s) | %s"):format(firstName, lastName, callsign, job),
                information = randomInfo,
                jobs = Config.Dispatch.CallComplete,
                coords = coords,
            })
        end

        if Config.EnableBonusPayCallComplete then
            Wait(5000)

            Player.Functions.AddMoney('bank', Config.BonusPayAmountCallComplete, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) cleared the call. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end

    end)
end)

--------------------------------------
-- Pullover
--------------------------------------
--PendingPullover = {}

RegisterNetEvent('ErsIntegration::OnPullover', function(pedData, vehicleData)
    local src = source
    PendingPullover[src] = { pedData = pedData, vehicleData = vehicleData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostal', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostal', function(streetName, postal)
    local src = source
    local data = PendingPullover[src]
    if not data then return end

    local pedData = data.pedData
    local vehicleData = data.vehicleData
    PendingPullover[src] = nil

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local pedPlate = vehicleData.license_plate or "N/A"
    local pedMake = vehicleData.make or "N/A"
    local pedModel = vehicleData.model or "N/A"
    local pedColor = vehicleData.color or "N/A"
    local pedColor2 = vehicleData.color_secondary or "N/A"
    local pedClass = vehicleData.vehicle_class or "N/A"
    local pedOwner = vehicleData.owner_name or "N/A"
    local pedInsurance = vehicleData.insurance and "true" or "false"
    local pedBolo = vehicleData.bolo and "true" or "false"
    local pedStolen = vehicleData.stolen and "true" or "false"

    CreateThread(function()
        if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnim', src)
            end
        if Config.ShowlibNotify then
            
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Dispatch - Traffic Stop',
                description = ('%s (%s) to Dispatch. Traffic stop at %s %s with a %s %s. Plate: %s')
                    :format(lastName, callsign, postal, streetName, pedColor, pedModel, pedPlate),
                type = 'success',
                duration = 4000,
                icon = 'car'
            })
        end

        if Config.EnableRadarLock then
            Wait(1000)
            TriggerClientEvent('ersi:client:radarFrontLock', src)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'ALPR Lock',
                description = ('%s (%s) Locked Plate: %s')
                    :format(lastName, callsign, pedPlate),
                type = 'primary',
                duration = 5000,
                icon = 'car'
            })
        end
        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:PulloverTextUI', src, 'Traffic Stop')
        end

        Wait(Config.WaitTimes.PulloverNotify or 5000)

        if Config.EnablePulloverNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'trafficstop',
                title = "TrafficStop",
                icon = 'fa-solid fa-car-on',
                priority = 2,
                message = ("%s (%s) | Traffic"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                vehicle = ("%s %s"):format(pedMake, pedModel),
                plate = pedPlate,
                color = ("%s, %s"):format(pedColor, pedColor2),
                class = pedClass,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Show me on a Traffic Stop. - PLATE CHECK - Owner: %s | Insurance: %s | BOLO: %s | Stolen: %s |"):format(
                    lastName, callsign, pedOwner, pedInsurance, pedBolo, pedStolen)
            })
        end

        if Config.EnableBonusPayTrafficStop then
            Wait(5000)

            Player.Functions.AddMoney('bank', Config.BonusPayAmountTrafficStop, 'callout-complete')

            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Bonus Pay',
                description = ('%s (%s) initiated a traffic stop. You received a bonus!')
                    :format(lastName, callsign),
                type = 'success',
                duration = 8000,
                icon = 'coins'
            })
        end
    end)
end)

--------------------------------------
-- Pullover Conclude
--------------------------------------
--PendingPulloverEnd = {}

RegisterNetEvent('ErsIntegration::OnPulloverEnded', function(pedData, vehicleData)
    local src = source
    PendingPulloverEnd[src] = { pedData = pedData, vehicleData = vehicleData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostalEnd', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostalEnd', function(streetName, postal)
    local src = source
    local data = PendingPulloverEnd[src]
    if not data then return end

    local pedData = data.pedData
    local vehicleData = data.vehicleData
    PendingPulloverEnd[src] = nil 

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    local pedPlate = vehicleData.license_plate or "N/A"
    local pedMake = vehicleData.make or "N/A"
    local pedModel = vehicleData.model or "N/A"
    local pedColor = vehicleData.color or "N/A"
    local pedColor2 = vehicleData.color_secondary or "N/A"
    local pedClass = vehicleData.vehicle_class or "N/A"

    CreateThread(function()
        Wait(Config.WaitTimes.PulloverEnd or 5000)

        if Config.EnablePulloverCode4 then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'codefour',
                title = "Code4",
                icon = 'fas fa-car-side',
                priority = 2,
                message = ("%s (%s) | Code-4"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Code-4 from my last Traffic"):format(lastName, callsign),
            })
        end
    end)
end)



--------------------------------------
-- Pursuit Start
--------------------------------------
--PendingPursuit = {}

RegisterNetEvent('ErsIntegration::OnPursuitStarted', function(pedData)
    local src = source
    PendingPursuit[src] = { pedData = pedData }

    TriggerClientEvent('ErsIntegration:client:GetStreetAndPostalPursuit', src)
end)

RegisterNetEvent('ErsIntegration:server:ReceiveStreetAndPostalPursuit', function(streetName, postal)
    local src = source
    local data = PendingPursuit[src]
    if not data then return end

    local pedData = data.pedData
    PendingPursuit[src] = nil 

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local coords = GetEntityCoords(GetPlayerPed(src))
    local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
    local lastName = Player.PlayerData.charinfo.lastname or "N/A"
    local callsign = Player.PlayerData.metadata.callsign or "N/A"

    CreateThread(function()
        if Config.ShowlibNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerClientEvent('QBCore:Notify', src,
                    ('%s (%s) to Dispatch. Show me in Active Pursuit @ %s %s')
                        :format(lastName, callsign, postal, streetName),
                    'success',
                    4000
                )
        end
        Wait(Config.WaitTimes.PursuitStart or 5000)

        if Config.EnablePursuitNotify then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end
            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = "Pursuit",
                icon = 'fa-solid fa-car-on',
                priority = 2,
                message = ("%s (%s) | Pursuit"):format(lastName, callsign),
                name = ("%s %s (%s)"):format(firstName, lastName, callsign),
                coords = coords,
                street = ("%s %s"):format(postal, streetName or "Unknown"),
                alertTime = 10,
                jobs = Config.Dispatch.TrafficStop,
                information = ("%s (%s). Show me in an Active Pursuit"):format(lastName, callsign)
            })
        end
    end)
end)





--------------------------------------
-- Pursuit Conclude
--------------------------------------
-- RegisterNetEvent('ErsIntegration::OnPursuitEnded', function(pedData)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local coords = GetEntityCoords(GetPlayerPed(src))
--     local firstName = Player.PlayerData.charinfo.firstname or "Unknown"
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     Citizen.CreateThread(function()
--         Wait(Config.WaitTimes.PursuitStart)

--         if Config.EnablePursuitCode4 then
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'codefour',
--                 title = "Pursuit",
--                 icon = 'fas fa-car',
--                 priority = 2,
--                 message = ("%s (%s) | Code"):format(     
--                     lastName,
--                     callsign),
--                 name = ("%s %s (%s)"):format(
--                     firstName,
--                     lastName,
--                     callsign),
--                 coords = coords,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.TrafficStop,
--                 information = ("%s (%s). Show me in a Active Pursuit"):format(
--                     lastName, 
--                     callsign 
--                 ),
--             })
--         end

--     end)
-- end)

--------------------------------------------------------------------------------------------------
-- Request EVENTS
--------------------------------------------------------------------------------------------------
-- RegisterNetEvent('ErsIntegration:server:OnCoronerRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"



--     CreateThread(function()
--         if Config.EnableCoronerRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Coroner Request',
--                 description = ('%s (%s) requesting coroner services @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-skull-crossbones'
--             })
--         end

--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Coroner services requested',
--                 icon = 'fas fa-skull-crossbones',
--                 color = '#8b0000',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000) 
        
--         if Config.EnableCoronerArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch', 
--                 codeName = 'dispatch',
--                 title = "Coroner",
--                 icon = 'fas fa-skull-crossbones',
--                 message = ("Coroner On Scene | %s"):format(
--                     postal),
--                 name = ("Coroner Service"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 alertTime = 10,
--                 priority = 1,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised local Coroner is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),          
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnMechanicRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableMechanicRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Mechanic Request',
--                 description = ('%s (%s) requesting mechanic services @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-tools'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Mechanic requested',
--                 icon = 'fas fa-tools',
--                 color = '#f39c12',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableMechanicArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "MechanicResponding",
--                 icon = 'fas fa-tools',
--                 message = ("Roadside Assistance On Scene | %s"):format(
--                     postal),
--                 name = ("Mechanic Service"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 alertTime = 10,
--                 priority = 2,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Auto Mechanic is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnTowRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"
--     -- local coords = GetEntityCoords(GetPlayerPed(src))


--     CreateThread(function()
--         if Config.EnableTowRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Tow Request',
--                 description = ('%s (%s) requesting tow truck @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-truck-pickup'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Tow Truck Requested',
--                 icon = 'fas fa-truck-pickup',
--                 color = '#f39c12',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableTowArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "TowTruck",
--                 icon = 'fas fa-truck-pickup',
--                 message = ("Tow Service On Scene | %s"):format(
--                     postal),
--                 name = ("Towing Service"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 2,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Tow Truck Service is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)


-- RegisterNetEvent('ErsIntegration:server:OnTaxiRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableTaxiRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Taxi Request',
--                 description = ('%s (%s) requesting taxi service @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fa-solid fa-taxi'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Taxi Requested',
--                 icon = 'fa-solid fa-taxi',
--                 color = '#f39c12',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableTaxiArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "TaxiResponding",
--                 icon = 'fa-solid fa-taxi',
--                 message = ("Taxi Service On Scene | %s"):format(
--                     postal),
--                 name = ("Taxi Service"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 2,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Taxi Service has been dispatched and is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnPoliceRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableTransportRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Transport Request',
--                 description = ('%s (%s) to Dispatch. Send a Police Transport to %s %s for a individual.')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fa-solid fa-car-on'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Police Transport Requested',
--                 icon = 'fa-solid fa-car-on',
--                 color = '#2c3e50',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableTransportArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "PoliceTransport",
--                 icon = 'fa-solid fa-car-on',
--                 message = ("PD Transport On Scene | %s"):format(
--                     postal),
--                 name = ("Police Transport"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 2,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Police Transport Officer has been dispatched and is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnAnimalRescueRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableAnimalRescueRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Animal Rescue',
--                 description = ('%s (%s) to Dispatch. Animal Rescue is needed immediately @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fa-solid fa-paw'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Animal Rescue Requested',
--                 icon = 'fa-solid fa-paw',
--                 color = '#f39c12',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableAnimalRescueArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "AnimalRescue",
--                 icon = 'fa-solid fa-paw',
--                 message = ("Animal Control On Scene | %s"):format(
--                     postal),
--                 name = ("Animal Rescue"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 2,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Animal Control Supervisor has been dispatched and is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnAmbulanceRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableAmbulanceRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - EMS Request',
--                 description = ('%s (%s) to Dispatch. EMS needed immediately @ %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-ambulance'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'EMS Requested',
--                 icon = 'fas fa-ambulance',
--                 color = '#1e90ff',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableAmbulanceArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "Ambulance",
--                 icon = 'fas fa-ambulance',
--                 message = ("Paramedic Arriving | %s"):format(
--                     postal),
--                 name = ("Ambulance Service"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 1,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Paramedic has been dispatched and is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnFireRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--    CreateThread(function()
--         if Config.EnableFireRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Fire Rescue',
--                 description = ('%s (%s) to Dispatch. Send Fire Rescue to %s %s')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-fire-flame-curved'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Fire Rescue Requested',
--                 icon = 'fas fa-fire-flame-curved',
--                 color = '#f31212',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000)
--         if Config.EnableFireArrive then 
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end       
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch',
--                 codeName = 'dispatch',
--                 title = "FireRescue",
--                 icon = 'fas fa-fire-flame-curved',
--                 message = ("Fire Rescue On Scene | %s"):format(
--                     postal),
--                 name = ("Fire Rescue"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 1,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised Fire Rescue has been dispatched and is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

-- RegisterNetEvent('ErsIntegration:server:OnRoadServiceRequested', function(postal, streetName)
--     if not Config.EnableServiceRequestandArrive then return end
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local ped = GetPlayerPed(src)
--     local coords = GetEntityCoords(ped)
--     local lastName = Player.PlayerData.charinfo.lastname or "Unknown"
--     local callsign = Player.PlayerData.metadata.callsign or "N/A"

--     CreateThread(function()
--         if Config.EnableRoadServiceRequest then
--             TriggerClientEvent('ox_lib:notify', src, {
--                 title = 'Dispatch - Road Crew',
--                 description = ('%s (%s) to Dispatch. I need a Road Crew @ %s %s. We got a mess!')
--                     :format(lastName, callsign, postal, streetName),
--                 type = 'success',
--                 duration = 4000,
--                 icon = 'fas fa-broom'
--             })
--         end
--         if Config.ShowTextUI then
--             TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
--                 message = 'Road Service Requested',
--                 icon = 'fas fa-broom',
--                 color = '#f39c12',
--                 duration = 8000
--             })
--         end
--         Wait(Config.WaitTimes.RequestEvents or 5000) 
--         if Config.EnableRoadServiceArrive then
--             if Config.EnableRadioAnim then
--                 TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
--             end
--             TriggerEvent('ps-dispatch:server:notify', {
--                 code = 'Dispatch', 
--                 codeName = 'dispatch',
--                 title = 'RoadService',
--                 icon = 'fas fa-broom',
--                 message = ("Road Service On Scene | %s"):format(
--                     postal),
--                 name = ("Road Service Crew"),
--                 coords = coords,
--                 street = ("%s %s"):format(
--                     postal,
--                     streetName or "Unknown"),
--                 priority = 2,
--                 alertTime = 10,
--                 jobs = Config.Dispatch.ServiceRequest,
--                 information = ("Dispatch to %s (%s). Be advised a Road Service Crew is confirmed 10-97 to your location."):format(
--                     lastName, 
--                     callsign),
--             })
--         end
--     end)
-- end)

--------------------------------------------------------------------------------------------------
-- Request EVENTS
--------------------------------------------------------------------------------------------------

local ServiceRequests = {
    Coroner = {
        event = 'ErsIntegration:server:OnCoronerRequested',
        requestEnabled = 'EnableCoronerRequest',
        arriveEnabled = 'EnableCoronerArrive',
        notifyTitle = 'Dispatch - Coroner Request',
        notifyDesc = '%s (%s) requesting coroner services @ %s %s',
        textMessage = 'Coroner services requested',
        icon = 'fas fa-skull-crossbones',
        color = '#8b0000',
        dispatchTitle = 'Coroner',
        dispatchMessage = 'Coroner On Scene | %s',
        dispatchName = 'Coroner Service',
        priority = 1,
        information = 'Dispatch to %s (%s). Be advised local Coroner is confirmed 10-97 to your location.'
    },

    Mechanic = {
        event = 'ErsIntegration:server:OnMechanicRequested',
        requestEnabled = 'EnableMechanicRequest',
        arriveEnabled = 'EnableMechanicArrive',
        notifyTitle = 'Dispatch - Mechanic Request',
        notifyDesc = '%s (%s) requesting mechanic services @ %s %s',
        textMessage = 'Mechanic requested',
        icon = 'fas fa-tools',
        color = '#f39c12',
        dispatchTitle = 'MechanicResponding',
        dispatchMessage = 'Roadside Assistance On Scene | %s',
        dispatchName = 'Mechanic Service',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Auto Mechanic is confirmed 10-97 to your location.'
    },

    Tow = {
        event = 'ErsIntegration:server:OnTowRequested',
        requestEnabled = 'EnableTowRequest',
        arriveEnabled = 'EnableTowArrive',
        notifyTitle = 'Dispatch - Tow Request',
        notifyDesc = '%s (%s) requesting tow truck @ %s %s',
        textMessage = 'Tow Truck Requested',
        icon = 'fas fa-truck-pickup',
        color = '#f39c12',
        dispatchTitle = 'TowTruck',
        dispatchMessage = 'Tow Service On Scene | %s',
        dispatchName = 'Towing Service',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Tow Truck Service is confirmed 10-97 to your location.'
    },

    Taxi = {
        event = 'ErsIntegration:server:OnTaxiRequested',
        requestEnabled = 'EnableTaxiRequest',
        arriveEnabled = 'EnableTaxiArrive',
        notifyTitle = 'Dispatch - Taxi Request',
        notifyDesc = '%s (%s) requesting taxi service @ %s %s',
        textMessage = 'Taxi Requested',
        icon = 'fa-solid fa-taxi',
        color = '#f39c12',
        dispatchTitle = 'TaxiResponding',
        dispatchMessage = 'Taxi Service On Scene | %s',
        dispatchName = 'Taxi Service',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Taxi Service has been dispatched and is confirmed 10-97 to your location.'
    },

    Police = {
        event = 'ErsIntegration:server:OnPoliceRequested',
        requestEnabled = 'EnableTransportRequest',
        arriveEnabled = 'EnableTransportArrive',
        notifyTitle = 'Dispatch - Transport Request',
        notifyDesc = '%s (%s) to Dispatch. Send a Police Transport to %s %s for a individual.',
        textMessage = 'Police Transport Requested',
        icon = 'fa-solid fa-car-on',
        color = '#2c3e50',
        dispatchTitle = 'PoliceTransport',
        dispatchMessage = 'PD Transport On Scene | %s',
        dispatchName = 'Police Transport',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Police Transport Officer has been dispatched and is confirmed 10-97 to your location.'
    },

    AnimalRescue = {
        event = 'ErsIntegration:server:OnAnimalRescueRequested',
        requestEnabled = 'EnableAnimalRescueRequest',
        arriveEnabled = 'EnableAnimalRescueArrive',
        notifyTitle = 'Dispatch - Animal Rescue',
        notifyDesc = '%s (%s) to Dispatch. Animal Rescue is needed immediately @ %s %s',
        textMessage = 'Animal Rescue Requested',
        icon = 'fa-solid fa-paw',
        color = '#f39c12',
        dispatchTitle = 'AnimalRescue',
        dispatchMessage = 'Animal Control On Scene | %s',
        dispatchName = 'Animal Rescue',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Animal Control Supervisor has been dispatched and is confirmed 10-97 to your location.'
    },

    Ambulance = {
        event = 'ErsIntegration:server:OnAmbulanceRequested',
        requestEnabled = 'EnableAmbulanceRequest',
        arriveEnabled = 'EnableAmbulanceArrive',
        notifyTitle = 'Dispatch - EMS Request',
        notifyDesc = '%s (%s) to Dispatch. EMS needed immediately @ %s %s',
        textMessage = 'EMS Requested',
        icon = 'fas fa-ambulance',
        color = '#1e90ff',
        dispatchTitle = 'Ambulance',
        dispatchMessage = 'Paramedic Arriving | %s',
        dispatchName = 'Ambulance Service',
        priority = 1,
        information = 'Dispatch to %s (%s). Be advised a Paramedic has been dispatched and is confirmed 10-97 to your location.'
    },

    Fire = {
        event = 'ErsIntegration:server:OnFireRequested',
        requestEnabled = 'EnableFireRequest',
        arriveEnabled = 'EnableFireArrive',
        notifyTitle = 'Dispatch - Fire Rescue',
        notifyDesc = '%s (%s) to Dispatch. Send Fire Rescue to %s %s',
        textMessage = 'Fire Rescue Requested',
        icon = 'fas fa-fire-flame-curved',
        color = '#f31212',
        dispatchTitle = 'FireRescue',
        dispatchMessage = 'Fire Rescue On Scene | %s',
        dispatchName = 'Fire Rescue',
        priority = 1,
        information = 'Dispatch to %s (%s). Be advised Fire Rescue has been dispatched and is confirmed 10-97 to your location.'
    },

    RoadService = {
        event = 'ErsIntegration:server:OnRoadServiceRequested',
        requestEnabled = 'EnableRoadServiceRequest',
        arriveEnabled = 'EnableRoadServiceArrive',
        notifyTitle = 'Dispatch - Road Crew',
        notifyDesc = '%s (%s) to Dispatch. I need a Road Crew @ %s %s. We got a mess!',
        textMessage = 'Road Service Requested',
        icon = 'fas fa-broom',
        color = '#f39c12',
        dispatchTitle = 'RoadService',
        dispatchMessage = 'Road Service On Scene | %s',
        dispatchName = 'Road Service Crew',
        priority = 2,
        information = 'Dispatch to %s (%s). Be advised a Road Service Crew is confirmed 10-97 to your location.'
    }
}

local function HandleServiceRequest(src, postal, streetName, data)
    if not Config.EnableServiceRequestandArrive then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    local lastName = Player.PlayerData.charinfo.lastname or 'Unknown'
    local callsign = Player.PlayerData.metadata.callsign or 'N/A'

    postal = postal or 'Unknown'
    streetName = streetName or 'Unknown'

    CreateThread(function()
        if Config[data.requestEnabled] then
            TriggerClientEvent('ox_lib:notify', src, {
                title = data.notifyTitle,
                description = data.notifyDesc:format(lastName, callsign, postal, streetName),
                type = 'success',
                duration = 4000,
                icon = data.icon
            })
        end

        if Config.ShowTextUI then
            TriggerClientEvent('ersi:client:TextUI:ServiceRequest', src, {
                message = data.textMessage,
                icon = data.icon,
                color = data.color,
                duration = 8000
            })
        end

        Wait(Config.WaitTimes.RequestEvents or 5000)

        if Config[data.arriveEnabled] then
            if Config.EnableRadioAnim then
                TriggerClientEvent('ersi:client:PlayRadioAnimPhoneTalk', src)
            end

            TriggerEvent('ps-dispatch:server:notify', {
                code = 'Dispatch',
                codeName = 'dispatch',
                title = data.dispatchTitle,
                icon = data.icon,
                message = data.dispatchMessage:format(postal),
                name = data.dispatchName,
                coords = coords,
                street = ('%s %s'):format(postal, streetName),
                priority = data.priority,
                alertTime = 10,
                jobs = Config.Dispatch.ServiceRequest,
                information = data.information:format(lastName, callsign)
            })
        end
    end)
end

for _, data in pairs(ServiceRequests) do
    RegisterNetEvent(data.event, function(postal, streetName)
        HandleServiceRequest(source, postal, streetName, data)
    end)
end

-- =========================================================
-- ERS Tablet Usable Item - qb-inventory / QBCore
-- =========================================================
CreateThread(function()
    if not Config.TabletItem or not Config.TabletItem.enabled then return end
    if not Config.TabletItem.itemName then return end

    if QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
        QBCore.Functions.CreateUseableItem(Config.TabletItem.itemName, function(src, item)
            if not HasTabletAccess(src) then
                DenyTabletAccess(src)
                return
            end

            TriggerClientEvent('ersi:client:useDatabaseTablet', src)
        end)
    end
end)

-- =========================================================
-- ERS Tablet Usable Item - ox_inventory
-- =========================================================
CreateThread(function()
    if GetResourceState('ox_inventory') ~= 'started' then return end
    if not Config.TabletItem or not Config.TabletItem.enabled then return end
    if not Config.TabletItem.itemName then return end

    local success, err = pcall(function()
        exports.ox_inventory:RegisterUsableItem(Config.TabletItem.itemName, function(data)
            local src = data.source

            if not HasTabletAccess(src) then
                DenyTabletAccess(src)
                return
            end

            TriggerClientEvent('ersi:client:useDatabaseTablet', src)
        end)
    end)

    if not success then
        print('[ERS Tablet] ox_inventory RegisterUsableItem not available. Use client.event in ox_inventory/data/items.lua instead.')
    end
end)


CreateThread(function()
    while true do
        Wait(Config.PersonnelLocation and Config.PersonnelLocation.updateInterval or 60000)

        if Config.PersonnelLocation and Config.PersonnelLocation.enabled then
            for _, src in pairs(QBCore.Functions.GetPlayers()) do
                TriggerClientEvent('ErsIntegration:client:GetStreetAndPostal', src)
            end
        end
    end
end)
