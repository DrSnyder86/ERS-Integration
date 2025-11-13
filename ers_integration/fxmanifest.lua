fx_version 'cerulean'
game 'gta5'

author 'DrSnyder'
description 'ERS Integration for Qb and Qbox using Ps-dispatch and Radial Menu'
version '1.0'


client_scripts {
    'client.lua',
    --'tablet.lua'
}

server_scripts {
    '@qb-core/shared/locale.lua', 
    --'@oxmysql/lib/MySQL.lua',      
    'server.lua'
}


dependencies {
    'qb-core',
    'ps-dispatch',
    -- 'ps-mdt',
    'ox_lib'
}
