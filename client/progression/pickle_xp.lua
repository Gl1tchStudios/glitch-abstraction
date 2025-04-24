-- pickle_xp Client
GlitchLib.Utils.DebugLog('pickle_xp client module loaded')

-- Get current XP
GlitchLib.Progression.GetXP = function(name)
    if not name then
        return exports.pickle_xp:GetXP()
    end
    return exports.pickle_xp:GetXP(name)
end

-- Get current level
GlitchLib.Progression.GetLevel = function(name)
    if name then
        return exports.pickle_xp:GetLevel(name)
    else
        return exports.pickle_xp:GetLevel()
    end
end

-- Draw XP bar
GlitchLib.Progression.DrawXPBar = function(show)
    if show then
        exports.pickle_xp:DrawXPBar()
    else
        exports.pickle_xp:HideXPBar()
    end
end

-- Get rank data (ranks, current rank, next rank)
GlitchLib.Progression.GetRankData = function()
    return exports.pickle_xp:GetRankData()
end

-- Get user data (level, xp, rankLevel)
GlitchLib.Progression.GetUserData = function()
    return exports.pickle_xp:GetUserData()
end

-- Check if player has a specific rank
GlitchLib.Progression.HasRank = function(rank)
    if not rank then return false end
    return exports.pickle_xp:HasRank(rank)
end

-- Toggle rank visibility
GlitchLib.Progression.ShowRank = function(state)
    if state then
        exports.pickle_xp:ShowRank()
    else
        exports.pickle_xp:HideRank()
    end
end

-- Get XP data for all categories
GlitchLib.Progression.GetXPData = function()
    return exports.pickle_xp:GetXPData()
end

-- Get required XP for a specific level in a category (shared function)
GlitchLib.Progression.GetLevelXP = function(name, level)
    if not name or not level then return 0 end
    return exports.pickle_xp:GetLevelXP(name, level)
end

-- Get current level of a category (shared function)
GlitchLib.Progression.GetCategoryLevel = function(name)
    if not name then return 0 end
    return exports.pickle_xp:GetCategoryLevel(name)
end