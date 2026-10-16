fx_version 'cerulean'
game 'gta5'
author 'Qbox Project, modified by Meteo'

description 'QBX_Vehicles'
repository 'https://github.com/Qbox-project/qbx_vehicles'
version '1.4.2'

shared_scripts {
    'shared/rename.lua',
}

escrow_ignore {
    'shared/rename.lua',
}

server_scripts {
    '@ox_lib/init.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}

server_only 'yes'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
provide 'qbx_vehicles'
