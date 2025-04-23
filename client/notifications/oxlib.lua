-- ox_lib Notifications Implementation
GlitchLib.Utils.DebugLog('ox_lib notifications module loaded')

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    lib.notify({
        title = params.title,
        description = params.description or params.message,
        type = params.type or 'info',
        duration = params.duration or 5000,
        position = params.position or 'top-right',
        icon = params.icon
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