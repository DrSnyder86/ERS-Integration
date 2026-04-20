-- qb-radialmenu/config.lua

-- Add right after
-- Config.MenuItems = {
--==========================
-- ERS STUFF START
--==========================
-- This is a complete table


{
    id = 'ers_x',
    title = 'ERS',
    icon = 'clipboard-list',
    items = {
        {
            id = 'ers_duty',
            title = 'ERS Duty',
            icon = 'clipboard-list',
            items = {
                { id = 'toggle_police', title = 'Toggle Police Duty', icon = 'user-shield', type = 'server', event = 'ers:server:TogglePoliceShift', shouldClose = true },
                { id = 'toggle_ambulance', title = 'Toggle Ambulance Duty', icon = 'briefcase-medical', type = 'server', event = 'ers:server:ToggleAmbulanceShift', shouldClose = true },
                { id = 'toggle_fire', title = 'Toggle Fire Duty', icon = 'fire-extinguisher', type = 'server', event = 'ers:server:ToggleFireShift', shouldClose = true },
                { id = 'toggle_tow', title = 'Toggle Tow Duty', icon = 'truck', type = 'server', event = 'ers:server:ToggleTowShift', shouldClose = true },
            }
        },
        {
            id = 'ers_calls',
            title = 'ERS Utilities',
            icon = 'list-check',
            items = {
                {
                    id = 'police_database',
                    title = 'Database',
                    icon = 'wifi',
                    type = 'client',
                    event = 'ersi:client:openPoliceDatabaseMenu',
                    shouldClose = true
                },
                { id = 'request_callout', title = 'Request 911 Call', icon = 'bell', type = 'client', event = 'ersi:callout:request', shouldClose = true },
                { id = 'toggle_callouts', title = 'Toggle 911 Dispatch', icon = 'clipboard-list', type = 'client', event = 'ersi:callouts:toggle', shouldClose = true },
                { id = 'wraith', title = 'Wraith Radar', icon = 'car-side', type = 'client', event = 'wk:openRemote', shouldClose = true },
                { id = 'mdt_toggle', title = 'MDT Tablet', icon = 'tablet-alt', type = 'client', event = 'ersi:mdt:toggle', shouldClose = true },
                { id = 'speedzone', title = 'Traffic Control', icon = 'triangle-exclamation', type = 'client', event = 'ersi:speedzone', shouldClose = true },
            }
        },
        {
            id = 'ers_cancel',
            title = 'Cancel Requests',
            icon = 'triangle-exclamation',
            items = {
                { id = 'cancel_ambulance', title = 'Cancel Ambulance', icon = 'ambulance', type = 'client', event = 'ersi:call:cancelambulance', shouldClose = true },
                { id = 'cancel_fire', title = 'Cancel Fire Unit', icon = 'truck', type = 'client', event = 'ersi:call:cancelfire', shouldClose = true },
                { id = 'cancel_police', title = 'Cancel Police', icon = 'shield-alt', type = 'client', event = 'ersi:call:cancelpolice', shouldClose = true },
                { id = 'cancel_coroner', title = 'Cancel Coroner', icon = 'skull-crossbones', type = 'client', event = 'ersi:call:cancelcoroner', shouldClose = true },
                { id = 'cancel_taxi', title = 'Cancel Taxi', icon = 'taxi', type = 'client', event = 'ersi:call:canceltaxi', shouldClose = true },
                { id = 'cancel_tow', title = 'Cancel Tow', icon = 'truck', type = 'client', event = 'ersi:call:canceltow', shouldClose = true },
                { id = 'cancel_mechanic', title = 'Cancel Mechanic', icon = 'wrench', type = 'client', event = 'ersi:call:cancelmechanic', shouldClose = true },
                { id = 'cancel_animal_rescue', title = 'Cancel Animal Rescue', icon = 'paw', type = 'client', event = 'ersi:call:cancelanimalrescue', shouldClose = true },
                { id = 'cancel_roadservice', title = 'Cancel Road Service', icon = 'truck', type = 'client', event = 'ersi:call:cancelroadservice', shouldClose = true },
            }
        },
        {
            id = 'ers_request',
            title = 'ERS Services',
            icon = 'clipboard-list',
            items = {
                { id = 'request_ambulance', title = 'Ambulance', icon = 'ambulance', type = 'client', event = 'ersi:call:ambulance', shouldClose = true },
                { id = 'request_police', title = 'PD Transport', icon = 'shield-alt', type = 'client', event = 'ersi:call:police', shouldClose = true },
                { id = 'request_tow', title = 'Tow', icon = 'truck', type = 'client', event = 'ersi:call:tow', shouldClose = true },
                { id = 'requestfire', title = 'Fire Unit', icon = 'truck', type = 'client', event = 'ersi:call:requestfire', shouldClose = true },
                { id = 'request_coroner', title = 'Coroner', icon = 'skull-crossbones', type = 'client', event = 'ersi:call:coroner', shouldClose = true },
                { id = 'request_mechanic', title = 'Mechanic', icon = 'wrench', type = 'client', event = 'ersi:call:mechanic', shouldClose = true },
                { id = 'request_roadservice', title = 'Road Service', icon = 'truck', type = 'client', event = 'ersi:call:roadservice', shouldClose = true },
                { id = 'request_taxi', title = 'Taxi', icon = 'taxi', type = 'client', event = 'ersi:call:taxi', shouldClose = true },
                { id = 'request_animal_rescue', title = 'Animal Rescue', icon = 'paw', type = 'client', event = 'ersi:call:animalrescue', shouldClose = true },
            }
        },
    }
},

--==========================
-- ERS STUFF END
--==========================
