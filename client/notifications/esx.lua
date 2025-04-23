-- ESX Notifications Implementation
GlitchLib.Utils.DebugLog('ESX notifications module loaded')

local ESX = exports['es_extended']:getSharedObject()

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    ESX.ShowNotification(params.description or params.message or params.title)
end

-- Success notification
GlitchLib.Notifications.Success = function(title, message, duration)
    ESX.ShowNotification(message or title)
end

-- Error notification
GlitchLib.Notifications.Error = function(title, message, duration)
    ESX.ShowNotification(message or title)
end

-- Info notification
GlitchLib.Notifications.Info = function(title, message, duration)
    ESX.ShowNotification(message or title)
end

-- Warning notification
GlitchLib.Notifications.Warning = function(title, message, duration)
    ESX.ShowNotification(message or title)
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    GlitchLib.Notifications.Show(params)
end