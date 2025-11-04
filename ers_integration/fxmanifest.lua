fx_version 'cerulean'
game 'gta5'

author 'DrSnyder'
description 'Qbox ERS Integration'
version '1.0'


client_scripts {
    'client.lua',
}

server_scripts {
    '@qb-core/shared/locale.lua',    
    'server.lua'
}


dependencies {
    'qb-core',
    'ps-dispatch',
    'ox_lib'
}


