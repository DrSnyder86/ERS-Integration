-- ===============================================================================================================
-- This config defines the locations for duty toggles for Police, Ambulance, Fire, and Tow jobs. 
-- Adjust the vector3 coordinates to match your server's station duty locations.
-- ===============================================================================================================

Config = Config or {}

-- Ox_target and Qb-target duty locations
Config.DutyPoints = {
    police = {
        vec3(441.689606,-982.033081,30.836691),   -- Mission Row
        vec3(1853.898926,3687.701660,34.368851),   -- Sandy Sheriff
		vec3(-447.184235,6012.980957,32.419365), -- Paleto Sheriff
		vec3(362.951691,-1590.943604,29.398693), -- Davis Sheriff
		vec3(484.157379, 2651.660156, 42.979469), -- Harmony BCSO
		vec3(1537.086304,795.364746,77.799271), -- SAHP LS Freeway
		vec3(1659.286987,4793.820312,42.326149), -- Grapeseed Sheriff
		vec3(2572.544678,5054.394043,44.642319), -- Blaine County SAHP
		vec3(831.680054,-1294.253906,26.875271), -- SAHP Popular St
		vec3(-1096.752930,-841.261475,19.343437), -- Vespucci PD
        vec3(-755.046448, -1521.858154, 4.946587), -- LSSD La Puerta Heliport
    },
    ambulance = {
        vec3(307.449036,-595.337158,43.123158), -- Pillbox Medical
        vec3(1833.285400,3676.097412,34.274117), -- Sandy Medical
        vec3(-251.889236,6334.766113,32.445705), -- Paleto Medical
    },
    fire = {
        vec3(197.595993, -1650.366699, 28.904411), -- Davis Fire
        vec3(-1681.793945, 53.475166, 64.089745), -- Richman Fire
        vec3(-1233.390259,-1396.312866,4.278352), -- Vespucci Fire
        vec3(1773.531128, 4604.865234, 37.632195), -- Grapeseed Fire
        vec3(-375.695068,6117.116211,31.429543), -- Paleto FD
    },
    tow = {
        vec3(471.466644, -1310.989868, 29.237516), -- Hayes Auto - Little Bighorn
        vec3(891.851440, 3604.529053, 33.305969), -- Sandy Customs
        vec3(1186.479614, 2637.883789, 38.232563), -- Harmony Repair
        vec3(100.728455, 6620.212402, 32.266003), -- Paleto Customs
    }
}

-- Target menu for duty toggles. If your menu is inoperable, switch to the qb-target config below. Check `F8` console for errors.
-- This is due to the fact that qb scripts do not like certain icons and vice-versa.
-- Ox-target 
Config.DutyConfig = {
    police = { icon = "fa-solid fa-car-on", label = "ERS Police Duty", event = "ers:server:TogglePoliceShift" },
    ambulance = { icon = "fa-solid fa-truck-medical", label = "ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
    fire = { icon = "fa-solid fa-fire", label = "ERS Fire Duty", event = "ers:server:ToggleFireShift" },
    tow = { icon = "fa-solid fa-car-burst", label = "ERS Tow Duty", event = "ers:server:ToggleTowShift" },
}
-- -- Qb-target
-- Config.DutyConfig = {
--     police = { icon = "user-shield", label = "ERS Police Duty", event = "ers:server:TogglePoliceShift" },
--     ambulance = { icon = "briefcase-medical", label = "ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
--     fire = { icon = "fire-extinguisher", label = "ERS Fire Duty", event = "ers:server:ToggleFireShift" },
--     tow = { icon = "truck", label = "ERS Tow Duty", event = "ers:server:ToggleTowShift" },
-- }
