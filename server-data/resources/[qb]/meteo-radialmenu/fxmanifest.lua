fx_version 'cerulean'
game 'gta5'
author 'QBCore Framework, modified by Meteo'
repository 'https://github.com/qbcore-fivem/qb-radialmenu'

description 'Rewritten and fully optimized f1menu for the Meteo v2 Package'
version '1.2.0'

provide 'qb-radialmenu'

ox_lib 'locale'

ui_page 'web/index.html'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/rename.lua',
    'config.lua'
}

client_scripts {
    '@qbx_core/modules/playerdata.lua',
    'client/main.lua',
    -- 'client/clothing.lua',
    'client/stretcher.lua'
}

server_scripts {
    'server/stretcher.lua'
}

files {
    'locales/*.json',
    'web/index.html',
    'web/css/main.css',
    'web/js/main.js',
    'web/js/RadialMenu.js',
}

lua54 'yes'
