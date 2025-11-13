-- qbx-radialmenu/config/client.lua

RadialMenu:AddOption({
    id = 'ersutilities',
    title = 'ERS Utilities',
    icon = 'clipboard-list',
    items = {

        -- ERS Dispatch Section
        {
            id = 'ers',
            title = 'ERS Dispatch',
            icon = 'list-check',
            items = {
                {
                    id = 'request_callout',
                    title = 'Request 911 Call',
                    icon = 'bell',
                    type = 'client',
                    event = 'callout:request',
                },
                {
                    id = 'toggle_shift',
                    title = 'Toggle Shift',
                    icon = 'user-clock',
                    type = 'client',
                    event = 'shift:toggle',
                },
                {
                    id = 'toggle_callouts',
                    title = 'Toggle 911 Dispatch',
                    icon = 'clipboard-list',
                    type = 'client',
                    event = 'callouts:toggle',
                },
                {
                    id = 'wraith',
                    title = 'Wraith Radar',
                    icon = 'car-side',
                    type = 'client',
                    event = 'wk:openRemote',
                },
                {
                    id = 'mdt_toggle',
                    title = 'MDT Tablet',
                    icon = 'tablet-alt',
                    type = 'client',
                    event = 'mdt:toggle',
                },
                {
                    id = 'speedzone',
                    title = 'Traffic Control',
                    icon = 'triangle-exclamation',
                    type = 'client',
                    event = 'custom:speedzone',
                },
            },
        },

        -- Cancel Requests Section
        {
            id = 'cancel_requests',
            title = 'Cancel Requests',
            icon = 'triangle-exclamation',
            items = {
                {
                    id = 'cancel_ambulance',
                    title = 'Cancel Ambulance',
                    icon = 'ambulance',
                    type = 'client',
                    event = 'call:cancelambulance',
                },
                {
                    id = 'cancel_fire',
                    title = 'Cancel Fire Unit',
                    icon = 'truck',
                    type = 'client',
                    event = 'call:cancelfire',
                },
                {
                    id = 'cancel_police',
                    title = 'Cancel Police',
                    icon = 'shield-alt',
                    type = 'client',
                    event = 'call:cancelpolice',
                },
                {
                    id = 'cancel_coroner',
                    title = 'Cancel Coroner',
                    icon = 'skull-crossbones',
                    type = 'client',
                    event = 'call:cancelcoroner',
                },
                {
                    id = 'cancel_taxi',
                    title = 'Cancel Taxi',
                    icon = 'taxi',
                    type = 'client',
                    event = 'call:canceltaxi',
                },
                {
                    id = 'cancel_tow',
                    title = 'Cancel Tow',
                    icon = 'truck',
                    type = 'client',
                    event = 'call:canceltow',
                },
                {
                    id = 'cancel_mechanic',
                    title = 'Cancel Mechanic',
                    icon = 'wrench',
                    type = 'client',
                    event = 'call:cancelmechanic',
                },
                {
                    id = 'cancel_animal_rescue',
                    title = 'Cancel Animal Rescue',
                    icon = 'paw',
                    type = 'client',
                    event = 'call:cancelanimalrescue',
                },
                {
                    id = 'cancel_roadservice',
                    title = 'Cancel Road Service',
                    icon = 'truck',
                    type = 'client',
                    event = 'call:cancelroadservice',
                },
            },
        },

        -- ERS Services Section
        {
            id = 'ersservices',
            title = 'ERS Services',
            icon = 'clipboard-list',
            items = {
                {
                    id = 'request_ambulance',
                    title = 'Ambulance',
                    icon = 'ambulance',
                    type = 'client',
                    event = 'call:ambulance',
                },
                {
                    id = 'request_police',
                    title = 'PD Transport',
                    icon = 'shield-alt',
                    type = 'client',
                    event = 'call:police',
                },
                {
                    id = 'request_tow',
                    title = 'Tow',
                    icon = 'truck',
                    type = 'client',
                    event = 'call:tow',
                },
                {
                    id = 'request_fire',
                    title = 'Fire Unit',
                    icon = 'truck',
                    type = 'client',
                    event = 'custom:requestfire',
                },
                {
                    id = 'request_coroner',
                    title = 'Coroner',
                    icon = 'skull-crossbones',
                    type = 'client',
                    event = 'call:coroner',
                },
                {
                    id = 'request_mechanic',
                    title = 'Mechanic',
                    icon = 'wrench',
                    type = 'client',
                    event = 'call:mechanic',
                },
                {
                    id = 'request_roadservice',
                    title = 'Road Service',
                    icon = 'truck',
                    type = 'client',
                    event = 'call:roadservice',
                },
                {
                    id = 'request_taxi',
                    title = 'Taxi',
                    icon = 'taxi',
                    type = 'client',
                    event = 'call:taxi',
                },
                {
                    id = 'request_animal_rescue',
                    title = 'Animal Rescue',
                    icon = 'paw',
                    type = 'client',
                    event = 'call:animalrescue',
                },
            },
        },

        -- Optional State Dispatch (ps-dispatch)
        {
            id = 'dispatch',
            title = 'State Dispatch',
            icon = 'list-check',
            items = {
                {
                    id = 'trafficStop',
                    title = '10-11',
                    icon = 'car-side',
                    type = 'client',
                    event = 'ps-dispatch:client:trafficstop',
                },
                {
                    id = 'emergencyButton',
                    title = '10-99',
                    icon = 'bell',
                    type = 'client',
                    event = 'ps-dispatch:client:officerbackup',
                },
                {
                    id = 'fireCall',
                    title = 'FIRE',
                    icon = 'bell',
                    type = 'client',
                    event = 'ps-dispatch:client:firecall',
                },
                {
                    id = 'enroute',
                    title = '10-97',
                    icon = 'bell',
                    type = 'client',
                    event = 'ps-dispatch:client:enroute',
                },
                {
                    id = 'onscene',
                    title = '10-23',
                    icon = 'bell',
                    type = 'client',
                    event = 'ps-dispatch:client:onscene',
                },
                {
                    id = 'codefour',
                    title = 'Code-4',
                    icon = 'bell',
                    type = 'client',
                    event = 'ps-dispatch:client:codefour',
                },
            },
        },
    }
})
