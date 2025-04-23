fx_version 'cerulean'
author 'Glitch Studios'
game 'gta5'

shared_scripts {
    'shared/*.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

dependency {
    'ox_lib',
    'ox_target',
}

lua54 'yes'