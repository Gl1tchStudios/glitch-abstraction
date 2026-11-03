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

-- Check if resource is actually available (Qbox provides 'qb-core')
if not GlitchAbst.Utils.IsStarted('qb-core') and not GlitchAbst.Utils.IsStarted('qbx_core') then
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
    -- Qbox without its 'qb-core' provide: the same export lives under qbx_core
    success, result = pcall(function() return exports['qbx_core']:GetCoreObject() end)
end

if not success or not result then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore integration')
    return false
end

QBCore = result
GlitchAbst.Framework.QBCore = QBCore
GlitchAbst.Framework.Type = 'QBCore'
GlitchAbst.Utils.DebugLog('QBCore framework module loaded')

-- Player data ({} before a character is loaded)
GlitchAbst.Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData() or {}
end

-- Callbacks
GlitchAbst.Framework.TriggerCallback = function(name, cb, ...)
    QBCore.Functions.TriggerCallback(name, cb, ...)
end

-- Notifications
GlitchAbst.Framework.Notify = function(message, type, duration)
    local notifyType = GlitchAbst.Notifications and GlitchAbst.Notifications.Type
    -- 'framework' means the notification module is routed back here: do not loop
    if notifyType and notifyType ~= 'framework' and GlitchAbst.Notifications.Show then
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
    AddTextEntry('qbHelpNotification', tostring(message))
    if thisFrame then
        DisplayHelpTextThisFrame('qbHelpNotification', false)
    else
        BeginTextCommandDisplayHelp('qbHelpNotification')
        EndTextCommandDisplayHelp(0, false, true, -1)
    end
end

local function Teleport(coords, callback)
    DoScreenFadeOut(500)
    Wait(1000)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(PlayerPedId(), coords.w or 0.0)
    Wait(500)
    DoScreenFadeIn(500)
    if callback then callback() end
end

-- Player functions (call from a thread: this waits for the screen fades)
GlitchAbst.Framework.SpawnPlayer = function(coords, callback)
    if not coords then return false end
    local data = QBCore.Functions.GetPlayerData() or {}
    local meta = data.metadata or {}
    if meta.isdead or meta.inlaststand or IsEntityDead(PlayerPedId()) then
        -- Player is dead, revive first
        TriggerEvent("hospital:client:Revive")
        SetTimeout(1000, function()
            Teleport(coords, callback)
        end)
    else
        Teleport(coords, callback)
    end
    return true
end

local function DrawTextAt(x, y, text)
    text = tostring(text or '')
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)

    -- Background
    local factor = (string.len(text)) / 370
    DrawRect(x, y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 68)
end

-- UI functions
GlitchAbst.Framework.DrawText = function(x, y, text)
    DrawTextAt(x, y, text)
end

-- 3D text (skipped when the point is off screen)
GlitchAbst.Framework.Draw3DText = function(coords, text)
    if not coords then return end
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    DrawTextAt(_x, _y, text)
end

-- Get closest player (client player index, distance); -1, -1 when nobody is near
GlitchAbst.Framework.GetClosestPlayer = function()
    local pedCoords = GetEntityCoords(PlayerPedId())
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords and QBCore.Functions.GetPlayersFromCoords() or GetActivePlayers()
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
    if vehicle and DoesEntityExist(vehicle) then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end
    return nil
end

GlitchAbst.Framework.SetVehicleProperties = function(vehicle, props)
    if vehicle and DoesEntityExist(vehicle) and props then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
        return true
    end
    return false
end

-- Return true to indicate successful initialization
return true
