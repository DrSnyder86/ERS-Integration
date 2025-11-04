--add these categories in your radial menu. qbx-radialmenu/config/client.lua

            {
            id = 'ersutilities',
            icon = 'clipboard-list',
            label = 'ERS Utilities',
            items = {
                {
                    id = 'ers',
                    icon = 'list-check',
                    label = 'ERS Dispatch',
                    items = {
                    {
                        id = 'request_callout',
                        icon = 'bell', 
                        label = 'Request 911 Call',
                        event = 'callout:request',
                    },
                    {
                        id = 'toggle_shift',
                        icon = 'user-clock', 
                        label = 'Toggle Shift',
                        event = 'shift:toggle',
                    },
                    {
                        id = 'toggle_callouts',
                        icon = 'clipboard-list',
                        label = 'Toggle 911 Dispatch',
                        event = 'callouts:toggle',
                    },
                    --optional toggle /mdt and wraith radar remote
                    {
				        id = 'wraith',
				        icon = 'car-side',
				        label = 'Wraith Radar',
				        event = 'wk:openRemote',
			        },
                    {
                        id = 'mdt_toggle',
                        icon = 'tablet-alt',
                        label = 'MDT Tablet',
                        event = 'mdt:toggle',
                    },
                },
            },

            --cancel requests
            {
                    id = 'cancel_requests',
                    icon = 'triangle-exclamation',
                    label = 'Cancel Requests',
                    items = {
                    {
                        id = 'cancel_ambulance',
                        icon = 'ambulance',
                        label = 'Cancel Ambulance',
                        event = 'call:cancelambulance',
                    },
                    {
                        id = 'cancel_fire',
                        icon = 'truck',
                        label = 'Cancel Fire Unit',
                        event = 'call:cancelfire',
                    },
                    {
                        id = 'cancel_police',
                        icon = 'shield-alt',
                        label = 'Cancel Police',
                        event = 'call:cancelpolice',
                    },
                    {
                        id = 'cancel_coroner',
                        icon = 'skull-crossbones',
                        label = 'Cancel Coroner',
                        event = 'call:cancelcoroner',
                    },
                    {
                        id = 'cancel_taxi',
                        icon = 'taxi',
                        label = 'Cancel Taxi',
                        event = 'call:canceltaxi',
                    },
                    {
                        id = 'cancel_tow',
                        icon = 'truck',
                        label = 'Cancel Tow',
                        event = 'call:canceltow',
                    },
                    {
                        id = 'cancel_mechanic',
                        icon = 'wrench',
                        label = 'Cancel Mechanic',
                        event = 'call:cancelmechanic',
                    },
        
                    {
                        id = 'cancel_animal_rescue',
                        icon = 'paw',
                        label = 'Cancel Animal Rescue',
                        event = 'call:cancelanimalrescue',
                    },
                    {
                        id = 'cancel_roadservice',
                        icon = 'truck',
                        label = 'Cancel Road Service',
                        event = 'call:cancelroadservice',
                    },
                },
            },

            --service requests

            {
                id = 'ersservices',
                icon = 'clipboard-list',
                label = 'ERS Services',
                items = {
                {
                    id = 'request_ambulance',
                    icon = 'ambulance',
                    label = 'Ambulance',
                    event = 'call:ambulance',
                },                    
                {
                    id = 'request_police',
                    icon = 'shield-alt',
                    label = 'PD Transport',
                    event = 'call:police',
                },
                {
                    id = 'request_tow',
                    icon = 'truck',
                    label = 'Tow',
                    event = 'call:tow',
                },
                {
                    id = 'requestfire',
                    icon = 'truck',
                    label = 'Fire Unit',
                    event = 'custom:requestfire',
                },
                {
                    id = 'request_coroner',
                    icon = 'skull-crossbones',
                    label = 'Coroner',
                    event = 'call:coroner',
                },
                {
                    id = 'request_mechanic',
                    icon = 'wrench',
                    label = 'Mechanic',
                    event = 'call:mechanic',
                },
                {
                    id = 'request_roadservice',
                    icon = 'truck',  -- great fit for roadside assistance
                    label = 'Road Service',
                    event = 'call:roadservice',
                },
                {
                    id = 'request_taxi',
                    icon = 'taxi',
                    label = 'Taxi',
                    event = 'call:taxi',
                },            
                {
                    id = 'request_animal_rescue',
                    icon = 'paw',
                    label = 'Animal Rescue',
                    event = 'call:animalrescue',
                },
            },
        },

        --optional self dispatch ps-dispatch events

            {
                id = 'dispatch',
                icon = 'list-check',
                label = 'State Dispatch',
                items = {
                    {
						id = 'trafficStop',
						icon = 'car-side',
						label = '10-11',
						event = 'ps-dispatch:client:trafficstop',
					},
                    {
						id = 'emergencyButton',
						icon = 'bell',
						label = '10-99',
						event = 'ps-dispatch:client:officerbackup',
					},
                    {
						id = 'fireCall',
						icon = 'bell',
						label = 'FIRE',
						event = 'ps-dispatch:client:firecall',
					},
					{
						id = 'enroute',
						icon = 'bell',
						label = '10-97',
						event = 'ps-dispatch:client:enroute',
					},
                    {
						id = 'onscene',
						icon = 'bell',
						label = '10-23',
						event = 'ps-dispatch:client:onscene',
					},
                    {
						id = 'codefour',
						icon = 'bell',
						label = 'Code-4',
						event = 'ps-dispatch:client:codefour',
					},
                },
            },

            