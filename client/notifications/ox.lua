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

if not GlitchAbst.Utils.IsStarted('ox_lib') then
    GlitchAbst.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Types other systems use -> ox_lib types (inform, success, error, warning)
local TYPES = { info = 'inform', inform = 'inform', primary = 'inform', success = 'success', error = 'error', warning = 'warning', warn = 'warning' }

-- Setup notification methods
GlitchAbst.Notifications.Ox.Show = function(params)
    if not params then return end

    params = type(params) == 'table' and params or {message = tostring(params)}

    -- Map all supported parameters from the lib.notify documentation
    exports['ox_lib']:notify({
        id = params.id,                                     -- Unique notification ID
        title = params.title,                               -- Notification title
        description = params.message or params.description, -- Support both description and message
        duration = params.duration or 5000,                 -- Duration in ms
        showDuration = params.showDuration,                 -- Whether to show countdown
        position = params.position or 'top-right',          -- Position on screen
        type = TYPES[params.type or 'inform'] or 'inform',  -- Notification type
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

local function Typed(kind)
    return function(title, message, duration, options)
        options = type(options) == 'table' and options or {}
        options.title = title
        options.message = message
        options.type = kind
        options.duration = duration
        return GlitchAbst.Notifications.Ox.Show(options)
    end
end

GlitchAbst.Notifications.Ox.Success = Typed('success')
GlitchAbst.Notifications.Ox.Error = Typed('error')
GlitchAbst.Notifications.Ox.Info = Typed('inform')
GlitchAbst.Notifications.Ox.Warning = Typed('warning')

-- Top-level convenience methods
GlitchAbst.Notifications.Success = GlitchAbst.Notifications.Ox.Success
GlitchAbst.Notifications.Error = GlitchAbst.Notifications.Ox.Error
GlitchAbst.Notifications.Info = GlitchAbst.Notifications.Ox.Info
GlitchAbst.Notifications.Warning = GlitchAbst.Notifications.Ox.Warning

-- ox_lib has no boxes or updates: these show a new notification instead
GlitchAbst.Notifications.AddBox = function(notificationId, title, message, color)
    return GlitchAbst.Notifications.Show({ title = title, description = message })
end
GlitchAbst.Notifications.RemoveBox = function() return false end
GlitchAbst.Notifications.Remove = function() return false end
GlitchAbst.Notifications.Update = function(notificationId, boxId, newMessage, newTitle)
    return GlitchAbst.Notifications.Show({ title = newTitle, description = newMessage })
end
GlitchAbst.Notifications.Toggle = function(id, title, message)
    return GlitchAbst.Notifications.Show({ title = title, description = message })
end

-- Style-focused notifications
GlitchAbst.Notifications.Ox.Custom = function(params)
    return GlitchAbst.Notifications.Ox.Show(params)
end

-- Sound notification
GlitchAbst.Notifications.Ox.WithSound = function(params, soundBank, soundSet, soundName)
    params = type(params) == 'table' and params or { message = tostring(params) }
    params.sound = {
        bank = soundBank,
        set = soundSet,
        name = soundName
    }
    return GlitchAbst.Notifications.Ox.Show(params)
end

-- Animated icon notification
GlitchAbst.Notifications.Ox.WithAnimation = function(params, animation, iconAlign)
    params = type(params) == 'table' and params or { message = tostring(params) }
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
