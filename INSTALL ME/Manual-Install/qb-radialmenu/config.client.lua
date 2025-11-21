-- qb-radialmenu/config.lua

-- Add right after
-- Config.MenuItems = {
--==========================
-- ERS STUFF START
--==========================
-- This is a complete table


{
    id = 'ers_x',
    title = 'ERS Menu',
    icon = 'laptop',
    items = {
        {
            id = 'ers_duty',
            title = 'ERS Duty',
            icon = 'user-clock',
            items = {
                { id = 'togglepolice', title = 'Police Duty', icon = 'user-shield', type = 'server', event = 'ers:server:TogglePoliceShift', shouldClose = true },
                { id = 'toggleambulance', title = 'Ambulance Duty', icon = 'user-nurse', type = 'server', event = 'ers:server:ToggleAmbulanceShift', shouldClose = true },
                { id = 'togglefire', title = 'Fire Duty', icon = 'fire', type = 'server', event = 'ers:server:ToggleFireShift', shouldClose = true },
                { id = 'toggletow', title = 'Tow Duty', icon = 'truck-pickup', type = 'server', event = 'ers:server:ToggleTowShift', shouldClose = true },
            }
        },
        {
            id = 'ers_calls',
            title = 'ERS Utilities',
            icon = 'user-lock',
            items = {
                { id = 'requestcallout', title = 'Request Call', icon = 'bullhorn', type = 'client', event = 'ersi:callout:request', shouldClose = true },
                { id = 'togglecallouts', title = 'Toggle Dispatch', icon = 'satellite-dish', type = 'client', event = 'ersi:callouts:toggle', shouldClose = true },
                { id = 'wraith', title = 'Wraith Radar', icon = 'mobile', type = 'client', event = 'wk:openRemote', shouldClose = true },
                { id = 'mdttoggle', title = 'MDT', icon = 'tablet', type = 'client', event = 'ersi:mdt:toggle', shouldClose = true },
                { id = 'speedzone', title = 'Traffic Control', icon = 'traffic-light', type = 'client', event = 'ersi:speedzone', shouldClose = true },
            }
        },
        {
            id = 'ers_cancel',
            title = 'Cancel Requests',
            icon = 'users-slash',
            items = {
                { id = 'cancel_ambulance', title = 'Cancel Ambulance', icon = 'briefcase-medical', type = 'client', event = 'ersi:call:cancelambulance', shouldClose = true },
                { id = 'cancel_fire', title = 'Cancel Fire Unit', icon = 'fire', type = 'client', event = 'ersi:call:cancelfire', shouldClose = true },
                { id = 'cancel_police', title = 'Cancel Police', icon = 'handcuffs', type = 'client', event = 'ersi:call:cancelpolice', shouldClose = true },
                { id = 'cancel_coroner', title = 'Cancel Coroner', icon = 'skull-crossbones', type = 'client', event = 'ersi:call:cancelcoroner', shouldClose = true },
                { id = 'cancel_taxi', title = 'Cancel Taxi', icon = 'taxi', type = 'client', event = 'ersi:call:canceltaxi', shouldClose = true },
                { id = 'cancel_tow', title = 'Cancel Tow', icon = 'truck-pickup', type = 'client', event = 'ersi:call:canceltow', shouldClose = true },
                { id = 'cancel_mechanic', title = 'Cancel Mechanic', icon = 'wrench', type = 'client', event = 'ersi:call:cancelmechanic', shouldClose = true },
                { id = 'cancel_animal_rescue', title = 'Cancel Animal Rescue', icon = 'paw', type = 'client', event = 'ersi:call:cancelanimalrescue', shouldClose = true },
                { id = 'cancel_roadservice', title = 'Cancel Road Service', icon = 'broom', type = 'client', event = 'ersi:call:cancelroadservice', shouldClose = true },
            }
        },
        {
            id = 'ers_request',
            title = 'ERS Services',
            icon = 'users',
            items = {
                { id = 'requestambulance', title = 'Ambulance', icon = 'briefcase-medical', type = 'client', event = 'ersi:call:ambulance', shouldClose = true },
                { id = 'requestpolice', title = 'PD Transport', icon = 'handcuffs', type = 'client', event = 'ersi:call:police', shouldClose = true },
                { id = 'requesttow', title = 'Tow', icon = 'truck-pickup', type = 'client', event = 'ersi:call:tow', shouldClose = true },
                { id = 'requestfire', title = 'Fire Unit', icon = 'fire', type = 'client', event = 'ersi:custom:requestfire', shouldClose = true },
                { id = 'requestcoroner', title = 'Coroner', icon = 'skull-crossbones', type = 'client', event = 'ersi:call:coroner', shouldClose = true },
                { id = 'requestmechanic', title = 'Mechanic', icon = 'wrench', type = 'client', event = 'ersi:call:mechanic', shouldClose = true },
                { id = 'requestroadservice', title = 'Road Service', icon = 'broom', type = 'client', event = 'ersi:call:roadservice', shouldClose = true },
                { id = 'requesttaxi', title = 'Taxi', icon = 'taxi', type = 'client', event = 'ersi:call:taxi', shouldClose = true },
                { id = 'requestanimalrescue', title = 'Animal Rescue', icon = 'paw', type = 'client', event = 'ersi:call:animalrescue', shouldClose = true },
            }
        },
        -- REMOVED FROM PS-DISPATCH
        -- {
        --     id = 'ers_state',
        --     title = 'State Dispatch',
        --     icon = 'list-check',
        --     items = {
        --         { id = 'trafficStop', title = '10-11', icon = 'car-side', type = 'client', event = 'ps-dispatch:client:trafficstop', shouldClose = true },
        --         { id = 'emergencyButton', title = '10-99', icon = 'bell', type = 'client', event = 'ps-dispatch:client:officerbackup', shouldClose = true },
        --         { id = 'fireCall', title = 'FIRE', icon = 'bell', type = 'client', event = 'ps-dispatch:client:firecall', shouldClose = true },
        --         { id = 'enroute', title = '10-97', icon = 'bell', type = 'client', event = 'ps-dispatch:client:enroute', shouldClose = true },
        --         { id = 'onscene', title = '10-23', icon = 'bell', type = 'client', event = 'ps-dispatch:client:onscene', shouldClose = true },
        --         { id = 'codefour', title = 'Code-4', icon = 'bell', type = 'client', event = 'ps-dispatch:client:codefour', shouldClose = true },
        --     }
        -- },
    }
},

--==========================
-- ERS STUFF END
--==========================