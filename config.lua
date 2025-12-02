-- ███████╗██████╗ ███████╗        ██╗███╗   ██╗████████╗███████╗ ██████╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
-- ██╔════╝██╔══██╗██╔════╝        ██║████╗  ██║╚══██╔══╝██╔════╝██╔════╝ ██╔══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
-- █████╗  ██████╔╝███████╗        ██║██╔██╗ ██║   ██║   █████╗  ██║  ███╗██████╔╝███████║   ██║   ██║██║   ██║██╔██╗ ██║
-- ██╔══╝  ██╔══██╗╚════██║        ██║██║╚██╗██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
-- ███████╗██║  ██║███████║███████╗██║██║ ╚████║   ██║   ███████╗╚██████╔╝██║  ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
-- ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝

-- ===============================================================================================================
-- CONFIGURATION FILE FOR ERS_INTEGRATION
-- ===============================================================================================================
-- This config defines the locations for duty toggles for Police, Ambulance, Fire, and Tow jobs. It also
-- includes global wait times for dispatch events such as callouts, pullovers, pursuits, and request events.
-- Adjust the vector3 coordinates to match your server's station duty locations, and modify wait times as needed.
-- ===============================================================================================================

Config = {}

-- Wraith radar auto-lock   = true/false
Config.EnableRadarLock      = true 

-- Ps-dispatch Notifications        = true/false
Config.EnableCalloutOffer           = true  -- Callout offer
Config.EnableCalloutAccept          = true  -- Callout accept
Config.EnableCalloutArrive          = true  -- Callout arrival
Config.EnableCalloutComplete        = true  -- Callout complete 
Config.EnablePulloverNotify         = true  -- Pullover start
Config.EnablePulloverCode4          = true  -- Pullover Code-4
Config.EnablePursuitNotify          = true  -- Pursuit started
Config.EnableServiceRequest         = true  -- Service request arrival

-- Display Info In Chat
Config.Show911CallInChat        = true  -- Show 911 call 
Config.ShowCalloutInChat        = true  -- Show callout info 
Config.ShowLicenseInChat        = true  -- Show license check (on ped interaction)
Config.ShowPlateInChat          = true  -- Show plate check (on pullover)

-- This determines which jobs (qb jobs not ERS) will receive dispatch notifications
-- Ps-dispatch uses job types for certain jobs. `LEO` for police, bcso and sasp. `EMS` for ambulance.
-- If you are not receiving notifications, check your qb-core shared jobs file. If there is no `type` defined, add your job name here.
Config.Dispatch = {
    CallOffer       = { 'fire', 'tow', 'leo', 'ems' },
    CallAccept      = { 'fire', 'tow', 'leo', 'ems' },
    CallArrive      = { 'fire', 'tow', 'leo', 'ems' },
    TrafficStop     = { 'leo' },
    ServiceRequest  = { 'fire', 'tow', 'leo', 'ems' },
    CallComplete    = { 'fire', 'tow', 'leo', 'ems' },
}

-- Player Reward For Completed Callout ($$$$)(Triggers when a callout is automatically completed. Pursuits, scene clean-ups)
Config.EnableBonusPay    = true
Config.BonusPayAmount    = 5000 -- Bank deposited money

-- Ps-dispatch Wait Times (in milliseconds - 10000 = 10 Seconds)(Time in between ERS dispatch events and ps-dispatch)(Simulates reaction and response times)
-- Set to 0 (ZERO) for no delay
Config.WaitTimes = {
    CalloutOffer         = 1000, -- How long after ERS dispatch notify does Ps-dispatch notify
    CalloutAccepted      = 5000, -- How long after callout accept does dispatch notify
    CalloutArrived       = 10000, -- How long after you arrived at the callout should you notify dispatch
    CalloutCompleted     = 6000,  -- How long after the callout is completed should you notify dispatch
    PulloverNotify       = 10000, -- How long after you initiate a traffic stop should you notify dispatch
    PulloverEnd          = 8000,  -- How long after you completed a traffic stop should you notify dispatch
    PursuitStart         = 5000,  -- How long after you initiate a pursuit should you notify dispatch
    RequestEvents        = 10000, -- How long after you request a service should dispatch notify you of their arrival
}

-- Ox_target and Qb-target duty locations
Config.DutyPoints = {
    police = {
        vec3(441.18, -981.97, 30.69),   --MRPD
        vec3(1854.03, 3687.2, 34.22),   --SANDY
		vec3(-447.3, 6013.3, 31.72),
    },
    ambulance = {
        vec3(441.18, -981.97, 30.69),   --MRPD
        vec3(311.18, -599.25, 43.29),
        vec3(-254.88, 6324.5, 32.58),
    },
    fire = {
        vec3(441.18, -981.97, 30.69),   --MRPD
        vec3(311.18, -599.25, 43.29),
        vec3(-254.88, 6324.5, 32.58),
    },
    tow = {
        vec3(441.18, -981.97, 30.69),   --MRPD
        vec3(471.39, -1311.03, 29.21),
        vec3(210.0, -1410.0, 30.5),
    }
}

-- Target menu
Config.DutyConfig = {
    police = { icon = "fa-solid fa-car-on", label = "ERS Police Duty", event = "ers:server:TogglePoliceShift" },
    ambulance = { icon = "fa-solid fa-truck-medical", label = "ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
    fire = { icon = "fa-solid fa-fire", label = "ERS Fire Duty", event = "ers:server:ToggleFireShift" },
    tow = { icon = "fa-solid fa-car-burst", label = "ERS Tow Duty", event = "ers:server:ToggleTowShift" },
}



