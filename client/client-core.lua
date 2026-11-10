-- Ensure GlitchAbst is initialized
if not GlitchAbst then
    print("^1[CRITICAL ERROR] GlitchAbst not initialized before client-core.lua^7")
    GlitchAbst = {
        Framework = {},
        UI = {},
        Target = {},
        Inventory = {},
        Progression = {},
        DoorLock = {},
        Cutscene = {},
        Scaleform = {},
        Notifications = {},
        Utils = {},
        IsReady = false
    }

    GlitchAbst.Utils.DebugLog = function(message)
        print('[GlitchAbst] ' .. tostring(message))
    end
end

-- Run once, even if something includes this file twice
if GlitchAbst._clientCoreLoaded then return end
GlitchAbst._clientCoreLoaded = true

local Utils = GlitchAbst.Utils
local Started = Utils.IsStarted

-- Config names -> module file names (the files do not all match the config names)
local FRAMEWORK_FILES = { ESX = 'esx', QBCore = 'qbcore' }
local UI_FILES = { ox = 'ox', qb = 'qbcore', qbcore = 'qbcore', esx = 'esx' }
local TARGET_FILES = { ox = 'ox', qb = 'qb', esx = 'bt' }
local INVENTORY_FILES = { ox = 'ox', qb = 'qbcore', esx = 'esx' }
local DOORLOCK_FILES = { ox = 'ox', qb = 'qbcore', esx = 'esx' }
local NOTIFY_FILES = { glitch = 'glitch', ox = 'ox', qb = 'qbcore', esx = 'esx' }

local loaded = {}

local function LoadFirst(kind, list, dir, files, choice, allow)
    for _, entry in ipairs(list or {}) do
        local wanted = (choice == nil or choice == 'auto' or choice == entry.name)
        if wanted and Started(entry.resourceName) and (not allow or allow(entry)) then
            local file = files[entry.name]
            if file then
                local ok, res = Utils.LoadModule(dir .. file .. '.lua')
                if ok then
                    Utils.DebugLog('Loaded ' .. kind .. ' module: ' .. entry.name)
                    return entry.name
                end
                Utils.DebugLog('Could not load ' .. kind .. ' module ' .. entry.name .. ': ' .. tostring(res))
            end
        end
    end
    return nil
end

local function LoadFramework()
    if loaded.framework then return end
    if not GlitchAbst.FrameworkName or GlitchAbst.FrameworkName == 'unknown' then
        GlitchAbst.FrameworkName = Utils.DetectFramework()
    end
    local name = GlitchAbst.FrameworkName
    local file = FRAMEWORK_FILES[name]
    if not file then
        Utils.DebugLog('No supported framework running')
        return
    end
    local ok, res = Utils.LoadModule('client/framework/' .. file .. '.lua')
    if ok then
        GlitchAbst.Framework.Type = name
        loaded.framework = name
        Utils.DebugLog('Framework loaded: ' .. name)
    else
        Utils.DebugLog('Failed to load framework ' .. name .. ': ' .. tostring(res))
    end
end

local function LoadUI()
    if loaded.ui then return end
    -- Detect again on every attempt: ox_lib may not have been running at the first pass
    if not GlitchAbst.UISystem or Config.UISystem == 'auto' then
        GlitchAbst.UISystem = Utils.DetectUISystem()
    end
    local uiSystem = GlitchAbst.UISystem or 'ox'
    local file = UI_FILES[string.lower(uiSystem)]
    local ok, res = false, 'unknown UI system ' .. tostring(uiSystem)
    if file then ok, res = Utils.LoadModule('client/ui/' .. file .. '.lua') end

    if not ok and uiSystem ~= 'ox' and Started('ox_lib') then
        Utils.DebugLog('UI ' .. uiSystem .. ' failed (' .. tostring(res) .. '), falling back to ox_lib')
        GlitchAbst.UISystem = 'ox'
        uiSystem = 'ox'
        ok, res = Utils.LoadModule('client/ui/ox.lua')
    end

    if ok then
        GlitchAbst.UI.Type = uiSystem
        loaded.ui = uiSystem
    else
        Utils.DebugLog('WARNING: No UI system loaded (' .. tostring(res) .. ')')
    end
end

local function LoadTarget()
    if loaded.target then return end
    local name = LoadFirst('target', Config.Target, 'client/target/', TARGET_FILES, Config.TargetSystem)
    if name then
        GlitchAbst.Target.Type = name
        loaded.target = name
    end
end

local function LoadInventory()
    if loaded.inventory then return end
    local name = LoadFirst('inventory', Config.Inventory, 'client/inventory/', INVENTORY_FILES, Config.InventorySystem, function(entry)
        if entry.name == 'esx' then return GlitchAbst.FrameworkName == 'ESX' end
        return true
    end)
    if name then
        GlitchAbst.Inventory.Type = name
        loaded.inventory = name
    end
end

local function LoadDoorLock()
    if loaded.doorlock then return end
    local name = LoadFirst('door lock', Config.DoorLock, 'client/doorlock/', DOORLOCK_FILES, Config.DoorlockSystem, function(entry)
        if entry.name == 'qb' then return Started('qb-core') end
        if entry.name == 'esx' then return Started('es_extended') end
        return true
    end)
    if name then
        GlitchAbst.DoorLock.Type = name
        loaded.doorlock = name
    end
end

-- Which XP module to use: Config.xpSystem 'glitch_xpSystem', 'pickle_xp' or 'auto'.
-- The XP resource usually starts after this library, so 'auto' only needs it to exist.
local function XPChoice()
    local choice = Config.xpSystem or 'auto'
    if choice ~= 'auto' then return choice end
    if GetResourceState('glitch-xpSystem') ~= 'missing' or GetResourceState('glitch_xpSystem') ~= 'missing' then
        return 'glitch_xpSystem'
    end
    if GetResourceState('pickle_xp') ~= 'missing' then return 'pickle_xp' end
    return nil
end
local XP_FILES = { glitch_xpSystem = 'glitch_xpsystem', pickle_xp = 'pickle_xp' }

local function LoadProgression()
    if loaded.progression then return end
    local choice = XPChoice()
    local xpFile = choice and XP_FILES[choice]
    if not xpFile then return end
    local ok, res = Utils.LoadModule('client/progression/' .. xpFile .. '.lua')
    if ok then
        GlitchAbst.Progression.Type = choice
        loaded.progression = choice
    else
        Utils.DebugLog('Could not load progression module: ' .. tostring(res))
    end
end

-- Last resort: route notifications through the framework's own notify
local function FrameworkNotifications()
    GlitchAbst.Notifications.Show = function(params)
        params = type(params) == 'table' and params or { description = tostring(params) }
        if GlitchAbst.Framework.Notify then
            GlitchAbst.Framework.Notify(params.description or params.message or params.title, params.type, params.duration)
        else
            BeginTextCommandThefeedPost('STRING')
            AddTextComponentSubstringPlayerName(tostring(params.description or params.message or params.title or ''))
            EndTextCommandThefeedPostTicker(false, true)
        end
        return 1
    end
    GlitchAbst.Notifications.Success = function(title, message, duration)
        return GlitchAbst.Notifications.Show({ title = title, description = message or title, type = 'success', duration = duration })
    end
    GlitchAbst.Notifications.Error = function(title, message, duration)
        return GlitchAbst.Notifications.Show({ title = title, description = message or title, type = 'error', duration = duration })
    end
    GlitchAbst.Notifications.Info = function(title, message, duration)
        return GlitchAbst.Notifications.Show({ title = title, description = message or title, type = 'info', duration = duration })
    end
    GlitchAbst.Notifications.Warning = function(title, message, duration)
        return GlitchAbst.Notifications.Show({ title = title, description = message or title, type = 'warning', duration = duration })
    end
    GlitchAbst.UI.Notify = function(params)
        return GlitchAbst.Notifications.Show(params)
    end
    GlitchAbst.Notifications.Type = 'framework'
end

local function LoadNotifications(final)
    if loaded.notifications and loaded.notifications ~= 'framework' then return end

    local choice = Config.NotificationSystem
    local name
    if choice and choice ~= 'auto' then
        name = LoadFirst('notification', Config.Notifications, 'client/notifications/', NOTIFY_FILES, choice)
        if not name then Utils.DebugLog('Configured notification system ' .. choice .. ' is not available') end
    end
    if not name then
        name = LoadFirst('notification', Config.Notifications, 'client/notifications/', NOTIFY_FILES, 'auto')
    end

    if name then
        GlitchAbst.Notifications.Type = name
        loaded.notifications = name
    elseif final or not loaded.notifications then
        Utils.DebugLog('No standalone notification system found, using framework notifications')
        FrameworkNotifications()
        loaded.notifications = 'framework'
    end
end

local function LoadExtras()
    if loaded.extras then return end
    loaded.extras = true

    local ok, err = Utils.LoadModule('client/scaleform/scaleform.lua')
    if not ok then
        Utils.DebugLog('Failed to load scaleform module: ' .. tostring(err))
        GlitchAbst.Scaleform = GlitchAbst.Scaleform or {}
        GlitchAbst.Scaleform.Active = {}
        GlitchAbst.Scaleform.Load = function() return nil end
        GlitchAbst.Scaleform.Unload = function() return false end
        GlitchAbst.Scaleform.CallFunction = function() return false end
        GlitchAbst.Scaleform.Render = function() return false end
        GlitchAbst.Scaleform.Render3D = function() return false end
    end

    ok, err = Utils.LoadModule('client/cutscene/cutscene.lua')
    if not ok then Utils.DebugLog('Failed to load cutscene module: ' .. tostring(err)) end

    -- cutscenes played on this player with the map streamed (server/cutscene) + the /cutsceneadmin browser
    -- (optional, see Config.Cutscenes.Enabled)
    for _, file in ipairs(Utils.CutscenesEnabled() and { 'client/cutscene/stream.lua', 'client/cutscene/admin.lua' } or {}) do
        ok, err = Utils.LoadModule(file)
        if not ok then Utils.DebugLog('Failed to load ' .. file .. ': ' .. tostring(err)) end
    end
end

local function LoadAll(final)
    LoadFramework()
    LoadUI()
    LoadTarget()
    LoadInventory()
    LoadDoorLock()
    LoadProgression()
    LoadNotifications(final)
    LoadExtras()

    if not GlitchAbst.UI.Notify then
        GlitchAbst.UI.Notify = function(params)
            params = type(params) == 'table' and params or {message = tostring(params)}
            BeginTextCommandThefeedPost('STRING')
            AddTextComponentSubstringPlayerName(tostring(params.message or params.description or 'Notification'))
            EndTextCommandThefeedPostTicker(false, true)
        end
    end
end

-- No XP system: safe defaults so callers never index nil
local function ProgressionDefaults()
    local P = GlitchAbst.Progression
    P.Type = P.Type or 'none'
    P.IsAvailable = P.IsAvailable or function() return false end
    P.GetXPData = P.GetXPData or function() return {} end
    P.GetXP = P.GetXP or function() return 0 end
    P.GetLevel = P.GetLevel or function() return 0 end
    P.GetLevelXP = P.GetLevelXP or function() return 0 end
    P.GetCategoryLevel = P.GetCategoryLevel or function() return 0 end
end

-- First pass straight away, so resources that grab the library while they start
-- already get working functions.
LoadAll(false)

-- Second pass for resources that started after us (glitch-notifications, the XP
-- system, a late framework), then announce that the library is ready.
CreateThread(function()
    Wait(1000)
    LoadAll(true)
    if not loaded.progression then ProgressionDefaults() end
    GlitchAbst.IsReady = loaded.framework and true or false
    Utils.DebugLog('GlitchAbst initialization complete (framework ' .. tostring(loaded.framework) .. ', ui ' .. tostring(loaded.ui)
        .. ', target ' .. tostring(loaded.target) .. ', inventory ' .. tostring(loaded.inventory) .. ', notify ' .. tostring(loaded.notifications) .. ')')
    TriggerEvent('GlitchAbst:ready', GlitchAbst.IsReady)
end)

-- Expose public exports
exports('getAbstraction', function()
    return GlitchAbst
end)
