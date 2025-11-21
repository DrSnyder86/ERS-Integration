fx_version 'cerulean'
game 'gta5'

author 'DrSnyder'
description 'ERS Integration for QB-Core & QBOX using qbx-radialmenu/qb-radailmenu + ps-dispatch'
version '1.3'

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client/*.lua'
}

server_scripts {
    '@qb-core/shared/locale.lua',
    'server/*.lua'
}

dependencies {
    'qb-core',
    'ps-dispatch',
}



