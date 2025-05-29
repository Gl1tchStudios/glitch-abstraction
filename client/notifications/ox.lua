-- ox_lib notification module for GlitchAbst

-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ox notifications module^7")
    return false
end

GlitchAbst.Notifications = GlitchAbst.Notifications or {}
GlitchAbst.Notifications.Ox = GlitchAbst.Notifications.Ox or {}

if Config and Config.NotificationSystem and Config.NotificationSystem ~= 'ox' and Config.NotificationSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ox notifications module (using ' .. Config.NotificationSystem .. ')')
    return false
end

if GetResourceState('ox_lib') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Setup notification methods
GlitchAbst.Notifications.Ox.Show = function(params)
    if not params then return end
    
    params = type(params) == 'table' and params or {message = tostring(params)}
    
    -- Map all supported parameters from the lib.notify documentation
    exports['ox_lib']:notify({
        id = params.id,                                     -- Unique notification ID
        title = params.title,                               -- Notification title
        description = params.message or params.description, -- Support both description and message
        duration = params.duration or 3000,                 -- Duration in ms
        showDuration = params.showDuration,                 -- Whether to show countdown
        position = params.position or 'top-right',          -- Position on screen
        type = params.type or 'inform',                     -- Notification type
        style = params.style,                               -- Custom CSS styles
        icon = params.icon,                                 -- FA6 icon name
        iconColor = params.iconColor,                       -- Icon color
        iconAnimation = params.iconAnimation,               -- Icon animation
        alignIcon = params.alignIcon or 'center',           -- Icon alignment
        sound = params.sound                                -- Sound options
    })
    
    return params.id or 1
end

-- Main notification functions
GlitchAbst.Notifications.Show = function(params)
    return GlitchAbst.Notifications.Ox.Show(params)
end

GlitchAbst.Notifications.Ox.Success = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.Notifications.Ox.Show(options)
end

GlitchAbst.Notifications.Ox.Error = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.Notifications.Ox.Show(options)
end

GlitchAbst.Notifications.Ox.Info = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.Notifications.Ox.Show(options)
end

GlitchAbst.Notifications.Ox.Warning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.Notifications.Ox.Show(options)
end

-- Top-level convenience methods
GlitchAbst.Notifications.Success = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.Notifications.Show(options)
end

GlitchAbst.Notifications.Error = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.Notifications.Show(options)
end

GlitchAbst.Notifications.Info = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.Notifications.Show(options)
end

GlitchAbst.Notifications.Warning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.Notifications.Show(options)
end

-- Style-focused notifications
GlitchAbst.Notifications.Ox.Custom = function(params)
    return GlitchAbst.Notifications.Ox.Show(params)
end

-- Sound notification
GlitchAbst.Notifications.Ox.WithSound = function(params, soundBank, soundSet, soundName)
    params.sound = {
        bank = soundBank,
        set = soundSet,
        name = soundName
    }
    return GlitchAbst.Notifications.Ox.Show(params)
end

-- Animated icon notification
GlitchAbst.Notifications.Ox.WithAnimation = function(params, animation, iconAlign)
    params.iconAnimation = animation
    params.alignIcon = iconAlign or 'center'
    return GlitchAbst.Notifications.Ox.Show(params)
end

-- For backward compatibility
GlitchAbst.UI.Notify = function(params)
    return GlitchAbst.Notifications.Show(params)
end

GlitchAbst.Utils.DebugLog('ox_lib notifications module loaded')
return true