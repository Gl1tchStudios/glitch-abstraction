-- Glitch Notifications
GlitchLib.Utils.DebugLog('Glitch notifications module loaded')

if GetResourceState('glitch-notifications') ~= 'started' then
    GlitchLib.Utils.DebugLog('Glitch notification resource is not started')
    return false
end

if Config.NotificationSystem ~= 'auto' and Config.NotificationSystem ~= 'glitch' then
    GlitchLib.Utils.DebugLog('Skipping Glitch notifications (using ' .. Config.NotificationSystem .. ')')
    return false
end

-- Store notification IDs for reference
local activeNotifications = {}
local nextNotificationId = 1

-- Map notification types to colors
local typeToColor = {
    success = '#00a65a',  -- Green
    error = '#dd4b39',    -- Red
    warning = '#f39c12',  -- Orange/Yellow
    info = '#00c0ef',     -- Blue
    primary = '#3c8dbc'   -- Light Blue
}

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    local title = params.title or ''
    local message = params.description or params.message or ''
    local duration = params.duration or 5000
    local color = params.color or typeToColor[params.type or 'info'] or '#00c0ef'
    local noAnimation = params.noAnimation or false
    
    -- Use the correct export
    local notificationId = exports['glitch-notifications']:ShowNotification(
        title,
        message,
        duration,
        color,
        noAnimation
    )
    
    -- Store the notification id for potential future use
    activeNotifications[nextNotificationId] = notificationId
    nextNotificationId = nextNotificationId + 1
    
    return notificationId
end

-- Success notification
GlitchLib.Notifications.Success = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

-- Error notification
GlitchLib.Notifications.Error = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

-- Info notification
GlitchLib.Notifications.Info = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

-- Warning notification
GlitchLib.Notifications.Warning = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Add additional functions from the new exports

-- Add box to an existing notification
GlitchLib.Notifications.AddBox = function(notificationId, title, message, color)
    if not notificationId then return nil end
    
    return exports['glitch-notifications']:AddBoxToNotification(
        notificationId,
        title,
        message,
        color or '#FFFFFF',
        false
    )
end

-- Remove a specific box from a notification
GlitchLib.Notifications.RemoveBox = function(notificationId, boxId)
    if not notificationId or not boxId then return false end
    
    exports['glitch-notifications']:RemoveBoxFromNotification(notificationId, boxId)
    return true
end

-- Remove an entire notification
GlitchLib.Notifications.Remove = function(notificationId)
    if not notificationId then return false end
    
    exports['glitch-notifications']:RemoveNotification(notificationId)
    return true
end

-- Update content of a notification box
GlitchLib.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if not notificationId or not boxId then return false end
    
    exports['glitch-notifications']:UpdateBoxContent(
        notificationId,
        boxId,
        newMessage,
        newTitle,
        newColor
    )
    return true
end

-- Toggle a notification on or off
GlitchLib.Notifications.Toggle = function(id, title, message, color)
    exports['glitch-notifications']:ToggleNotification(
        id,
        title,
        message,
        color or '#FFFFFF'
    )
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    return GlitchLib.Notifications.Show(params)
end