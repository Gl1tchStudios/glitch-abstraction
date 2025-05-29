-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading Glitch notifications module^7")
    return false
end

GlitchAbst.Notifications = GlitchAbst.Notifications or {}
GlitchAbst.Notifications.Glitch = GlitchAbst.Notifications.Glitch or {}

local glitchNotificationsAvailable = GetResourceState('glitch-notifications') == 'started'

if not glitchNotificationsAvailable then
    GlitchAbst.Utils.DebugLog('glitch-notifications resource is not available')
else
    GlitchAbst.Utils.DebugLog('Glitch notifications module loaded')
end

-- Store notification IDs for reference
local activeNotifications = {}
local nextNotificationId = 1

local typeToColor = {
    success = '#00a65a',  -- Green
    error = '#dd4b39',    -- Red
    warning = '#f39c12',  -- Orange/Yellow
    info = '#00c0ef',     -- Blue
    primary = '#3c8dbc'   -- Light Blue
}

GlitchAbst.Notifications.Glitch.Show = function(params)
    if not glitchNotificationsAvailable then 
        return GlitchAbst.Notifications.Fallback('Show', params)
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
GlitchAbst.Notifications.Glitch.Success = function(title, message, duration)
    return GlitchAbst.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

-- Error notification
GlitchAbst.Notifications.Glitch.Error = function(title, message, duration)
    return GlitchAbst.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

-- Info notification
GlitchAbst.Notifications.Glitch.Info = function(title, message, duration)
    return GlitchAbst.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

-- Warning notification
GlitchAbst.Notifications.Glitch.Warning = function(title, message, duration)
    return GlitchAbst.Notifications.Glitch.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Add box to an existing notification
GlitchAbst.Notifications.Glitch.AddBox = function(notificationId, title, message, color)
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
GlitchAbst.Notifications.Glitch.RemoveBox = function(notificationId, boxId)
    if not glitchNotificationsAvailable or not notificationId or not boxId then return false end
    
    exports['glitch-notifications']:RemoveBoxFromNotification(notificationId, boxId)
    return true
end

-- Remove an entire notification
GlitchAbst.Notifications.Glitch.Remove = function(notificationId)
    if not glitchNotificationsAvailable or not notificationId then return false end
    
    exports['glitch-notifications']:RemoveNotification(notificationId)
    return true
end

-- Update content of a notification box
GlitchAbst.Notifications.Glitch.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
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
GlitchAbst.Notifications.Glitch.Toggle = function(id, title, message, color)
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
GlitchAbst.Notifications.Fallback = function(method, params)
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
    if GlitchAbst.FrameworkName == 'ESX' then
        if method == 'Show' then
            TriggerEvent('esx:showNotification', (params.title and (params.title .. ': ') or '') .. 
                (params.description or params.message or ''), params.type or 'info')
            return 1 -- Return dummy ID
        end
        return nil
    end
    
    -- Try QBCore notifications if available
    if GlitchAbst.FrameworkName == 'QBCore' then
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
GlitchAbst.Notifications.Show = function(params)
    -- If explicitly configured to use Glitch, then use it when available
    if Config.NotificationSystem == 'glitch' and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.Show(params)
    end
    
    -- For auto mode, implement a proper priority order
    if Config.NotificationSystem == 'auto' then
        -- Define the priority order for auto detection
        local priorityOrder = Config.NotificationsPriority or {
            'ox', -- Default to ox first
            'qb',
            'esx', 
            'glitch', -- Glitch comes last in priority for auto mode
            'native'
        }
        
        -- Try each system in priority order
        for _, system in ipairs(priorityOrder) do
            -- Check for ox lib
            if system == 'ox' and GetResourceState('ox_lib') == 'started' then
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
            
            -- Check for QBCore
            if system == 'qb' and GlitchAbst.FrameworkName == 'QBCore' then
                TriggerEvent('QBCore:Notify', params.description or params.message, 
                    params.type or 'primary', params.duration or 5000)
                return 2 -- Return dummy ID
            end
            
            -- Check for ESX
            if system == 'esx' and GlitchAbst.FrameworkName == 'ESX' then
                TriggerEvent('esx:showNotification', 
                    (params.title and (params.title .. ': ') or '') .. 
                    (params.description or params.message or ''), 
                    params.type or 'info')
                return 3 -- Return dummy ID
            end
            
            -- Check for Glitch (now lower priority in auto mode)
            if system == 'glitch' and glitchNotificationsAvailable then
                return GlitchAbst.Notifications.Glitch.Show(params)
            end
        end
        
        -- Native as absolute fallback (if included in priority list)
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(params.description or params.message or '')
        EndTextCommandThefeedPostTicker(false, true)
        return 4 -- Return dummy ID
    end
    
    -- For specific configured systems
    if Config.NotificationSystem == 'ox' then
        return GlitchAbst.Notifications.Fallback('Show', params)
    elseif Config.NotificationSystem == 'qb' then
        return GlitchAbst.Notifications.Fallback('Show', params)
    elseif Config.NotificationSystem == 'esx' then
        return GlitchAbst.Notifications.Fallback('Show', params)
    end
    
    -- Last resort fallback
    return GlitchAbst.Notifications.Fallback('Show', params)
end

GlitchAbst.Notifications.Success = function(title, message, duration)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message,
        type = 'success',
        duration = duration
    })
end

GlitchAbst.Notifications.Error = function(title, message, duration)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message,
        type = 'error',
        duration = duration
    })
end

GlitchAbst.Notifications.Info = function(title, message, duration)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message,
        type = 'info',
        duration = duration
    })
end

GlitchAbst.Notifications.Warning = function(title, message, duration)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message,
        type = 'warning',
        duration = duration
    })
end

-- Basic fallback functions for extended functionality
GlitchAbst.Notifications.AddBox = function(notificationId, title, message, color)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.AddBox(notificationId, title, message, color)
    end
    -- Most systems don't have AddBox functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = title, description = message})
end

GlitchAbst.Notifications.RemoveBox = function(notificationId, boxId)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.RemoveBox(notificationId, boxId)
    end
    return false
end

GlitchAbst.Notifications.Remove = function(notificationId)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.Remove(notificationId)
    end
    return false
end

GlitchAbst.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.Update(notificationId, boxId, newMessage, newTitle, newColor)
    end
    -- Most systems don't have Update functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = newTitle, description = newMessage})
end

GlitchAbst.Notifications.Toggle = function(id, title, message, color)
    if (Config.NotificationSystem == 'glitch' or Config.NotificationSystem == 'auto') and glitchNotificationsAvailable then
        return GlitchAbst.Notifications.Glitch.Toggle(id, title, message, color)
    end
    -- Most systems don't have Toggle functionality, so fall back to showing a new notification
    return GlitchAbst.Notifications.Show({title = title, description = message})
end

-- Mirror function to UI namespace for backward compatibility
GlitchAbst.UI.Notify = function(params)
    return GlitchAbst.Notifications.Show(params)
end

-- Return availability status
return glitchNotificationsAvailable