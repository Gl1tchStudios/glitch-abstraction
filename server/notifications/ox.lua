-- ox_lib server-side notification module for GlitchAbst

-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ox server notifications module^7")
    return false
end

-- Initialize server notifications namespace
GlitchAbst.ServerNotifications = GlitchAbst.ServerNotifications or {}
GlitchAbst.ServerNotifications.Ox = GlitchAbst.ServerNotifications.Ox or {}

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_lib resource is not available on the server')
    return false
end

GlitchAbst.Utils.DebugLog('ox_lib server notifications module loaded')

-- Send notification to specific player
GlitchAbst.ServerNotifications.Ox.Show = function(playerId, params)
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
GlitchAbst.ServerNotifications.Ox.Broadcast = function(params)
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
GlitchAbst.ServerNotifications.Show = function(playerId, params)
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, params)
end

GlitchAbst.ServerNotifications.Broadcast = function(params)
    return GlitchAbst.ServerNotifications.Ox.Broadcast(params)
end

-- Success notification to specific player
GlitchAbst.ServerNotifications.Ox.Success = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, options)
end

-- Error notification to specific player
GlitchAbst.ServerNotifications.Ox.Error = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, options)
end

-- Info notification to specific player
GlitchAbst.ServerNotifications.Ox.Info = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, options)
end

-- Warning notification to specific player
GlitchAbst.ServerNotifications.Ox.Warning = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, options)
end

-- Broadcast success notification to all players
GlitchAbst.ServerNotifications.Ox.BroadcastSuccess = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast error notification to all players
GlitchAbst.ServerNotifications.Ox.BroadcastError = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast info notification to all players
GlitchAbst.ServerNotifications.Ox.BroadcastInfo = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Broadcast(options)
end

-- Broadcast warning notification to all players
GlitchAbst.ServerNotifications.Ox.BroadcastWarning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Ox.Broadcast(options)
end

-- Top-level convenience methods
GlitchAbst.ServerNotifications.Success = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Show(playerId, options)
end

GlitchAbst.ServerNotifications.Error = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Show(playerId, options)
end

GlitchAbst.ServerNotifications.Info = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Show(playerId, options)
end

GlitchAbst.ServerNotifications.Warning = function(playerId, title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Show(playerId, options)
end

-- Broadcast convenience methods
GlitchAbst.ServerNotifications.BroadcastSuccess = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'success'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Broadcast(options)
end

GlitchAbst.ServerNotifications.BroadcastError = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'error'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Broadcast(options)
end

GlitchAbst.ServerNotifications.BroadcastInfo = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'inform'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Broadcast(options)
end

GlitchAbst.ServerNotifications.BroadcastWarning = function(title, message, duration, options)
    options = options or {}
    options.title = title
    options.message = message
    options.type = 'warning'
    options.duration = duration
    return GlitchAbst.ServerNotifications.Broadcast(options)
end

-- Style-focused notifications
GlitchAbst.ServerNotifications.Ox.Custom = function(playerId, params)
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, params)
end

-- Sound notification
GlitchAbst.ServerNotifications.Ox.WithSound = function(playerId, params, soundBank, soundSet, soundName)
    params.sound = {
        bank = soundBank,
        set = soundSet,
        name = soundName
    }
    return GlitchAbst.ServerNotifications.Ox.Show(playerId, params)
end

-- For backward compatibility
GlitchAbst.ServerUI = GlitchAbst.ServerUI or {}
GlitchAbst.ServerUI.Notify = function(playerId, params)
    return GlitchAbst.ServerNotifications.Show(playerId, params)
end

return true