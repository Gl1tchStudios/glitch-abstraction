Config = Config or {}

Config.Debug = true

Config.UseFramework = 'auto'  -- Options: 'ESX', 'QBCore', 'auto'

-- Initialize GlitchLib globals BEFORE thread execution
GlitchLib = GlitchLib or {}
GlitchLib.Utils = GlitchLib.Utils or {}
GlitchLib.Framework = GlitchLib.Framework or {}
GlitchLib.Notifications = GlitchLib.Notifications or {}
GlitchLib.UI = GlitchLib.UI or {}

-- Debug function needed right away
GlitchLib.Utils.DebugLog = function(message)
    if Config.Debug then
        print('[GlitchLib] ' .. message)
    end
end

-- framework detection
local function DetectFramework()
    local configFramework = Config.UseFramework
    local detected = nil
    
    if configFramework ~= 'auto' then
        GlitchLib.Utils.DebugLog('Using configured framework: ' .. configFramework)
        return configFramework
    end
    
    if GetResourceState('es_extended') == 'started' then
        detected = 'ESX'
    elseif GetResourceState('qb-core') == 'started' then
        detected = 'QBCore'
    end
    
    if detected then
        GlitchLib.Utils.DebugLog('Auto-detected framework: ' .. detected)
    else
        GlitchLib.Utils.DebugLog('WARNING: No supported framework detected!')
        detected = 'unknown'
    end
    
    return detected
end

-- Store detected framework globally
GlitchLib.FrameworkName = DetectFramework()

-- Function to detect UI system
local function DetectUISystem()
    local configUI = Config and Config.UISystem or 'auto'
    local detected = nil
    
    if configUI ~= 'auto' then
        GlitchLib.Utils.DebugLog('Using configured UI system: ' .. configUI)
        return configUI
    end
    
    -- Auto-detection based on priority order
    if Config and Config.UI then
        for _, ui in ipairs(Config.UI) do
            if GetResourceState(ui.resourceName) == 'started' then
                detected = ui.name
                break
            end
        end
    end
    
    -- Fall back to detected framework if no UI system is found
    if not detected and GlitchLib.FrameworkName and GlitchLib.FrameworkName ~= 'unknown' then
        detected = string.lower(GlitchLib.FrameworkName)
    end
    
    if detected then
        GlitchLib.Utils.DebugLog('Auto-detected UI system: ' .. detected)
    else
        GlitchLib.Utils.DebugLog('WARNING: No UI system detected, using default')
        detected = 'ox' -- Default fallback
    end
    
    return detected
end

GlitchLib.UISystem = DetectUISystem()

-- Frameworks our library supports
Config.Framework = {
    {name = 'ESX', resourceName = 'es_extended', getObject = function() return exports['es_extended']:getSharedObject() end},
    {name = 'QBCore', resourceName = 'qb-core', getObject = function() return exports['qb-core']:GetCoreObject() end},
}

-- Inventory systems
Config.Inventory = {
    {name = 'ox', resourceName = 'ox_inventory'},
    {name = 'qb', resourceName = 'qb-inventory'},
    {name = 'esx', resourceName = 'es_extended'},
}

-- Target systems
Config.Target = {
    {name = 'ox', resourceName = 'ox_target'},
    {name = 'qb', resourceName = 'qb-target'},
    {name = 'esx', resourceName = 'bt-target'},
}

-- Door Lock systems
Config.DoorLock = {
    {name = 'ox', resourceName = 'ox_doorlock'},
    {name = 'qb', resourceName = 'qb-doorlock'},
    {name = 'esx', resourceName = 'esx_doorlock'},
}

-- Notification systems
Config.Notifications = {
    {name = 'glitch', resourceName = 'glitch-notifications'},
    {name = 'ox', resourceName = 'ox_lib'},
    {name = 'qb', resourceName = 'qb-core'},
    {name = 'esx', resourceName = 'es_extended'},
}

Config.FrameworkMapping = {
    ["QBox"] = "QBCore" -- QBox is the same as QBCore as it's a fork of it
}

-- UI systems available
Config.UI = {
    {name = 'ox', resourceName = 'ox_lib'},
    {name = 'qb', resourceName = 'qb-core'},
    {name = 'esx', resourceName = 'es_extended'},
}

Config.UISystem = 'auto' -- 'auto', 'ox', 'qb', 'esx'

Config.NotificationSystem = 'auto' -- 'auto', 'glitch', 'ox', 'qb', 'esx

Config.ProgressCircle = true -- Use circle progress bar for oxlib

-- XP system
Config.xpSystem = 'pickle_xp'