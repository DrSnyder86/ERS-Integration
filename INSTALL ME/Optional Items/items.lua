-- ox_inventory
-- ox_inventory/data/items.lua
	['ers_tablet'] = {
        label = 'ERS Tablet',
        weight = 1000,
        stack = false,
        close = true,
        description = 'Emergency Response System mobile data terminal.',
        client = {
            event = 'ersi:client:useDatabaseTablet'
        }
    },
	
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

ers_tablet = {
    name = 'ers_tablet',
    label = 'ERS Tablet',
    weight = 500,
    type = 'item',
    image = 'ers_tablet.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'Emergency Response System mobile data terminal.',
    client = {
        event = 'ersi:client:useDatabaseTablet'
    }
},

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
