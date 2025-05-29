fx_version 'cerulean'
game 'gta5'

author 'Glitch Studios'
description 'A comprehensive abstraction layer for FiveM that seamlessly integrates multiple frameworks, inventory systems, UIs, targeting systems, and more under one unified API.'
version '1.0.0'

lua54 'yes'

-- IMPORTANT: The loading order is critical here so we HIGHLY recommend you do not change it.
shared_scripts {
    'shared/config-core.lua',  -- This MUST be first to establish globals
    'shared/utils.lua',        -- Utilities used by other modules
    'shared/config-main.lua',  -- Configuration after core initialization
    'shared/*.lua'            -- Other shared scripts
}

client_scripts {
    'client/client-core.lua',
    'client/framework/*.lua',
    'client/**/*.lua'
}

server_scripts {
    'server/server-core.lua',
    'server/framework/*.lua',
    'server/**/*.lua'
}

exports {
    'getAbstraction'
}