-- ============================================================================================================
-- CONFIGURATION FILE FOR ERS_INTEGRATION
-- ============================================================================================================
-- This config defines the locations for duty toggles for Police, Ambulance, Fire, and Tow jobs. It also
-- includes global wait times for various ERS events such as callouts, pullovers, pursuits, and request events.
-- Adjust the vector3 coordinates to match your server's station locations, and modify wait times as needed.
-- Configure a bonus pay amount for completed callouts
-- ============================================================================================================

Config = {}
-- ox_target and qb-target duty locations
Config.DutyPoints = {
    police = {
        vec3(441.18, -981.97, 30.69),
        vec3(1854.03, 3687.2, 34.22), --SANDY
		vec3(-447.3, 6013.3, 31.72),
		vec3(362.72, -1590.5, 29.29),
		vec3(483.99, 2652.12, 43.17),
		vec3(1536.58, 795.69, 77.65),
		--vec3(-3149.23, 1135.89, 21.07),
		vec3(1659.65, 4793.77, 42.26),
		vec3(633.9, 6.78, 82.63),
		vec3(2573.07, 5055.07, 44.64),
		vec3(831.69, -1293.64, 26.72),
		vec3(-1097.17, -841.96, 19.32),
    },
    ambulance = {
        vec3(311.18, -599.25, 43.29),
        vec3(-254.88, 6324.5, 32.58),
    },
    fire = {
        vec3(311.18, -599.25, 43.29),
        vec3(-254.88, 6324.5, 32.58),
    },
    tow = {
        vector3(200.0, -1400.0, 30.5),
        vector3(210.0, -1410.0, 30.5),
        vector3(190.0, -1390.0, 30.5),
    }
}

-- true/false - wraith radar front plate auto lock on pullover
Config.EnableRadarLock = true 

-- Global Wait Times (in milliseconds)(Simulates reaction and response times)
Config.WaitTimes = {
    CalloutAccepted      = 10000, -- 10 seconds
    CalloutArrived       = 10000, -- How long after you arrived at the callout should you notify dispatch
    CalloutCompleted     = 6000,  -- How long after the callout is completed should you notify dispatch
    PulloverNotify       = 10000, -- How long after you initiate a traffic stop should you notify dispatch
    PulloverEnd          = 8000,  -- How long after you completed a traffic stop should you notify dispatch
    PursuitStart         = 8000,  -- How long after you initiate a pursuit should you notify dispatch
    RequestEvents        = 8000,  -- How long after you request a service should dispatch notify you of their arrival
}

-- Player Reward For Completed Callout ($$$$)
Config.BonusPay = 5000 -- Bank deposited money



