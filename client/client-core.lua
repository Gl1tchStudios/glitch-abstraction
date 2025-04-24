-- Ensure GlitchLib is initialized
if not GlitchLib then
    print("^1[CRITICAL ERROR] GlitchLib not initialized before client-core.lua^7")
    GlitchLib = {
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
    
    GlitchLib.Utils.DebugLog = function(message)
        print('[GlitchLib] ' .. message)
    end
end

local hasInitialized = false

local function InitializeLibrary()
    -- Check if already initialized and exit early
    if hasInitialized then
        GlitchLib.Utils.DebugLog('GlitchLib already initialized, skipping duplicate initialization')
        return false
    end
    
    hasInitialized = true
    GlitchLib.Utils.DebugLog('Initializing GlitchLib client...')
    
    -- Load framework support with nil check
    local frameworkLoaded = false
    if Config and Config.Framework then
        for _, fw in ipairs(Config.Framework) do
            if GetResourceState(fw.resourceName) ~= 'missing' then
                local frameworkName = fw.name
                GlitchLib.Utils.DebugLog('Detected framework: ' .. frameworkName)
                
                local implementationName = frameworkName
                if Config.FrameworkMapping and Config.FrameworkMapping[frameworkName] then
                    implementationName = Config.FrameworkMapping[frameworkName]
                    GlitchLib.Utils.DebugLog('Using implementation: ' .. implementationName)
                end
                
                -- Load the framework module
                local status, result = pcall(function()
                    local frameworkModule = LoadResourceFile(GetCurrentResourceName(), 'client/framework/' .. string.lower(implementationName) .. '.lua')
                    if frameworkModule then
                        local loadedModule = load(frameworkModule)
                        if loadedModule then
                            local success = loadedModule()
                            if success then
                                GlitchLib.Framework.Type = frameworkName
                                frameworkLoaded = true
                                return true
                            end
                        end
                    end
                    error('Failed to load framework module')
                end)
                
                if status and result then
                    GlitchLib.Utils.DebugLog('Framework loaded successfully')
                    break
                else
                    GlitchLib.Utils.DebugLog('Failed to load framework: ' .. tostring(result))
                end
            end
        end
    else
        GlitchLib.Utils.DebugLog('WARNING: Config.Framework is missing')
    end

    if not frameworkLoaded then
        GlitchLib.Utils.DebugLog('No supported framework found')
    end

    -- Load UI system with nil check
    local uiLoaded = false
    local uiSystem = GlitchLib.UISystem or 'native'

    GlitchLib.Utils.DebugLog('Loading UI system: ' .. uiSystem)

    local status, err = pcall(function()
        local uiModule = LoadResourceFile(GetCurrentResourceName(), 'client/ui/' .. string.lower(uiSystem) .. '.lua')
        if uiModule then
            load(uiModule)()
            GlitchLib.UI.Type = uiSystem
            uiLoaded = true
        else
            error('UI module not found: ' .. uiSystem)
        end
    end)

    if not status then
        GlitchLib.Utils.DebugLog('Failed to load UI system: ' .. err)
        
        if uiSystem ~= 'ox' and GetResourceState('ox_lib') == 'started' then
            GlitchLib.Utils.DebugLog('Attempting fallback to ox_lib UI')
            
            local fallbackStatus, fallbackErr = pcall(function()
                local oxModule = LoadResourceFile(GetCurrentResourceName(), 'client/ui/ox.lua')
                if oxModule then
                    load(oxModule)()
                    GlitchLib.UI.Type = 'ox'
                    uiLoaded = true
                else
                    error('Fallback UI module not found')
                end
            end)
            
            if not fallbackStatus then
                GlitchLib.Utils.DebugLog('Fallback to ox_lib UI failed: ' .. fallbackErr)
            end
        end
    end

    if not uiLoaded then
        GlitchLib.Utils.DebugLog('WARNING: No UI system loaded, using basic native UI')
        
        -- Define basic native UI functions as fallback
        GlitchLib.UI.ShowNotification = function(message)
            SetNotificationTextEntry('STRING')
            AddTextComponentString(message)
            DrawNotification(false, true)
        end
        
        GlitchLib.UI.Type = 'native'
    end
    
    local targetLoaded = false
    if Config and Config.Target then
        for _, tg in ipairs(Config.Target) do
            if GetResourceState(tg.resourceName) == 'started' then
                GlitchLib.Utils.DebugLog('Loading target system: ' .. tg.name)
                
                local status, err = pcall(function()
                    local targetModule = LoadResourceFile(GetCurrentResourceName(), 'client/target/' .. string.lower(tg.name) .. '.lua')
                    if targetModule then
                        load(targetModule)()
                        GlitchLib.Target.Type = tg.name
                        targetLoaded = true
                    else
                        error('Target module not found')
                    end
                end)
                
                if status then
                    break
                else
                    GlitchLib.Utils.DebugLog('Failed to load target system: ' .. err)
                end
            end
        end
    end
    
    -- Load door lock system
    local doorLockLoaded = false
    if Config and Config.DoorLock then
        for _, dl in ipairs(Config.DoorLock) do
            if GetResourceState(dl.resourceName) ~= 'missing' then
                GlitchLib.Utils.DebugLog('Loading door lock system: ' .. dl.name)
                
                -- Load the appropriate door lock module
                local status, err = pcall(function()
                    local doorLockModule = LoadResourceFile(GetCurrentResourceName(), 'client/doorlock/' .. string.lower(dl.name) .. '.lua')
                    if doorLockModule then
                        load(doorLockModule)()
                        GlitchLib.DoorLock.Type = dl.name
                        doorLockLoaded = true
                    else
                        error('Door lock module not found')
                    end
                end)
                
                if not status then
                    GlitchLib.Utils.DebugLog('Failed to load door lock system: ' .. err)
                end
                
                break
            end
        end
    else
        GlitchLib.Utils.DebugLog('WARNING: Config.DoorLock is missing')
    end
    
    if not doorLockLoaded then
        GlitchLib.Utils.DebugLog('No supported door lock system found')
    end
    
    -- Load progression system
    local progressionLoaded = false
    if GetResourceState('pickle_xp') ~= 'missing' then
        GlitchLib.Utils.DebugLog('Loading progression system: pickle_xp')
        
        -- Load pickle_xp module
        local status, err = pcall(function()
            local progressionModule = LoadResourceFile(GetCurrentResourceName(), 'client/progression/pickle_xp.lua')
            if progressionModule then
                load(progressionModule)()
                GlitchLib.Progression.Type = 'pickle_xp'
                progressionLoaded = true
            else
                error('Progression module not found')
            end
        end)
        
        if not status then
            GlitchLib.Utils.DebugLog('Failed to load progression system: ' .. err)
        end
    end
    
    if not progressionLoaded then
        GlitchLib.Utils.DebugLog('No supported progression system found')
    end

    -- Load notification system with proper resource checking
    local notificationLoaded = false
    
    if Config and Config.NotificationSystem ~= nil and Config.NotificationSystem ~= 'auto' then
        local notifSystem = Config.NotificationSystem
        
        local resourceName = nil
        if Config.Notifications then
            for _, notif in ipairs(Config.Notifications) do
                if notif.name == notifSystem then
                    resourceName = notif.resourceName
                    break
                end
            end
        end
        
        if resourceName and GetResourceState(resourceName) == 'started' then
            GlitchLib.Utils.DebugLog('Using configured notification system: ' .. notifSystem)
            
            local status, err = pcall(function()
                local notifModule = LoadResourceFile(GetCurrentResourceName(), 'client/notifications/' .. string.lower(notifSystem) .. '.lua')
                if notifModule then
                    load(notifModule)()
                    GlitchLib.Notifications.Type = notifSystem
                    notificationLoaded = true
                else
                    error('Notification module not found: ' .. notifSystem)
                end
            end)
            
            if not status then
                GlitchLib.Utils.DebugLog('Failed to load notification system: ' .. err)
            end
        else
            GlitchLib.Utils.DebugLog('Configured notification system ' .. notifSystem .. ' resource not available')
        end
    elseif Config and Config.Notifications then
        for _, notif in ipairs(Config.Notifications) do
            if GetResourceState(notif.resourceName) == 'started' then
                GlitchLib.Utils.DebugLog('Loading notification system: ' .. notif.name)
                
                local status, err = pcall(function()
                    local notifModule = LoadResourceFile(GetCurrentResourceName(), 'client/notifications/' .. string.lower(notif.name) .. '.lua')
                    if notifModule then
                        load(notifModule)()
                        GlitchLib.Notifications.Type = notif.name
                        notificationLoaded = true
                    else
                        error('Notification module not found: ' .. notif.name)
                    end
                end)
                
                if status then
                    break
                else
                    GlitchLib.Utils.DebugLog('Failed to load notification system: ' .. err)
                end
            end
        end
    end

    if not notificationLoaded then
        GlitchLib.Utils.DebugLog('No standalone notification system found, using framework notifications')
        
        GlitchLib.Notifications.Show = function(params)
            GlitchLib.Framework.Notify(params.description or params.message or params.title, params.type)
        end
        
        GlitchLib.Notifications.Success = function(title, message, duration)
            GlitchLib.Framework.Notify(message or title, 'success', duration)
        end
        
        GlitchLib.Notifications.Error = function(title, message, duration)
            GlitchLib.Framework.Notify(message or title, 'error', duration)
        end
        
        GlitchLib.Notifications.Info = function(title, message, duration)
            GlitchLib.Framework.Notify(message or title, 'info', duration)
        end
        
        GlitchLib.Notifications.Warning = function(title, message, duration)
            GlitchLib.Framework.Notify(message or title, 'warning', duration)
        end
        
        GlitchLib.UI.Notify = function(params)
            GlitchLib.Notifications.Show(params)
        end
        
        GlitchLib.Notifications.Type = 'framework'
        notificationLoaded = true
    end

    local status, err = pcall(function()
        local scaleformModule = LoadResourceFile(GetCurrentResourceName(), 'client/scaleform/scaleform.lua')
        if scaleformModule then
            load(scaleformModule)()
            GlitchLib.Utils.DebugLog('Scaleform module loaded')
        else
            error('Scaleform module not found, using empty functions')
        end
    end)

    if not status then
        GlitchLib.Utils.DebugLog('Failed to load scaleform module: ' .. err)
        GlitchLib.Scaleform = GlitchLib.Scaleform or {}
        GlitchLib.Scaleform.Active = {}
        GlitchLib.Scaleform.Load = function() return nil end
        GlitchLib.Scaleform.Unload = function() return false end
        GlitchLib.Scaleform.CallFunction = function() return false end
        GlitchLib.Scaleform.Render = function() return false end
        GlitchLib.Scaleform.Render3D = function() return false end
    end

    local status, err = pcall(function()
        local cutsceneModule = LoadResourceFile(GetCurrentResourceName(), 'client/cutscene/cutscene.lua')
        if cutsceneModule then
            load(cutsceneModule)()
            GlitchLib.Utils.DebugLog('Cutscene module loaded')
        else
            error('Cutscene module not found')
        end
    end)

    if not GlitchLib.UI.Notify then
        print("WARNING: Setting up emergency notification fallback")
        GlitchLib.UI.Notify = function(params)
            params = type(params) == 'table' and params or {message = tostring(params)}
            SetNotificationTextEntry('STRING')
            AddTextComponentString(params.message or params.description or "Notification")
            DrawNotification(false, true)
        end
    end
    
    GlitchLib.IsReady = frameworkLoaded
    GlitchLib.Utils.DebugLog('GlitchLib initialization complete')
    
    TriggerEvent('glitchlib:ready')
    
    return true
end

-- Initialize when resource starts
CreateThread(function()
    Wait(500)
    InitializeLibrary()
end)

-- Expose public exports
exports('GetLib', function()
    return GlitchLib
end)