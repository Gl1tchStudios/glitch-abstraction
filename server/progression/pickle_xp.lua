-- pickle_xp Server
GlitchAbst.Utils.DebugLog('pickle_xp server module loaded')

-- Get player XP
GlitchAbst.Progression.GetXP = function(source)
    if not source then return 0 end
    return exports.pickle_xp:GetXP(source)
end

-- Add XP to player
GlitchAbst.Progression.AddXP = function(source, amount, reason)
    if not source or not amount then return false end
    exports.pickle_xp:AddXP(source, amount, reason)
    return true
end

-- Set XP for player
GlitchAbst.Progression.SetXP = function(source, amount)
    if not source or not amount then return false end
    exports.pickle_xp:SetXP(source, amount)
    return true
end

-- Get player level
GlitchAbst.Progression.GetLevel = function(source)
    if not source then return 0 end
    return exports.pickle_xp:GetLevel(source)
end

-- Set player level
GlitchAbst.Progression.SetLevel = function(source, level)
    if not source or not level then return false end
    exports.pickle_xp:SetLevel(source, level)
    return true
end

-- Add levels to player
GlitchAbst.Progression.AddLevels = function(source, amount)
    if not source or not amount then return false end
    exports.pickle_xp:AddLevels(source, amount)
    return true
end

-- Register XP source
GlitchAbst.Progression.RegisterXPSource = function(name, min, max, notify)
    if not name or not min or not max then return false end
    exports.pickle_xp:RegisterXPSource(name, min, max, notify)
    return true
end

-- Award XP from registered source
GlitchAbst.Progression.AwardXPFromSource = function(source, sourceName)
    if not source or not sourceName then return false end
    exports.pickle_xp:AwardXPFromSource(source, sourceName)
    return true
end

-- Get rank data (ranks, current rank, next rank)
GlitchAbst.Progression.GetRankData = function(source)
    if not source then return nil end
    return exports.pickle_xp:GetRankData(source)
end

-- Get user data (level, xp, rankLevel)
GlitchAbst.Progression.GetUserData = function(source)
    if not source then return nil end
    return exports.pickle_xp:GetUserData(source)
end

-- Check if a player has a specific rank
GlitchAbst.Progression.HasRank = function(source, rank)
    if not source or not rank then return false end
    return exports.pickle_xp:HasRank(source, rank)
end

-- Add XP to a specific category for a player
GlitchAbst.Progression.AddPlayerXP = function(source, name, xp)
    if not source or not name or not xp then return false end
    exports.pickle_xp:AddPlayerXP(source, name, xp)
    return true
end

-- Remove XP from a specific category for a player
GlitchAbst.Progression.RemovePlayerXP = function(source, name, xp)
    if not source or not name or not xp then return false end
    exports.pickle_xp:RemovePlayerXP(source, name, xp)
    return true
end

-- Set XP for a specific category for a player
GlitchAbst.Progression.SetPlayerXP = function(source, name, xp)
    if not source or not name or not xp then return false end
    exports.pickle_xp:SetPlayerXP(source, name, xp)
    return true
end

-- Get XP data for a specific category for a player
GlitchAbst.Progression.GetPlayerXPData = function(source, name)
    if not source or not name then return nil end
    return exports.pickle_xp:GetPlayerXPData(source, name)
end

-- Get level for a specific category for a player
GlitchAbst.Progression.GetPlayerLevel = function(source, name)
    if not source or not name then return 0 end
    return exports.pickle_xp:GetPlayerLevel(source, name)
end

-- Initialize XP for a player
GlitchAbst.Progression.InitializePlayerXP = function(source, cb)
    if not source then return false end
    exports.pickle_xp:InitializePlayerXP(source, cb)
    return true
end

-- Register an XP category
GlitchAbst.Progression.RegisterXPCategory = function(name, label, xpStart, xpFactor, maxLevel)
    if not name or not label or not xpStart or not xpFactor then return false end
    exports.pickle_xp:RegisterXPCategory(name, label, xpStart, xpFactor, maxLevel)
    return true
end

-- Get required XP for a specific level in a category (shared function)
GlitchAbst.Progression.GetLevelXP = function(name, level)
    if not name or not level then return 0 end
    return exports.pickle_xp:GetLevelXP(name, level)
end

-- Get current level of a category (shared function)
GlitchAbst.Progression.GetCategoryLevel = function(name)
    if not source or not name then return 0 end
    return exports.pickle_xp:GetCategoryLevel(name)
end