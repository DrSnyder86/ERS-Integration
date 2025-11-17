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
                { id = 'togglepolice', title = 'Toggle Police Duty', icon = 'user-shield', type = 'server', event = 'ers:server:TogglePoliceShift', shouldClose = true },
                { id = 'toggleambulance', title = 'Toggle Ambulance Duty', icon = 'briefcase-medical', type = 'server', event = 'ers:server:ToggleAmbulanceShift', shouldClose = true },
                { id = 'togglefire', title = 'Toggle Fire Duty', icon = 'fire-extinguisher', type = 'server', event = 'ers:server:ToggleFireShift', shouldClose = true },
                { id = 'toggletow', title = 'Toggle Tow Duty', icon = 'truck', type = 'server', event = 'ers:server:ToggleTowShift', shouldClose = true },
            }
        },
        {
            id = 'ers_calls',
            title = 'ERS Utilities',
            icon = 'list-check',
            items = {
                { id = 'requestcallout', title = 'Request 911 Call', icon = 'bell', type = 'client', event = 'callout:request', shouldClose = true },
                { id = 'togglecallouts', title = 'Toggle 911 Dispatch', icon = 'clipboard-list', type = 'client', event = 'callouts:toggle', shouldClose = true },
                { id = 'wraith', title = 'Wraith Radar', icon = 'car-side', type = 'client', event = 'wk:openRemote', shouldClose = true },
                { id = 'mdttoggle', title = 'MDT Tablet', icon = 'clipboard-list', type = 'client', event = 'mdt:toggle', shouldClose = true },
                { id = 'speedzone', title = 'Traffic Control', icon = 'triangle-exclamation', type = 'client', event = 'custom:speedzone', shouldClose = true },
            }
        },
        {
            id = 'ers_cancel',
            title = 'Cancel Requests',
            icon = 'triangle-exclamation',
            items = {
                { id = 'cancel_ambulance', title = 'Cancel Ambulance', icon = 'briefcase-medical', type = 'client', event = 'call:cancelambulance', shouldClose = true },
                { id = 'cancel_fire', title = 'Cancel Fire Unit', icon = 'truck', type = 'client', event = 'call:cancelfire', shouldClose = true },
                { id = 'cancel_police', title = 'Cancel Police', icon = 'user-shield', type = 'client', event = 'call:cancelpolice', shouldClose = true },
                { id = 'cancel_coroner', title = 'Cancel Coroner', icon = 'skull-crossbones', type = 'client', event = 'call:cancelcoroner', shouldClose = true },
                { id = 'cancel_taxi', title = 'Cancel Taxi', icon = 'taxi', type = 'client', event = 'call:canceltaxi', shouldClose = true },
                { id = 'cancel_tow', title = 'Cancel Tow', icon = 'truck', type = 'client', event = 'call:canceltow', shouldClose = true },
                { id = 'cancel_mechanic', title = 'Cancel Mechanic', icon = 'wrench', type = 'client', event = 'call:cancelmechanic', shouldClose = true },
                { id = 'cancel_animal_rescue', title = 'Cancel Animal Rescue', icon = 'paw', type = 'client', event = 'call:cancelanimalrescue', shouldClose = true },
                { id = 'cancel_roadservice', title = 'Cancel Road Service', icon = 'truck', type = 'client', event = 'call:cancelroadservice', shouldClose = true },
            }
        },
        {
            id = 'ers_request',
            title = 'ERS Services',
            icon = 'clipboard-list',
            items = {
                { id = 'requestambulance', title = 'Ambulance', icon = 'briefcase-medical', type = 'client', event = 'call:ambulance', shouldClose = true },
                { id = 'requestpolice', title = 'PD Transport', icon = 'user-shield', type = 'client', event = 'call:police', shouldClose = true },
                { id = 'requesttow', title = 'Tow', icon = 'truck', type = 'client', event = 'call:tow', shouldClose = true },
                { id = 'requestfire', title = 'Fire Unit', icon = 'truck', type = 'client', event = 'custom:requestfire', shouldClose = true },
                { id = 'requestcoroner', title = 'Coroner', icon = 'skull-crossbones', type = 'client', event = 'call:coroner', shouldClose = true },
                { id = 'requestmechanic', title = 'Mechanic', icon = 'wrench', type = 'client', event = 'call:mechanic', shouldClose = true },
                { id = 'requestroadservice', title = 'Road Service', icon = 'truck', type = 'client', event = 'call:roadservice', shouldClose = true },
                { id = 'requesttaxi', title = 'Taxi', icon = 'taxi', type = 'client', event = 'call:taxi', shouldClose = true },
                { id = 'requestanimalrescue', title = 'Animal Rescue', icon = 'paw', type = 'client', event = 'call:animalrescue', shouldClose = true },
            }
        },
        {
            id = 'ers_state',
            title = 'State Dispatch',
            icon = 'list-check',
            items = {
                { id = 'trafficStop', title = '10-11', icon = 'car-side', type = 'client', event = 'ps-dispatch:client:trafficstop', shouldClose = true },
                { id = 'emergencyButton', title = '10-99', icon = 'bell', type = 'client', event = 'ps-dispatch:client:officerbackup', shouldClose = true },
                { id = 'fireCall', title = 'FIRE', icon = 'bell', type = 'client', event = 'ps-dispatch:client:firecall', shouldClose = true },
                { id = 'enroute', title = '10-97', icon = 'bell', type = 'client', event = 'ps-dispatch:client:enroute', shouldClose = true },
                { id = 'onscene', title = '10-23', icon = 'bell', type = 'client', event = 'ps-dispatch:client:onscene', shouldClose = true },
                { id = 'codefour', title = 'Code-4', icon = 'bell', type = 'client', event = 'ps-dispatch:client:codefour', shouldClose = true },
            }
        },
    }
},

--==========================
-- ERS STUFF END

--==========================
