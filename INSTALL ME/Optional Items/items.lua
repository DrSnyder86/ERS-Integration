-- ox_inventory
-- ox_inventory/data/items.lua

    ['mdt_tablet'] = {
		label = 'MDT Tablet',
		weight = 500,
		stack = false,
		close = true,
        allowArmed = false,
		description = 'A police-issued tablet to access the MDT system.',
		client = {
			event = 'ersi:client:useMDTTablet',
		},
	},

    ["broom"] = {
        label = "Broom", 
		weight = 500, 
		stack = false, 
		close = true, 
        allowArmed = false,
		description = "Clean your scenes",
        client = { 
			event = "ersi:broom", 
		},
    },

	['wraithradar'] = {
        label = 'Wraith Radar Remote',
        weight = 100,
		stack = false,
        close = true, 
        allowArmed = false,
		description = "Remote for Police Radar Control",
        client = {
            event = 'wk:openRemote'
        }
    },

    ['firehose'] = {
        label = 'Fire Hose',
        weight = 500,
		stack = false,
        close = true, 
        allowArmed = false,
		description = "Put out those flames",
        client = {
            event = 'ersi:firehose'
        }
    },

    ['stretcher'] = {
        label = 'Stretcher',
        weight = 1000,
		stack = false,
        close = true, 
        allowArmed = false,
		description = "Fix me up doc",
        client = {
            event = 'ersi:stretcher'
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
        event = 'ersi:client:useMDTTablet'
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
        event = 'ersi:broom'
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

firehose = {
    name = 'firehose',
    label = 'Fire Hose',
    weight = 500,
    type = 'item',
    image = 'firehose.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'Put out those flames',
    client = {
        event = 'ersi:firehose'
    }
},

stretcher = {
    name = 'stretcher',
    label = 'Stretcher',
    weight = 500,
    type = 'item',
    image = 'stretcher.png',
    unique = false,
    useable = true,
    shouldClose = true,
    description = 'Fix me up doc',
    client = {
        event = 'ersi:stretcher'
    }
},