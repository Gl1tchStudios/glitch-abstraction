-- pickle_xp Server
GlitchAbst.Progression = GlitchAbst.Progression or {}
GlitchAbst.Utils.DebugLog('pickle_xp server module loaded')

-- Looked up on every call: the XP resource may start after this library
local function Call(name, ...)
    if GetResourceState('pickle_xp') ~= 'started' then
        GlitchAbst.Utils.DebugLog('pickle_xp is not running (' .. name .. ')')
        return false
    end
    local e = exports.pickle_xp
    return pcall(e[name], e, ...)
end

GlitchAbst.Progression.IsAvailable = function()
    return GetResourceState('pickle_xp') == 'started'
end

GlitchAbst.Progression.GetXPData = function(source, name)
    if not source or not name then return 0, 0 end
    -- GetPlayerXPData returns a table keyed by category name:
    -- { ["electrical"] = { label, xp, level, level_xp }, ... }
    local ok, data = Call('GetPlayerXPData', source, name)
    if not ok or type(data) ~= 'table' then return 0, 0 end
    local cat = data[name]
    if not cat or type(cat) ~= 'table' then return 0, 0 end
    return cat.level or 0, cat.xp or 0
end

GlitchAbst.Progression.AddXP = function(source, name, amount)
    if not source or not name or not tonumber(amount) then return false end
    local ok, res = Call('AddPlayerXP', source, name, tonumber(amount))
    return ok and res ~= false
end

GlitchAbst.Progression.RemoveXP = function(source, name, xp)
    if not source or not name or not tonumber(xp) then return false end
    local ok, res = Call('RemovePlayerXP', source, name, tonumber(xp))
    return ok and res ~= false
end

GlitchAbst.Progression.SetXP = function(source, name, amount)
    if not source or not name or not tonumber(amount) then return false end
    local ok, res = Call('SetPlayerXP', source, name, tonumber(amount))
    return ok and res ~= false
end

GlitchAbst.Progression.GetLevel = function(source, name)
    if not source then return 0 end
    local ok, data = Call('GetPlayerLevel', source, name)
    if not ok then return 0 end
    if type(data) == 'number' then return data end
    return (type(data) == 'table' and data.level) or 0
end

GlitchAbst.Progression.InitializePlayerXP = function(source, cb)
    if not source then return false end
    local ok = Call('InitializePlayerXP', source, cb)
    return ok
end

GlitchAbst.Progression.RegisterXPCategory = function(name, label, xpStart, xpFactor, maxLevel)
    if not name or not label then return false end
    local ok = Call('RegisterXPCategory', name, label, (xpStart or 1000), (xpFactor or 0.5), (maxLevel or 10))
    return ok
end

return true
