-- glitch-abstraction configuration. Plain values only, safe to edit (listed in escrow_ignore).
Config = {}

Config.Debug = false                -- print [GlitchAbst] debug lines and the startup summary to the console
Config.EventGuard = true            -- net event counter for glitch-poolcleaning. Does nothing when that resource is missing, set false to never wrap events

Config.UseFramework = 'auto'        -- 'auto', 'ESX' or 'QBCore' (Qbox counts as QBCore)

-- Which module to use when more than one is running ('auto' = first running one in the lists below)
Config.UISystem = 'auto'            -- 'auto', 'ox', 'qb', 'esx'
Config.NotificationSystem = 'auto'  -- 'auto', 'glitch', 'ox', 'qb', 'esx'
Config.InventorySystem = 'auto'     -- 'auto', 'ox', 'qb', 'esx'
Config.TargetSystem = 'auto'        -- 'auto', 'ox', 'qb', 'esx' (esx = bt-target)
Config.DoorlockSystem = 'auto'      -- 'auto', 'ox', 'qb', 'esx'

Config.ProgressCircle = true        -- ox_lib: draw every progress bar as the circle

-- XP system: 'auto', 'glitch_xpSystem' or 'pickle_xp'.
-- 'auto' uses glitch-xpSystem when it is installed, then pickle_xp, otherwise XP calls do nothing.
Config.xpSystem = 'auto'

-- Detection order for 'auto'. First running resource wins.
Config.UI = {
    { name = 'ox', resourceName = 'ox_lib' },
    { name = 'qb', resourceName = 'qb-core' },
    { name = 'esx', resourceName = 'es_extended' },
}

Config.Inventory = {
    { name = 'ox', resourceName = 'ox_inventory' },
    { name = 'qb', resourceName = 'qb-inventory' },
    { name = 'esx', resourceName = 'es_extended' },
}

Config.Target = {
    { name = 'ox', resourceName = 'ox_target' },
    { name = 'qb', resourceName = 'qb-target' },
    { name = 'esx', resourceName = 'bt-target' },
}

Config.DoorLock = {
    { name = 'ox', resourceName = 'ox_doorlock' },
    { name = 'qb', resourceName = 'qb-doorlock' },
    { name = 'esx', resourceName = 'esx_doorlock' },
}

Config.Notifications = {
    { name = 'glitch', resourceName = 'glitch-notifications' },
    { name = 'ox', resourceName = 'ox_lib' },
    { name = 'qb', resourceName = 'qb-core' },
    { name = 'esx', resourceName = 'es_extended' },
}

-- Cutscenes played on a player, plus the /cutsceneadmin browser. This is an optional staff tool built for
-- Glitch Studios servers (it uses glitch-mapHandler, glitch-appearance, glitch-photos and glitch-admin when
-- they are running). The bridge itself does not need it.
Config.Cutscenes = {
    Enabled = 'auto',           -- true, false, or 'auto' (on only when glitch-mapHandler is installed)
    BucketBase = 6600,          -- must not overlap buckets used by other resources. Each player gets BucketBase + their server id while a cutscene plays
    StreamTimeoutMs = 8000,     -- longest wait for the map around the camera to load
    LoadTimeoutMs = 20000,      -- longest wait for the cutscene itself to load
    MaxMinutes = 6,             -- the bucket is given back after this even if the client never says it ended
    FillerSlots = 3,            -- filler characters for MP_2..MP_4 (online / DLC scenes)
    -- Tables read for saved looks of filler characters (needs oxmysql). Letters, numbers and underscores only.
    Database = {
        SkinsTable = 'playerskins', -- table with citizenid, model, skin and active columns
        PlayersTable = 'players',   -- qbx_core players table
    },
    Admin = {
        Enabled = true,
        Command = 'cutsceneadmin',
        Ace = 'admin',          -- who may open the browser. Changeable from the panel (gear) by EditAce holders.
        EditAce = 'founder',    -- who may change Ace from the panel (saved, beats the value above until cleared)
    },
    -- pinned at the top of the browser's Featured tab
    Featured = {
        'mp_intro_concat', 'mph_tut_int', 'mph_pri_int', 'mph_hum_int', 'mph_nar_int', 'mph_pac_int',
        'mph_fin_cel_apt', 'hs4_cas_int', 'hs4_lsa_take_vel', 'hs3_arc_int',
    },
}
