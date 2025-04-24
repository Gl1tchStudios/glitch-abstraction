-- ox_lib server-side notification module for GlitchLib

-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ox server notifications module^7")
    return false
end

-- Initialize server notifications namespace
GlitchLib.ServerNotifications = GlitchLib.ServerNotifications or {}
GlitchLib.ServerNotifications.Ox = GlitchLib.ServerNotifications.Ox or {}

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_lib resource is not available on the server')
    return false
end

GlitchLib.Utils.DebugLog('ox_lib server notifications module loaded')

-- Send notification to specific player
GlitchLib.ServerNotifications.Ox.Show = function(playerId, params)
    if not playerId or not params then return end
    
    params = type(params) == 'table' and params or {message = tostring(params)}
    
    -- Send notification to the specified player
    TriggerClientEvent('ox_lib:notify', playerId, {
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
    
    return true
end

-- Broadcast notification to all players
GlitchLib.ServerNotifications.Ox.Broadcast = function(params)
    if not params then return end
    
    params = type(params) == 'table' and params or {message = tostring(params)}
    
    -- Send notification to all players
    TriggerClientEvent('ox_lib:notify', -1, {
        id = params.id,
        title = params.title,
        description = params.message or params.description,
        duration = params.duration or 3000,
        showDuration = params.showDuration,
        position = params.position or 'top-right',
        type = params.type or 'inform',
        style = params.style,
        icon = params.icon,
        iconColor = params.iconColor,
        iconAnimation = params.iconAnimation,
        alignIcon = params.alignIcon or 'center',
        sound = params.sound
    })
    
    return true
end

-- Main server notification function (used when this is the chosen notification system)
GlitchLib.ServerNotifications.Show = function(playerId, params)
    return GlitchLib.ServerNotifications.Ox.Show(playerId, params)
end

GlitchLib.ServerNotifications.Broadcast = function(params)
    return GlitchLib.ServerNotifications.Ox.Broadcast(params)
end

-- Success notification to specific player
GlitchLib.ServerNotifications.Ox.Success = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Show(playerId, options)
end

-- Error notification to specific player
GlitchLib.ServerNotifications.Ox.Error = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Show(playerId, options)
end

-- Info notification to specific player
GlitchLib.ServerNotifications.Ox.Info = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Show(playerId, options)
end

-- Warning notification to specific player
GlitchLib.ServerNotifications.Ox.Warning = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Show(playerId, options)
end

-- Broadcast success notification to all players
GlitchLib.ServerNotifications.Ox.BroadcastSuccess = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast error notification to all players
GlitchLib.ServerNotifications.Ox.BroadcastError = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast info notification to all players
GlitchLib.ServerNotifications.Ox.BroadcastInfo = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast warning notification to all players
GlitchLib.ServerNotifications.Ox.BroadcastWarning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.ServerNotifications.Ox.Broadcast(options)
end

-- Top-level convenience methods
GlitchLib.ServerNotifications.Success = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.ServerNotifications.Show(playerId, options)
end

GlitchLib.ServerNotifications.Error = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.ServerNotifications.Show(playerId, options)
end

GlitchLib.ServerNotifications.Info = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.ServerNotifications.Show(playerId, options)
end

GlitchLib.ServerNotifications.Warning = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.ServerNotifications.Show(playerId, options)
end

-- Broadcast convenience methods
GlitchLib.ServerNotifications.BroadcastSuccess = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchLib.ServerNotifications.Broadcast(options)
end

GlitchLib.ServerNotifications.BroadcastError = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchLib.ServerNotifications.Broadcast(options)
end

GlitchLib.ServerNotifications.BroadcastInfo = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchLib.ServerNotifications.Broadcast(options)
end

GlitchLib.ServerNotifications.BroadcastWarning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchLib.ServerNotifications.Broadcast(options)
end

-- Style-focused notifications
GlitchLib.ServerNotifications.Ox.Custom = function(playerId, params)
    return GlitchLib.ServerNotifications.Ox.Show(playerId, params)
end

-- Sound notification
GlitchLib.ServerNotifications.Ox.WithSound = function(playerId, params, soundBank, soundSet, soundName)
    params.sound = {
        bank = soundBank,
        set = soundSet,
        name = soundName
    }
    return GlitchLib.ServerNotifications.Ox.Show(playerId, params)
end

-- For backward compatibility
GlitchLib.ServerUI = GlitchLib.ServerUI or {}
GlitchLib.ServerUI.Notify = function(playerId, params)
    return GlitchLib.ServerNotifications.Show(playerId, params)
end

return true