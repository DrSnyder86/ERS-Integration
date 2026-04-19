-- ===============================================================================================================
-- This config defines the locations for duty toggles for Police, Ambulance, Fire, and Tow jobs. 
-- Adjust the vector3 coordinates to match your server's station duty locations.
-- ===============================================================================================================

Config = Config or {}

-- Ox_target and Qb-target duty locations
Config.DutyPoints = {
    police = {
        vec3(441.18, -981.97, 30.69),   --MRPD
        vec3(1854.03, 3687.2, 34.22),   --SANDY
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
        vec3(190.0, -1390.0, 30.5),
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
-- Qb-target
-- Config.DutyConfig = {
--     police = { icon = "user-shield", label = "ERS Police Duty", event = "ers:server:TogglePoliceShift" },
--     ambulance = { icon = "briefcase-medical", label = "ERS Ambulance Duty", event = "ers:server:ToggleAmbulanceShift" },
--     fire = { icon = "fire-extinguisher", label = "ERS Fire Duty", event = "ers:server:ToggleFireShift" },
--     tow = { icon = "truck", label = "ERS Tow Duty", event = "ers:server:ToggleTowShift" },
-- }