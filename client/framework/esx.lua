-- ESX UI Module
if GlitchLib and GlitchLib.FrameworkName and GlitchLib.FrameworkName ~= 'ESX' then
    GlitchLib.Utils.DebugLog('Skipping ESX UI module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

-- Safe way to get ESX
local ESX = nil
local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

if not success or result == nil then
    GlitchLib.Utils.DebugLog('Failed to get ESX shared object')
    return false
end

ESX = result

if GlitchLib.FrameworkName ~= 'ESX' then
    GlitchLib.Utils.DebugLog('Skipping ESX framework module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

if not success or not result then
    -- Try the event method as fallback
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
        GlitchLib.Framework.ESX = ESX
        GlitchLib.Framework.Type = 'ESX'
        GlitchLib.Utils.DebugLog('ESX framework module loaded (via event)')
    end)
    return true
end

ESX = result
GlitchLib.Framework.ESX = ESX
GlitchLib.Framework.Type = 'ESX'
GlitchLib.Utils.DebugLog('ESX framework module loaded (via export)')

-- Player data
GlitchLib.Framework.GetPlayerData = function()
    return ESX.GetPlayerData()
end

-- Callbacks
GlitchLib.Framework.TriggerCallback = function(name, cb, ...)
    ESX.TriggerServerCallback(name, cb, ...)
end

-- Help notifications
GlitchLib.Framework.ShowHelpNotification = function(message, thisFrame)
    if thisFrame == nil then thisFrame = false end
    ESX.ShowHelpNotification(message, thisFrame)
end

-- Player functions
GlitchLib.Framework.SpawnPlayer = function(coords, callback)
    local isDead = ESX.IsPlayerDead()
    
    if isDead then
        -- Player is dead, handle respawn logic
        TriggerEvent('esx_ambulancejob:revive')
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
end

-- UI functions
GlitchLib.Framework.DrawText = function(x, y, text)
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
GlitchLib.Framework.Draw3DText = function(coords, text)
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
GlitchLib.Framework.GetClosestPlayer = function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    return closestPlayer, closestDistance
end

-- Vehicle functions
GlitchLib.Framework.GetVehicleProperties = function(vehicle)
    if DoesEntityExist(vehicle) then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
    return nil
end

GlitchLib.Framework.SetVehicleProperties = function(vehicle, props)
    if DoesEntityExist(vehicle) and props then
        ESX.Game.SetVehicleProperties(vehicle, props)
        return true
    end
    return false
end

-- Return true to indicate successful initialization
return true