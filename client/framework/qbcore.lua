local QBCore = exports['qb-core']:GetCoreObject()
GlitchLib.Utils.DebugLog('QBCore Client Framework module loaded')

-- Player Data
GlitchLib.Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData()
end

-- Notifications
GlitchLib.Framework.Notify = function(message, type, duration)
    QBCore.Functions.Notify(message, type, duration)
end

-- Callbacks
GlitchLib.Framework.TriggerCallback = function(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

-- Player Spawn
GlitchLib.Framework.SpawnPlayer = function(coords, callback)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    if callback then callback() end
end

-- Draw Text
GlitchLib.Framework.DrawText = function(x, y, text)
    QBCore.Functions.DrawText(x, y, text)
end

-- Draw 3D Text
GlitchLib.Framework.Draw3DText = function(coords, text)
    QBCore.Functions.DrawText3D(coords.x, coords.y, coords.z, text)
end

-- Get Closest Player
GlitchLib.Framework.GetClosestPlayer = function()
    return QBCore.Functions.GetClosestPlayer()
end

-- Get Vehicle Properties
GlitchLib.Framework.GetVehicleProperties = function(vehicle)
    return QBCore.Functions.GetVehicleProperties(vehicle)
end

-- Set Vehicle Properties
GlitchLib.Framework.SetVehicleProperties = function(vehicle, props)
    return QBCore.Functions.SetVehicleProperties(vehicle, props)
end