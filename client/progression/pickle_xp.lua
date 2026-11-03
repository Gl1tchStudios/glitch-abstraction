-- pickle_xp Client
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading pickle_xp progression module^7")
    return false
end

GlitchAbst.Progression = GlitchAbst.Progression or {}

-- Looked up on every call: the XP resource may start after this library
local function Call(name, ...)
    if GetResourceState('pickle_xp') ~= 'started' then return false end
    local e = exports.pickle_xp
    return pcall(e[name], e, ...)
end

GlitchAbst.Utils.DebugLog('pickle_xp client module loaded')

GlitchAbst.Progression.IsAvailable = function()
    return GetResourceState('pickle_xp') == 'started'
end

GlitchAbst.Progression.GetXPData = function()
    local ok, data = Call('GetXPData')
    return ok and data or {}
end

GlitchAbst.Progression.GetXP = function(name)
    local ok, xp
    if name then ok, xp = Call('GetXP', name) else ok, xp = Call('GetXP') end
    return ok and xp or 0
end

GlitchAbst.Progression.GetLevel = function(name)
    local ok, level
    if name then ok, level = Call('GetLevel', name) else ok, level = Call('GetLevel') end
    return ok and level or 0
end

GlitchAbst.Progression.GetLevelXP = function(name, level)
    if not name or not level then return 0 end
    local ok, xp = Call('GetLevelXP', name, level)
    return ok and xp or 0
end

GlitchAbst.Progression.GetCategoryLevel = function(name)
    if not name then return 0 end
    local ok, level = Call('GetCategoryLevel', name)
    return ok and level or 0
end

return true
