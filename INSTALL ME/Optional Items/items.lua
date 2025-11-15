-- ox_inventory
-- ox_inventory/data/items.lua

    ['mdt_tablet'] = {
		label = 'MDT Tablet',
		weight = 500,
		stack = false,
		close = true,
		description = 'A police-issued tablet to access the MDT system.',
		client = {
			event = 'custom:client:useMDTTablet',
		},
	},

    ["broom"] = {
        label = "Broom", 
		weight = 100, 
		stack = false, 
		close = true, 
		description = "Clean your scenes",
        client = { 
			event = "custom:broom", 
		},
    },

	['wraithradar'] = {
        label = 'Wraith Radar Remote',
        weight = 100,
		stack = false,
        allowArmed = true,
		description = "Remote for Police Radar Control",
        client = {
            event = 'wk:openRemote'
        }
    },


-- qb-inventory
-- qb-core/shared/items.lua

mdt_tablet = {
    name = 'mdt_tablet',
    label = 'MDT Tablet',
    weight = 500,
    type = 'item',
    image = 'mdt_tablet.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'A police-issued tablet to access the MDT system',
    client = {
        event = 'custom:client:useMDTTablet'
    }
},

broom = {
    name = 'broom',
    label = 'Broom',
    weight = 100,
    type = 'item',
    image = 'broom.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'Clean your scenes',
    client = {
        event = 'custom:broom'
    }
},

wraithradar = {
    name = 'wraithradar',
    label = 'Wraith Radar Remote',
    weight = 100,
    type = 'item',
    image = 'wraithradar.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'Remote for Police Radar Control',
    client = {
        event = 'wk:openRemote'
    }
},