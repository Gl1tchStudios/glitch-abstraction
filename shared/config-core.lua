-- Core initialisation: the shared GlitchAbst table. Loads after config.lua.
_G.GlitchAbst = _G.GlitchAbst or { -- keep the table if this file runs twice
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

GlitchAbst.Utils = GlitchAbst.Utils or {}

GlitchAbst.Utils.DebugLog = function(message)
    if Config and Config.Debug then
        print('[GlitchAbst] ' .. tostring(message))
    end
end
