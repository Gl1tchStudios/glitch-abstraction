if Config.NotificationSystem ~= 'auto' and Config.NotificationSystem ~= 'glitch' then
    GlitchLib.Utils.DebugLog('Skipping glitch notifications (using ' .. Config.NotificationSystem .. ' instead)')
    return false
end

-- Check if resource is actually available
if GetResourceState('glitch-notifications') ~= 'started' then
    GlitchLib.Utils.DebugLog('glitch-notifications resource is not available')
    return false
end

if GlitchLib.FrameworkName ~= 'ESX' then
    GlitchLib.Utils.DebugLog('Skipping ESX notifications module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

-- Safe way to get ESX
local ESX = nil
local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

-- Track notification IDs for ESX (which doesn't natively support IDs)
local activeESXNotifications = {}
local nextESXNotificationId = 1

-- Define the initialization function BEFORE calling it
local function InitializeESXNotifications(eSXObj)
    GlitchLib.Utils.DebugLog('ESX notifications module loaded')
    
    -- Basic notification
    GlitchLib.Notifications.Show = function(params)
        eSXObj.ShowNotification(params.description or params.message or params.title)
        
        -- Create a pseudo-ID for this notification
        local notificationId = nextESXNotificationId
        nextESXNotificationId = nextESXNotificationId + 1
        
        -- Store reference
        activeESXNotifications[notificationId] = {
            id = notificationId,
            message = params.description or params.message or params.title
        }
        
        return notificationId
    end
    
    -- Success notification
    GlitchLib.Notifications.Success = function(title, message, duration)
        return GlitchLib.Notifications.Show({
            title = title,
            description = message
        })
    end
    
    -- Error notification
    GlitchLib.Notifications.Error = function(title, message, duration)
        return GlitchLib.Notifications.Show({
            title = title,
            description = message
        })
    end
    
    -- Info notification
    GlitchLib.Notifications.Info = function(title, message, duration)
        return GlitchLib.Notifications.Show({
            title = title,
            description = message
        })
    end
    
    -- Warning notification
    GlitchLib.Notifications.Warning = function(title, message, duration)
        return GlitchLib.Notifications.Show({
            title = title,
            description = message
        })
    end
    
    -- Advanced notification functions (ESX has limited support)
    
    -- Add box to an existing notification (not supported in ESX)
    GlitchLib.Notifications.AddBox = function(notificationId, title, message, color)
        -- ESX doesn't support adding boxes to notifications
        -- Show a new notification instead
        return GlitchLib.Notifications.Show({
            title = title,
            description = message
        })
    end
    
    -- Remove a specific box from a notification (not supported in ESX)
    GlitchLib.Notifications.RemoveBox = function(notificationId, boxId)
        -- Not supported in ESX
        return false
    end
    
    -- Remove an entire notification (not supported in ESX)
    GlitchLib.Notifications.Remove = function(notificationId)
        -- ESX doesn't support removing notifications
        -- Just mark it as removed in our tracking
        if activeESXNotifications[notificationId] then
            activeESXNotifications[notificationId] = nil
            return true
        end
        return false
    end
    
    -- Update content of a notification (not supported in ESX)
    GlitchLib.Notifications.Update = function(notificationId, boxId, newMessage, newTitle, newColor)
        -- ESX doesn't support updating notifications
        -- Show a new one instead
        return GlitchLib.Notifications.Show({
            title = newTitle,
            description = newMessage
        })
    end
    
    -- Toggle a notification (not supported in ESX)
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
end

if success and result then
    ESX = result
    InitializeESXNotifications(ESX)
else
    -- Try the event method as fallback
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
            if ESX then
                InitializeESXNotifications(ESX)
                break
            end
        end
    end)
end