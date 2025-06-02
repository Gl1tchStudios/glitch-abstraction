-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading pickle_xp progression module^7")
    return false
end

-- Initialize progression namespace
GlitchAbst.Progression = GlitchAbst.Progression or {}

-- Skip if XP system doesn't match
if Config and Config.xpSystem and Config.xpSystem ~= 'pickle_xp' then
    GlitchAbst.Utils.DebugLog('Skipping pickle_xp module (using ' .. Config.xpSystem .. ' instead)')
    return false
end

-- Check if resource is actually available
if GetResourceState('pickle_xp') ~= 'started' then
    GlitchAbst.Utils.DebugLog('pickle_xp resource is not available')
    return false
end

GlitchAbst.Utils.DebugLog('pickle_xp progression module loaded')

-- pickle_xp Client
GlitchAbst.Utils.DebugLog('pickle_xp client module loaded')

-- Get XP data for all categories
GlitchAbst.Progression.GetXPData = function()
    return exports.pickle_xp:GetXPData()
end

-- Get current XP
GlitchAbst.Progression.GetXP = function(name)
    if not name then
        return exports.pickle_xp:GetXP()
    end
    return exports.pickle_xp:GetXP(name)
end

-- Get current level
GlitchAbst.Progression.GetLevel = function(name)
    if name then
        return exports.pickle_xp:GetLevel(name)
    else
        return exports.pickle_xp:GetLevel()
    end
end

-- Get required XP for a specific level in a category (shared function)
GlitchAbst.Progression.GetLevelXP = function(name, level)
    if not name or not level then return 0 end
    return exports.pickle_xp:GetLevelXP(name, level)
end

-- Get current level of a category (shared function)
GlitchAbst.Progression.GetCategoryLevel = function(name)
    if not name then return 0 end
    return exports.pickle_xp:GetCategoryLevel(name)
end
