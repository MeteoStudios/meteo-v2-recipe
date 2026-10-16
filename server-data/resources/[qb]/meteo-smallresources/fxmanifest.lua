fx_version 'cerulean'
game 'gta5'
author 'QBCore Framework, modified by Meteo'
repository 'https://github.com/qbcore-fivem/qb-smallresources'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
description 'modified and optimized for meteo server v2'
version '1.4.0'

provide 'qb-smallresources'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/rename.lua',
    'config.lua'
}

escrow_ignore {
    'shared/rename.lua',
}
server_script 'server/*.lua'
client_scripts {
    'client/*.lua'
}

data_file 'FIVEM_LOVES_YOU_4B38E96CC036038F' 'events.meta'
data_file 'FIVEM_LOVES_YOU_341B23A2F0E0F131' 'popgroups.ymt' -- new modern vehicles on road
data_file 'POPSCHED_FILE' 'popcycle.dat' -- for prompt sandy maps

files {
    'locales/*.json',
    'events.meta',
    'popgroups.ymt',
    'popcycle.dat',
    'relationships.dat'
}
