-- add to ps-dispatch/shared/config.lua
-- anywhere in the table
-- Config.Blips = {

    --ERS ADDON 
    ['codefour'] = {
        radius = 20,
        sprite = 133,
        color = 3,
        scale = 0.5,
        length = 1.0,
        sound = 'robberysound',
        offset = false,
        flash = false
    },
    ['onscene'] = {
        radius = 50,
        sprite = 161,
        color = 5,
        scale = 1.0,
        length = 3,
        sound = 'robberysound',
        offset = false,
        flash = false
    },
    ['enroute'] = {
        radius = 10,
        sprite = 126,
        color = 3,
        scale = 0.5,
        length = 0.1,
        sound = 'robberysound',
        offset = false,
        flash = false
    },
    ['trafficstop'] = {
        radius = 25.0,
        sprite = 42,
        color = 1,
        scale = 0.5,
        length = 1,
        sound = 'robberysound',
        offset = false,
        flash = false
    },
	['firecall'] = {
        radius = 25.0,
        sprite = 833,
        color = 1,
        scale = 0.5,
        length = 2,
        sound = 'ringing',
        offset = false,
        flash = true
    },
    ['dispatch'] = {
        radius = 10,
        sprite = 419,
        color = 1,
        scale = 0.5,
        length = 0.1,
        sound = 'Lose_1st',
        sound2 = 'GTAO_FM_Events_Soundset',
        offset = false,
        flash = false
    },
--ERS ADDON END