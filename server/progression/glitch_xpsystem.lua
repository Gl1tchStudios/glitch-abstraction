-- glitch_xpSystem Server
GlitchAbst.Progression = GlitchAbst.Progression or {}
GlitchAbst.Utils.DebugLog('glitch_xpSystem server module loaded')

-- The XP resource has shipped as both glitch-xpSystem and glitch_xpSystem.
-- Exports only resolve under the real resource name, so pick whichever is started.
-- Looked up on every call: the XP resource starts after this library in server.cfg.
local function XPResource()
    if GetResourceState('glitch-xpSystem') == 'started' then return 'glitch-xpSystem' end
    if GetResourceState('glitch_xpSystem') == 'started' then return 'glitch_xpSystem' end
end

-- Call an XP export safely. Returns ok, results...
local function Call(name, ...)
    local res = XPResource()
    if not res then
        GlitchAbst.Utils.DebugLog('glitch_xpSystem is not running (' .. name .. ')')
        return false
    end
    local e = exports[res]
    return pcall(e[name], e, ...)
end

GlitchAbst.Progression.IsAvailable = function()
    return XPResource() ~= nil
end

GlitchAbst.Progression.GetXPData = function(source, name)
    if not source or not name then return 0, 0 end
    -- GetPlayerXPData returns a table keyed by category name:
    -- { ["electrical"] = { label, xp, level, level_xp }, ... }
    -- so we index by name, not .level/.xp directly.
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
    -- GetPlayerLevel returns a plain number, not a table.
    -- Guard defensively in case the return type ever changes.
    if type(data) == 'number' then return data end
    return (type(data) == 'table' and data.level) or 0
end

-- Initialize XP for a player
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
