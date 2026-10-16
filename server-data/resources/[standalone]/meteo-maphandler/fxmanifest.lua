fx_version 'cerulean'
game 'gta5'

name 'meteo-maphandler'
description 'Loads map IPLs, interior sets and animated props in place of map scripts'
author 'Meteo Studios'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/cl_movers.lua',
    'client/cl_main.lua',
}

server_scripts {
    'server/sv_main.lua',
    'server/sv_movers.lua',
}

files {
    'locales/*.json',
}

dependency 'ox_lib'

lua54 'yes'

escrow_ignore {
    'shared/config.lua',
}
