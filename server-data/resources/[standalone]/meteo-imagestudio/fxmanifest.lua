fx_version 'cerulean'
game 'gta5'
lua54 'yes'
nui_callback_strict_mode 'true'

name 'meteo-imagestudio'
description 'In-game image studio: clean transparent images of vehicles, clothing and furnishing'
author 'Meteo Studios'
version '1.3.0'

ox_lib 'locale'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/rename.lua',
    'shared/config.lua',
    'shared/utils.lua',
    'shared/exports.lua',
}

client_scripts {
    'client/cl_studio.lua',
    'client/cl_camera.lua',
    'client/cl_capture.lua',
    'client/kinds/*.lua',
    'client/cl_main.lua',
}

server_scripts {
    'server/sv_main.lua',
    'server/sv_settings.lua',
    'server/sv_files.js',
}

ui_page 'web/build/index.html'

files {
    'locales/*.json',
    'web/build/index.html',
    'web/build/**/*',
    'images/**/*',
}
