-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading QBCore framework module^7")
    return false
end

-- Skip if framework doesn't match
if GlitchAbst.FrameworkName and GlitchAbst.FrameworkName ~= 'QBCore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-core') ~= 'started' then
    GlitchAbst.Utils.DebugLog('qb-core resource is not available')
    return false
end

-- Initialize framework modules
GlitchAbst.Framework = GlitchAbst.Framework or {}

-- QBCore Client Implementation
local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore integration')
    return false
end

QBCore = result
GlitchAbst.Framework.QBCore = QBCore
GlitchAbst.Framework.Type = 'QBCore'
GlitchAbst.Utils.DebugLog('QBCore framework module loaded')

-- Player data
GlitchAbst.Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData()
end

-- Callbacks
GlitchAbst.Framework.TriggerCallback = function(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

-- Notifications
GlitchAbst.Framework.Notify = function(message, type, duration)
    if GlitchAbst.Notifications and GlitchAbst.Notifications.Type then
        -- Use the notifications system if available
        GlitchAbst.Notifications.Show({
            description = message,
            type = type or 'info',
            duration = duration or 5000
        })
    else
        -- Fallback to QBCore notifications
        QBCore.Functions.Notify(message, type, duration)
    end
end

-- Help notifications
GlitchAbst.Framework.ShowHelpNotification = function(message, thisFrame)
    if thisFrame == nil then thisFrame = false end
    AddTextEntry('qbHelpNotification', message)
    DisplayHelpTextThisFrame('qbHelpNotification', thisFrame)
end

-- Player functions
GlitchAbst.Framework.SpawnPlayer = function(coords, callback)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        if PlayerData.metadata["isdead"] or PlayerData.metadata["inlaststand"] then
            -- Player is dead, handle respawn logic
            TriggerEvent("hospital:client:Revive")
            SetTimeout(1000, function()
                DoScreenFadeOut(500)
                Wait(1000)
                SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
                SetEntityHeading(PlayerPedId(), coords.w or 0.0)
                Wait(500)
                DoScreenFadeIn(500)
                if callback then callback() end
            end)
        else
            -- Player is alive
            DoScreenFadeOut(500)
            Wait(1000)
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
            SetEntityHeading(PlayerPedId(), coords.w or 0.0)
            Wait(500)
            DoScreenFadeIn(500)
            if callback then callback() end
        end
    end)
end

-- UI functions
GlitchAbst.Framework.DrawText = function(x, y, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    DrawText(x, y)
    
    -- Optional background
    local factor = (string.len(text)) / 370
    DrawRect(x, y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 68)
end

-- 3D text
GlitchAbst.Framework.Draw3DText = function(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 68)
end

-- Get closest player
GlitchAbst.Framework.GetClosestPlayer = function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    
    for i = 1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local targetPed = GetPlayerPed(closestPlayers[i])
            local dist = #(pedCoords - GetEntityCoords(targetPed))

            if closestDistance == -1 or closestDistance > dist then
                closestPlayer = closestPlayers[i]
                closestDistance = dist
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Vehicle functions
GlitchAbst.Framework.GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end
    return nil
end

GlitchAbst.Framework.SetVehicleProperties = function(vehicle, props)
    if DoesEntityExist(vehicle) and props then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
        return true
    end
    return false
end

-- Return true to indicate successful initialization
return true