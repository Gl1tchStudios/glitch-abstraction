local ESX = exports['es_extended']:getSharedObject()
GlitchLib.Utils.DebugLog('ESX Client Framework module loaded')

-- Player Data
GlitchLib.Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
end

-- Notifications
GlitchLib.Framework.Notify = function(message, type, duration)
    ESX.ShowNotification(message, type, duration)
end

-- HUD
GlitchLib.Framework.ShowHelpNotification = function(message, thisFrame)
    ESX.ShowHelpNotification(message, thisFrame)
end

-- Callbacks
GlitchLib.Framework.TriggerCallback = function(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

-- Player Spawn
GlitchLib.Framework.SpawnPlayer = function(coords, callback)
    ESX.Game.Teleport(PlayerPedId(), coords, callback)
end