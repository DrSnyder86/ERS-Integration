-- ox_inventory

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