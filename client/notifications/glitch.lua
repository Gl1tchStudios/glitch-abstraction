-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading Glitch notifications module^7")
    return false
end

-- Initialize notifications namespace
GlitchLib.Notifications = GlitchLib.Notifications or {}
GlitchLib.Notifications.Glitch = GlitchLib.Notifications.Glitch or {}

-- Initialize the available state
local glitchNotificationsAvailable = GetResourceState('glitch-notifications') == 'started'

if not glitchNotificationsAvailable then
    GlitchLib.Utils.DebugLog('glitch-notifications resource is not available')
    -- Don't return false, just mark as unavailable
else
    GlitchLib.Utils.DebugLog('Glitch notifications module loaded')
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

-- Basic notification in Glitch namespace
GlitchLib.Notifications.Glitch.Show = function(params)
    if not glitchNotificationsAvailable then 
        return GlitchLib.Notifications.Fallback('Show', params)
    end

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
GlitchLib.Notifications.Glitch.Success = function(title, message, duration)
    return GlitchLib.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

-- Error notification
GlitchLib.Notifications.Glitch.Error = function(title, message, duration)
    return GlitchLib.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

-- Info notification
GlitchLib.Notifications.Glitch.Info = function(title, message, duration)
    return GlitchLib.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

-- Warning notification
GlitchLib.Notifications.Glitch.Warning = function(title, message, duration)
    return GlitchLib.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Add box to an existing notification
GlitchLib.Notifications.Glitch.AddBox = function(notificationId, title, message, color)
    if not glitchNotificationsAvailable or not notificationId then return nil end
    
    return exports['glitch-notifications']:AddBoxToNotification(
        notificationId,
        title,
        message,
        color or '#FFFFFF',
        false
    )
end

-- Remove a specific box from a notification
GlitchLib.Notifications.Glitch.RemoveBox = function(notificationId, boxId)
    if not glitchNotificationsAvailable or not notificationId or not boxId then return false end
    
    exports['glitch-notifications']:RemoveBoxFromNotification(notificationId, boxId)
    return true
end

-- Remove an entire notification
GlitchLib.Notifications.Glitch.Remove = function(notificationId)
    if not glitchNotificationsAvailable or not notificationId then return false end
    
    exports['glitch-notifications']:RemoveNotification(notificationId)
    return true
end

-- Update content of a notification box
GlitchLib.Notifications.Glitch.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if not glitchNotificationsAvailable or not notificationId or not boxId then return false end
    
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
GlitchLib.Notifications.Glitch.Toggle = function(id, title, message, color)
    if not glitchNotificationsAvailable then return false end
    
    exports['glitch-notifications']:ToggleNotification(
        id,
        title,
        message,
        color or '#FFFFFF'
    )
    return true
end

-- Create fallback function to route to other notification systems
GlitchLib.Notifications.Fallback = function(method, params)
    -- First try ox_lib if available
    if GetResourceState('ox_lib') == 'started' then
        if method == 'Show' then
            exports['ox_lib']:notify({
                title = params.title,
                description = params.description or params.message,
                type = params.type or 'inform',
                duration = params.duration or 5000,
                position = params.position or 'top-right',
                icon = params.icon
            })
            return 1 -- Return dummy ID
        end
        -- Other methods can be added as needed
        return nil
    end
    
    -- Try ESX notifications if available
    if GlitchLib.FrameworkName == 'ESX' then
        if method == 'Show' then
            TriggerEvent('esx:showNotification', (params.title and (params.title .. ': ') or '') .. 
                (params.description or params.message or ''), params.type or 'info')
            return 1 -- Return dummy ID
        end
        return nil
    end
    
    -- Try QBCore notifications if available
    if GlitchLib.FrameworkName == 'QBCore' then
        if method == 'Show' then
            TriggerEvent('QBCore:Notify', params.description or params.message, params.type or 'primary', params.duration or 5000)
            return 1 -- Return dummy ID
        end
        return nil
    end
    
    -- Last resort - basic game notification
    if method == 'Show' then
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(params.description or params.message or '')
        EndTextCommandThefeedPostTicker(false, true)
        return 1 -- Return dummy ID
    end
    
    return nil
end

-- Create top-level functions that route to appropriate notification system
GlitchLib.Notifications.Show = function(params)
    -- If configured to use Glitch and it's available, use it
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.Show(params)
    end
    
    -- Otherwise use the fallback system
    return GlitchLib.Notifications.Fallback('Show', params)
end

GlitchLib.Notifications.Success = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

GlitchLib.Notifications.Error = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

GlitchLib.Notifications.Info = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

GlitchLib.Notifications.Warning = function(title, message, duration)
    return GlitchLib.Notifications.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Basic fallback functions for extended functionality
GlitchLib.Notifications.AddBox = function(notificationId, title, message, color)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.AddBox(notificationId, title, message, color)
    end
    -- Most systems don't have AddBox functionality, so fall back to showing a new notification
    return GlitchLib.Notifications.Show({title = title, description = message})
end

GlitchLib.Notifications.RemoveBox = function(notificationId, boxId)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.RemoveBox(notificationId, boxId)
    end
    return false
end

GlitchLib.Notifications.Remove = function(notificationId)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.Remove(notificationId)
    end
    return false
end

GlitchLib.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.Update(notificationId, boxId, newMessage, newTitle, newColor)
    end
    -- Most systems don't have Update functionality, so fall back to showing a new notification
    return GlitchLib.Notifications.Show({title = newTitle, description = newMessage})
end

GlitchLib.Notifications.Toggle = function(id, title, message, color)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchLib.Notifications.Glitch.Toggle(id, title, message, color)
    end
    -- Most systems don't have Toggle functionality, so fall back to showing a new notification
    return GlitchLib.Notifications.Show({title = title, description = message})
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    return GlitchLib.Notifications.Show(params)
end

-- Return availability status
return glitchNotificationsAvailable