Config = Config or {}

Config.Debug = false

Config.UseFramework = 'auto'  -- Options: 'ESX', 'QBCore', 'auto' (Qbox counts as QBCore)

-- Initialize GlitchAbst globals BEFORE thread execution
GlitchAbst = GlitchAbst or {}
GlitchAbst.Utils = GlitchAbst.Utils or {}
GlitchAbst.Framework = GlitchAbst.Framework or {}
GlitchAbst.Notifications = GlitchAbst.Notifications or {}
GlitchAbst.UI = GlitchAbst.UI or {}

-- Debug function needed right away
GlitchAbst.Utils.DebugLog = function(message)
    if Config.Debug then
        print('[GlitchAbst] ' .. tostring(message))
    end
end

local function Running(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

-- Framework detection. Qbox (qbx_core) provides 'qb-core' and ships a QBCore
-- compatible object, so it uses the QBCore modules; GlitchAbst.IsQbox tells them apart.
local function DetectFramework()
    local configFramework = Config.UseFramework
    GlitchAbst.IsQbox = Running('qbx_core')

    if configFramework and configFramework ~= 'auto' then
        if configFramework == 'QBox' or configFramework == 'Qbox' then configFramework = 'QBCore' end
        GlitchAbst.Utils.DebugLog('Using configured framework: ' .. configFramework)
        return configFramework
    end

    local detected
    if Running('es_extended') then
        detected = 'ESX'
    elseif Running('qbx_core') or Running('qb-core') then
        detected = 'QBCore'
    end

    if detected then
        GlitchAbst.Utils.DebugLog('Auto-detected framework: ' .. detected .. (GlitchAbst.IsQbox and ' (Qbox)' or ''))
    else
        GlitchAbst.Utils.DebugLog('WARNING: No supported framework detected yet')
        detected = 'unknown'
    end

    return detected
end
GlitchAbst.Utils.DetectFramework = DetectFramework

-- Store detected framework globally (the cores detect again if it was not running yet)
GlitchAbst.FrameworkName = DetectFramework()

-- UI systems available, in priority order. Defined before DetectUISystem runs:
-- it used to be defined further down, so 'auto' never saw this list and fell
-- back to the framework name (Qbox -> the QB UI with qb-input / qb-menu).
Config.UI = {
    {name = 'ox', resourceName = 'ox_lib'},
    {name = 'qb', resourceName = 'qb-core'},
    {name = 'esx', resourceName = 'es_extended'},
}

Config.UISystem = 'auto' -- 'auto', 'ox', 'qb', 'esx'

Config.NotificationSystem = 'auto' -- 'auto', 'glitch', 'ox', 'qb', 'esx'

-- Which module to use when more than one is running ('auto' = first running one in the lists below)
Config.InventorySystem = 'auto' -- 'auto', 'ox', 'qb', 'esx'
Config.TargetSystem = 'auto'    -- 'auto', 'ox', 'qb', 'esx' (esx = bt-target)
Config.DoorlockSystem = 'auto'  -- 'auto', 'ox', 'qb', 'esx'

Config.ProgressCircle = true -- Use circle progress bar for oxlib

-- Function to detect UI system
local function DetectUISystem()
    local configUI = Config and Config.UISystem or 'auto'
    local detected = nil

    if configUI ~= 'auto' then
        GlitchAbst.Utils.DebugLog('Using configured UI system: ' .. configUI)
        return configUI
    end

    -- Auto-detection based on priority order
    if Config and Config.UI then
        for _, ui in ipairs(Config.UI) do
            if Running(ui.resourceName) then
                detected = ui.name
                break
            end
        end
    end

    -- Fall back to detected framework if no UI system is found
    if not detected and GlitchAbst.FrameworkName and GlitchAbst.FrameworkName ~= 'unknown' then
        detected = GlitchAbst.FrameworkName == 'QBCore' and 'qb' or string.lower(GlitchAbst.FrameworkName)
    end

    if detected then
        GlitchAbst.Utils.DebugLog('Auto-detected UI system: ' .. detected)
    else
        GlitchAbst.Utils.DebugLog('WARNING: No UI system detected, using default')
        detected = 'ox' -- Default fallback
    end

    return detected
end
GlitchAbst.Utils.DetectUISystem = DetectUISystem

GlitchAbst.UISystem = DetectUISystem()

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

-- XP system: 'auto', 'glitch_xpSystem' or 'pickle_xp'
Config.xpSystem = 'auto'
