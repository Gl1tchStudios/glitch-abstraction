-- pickle_xp Server
GlitchAbst.Utils.DebugLog('pickle_xp server module loaded')

GlitchAbst.Progression.GetXPData = function(source, name)
    if not source or not name then return 0 end
    local data = exports.pickle_xp:GetPlayerXPData(source, name)
    return data.level, data.xp
end

GlitchAbst.Progression.AddXP = function(source, name, amount)
    if not source or not name or not amount then return false end
    exports.pickle_xp:AddPlayerXP(source, name, amount)
    return true
end

GlitchAbst.Progression.RemoveXP = function(source, name, xp)
    if not source or not name or not xp then return false end
    exports.pickle_xp:RemovePlayerXP(source, name, xp)
    return true
end

GlitchAbst.Progression.SetXP = function(source, name, amount)
    if not source or not name or not amount then return false end
    exports.pickle_xp:SetPlayerXP(source, name, amount)
    return true
end

GlitchAbst.Progression.GetLevel = function(source, name)
    if not source then return 0 end
    local data = exports.pickle_xp:GetPlayerLevel(source, name)
    return data.level
end

-- Initialize XP for a player
GlitchAbst.Progression.InitializePlayerXP = function(source, cb)
    if not source then return false end
    exports.pickle_xp:InitializePlayerXP(source, cb)
    return true
end

GlitchAbst.Progression.GetLevel = function(name, label, xpStart, xpFactor, maxLevel)
    if not name or not label then return 0 end
    exports.pickle_xp:RegisterXPCategory(name, label, (xpStart or 1000), (xpFactor or 0.5), (maxLevel or 10))
end