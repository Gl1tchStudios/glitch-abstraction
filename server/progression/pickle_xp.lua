-- pickle_xp Server
GlitchAbst.Utils.DebugLog('pickle_xp server module loaded')

GlitchAbst.Progression.GetXPData = function(source, name)
    if not source or not name then return 0, 0 end
    -- GetPlayerXPData returns a table keyed by category name:
    -- { ["electrical"] = { label, xp, level, level_xp }, ... }
    -- so we index by name, not .level/.xp directly.
    local data = exports.pickle_xp:GetPlayerXPData(source, name)
    if not data or type(data) ~= 'table' then return 0, 0 end
    local cat = data[name]
    if not cat or type(cat) ~= 'table' then return 0, 0 end
    return cat.level or 0, cat.xp or 0
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
    -- GetPlayerLevel returns a plain number, not a table.
    -- Guard defensively in case the return type ever changes.
    if type(data) == 'number' then return data end
    return (data and data.level) or 0
end

-- Initialize XP for a player
GlitchAbst.Progression.InitializePlayerXP = function(source, cb)
    if not source then return false end
    exports.pickle_xp:InitializePlayerXP(source, cb)
    return true
end

GlitchAbst.Progression.RegisterXPCategory = function(name, label, xpStart, xpFactor, maxLevel)
    if not name or not label then return 0 end
    exports.pickle_xp:RegisterXPCategory(name, label, (xpStart or 1000), (xpFactor or 0.5), (maxLevel or 10))
end