-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ESX notifications module^7")
    return false
end

-- Initialize notifications namespace
GlitchAbst.Notifications = GlitchAbst.Notifications or {}

-- Skip if notification system doesn't match
if Config and Config.NotificationSystem and Config.NotificationSystem ~= 'esx' and Config.NotificationSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ESX notifications module (using ' .. Config.NotificationSystem .. ')')
    return false
end

-- Check if resource is actually available
if not GlitchAbst.Utils.IsStarted('es_extended') then
    GlitchAbst.Utils.DebugLog('es_extended resource is not available')
    return false
end

-- Safe way to get ESX
local ESX = GlitchAbst.Framework and GlitchAbst.Framework.ESX
if not ESX then
    local success, result = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if success and result then
        ESX = result
    else
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end

if not ESX then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get ESX object, skipping ESX notifications')
    return false
end

GlitchAbst.Utils.DebugLog('ESX notifications module loaded')

-- Track notification IDs for ESX (which doesn't natively support IDs)
local activeESXNotifications = {}
local nextESXNotificationId = 1

-- Basic notification
GlitchAbst.Notifications.Show = function(params)
    params = type(params) == 'table' and params or { description = tostring(params) }
    local message = params.description or params.message or params.title or ''
    if params.title and (params.description or params.message) then
        message = params.title .. ': ' .. message
    end
    ESX.ShowNotification(message, params.type, params.duration)

    -- Create a pseudo-ID for this notification
    local notificationId = nextESXNotificationId
    nextESXNotificationId = nextESXNotificationId + 1

    -- Store reference
    activeESXNotifications[notificationId] = {
        id = notificationId,
        message = message
    }

    return notificationId
end

local function Typed(kind)
    return function(title, message, duration)
        return GlitchAbst.Notifications.Show({
            title = title,
            description = message,
            type = kind,
            duration = duration
        })
    end
end

GlitchAbst.Notifications.Success = Typed('success')
GlitchAbst.Notifications.Error = Typed('error')
GlitchAbst.Notifications.Info = Typed('info')
GlitchAbst.Notifications.Warning = Typed('warning')

-- Advanced notification functions (ESX has limited support)

-- Add box to an existing notification (not supported in ESX): shows a new notification
GlitchAbst.Notifications.AddBox = function(notificationId, title, message, color)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message
    })
end

-- Remove a specific box from a notification (not supported in ESX)
GlitchAbst.Notifications.RemoveBox = function(notificationId, boxId)
    return false
end

-- Remove an entire notification (not supported in ESX): only forgets it
GlitchAbst.Notifications.Remove = function(notificationId)
    if activeESXNotifications[notificationId] then
        activeESXNotifications[notificationId] = nil
        return true
    end
    return false
end

-- Update content of a notification (not supported in ESX): shows a new one
GlitchAbst.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
    return GlitchAbst.Notifications.Show({
        title = newTitle,
        description = newMessage
    })
end

-- Toggle a notification (not supported in ESX): shows a new one
GlitchAbst.Notifications.Toggle = function(id, title, message, color)
    return GlitchAbst.Notifications.Show({
        title = title,
        description = message
    })
end

-- Mirror function to UI namespace for backward compatibility
GlitchAbst.UI.Notify = function(params)
    return GlitchAbst.Notifications.Show(params)
end

return true
