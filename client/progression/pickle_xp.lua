-- pickle_xp Client
GlitchLib.Utils.DebugLog('pickle_xp client module loaded')

-- Get current XP
GlitchLib.Progression.GetXP = function()
    return exports.pickle_xp:GetXP()
end

-- Get current level
GlitchLib.Progression.GetLevel = function()
    return exports.pickle_xp:GetLevel()
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