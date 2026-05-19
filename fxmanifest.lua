-- ███████╗██████╗ ███████╗        ██╗███╗   ██╗████████╗███████╗ ██████╗ ██████╗  █████╗ ████████╗██╗ ██████╗ ███╗   ██╗
-- ██╔════╝██╔══██╗██╔════╝        ██║████╗  ██║╚══██╔══╝██╔════╝██╔════╝ ██╔══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
-- █████╗  ██████╔╝███████╗        ██║██╔██╗ ██║   ██║   █████╗  ██║  ███╗██████╔╝███████║   ██║   ██║██║   ██║██╔██╗ ██║
-- ██╔══╝  ██╔══██╗╚════██║        ██║██║╚██╗██║   ██║   ██╔══╝  ██║   ██║██╔══██╗██╔══██║   ██║   ██║██║   ██║██║╚██╗██║
-- ███████╗██║  ██║███████║███████╗██║██║ ╚████║   ██║   ███████╗╚██████╔╝██║  ██║██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║
-- ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝
--        _   ____  
-- __   _/ | | ___| 
-- \ \ / / | |___ \ 
--  \ V /| |_ ___) |
--   \_/ |_(_)____/ 

fx_version 'cerulean'  game 'gta5'
author 'DrSnyder'  name "ers_integration"  version '1.6'
description 'ERS Integration for QB-Core & QBOX using qbx-radialmenu/qb-radailmenu + ps-dispatch'
repository 'https://github.com/DrSnyder86/ERS-Integration'
license ''

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

shared_scripts {
    'config/*.lua'
}

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
    'oxmysql',
}
