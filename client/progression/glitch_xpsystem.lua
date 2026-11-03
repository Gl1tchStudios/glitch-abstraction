-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading glitch_xpSystem progression module^7")
    return false
end

-- Initialize progression namespace
GlitchAbst.Progression = GlitchAbst.Progression or {}

-- Skip if XP system doesn't match
if Config and Config.xpSystem and Config.xpSystem ~= 'glitch_xpSystem' and Config.xpSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping glitch_xpSystem module (using ' .. Config.xpSystem .. ' instead)')
    return false
end

-- The XP resource has shipped as both glitch-xpSystem and glitch_xpSystem.
-- Exports only resolve under the real resource name, so pick whichever is started.
-- Looked up on every call: the XP resource starts after this library.
local function XPResource()
    if GetResourceState('glitch-xpSystem') == 'started' then return 'glitch-xpSystem' end
    if GetResourceState('glitch_xpSystem') == 'started' then return 'glitch_xpSystem' end
end

local function Call(name, ...)
    local res = XPResource()
    if not res then return false end
    local e = exports[res]
    return pcall(e[name], e, ...)
end

GlitchAbst.Utils.DebugLog('glitch_xpSystem client module loaded')

GlitchAbst.Progression.IsAvailable = function()
    return XPResource() ~= nil
end

-- Get XP data for all categories
GlitchAbst.Progression.GetXPData = function()
    local ok, data = Call('GetXPData')
    return ok and data or {}
end

-- Get current XP
GlitchAbst.Progression.GetXP = function(name)
    local ok, xp
    if name then ok, xp = Call('GetXP', name) else ok, xp = Call('GetXP') end
    return ok and xp or 0
end

-- Get current level
GlitchAbst.Progression.GetLevel = function(name)
    local ok, level
    if name then ok, level = Call('GetLevel', name) else ok, level = Call('GetLevel') end
    return ok and level or 0
end

-- Get required XP for a specific level in a category (shared function)
GlitchAbst.Progression.GetLevelXP = function(name, level)
    if not name or not level then return 0 end
    local ok, xp = Call('GetLevelXP', name, level)
    return ok and xp or 0
end

-- Get current level of a category (shared function)
GlitchAbst.Progression.GetCategoryLevel = function(name)
    if not name then return 0 end
    local ok, level = Call('GetCategoryLevel', name)
    return ok and level or 0
end

return true
