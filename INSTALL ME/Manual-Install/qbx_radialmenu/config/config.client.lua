--add these categories in your radial menu. qbx-radialmenu/config/client.lua
--==========================
-- ERS STUFF START
--==========================
         {
    id = "ers_x",
    icon = "file-alt",
    label = "ERS Menu",
    items = {
        {
            id = "ers_duty",
            icon = "user-shield",
            label = "ERS Duty",
            items = {
                { id = "toggle_police", icon = "user-shield", label = "Toggle Police Duty", onSelect = function()
                TriggerServerEvent('ers:server:TogglePoliceShift')
            end },
                { id = "toggle_ambulance", icon = "user-nurse", label = "Toggle Ambulance Duty", onSelect = function()
                TriggerServerEvent('ers:server:ToggleAmbulanceShift')
            end },
                { id = "toggle_fire", icon = "fire", label = "Toggle Fire Duty", onSelect = function()
                TriggerServerEvent('ers:server:ToggleFireShift')
            end },
                { id = "toggle_tow", icon = "truck-pickup", label = "Toggle Tow Duty", onSelect = function()
                TriggerServerEvent('ers:server:ToggleTowShift')
            end },
            }
        },
        {
            id = "ers_calls",
            icon = "user-lock",
            label = "ERS Utilities",
            items = {
                { id = "request_callout", icon = "bullhorn", label = "Request 911 Call", event = "ersi:callout:request" },
                { id = "extra_menu", icon = "gears", label = "Extra Menu", event = "ersi:extra:menu" },
                { id = "toggle_callouts", icon = "broadcast-tower", label = "Toggle 911 Dispatch", event = "ersi:callouts:toggle" },
                { id = "wraith", icon = "mobile", label = "Wraith Radar", event = "wk:openRemote" },
                { id = "mdt_toggle", icon = "tablet-alt", label = "MDT Tablet", event = "ersi:mdt:toggle" },
                { id = "speedzone", icon = "traffic-light", label = "Traffic Control", event = "ersi:speedzone" },
            }
        },
        {
            id = "ers_cancel",
            icon = 'users-slash',
            label = 'Cancel Requests',
            items = {
                { id = 'cancel_ambulance', icon = 'ambulance', label = 'Cancel Ambulance', event = 'ersi:call:cancelambulance' },
                { id = 'cancel_fire', icon = 'fire', label = 'Cancel Fire Rescue', event = 'ersi:call:cancelfire' },
                { id = 'cancel_police', icon = 'handcuffs', label = 'Cancel Police', event = 'ersi:call:cancelpolice' },
                { id = 'cancel_coroner', icon = 'skull-crossbones', label = 'Cancel Coroner', event = 'ersi:call:cancelcoroner' },
                { id = 'cancel_taxi', icon = 'taxi', label = 'Cancel Taxi', event = 'ersi:call:canceltaxi' },
                { id = 'cancel_tow', icon = 'truck-pickup', label = 'Cancel Tow', event = 'ersi:call:canceltow' },
                { id = 'cancel_mechanic', icon = 'tools', label = 'Cancel Mechanic', event = 'ersi:call:cancelmechanic' },
                { id = 'cancel_animal_rescue', icon = 'paw', label = 'Cancel Animal Rescue', event = 'ersi:call:cancelanimalrescue' },
                { id = 'cancel_roadservice', icon = 'broom', label = 'Cancel Road Service', event = 'ersi:call:cancelroadservice' },
            }
        },
        {
            id = "ers_request",
            icon = 'users-cog',
            label = 'ERS Services',
            items = {
                { id = 'request_ambulance', icon = 'ambulance', label = 'Ambulance', event = 'ersi:call:ambulance' },
                { id = 'request_police', icon = 'handcuffs', label = 'PD Transport', event = 'ersi:call:police' },
                { id = 'request_tow', icon = 'truck-pickup', label = 'Tow', event = 'ersi:call:tow' },
                { id = 'requestfire', icon = 'fire', label = 'Fire Rescue', event = 'ersi:call:requestfire' },
                { id = 'request_coroner', icon = 'skull-crossbones', label = 'Coroner', event = 'ersi:call:coroner' },
                { id = 'request_mechanic', icon = 'tools', label = 'Mechanic', event = 'ersi:call:mechanic' },
                { id = 'request_roadservice', icon = 'broom', label = 'Road Service', event = 'ersi:call:roadservice' },
                { id = 'request_taxi', icon = 'taxi', label = 'Taxi', event = 'ersi:call:taxi' },
                { id = 'request_animal_rescue', icon = 'paw', label = 'Animal Rescue', event = 'ersi:call:animalrescue' },
            }
        },
        {
            id = "ers_state",
            icon = 'wifi',
            label = 'State Dispatch',
            items = {
                { id = 'trafficStop', icon = 'car-side', label = '10-11', event = 'ps-dispatch:client:trafficstop' },
                { id = 'emergencyButton', icon = 'bell', label = '10-99', event = 'ps-dispatch:client:officerbackup' },
                { id = 'fireCall', icon = 'fire', label = 'FIRE', event = 'ps-dispatch:client:firecall' },
                { id = 'enroute', icon = 'car-alt', label = '10-97', event = 'ps-dispatch:client:enroute' },
                { id = 'onscene', icon = 'bell', label = '10-23', event = 'ps-dispatch:client:onscene' },
                { id = 'codefour', icon = 'bell', label = 'Code-4', event = 'ps-dispatch:client:codefour' },
            }
        },
    }
},
--==========================
-- ERS STUFF END
--==========================
            