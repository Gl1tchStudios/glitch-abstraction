GlitchLib = {
    Framework = {},    -- Framework functions
    UI = {},           -- UI functions
    Target = {},       -- Target functions
    Inventory = {},    -- Inventory functions
    Progression = {},  -- Progression/XP functions
    DoorLock = {},     -- Door lock functions
    
    -- Server-only components
    
    Database = {},     -- Database access
    
    Utils = {},        -- Utility functions
    
    IsReady = false,   -- Whether the library is initialized
    Debug = Config.Debug
}

function GlitchLib.Utils.DebugLog(message)
    if GlitchLib.Debug then
        print('[GlitchLib] ' .. tostring(message))
    end
end

_G.GlitchLib = GlitchLib