fx_version 'cerulean'
game 'gta5'

author 'Glitch Studios'
description 'A comprehensive abstraction layer for FiveM that seamlessly integrates multiple frameworks, inventory systems, UIs, targeting systems, and more under one unified API.'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'shared/config-main.lua',
    'shared/config-core.lua',
    'shared/*.lua'
}

client_scripts {
    'client/framework/*.lua',
    'client/*.lua',
    'client/**/*.lua'
}

server_scripts {
    'server/framework/*.lua',
    'server/*.lua',
    'server/**/*.lua'
}

exports {
    'GetLib'
}