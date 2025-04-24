-- ox_lib notification module for GlitchLib

if Config.NotificationSystem ~= 'auto' and Config.NotificationSystem ~= 'ox' then
    GlitchLib.Utils.DebugLog('Skipping ox notifications (using ' .. Config.NotificationSystem .. ' instead)')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Setup notification methods
GlitchLib.Notifications.Show = function(params)
    if not params then return end
    
    params = type(params) == 'table' and params or {message = tostring(params)}
    
    exports['ox_lib']:notify({
        title = params.title,
        description = params.message or params.description,
        type = params.type or 'inform',
        position = params.position or 'top-right',
        duration = params.duration or 3000,
        icon = params.icon,
    })
end

GlitchLib.Notifications.Success = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        message = message,
        type = 'success',
        duration = duration
    })
end

GlitchLib.Notifications.Error = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        message = message,
        type = 'error',
        duration = duration
    })
end

GlitchLib.Notifications.Info = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        message = message,
        type = 'inform',
        duration = duration
    })
end

GlitchLib.Notifications.Warning = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        message = message,
        type = 'warning',
        duration = duration
    })
end

-- For backward compatibility
GlitchLib.UI.Notify = function(params)
    GlitchLib.Notifications.Show(params)
end

GlitchLib.Utils.DebugLog("ox_lib notification module loaded")
return true