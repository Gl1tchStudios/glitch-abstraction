fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'glitch-abstraction'
author 'Glitch Studios'
description 'Framework, inventory, target, UI, door lock, notification and XP abstraction layer for ESX, QBCore and Qbox servers'
version '1.2.1'

-- Required: ox_lib.
-- Detected at run time, nothing else is needed: qbx_core / qb-core / es_extended, ox_inventory / qb-inventory,
-- ox_target / qb-target / bt-target, ox_doorlock / qb-doorlock / esx_doorlock, glitch-notifications,
-- glitch-xpSystem / pickle_xp.
-- Optional cutscene tools (Config.Cutscenes): oxmysql, glitch-mapHandler, glitch-appearance, glitch-photos,
-- glitch-admin, glitch-cloudsLoading. See README.md.
dependency 'ox_lib'

-- The loading order is critical, do not change it. Add new shared files here by name (no glob:
-- FiveM does not skip files listed twice, so a glob would run config-core.lua again and wipe GlitchAbst).
shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',        -- plain values, edit freely
    'shared/config-core.lua',   -- creates the GlitchAbst table
    'shared/utils.lua',         -- helpers and framework / UI detection
    'shared/cutscene-catalog.lua',
}

-- Only the cores run as scripts. Each core picks the right module for this server
-- (framework, inventory, target, UI ...) and loads it once with LoadResourceFile.
-- Do not glob the module folders here: every module would run (several times),
-- in alphabetical order, and the last one loaded would win.
client_script 'client/client-core.lua'

server_scripts {
    'server/guard.lua', -- event counter for glitch-poolcleaning, does nothing when that resource is not installed
    'server/server-core.lua',
}

-- /cutsceneadmin cutscene browser (client/cutscene/admin.lua)
ui_page 'html/cutscene/index.html'

-- Client modules have to be shipped to the client for LoadResourceFile to read them
files {
    'client/**/*.lua',
    'html/cutscene/index.html',
    'html/cutscene/app.js',
    'html/cutscene/style.css',
}

-- Modules are read with LoadResourceFile, which cannot read escrowed files, so the whole resource stays open.
escrow_ignore {
    'shared/**/*.lua',
    'client/**/*.lua',
    'server/**/*.lua',
    'html/**',
}

exports {
    'getAbstraction',
}
