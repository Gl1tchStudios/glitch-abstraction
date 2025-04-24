-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading QBCore notifications module^7")
    return false
end

-- Initialize notifications namespace
GlitchLib.Notifications = GlitchLib.Notifications or {}

-- Skip if notification system doesn't match
if Config and Config.NotificationSystem and Config.NotificationSystem ~= 'qb' and Config.NotificationSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping QBCore notifications module (using ' .. Config.NotificationSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-core') ~= 'started' then
    GlitchLib.Utils.DebugLog('qb-core resource is not available')
    return false
end

GlitchLib.Utils.DebugLog('QBCore notifications module loaded')

-- Safe way to get QBCore
local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchLib.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore notifications')
    return false
end

QBCore = result

-- QBCore Notifications Implementation

-- Track notification IDs for QBCore (which doesn't natively support IDs)
local activeQBNotifications = {}
local nextQBNotificationId = 1

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    local qbType = 'primary'
    if params.type == 'error' then qbType = 'error'
    elseif params.type == 'success' then qbType = 'success'
    elseif params.type == 'warning' then qbType = 'error'
    elseif params.type == 'info' then qbType = 'primary' end
    
    QBCore.Functions.Notify(params.description or params.message or params.title, qbType, params.duration or 5000)
    
    -- Create a pseudo-ID for this notification
    local notificationId = nextQBNotificationId
    nextQBNotificationId = nextQBNotificationId + 1
    
    -- Store reference
    activeQBNotifications[notificationId] = {
        id = notificationId,
        message = params.description or params.message or params.title,
        type = qbType
    }
    
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

-- Advanced notification functions (limited support in QBCore)

-- Add box to an existing notification (not supported in QBCore)
GlitchLib.Notifications.AddBox = function(notificationId, title, message, color)
    -- QBCore doesn't support adding boxes to notifications
    -- Show a new notification instead
    return GlitchLib.Notifications.Show({
        title = title,
        description = message
    })
end

-- Remove a specific box from a notification (not supported in QBCore)
GlitchLib.Notifications.RemoveBox = function(notificationId, boxId)
    -- Not supported in QBCore
    return false
end

-- Remove an entire notification (not supported in QBCore)
GlitchLib.Notifications.Remove = function(notificationId)
    -- QBCore doesn't support removing notifications
    -- Just mark it as removed in our tracking
    if activeQBNotifications[notificationId] then
        activeQBNotifications[notificationId] = nil
        return true
    end
    return false
end

-- Update content of a notification (not supported in QBCore)
GlitchLib.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    -- QBCore doesn't support updating notifications
    -- Show a new one instead
    local qbType = 'primary'
    if activeQBNotifications[notificationId] then
        qbType = activeQBNotifications[notificationId].type
    end
    
    QBCore.Functions.Notify(newMessage, qbType, 5000)
    return nextQBNotificationId - 1
end

-- Toggle a notification (not supported in QBCore)
GlitchLib.Notifications.Toggle = function(id, title, message, color)
    -- Just show a new notification
    return GlitchLib.Notifications.Show({
        title = title,
        description = message
    })
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    return GlitchLib.Notifications.Show(params)
end