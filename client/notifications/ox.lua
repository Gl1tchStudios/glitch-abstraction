-- ox_lib notification module for GlitchLib

-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ox notifications module^7")
    return false
end

-- Initialize notifications namespace
GlitchLib.Notifications = GlitchLib.Notifications or {}
GlitchLib.Notifications.Ox = GlitchLib.Notifications.Ox or {}

-- Skip if notification system doesn't match
if Config and Config.NotificationSystem and Config.NotificationSystem ~= 'ox' and Config.NotificationSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping ox notifications module (using ' .. Config.NotificationSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Setup notification methods
GlitchLib.Notifications.Ox.Show = function(params)
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
    
    -- Return a dummy ID for compatibility with other systems
    return params.id or 1
end

-- Main notification function (used when this is the chosen notification system)
GlitchLib.Notifications.Show = function(params)
    return GlitchLib.Notifications.Ox.Show(params)
end

GlitchLib.Notifications.Ox.Success = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.Notifications.Ox.Show(options)
end

GlitchLib.Notifications.Ox.Error = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.Notifications.Ox.Show(options)
end

GlitchLib.Notifications.Ox.Info = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.Notifications.Ox.Show(options)
end

GlitchLib.Notifications.Ox.Warning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.Notifications.Ox.Show(options)
end

-- Top-level convenience methods
GlitchLib.Notifications.Success = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.Notifications.Show(options)
end

GlitchLib.Notifications.Error = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.Notifications.Show(options)
end

GlitchLib.Notifications.Info = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.Notifications.Show(options)
end

GlitchLib.Notifications.Warning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.Notifications.Show(options)
end

-- Style-focused notifications
GlitchLib.Notifications.Ox.Custom = function(params)
    return GlitchLib.Notifications.Ox.Show(params)
end

-- Sound notification
GlitchLib.Notifications.Ox.WithSound = function(params, soundBank, soundSet, soundName)
    params.sound = {
        bank = soundBank,
        set = soundSet,
        name = soundName
    }
    return GlitchLib.Notifications.Ox.Show(params)
end

-- Animated icon notification
GlitchLib.Notifications.Ox.WithAnimation = function(params, animation, iconAlign)
    params.iconAnimation = animation
    params.alignIcon = iconAlign or 'center'
    return GlitchLib.Notifications.Ox.Show(params)
end

-- For backward compatibility
GlitchLib.UI.Notify = function(params)
    return GlitchLib.Notifications.Show(params)
end

GlitchLib.Utils.DebugLog('ox_lib notifications module loaded')
return true