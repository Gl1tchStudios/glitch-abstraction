-- Core initialization file
_G.GlitchLib = {
    Framework = {},      -- Framework functions
    UI = {},             -- UI functions
    Target = {},         -- Target functions
    Inventory = {},      -- Inventory functions
    Progression = {},    -- Progression/XP functions
    DoorLock = {},       -- Door lock functions
    Cutscene = {},       -- Cutscene functions
    Scaleform = {},      -- Scaleform functions
    Notifications = {},  -- Notification functions
    
    -- Server-only components
    Database = {},       -- Database access
    
    Utils = {},          -- Utility functions
    
    IsReady = false      -- Whether the library is initialized
}

-- Initialize Config if not already done
if not _G.Config then
    _G.Config = {
        Debug = true,
        Framework = {
            {name = 'ESX', resourceName = 'es_extended'},
            {name = 'QBCore', resourceName = 'qb-core'}
        },
        Inventory = {
            {name = 'ox', resourceName = 'ox_inventory'},
            {name = 'qb', resourceName = 'qb-inventory'},
            {name = 'esx', resourceName = 'es_extended'},
        },
        Target = {
            {name = 'ox', resourceName = 'ox_target'},
            {name = 'qb', resourceName = 'qb-target'},
            {name = 'esx', resourceName = 'bt-target'},
        },
        DoorLock = {
            {name = 'ox', resourceName = 'ox_doorlock'},
            {name = 'qb', resourceName = 'qb-doorlock'},
            {name = 'esx', resourceName = 'esx_doorlock'},
        },
        Notifications = {
            {name = 'glitch', resourceName = 'glitch-notifications'},
            {name = 'ox', resourceName = 'ox_lib'},
            {name = 'qb', resourceName = 'qb-core'},
            {name = 'esx', resourceName = 'es_extended'},
        },
        UI = {
            {name = 'ox', resourceName = 'ox_lib'},
            {name = 'qb', resourceName = 'qb-core'},
            {name = 'esx', resourceName = 'es_extended'},
        },
        UseFramework = 'auto'
    }
end

-- Add debug utility function so it's available immediately
GlitchLib.Utils.DebugLog = function(message)
    if Config and Config.Debug then
        print('[GlitchLib] ' .. message)
    end
end