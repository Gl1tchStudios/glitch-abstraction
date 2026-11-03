fx_version 'cerulean'
game 'gta5'

author 'Glitch Studios'
description 'A comprehensive abstraction layer for FiveM that seamlessly integrates multiple frameworks, inventory systems, UIs, targeting systems, and more under one unified API.'
version '1.1.0'

lua54 'yes'

-- IMPORTANT: The loading order is critical here so we HIGHLY recommend you do not change it.
shared_scripts {
    'shared/config-core.lua',  -- This MUST be first to establish globals
    'shared/utils.lua',        -- Utilities used by other modules
    'shared/config-main.lua',  -- Configuration after core initialization
    'shared/cutscene-catalog.lua' -- Cutscene catalog (Cutscene.GetInfo / GetCatalog)
    -- No shared/*.lua glob: FiveM does not skip files listed twice, so a glob ran
    -- config-core.lua again and wiped GlitchAbst. Add new shared files here by name.
}

-- Only the cores run as scripts. Each core picks the right module for this server
-- (framework, inventory, target, UI ...) and loads it once with LoadResourceFile.
-- Do not glob the module folders here: every module would run (several times),
-- in alphabetical order, and the last one loaded would win.
client_script 'client/client-core.lua'

server_script 'server/server-core.lua'

-- Client modules have to be shipped to the client for LoadResourceFile to read them
files {
    'client/**/*.lua'
}

exports {
    'getAbstraction'
}
