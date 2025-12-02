
        -- ██████╗ ██████╗ ███████╗███╗   ██╗██╗   ██╗██████╗ ███████╗██████╗ 
        -- ██╔══██╗██╔══██╗██╔════╝████╗  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗
        -- ██║  ██║██████╔╝███████╗██╔██╗ ██║ ╚████╔╝ ██║  ██║█████╗  ██████╔╝
        -- ██║  ██║██╔══██╗╚════██║██║╚██╗██║  ╚██╔╝  ██║  ██║██╔══╝  ██╔══██╗
        -- ██████╔╝██║  ██║███████║██║ ╚████║   ██║   ██████╔╝███████╗██║  ██║
        -- ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝


fx_version 'cerulean'  game 'gta5'
author 'DrSnyder'  name "ers_integration"  version '1.4'
description 'ERS Integration for QB-Core & QBOX using qbx-radialmenu/qb-radailmenu + ps-dispatch'
repository 'https://github.com/DrSnyder86/ERS-Integration'
license ''

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client/*.lua',
}

server_scripts {
    '@qb-core/shared/locale.lua',
    'server/*.lua',
}

dependencies {
    'qb-core',
    'ps-dispatch',
}

