-- shared/config-core.lua always creates GlitchAbst first (see fxmanifest load order)
if GlitchAbst == nil then
    print('^1[glitch-abstraction] GlitchAbst missing: shared scripts did not load, check fxmanifest.lua^7')
    return
end

-- Run once, even if something includes this file twice
if GlitchAbst._serverCoreLoaded then return end
GlitchAbst._serverCoreLoaded = true

local Utils = GlitchAbst.Utils
local Started = Utils.IsStarted

-- Config names -> module file names (the files do not all match the config names)
local FRAMEWORK_FILES = { ESX = 'esx', QBCore = 'qbcore' }
local INVENTORY_FILES = { ox = 'ox', qb = 'qbcore', esx = 'esx' }
local DOORLOCK_FILES = { ox = 'ox', qb = 'qb', esx = 'esx' }

local loaded = {}

-- Try each running system in priority order and keep the first module that loads.
-- choice: Config.<X>System ('auto' or a name to force)
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
    if loaded.framework then return true end

    if not GlitchAbst.FrameworkName or GlitchAbst.FrameworkName == 'unknown' then
        GlitchAbst.FrameworkName = Utils.DetectFramework()
    end
    local name = GlitchAbst.FrameworkName
    local file = FRAMEWORK_FILES[name]
    if not file then
        Utils.DebugLog('No supported framework running (es_extended, qbx_core or qb-core)')
        return false
    end

    local ok, res = Utils.LoadModule('server/framework/' .. file .. '.lua')
    if not ok then
        Utils.DebugLog('Failed to load framework ' .. name .. ': ' .. tostring(res))
        return false
    end

    GlitchAbst.Framework.Type = name
    loaded.framework = name
    Utils.DebugLog('Successfully loaded framework: ' .. name)
    return true
end

local function LoadInventory()
    if loaded.inventory or not loaded.framework then return end
    local name = LoadFirst('inventory', Config.Inventory, 'server/inventory/', INVENTORY_FILES, Config.InventorySystem, function(entry)
        -- es_extended counts as an inventory only on ESX itself
        if entry.name == 'esx' then return GlitchAbst.FrameworkName == 'ESX' end
        return true
    end)
    if name then
        GlitchAbst.Inventory.Type = name
        loaded.inventory = name
    end
end

local function LoadDoorLock()
    if loaded.doorlock or not loaded.framework then return end
    local name = LoadFirst('door lock', Config.DoorLock, 'server/doorlock/', DOORLOCK_FILES, Config.DoorlockSystem, function(entry)
        if entry.name == 'qb' then return Started('qb-core') end
        if entry.name == 'esx' then return Started('es_extended') end
        return true
    end)
    if name then
        GlitchAbst.DoorLock.Type = name
        loaded.doorlock = name
    end
end

local function LoadNotifications()
    if loaded.notifications then return end
    if Started('ox_lib') then
        local ok, res = Utils.LoadModule('server/notifications/ox.lua')
        if ok then
            loaded.notifications = 'ox'
        else
            Utils.DebugLog('Could not load server notifications: ' .. tostring(res))
        end
    end
end

-- Which XP module to use: Config.xpSystem 'glitch_xpSystem', 'pickle_xp' or 'auto'.
-- The XP resource usually starts after this library, so 'auto' only needs it to exist.
local function XPChoice()
    local choice = Config.xpSystem or 'auto'
    if choice ~= 'auto' then return choice end
    local glitchState = GetResourceState('glitch-xpSystem')
    local glitchAliasState = GetResourceState('glitch_xpSystem')
    if (glitchState ~= 'missing' and glitchState ~= 'stopped')
        or (glitchAliasState ~= 'missing' and glitchAliasState ~= 'stopped') then
        return 'glitch_xpSystem'
    end
    if GetResourceState('pickle_xp') ~= 'missing' and GetResourceState('pickle_xp') ~= 'stopped' then return 'pickle_xp' end
    return nil
end
local XP_FILES = { glitch_xpSystem = 'glitch_xpsystem', pickle_xp = 'pickle_xp' }

local function LoadProgression()
    if loaded.progression then return end
    local choice = XPChoice()
    local xpFile = choice and XP_FILES[choice]
    if not xpFile then return end
    -- The XP resource may be named glitch-xpSystem or glitch_xpSystem; the module
    -- looks the resource up on every call, so it can load before the XP resource starts.
    local ok, res = Utils.LoadModule('server/progression/' .. xpFile .. '.lua')
    if ok then
        GlitchAbst.Progression.Type = choice
        loaded.progression = choice
    else
        Utils.DebugLog('Could not load progression module: ' .. tostring(res))
    end
end

-- Cutscenes played on players + /cutsceneadmin (needs nothing else, loads once)
local function LoadCutscenes()
    if loaded.cutscene then return end
    if not Utils.CutscenesEnabled() then return end
    loaded.cutscene = true
    local ok, res = Utils.LoadModule('server/cutscene/cutscene.lua')
    if not ok then Utils.DebugLog('Could not load the cutscene module: ' .. tostring(res)) end
end

local function LoadAll()
    LoadFramework()
    LoadInventory()
    LoadDoorLock()
    LoadNotifications()
    LoadProgression()
    LoadCutscenes()
end

-- No XP system: safe defaults so callers never index nil
local function ProgressionDefaults()
    local P = GlitchAbst.Progression
    P.Type = P.Type or 'none'
    P.IsAvailable = P.IsAvailable or function() return false end
    P.GetXPData = P.GetXPData or function() return 0, 0 end
    P.AddXP = P.AddXP or function() return false end
    P.RemoveXP = P.RemoveXP or function() return false end
    P.SetXP = P.SetXP or function() return false end
    P.GetLevel = P.GetLevel or function() return 0 end
    P.InitializePlayerXP = P.InitializePlayerXP or function() return false end
    P.RegisterXPCategory = P.RegisterXPCategory or function() return false end
end

-- First pass straight away, so resources that grab the library while they start
-- already get working functions.
LoadAll()

-- Second pass once the rest of server.cfg has started (frameworks or inventories
-- that started after us), then announce that the library is ready.
CreateThread(function()
    Wait(1000)

    LoadAll()

    if not loaded.progression then ProgressionDefaults() end
    GlitchAbst.IsReady = loaded.framework and true or false

    if Config.Debug or not GlitchAbst.IsReady then
        print(('^2[glitch-abstraction] library ready: %s^7'):format(GlitchAbst.IsReady and 'yes' or 'no'))
    end
    if not GlitchAbst.IsReady then
        print('^1[glitch-abstraction] No supported framework is running (es_extended, qbx_core or qb-core).^7')
    end

    TriggerEvent('GlitchAbst:ready', GlitchAbst.IsReady)
end)

-- Export the library
exports('getAbstraction', function()
    return GlitchAbst
end)
