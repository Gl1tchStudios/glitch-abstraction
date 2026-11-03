-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ESX framework module^7")
    return false
end

-- Skip if framework doesn't match
if GlitchAbst.FrameworkName and GlitchAbst.FrameworkName ~= 'ESX' then
    GlitchAbst.Utils.DebugLog('Skipping ESX module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end

-- Check if resource is actually available
if not GlitchAbst.Utils.IsStarted('es_extended') then
    GlitchAbst.Utils.DebugLog('es_extended resource is not available')
    return false
end

-- Initialize framework modules
GlitchAbst.Framework = GlitchAbst.Framework or {}

-- ESX Client Implementation
local ESX = nil
local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

if not success or not result then
    -- Legacy ESX: the event handler runs straight away
    TriggerEvent('esx:getSharedObject', function(obj) result = obj end)
    if not result then
        GlitchAbst.Utils.DebugLog('WARNING: Failed to get ESX object, skipping ESX integration')
        return false
    end
end

ESX = result
GlitchAbst.Framework.ESX = ESX
GlitchAbst.Framework.Type = 'ESX'
GlitchAbst.Utils.DebugLog('ESX framework module loaded')

-- Player data ({} before a character is loaded)
GlitchAbst.Framework.GetPlayerData = function()
    return ESX.GetPlayerData() or {}
end

-- Callbacks
GlitchAbst.Framework.TriggerCallback = function(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
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
    elseif ESX.ShowNotification then
        ESX.ShowNotification(message, type, duration)
    else
        TriggerEvent('esx:showNotification', message, type, duration)
    end
end

-- Help notifications
GlitchAbst.Framework.ShowHelpNotification = function(message, thisFrame)
    if thisFrame == nil then thisFrame = false end
    ESX.ShowHelpNotification(message, thisFrame)
end

local function IsDead()
    if ESX.PlayerData and ESX.PlayerData.dead then return true end
    if ESX.IsPlayerDead then
        local ok, dead = pcall(ESX.IsPlayerDead)
        if ok and dead then return true end
    end
    return IsEntityDead(PlayerPedId())
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
    if IsDead() then
        -- Player is dead, revive first
        TriggerEvent('esx_ambulancejob:revive')
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

-- Get closest player
GlitchAbst.Framework.GetClosestPlayer = function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    return closestPlayer, closestDistance
end

-- Vehicle functions
GlitchAbst.Framework.GetVehicleProperties = function(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
    return nil
end

GlitchAbst.Framework.SetVehicleProperties = function(vehicle, props)
    if vehicle and DoesEntityExist(vehicle) and props then
        ESX.Game.SetVehicleProperties(vehicle, props)
        return true
    end
    return false
end

-- Return true to indicate successful initialization
return true
