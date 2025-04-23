-- QBCore Notifications Implementation
GlitchLib.Utils.DebugLog('QBCore notifications module loaded')

local QBCore = exports['qb-core']:GetCoreObject()

-- Basic notification
GlitchLib.Notifications.Show = function(params)
    local qbType = 'primary'
    if params.type == 'error' then qbType = 'error'
    elseif params.type == 'success' then qbType = 'success'
    elseif params.type == 'warning' then qbType = 'error'
    elseif params.type == 'info' then qbType = 'primary' end
    
    QBCore.Functions.Notify(params.description or params.message or params.title, qbType, params.duration or 5000)
end

-- Success notification
GlitchLib.Notifications.Success = function(title, message, duration)
    QBCore.Functions.Notify(message or title, 'success', duration or 5000)
end

-- Error notification
GlitchLib.Notifications.Error = function(title, message, duration)
    QBCore.Functions.Notify(message or title, 'error', duration or 5000)
end

-- Info notification
GlitchLib.Notifications.Info = function(title, message, duration)
    QBCore.Functions.Notify(message or title, 'primary', duration or 5000)
end

-- Warning notification
GlitchLib.Notifications.Warning = function(title, message, duration)
    QBCore.Functions.Notify(message or title, 'error', duration or 5000)
end

-- Mirror function to UI namespace for backward compatibility
GlitchLib.UI.Notify = function(params)
    GlitchLib.Notifications.Show(params)
end