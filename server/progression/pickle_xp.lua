-- pickle_xp Server
GlitchLib.Utils.DebugLog('pickle_xp server module loaded')

-- Get player XP
GlitchLib.Progression.GetXP = function(source)
    if not source then return 0 end
    return exports.pickle_xp:GetXP(source)
end

-- Add XP to player
GlitchLib.Progression.AddXP = function(source, amount, reason)
    if not source or not amount then return false end
    exports.pickle_xp:AddXP(source, amount, reason)
    return true
end

-- Set XP for player
GlitchLib.Progression.SetXP = function(source, amount)
    if not source or not amount then return false end
    exports.pickle_xp:SetXP(source, amount)
    return true
end

-- Get player level
GlitchLib.Progression.GetLevel = function(source)
    if not source then return 0 end
    return exports.pickle_xp:GetLevel(source)
end

-- Set player level
GlitchLib.Progression.SetLevel = function(source, level)
    if not source or not level then return false end
    exports.pickle_xp:SetLevel(source, level)
    return true
end

-- Add levels to player
GlitchLib.Progression.AddLevels = function(source, amount)
    if not source or not amount then return false end
    exports.pickle_xp:AddLevels(source, amount)
    return true
end

-- Register XP source
GlitchLib.Progression.RegisterXPSource = function(name, min, max, notify)
    if not name or not min or not max then return false end
    exports.pickle_xp:RegisterXPSource(name, min, max, notify)
    return true
end

-- Award XP from registered source
GlitchLib.Progression.AwardXPFromSource = function(source, sourceName)
    if not source or not sourceName then return false end
    exports.pickle_xp:AwardXPFromSource(source, sourceName)
    return true
end

-- Get rank data (ranks, current rank, next rank)
GlitchLib.Progression.GetRankData = function(source)
    if not source then return nil end
    return exports.pickle_xp:GetRankData(source)
end

-- Get user data (level, xp, rankLevel)
GlitchLib.Progression.GetUserData = function(source)
    if not source then return nil end
    return exports.pickle_xp:GetUserData(source)
end

-- Check if a player has a specific rank
GlitchLib.Progression.HasRank = function(source, rank)
    if not source or not rank then return false end
    return exports.pickle_xp:HasRank(source, rank)
end