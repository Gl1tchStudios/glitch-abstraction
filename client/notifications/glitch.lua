-- Glitch Notifications Implementation
GlitchLib.Utils.DebugLog('Glitch notifications module loaded')

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    -- Convert our standard parameters to what Glitch Notifications expects
    exports['glitch-notifications']:SendNotification({
        title = params.title or '',
        message = params.description or params.message or '',
        type = params.type or 'info',
        duration = params.duration or 5000,
        position = params.position or 'top-right',
        icon = params.icon,
        style = params.style
    })
end

-- Success notification
GlitchLib.Notifications.Success = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

-- Error notification
GlitchLib.Notifications.Error = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

-- Info notification
GlitchLib.Notifications.Info = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

-- Warning notification
GlitchLib.Notifications.Warning = function(title, message, duration)
    GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    GlitchLib.Notifications.Show(params)
end