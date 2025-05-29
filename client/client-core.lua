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
        print('[GlitchAbst] ' .. message)
    end
end

local hasInitialized = false

local function InitializeLibrary()
    -- Check if already initialized and exit early
    if hasInitialized then
        GlitchAbst.Utils.DebugLog('GlitchAbst already initialized, skipping duplicate initialization')
        return false
    end
    
    hasInitialized = true
    GlitchAbst.Utils.DebugLog('Initializing GlitchAbst client...')
    
    -- Load framework support with nil check
    local frameworkLoaded = false
    if Config and Config.Framework then
        for _, fw in ipairs(Config.Framework) do
            if GetResourceState(fw.resourceName) ~= 'missing' then
                local frameworkName = fw.name
                GlitchAbst.Utils.DebugLog('Detected framework: ' .. frameworkName)
                
                local implementationName = frameworkName
                if Config.FrameworkMapping and Config.FrameworkMapping[frameworkName] then
                    implementationName = Config.FrameworkMapping[frameworkName]
                    GlitchAbst.Utils.DebugLog('Using implementation: ' .. implementationName)
                end
                
                -- Load the framework module
                local status, result = pcall(function()
                    local frameworkModule = LoadResourceFile(GetCurrentResourceName(), 'client/framework/' .. string.lower(implementationName) .. '.lua')
                    if frameworkModule then
                        local loadedModule = load(frameworkModule)
                        if loadedModule then
                            local success = loadedModule()
                            if success then
                                GlitchAbst.Framework.Type = frameworkName
                                frameworkLoaded = true
                                return true
                            end
                        end
                    end
                    error('Failed to load framework module')
                end)
                
                if status and result then
                    GlitchAbst.Utils.DebugLog('Framework loaded successfully')
                    break
                else
                    GlitchAbst.Utils.DebugLog('Failed to load framework: ' .. tostring(result))
                end
            end
        end
    else
        GlitchAbst.Utils.DebugLog('WARNING: Config.Framework is missing')
    end

    if not frameworkLoaded then
        GlitchAbst.Utils.DebugLog('No supported framework found')
    end

    -- Load UI system with nil check
    local uiLoaded = false
    local uiSystem = GlitchAbst.UISystem or 'native'

    GlitchAbst.Utils.DebugLog('Loading UI system: ' .. uiSystem)

    local status, err = pcall(function()
        local uiModule = LoadResourceFile(GetCurrentResourceName(), 'client/ui/' .. string.lower(uiSystem) .. '.lua')
        if uiModule then
            load(uiModule)()
            GlitchAbst.UI.Type = uiSystem
            uiLoaded = true
        else
            error('UI module not found: ' .. uiSystem)
        end
    end)

    if not status then
        GlitchAbst.Utils.DebugLog('Failed to load UI system: ' .. err)
        
        if uiSystem ~= 'ox' and GetResourceState('ox_lib') == 'started' then
            GlitchAbst.Utils.DebugLog('Attempting fallback to ox_lib UI')
            
            local fallbackStatus, fallbackErr = pcall(function()
                local oxModule = LoadResourceFile(GetCurrentResourceName(), 'client/ui/ox.lua')
                if oxModule then
                    load(oxModule)()
                    GlitchAbst.UI.Type = 'ox'
                    uiLoaded = true
                else
                    error('Fallback UI module not found')
                end
            end)
            
            if not fallbackStatus then
                GlitchAbst.Utils.DebugLog('Fallback to ox_lib UI failed: ' .. fallbackErr)
            end
        end
    end

    if not uiLoaded then
        GlitchAbst.Utils.DebugLog('WARNING: No UI system loaded, using basic native UI')
        
        -- Define basic native UI functions as fallback
        GlitchAbst.UI.ShowNotification = function(message)
            SetNotificationTextEntry('STRING')
            AddTextComponentString(message)
            DrawNotification(false, true)
        end
        
        GlitchAbst.UI.Type = 'native'
    end
    
    local targetLoaded = false
    if Config and Config.Target then
        for _, tg in ipairs(Config.Target) do
            if GetResourceState(tg.resourceName) == 'started' then
                GlitchAbst.Utils.DebugLog('Loading target system: ' .. tg.name)
                
                local status, err = pcall(function()
                    local targetModule = LoadResourceFile(GetCurrentResourceName(), 'client/target/' .. string.lower(tg.name) .. '.lua')
                    if targetModule then
                        load(targetModule)()
                        GlitchAbst.Target.Type = tg.name
                        targetLoaded = true
                    else
                        error('Target module not found')
                    end
                end)
                
                if status then
                    break
                else
                    GlitchAbst.Utils.DebugLog('Failed to load target system: ' .. err)
                end
            end
        end
    end
    
    -- Load door lock system
    local doorLockLoaded = false
    if Config and Config.DoorLock then
        for _, dl in ipairs(Config.DoorLock) do
            if GetResourceState(dl.resourceName) ~= 'missing' then
                GlitchAbst.Utils.DebugLog('Loading door lock system: ' .. dl.name)
                
                -- Load the appropriate door lock module
                local status, err = pcall(function()
                    local doorLockModule = LoadResourceFile(GetCurrentResourceName(), 'client/doorlock/' .. string.lower(dl.name) .. '.lua')
                    if doorLockModule then
                        load(doorLockModule)()
                        GlitchAbst.DoorLock.Type = dl.name
                        doorLockLoaded = true
                    else
                        error('Door lock module not found')
                    end
                end)
                
                if not status then
                    GlitchAbst.Utils.DebugLog('Failed to load door lock system: ' .. err)
                end
                
                break
            end
        end
    else
        GlitchAbst.Utils.DebugLog('WARNING: Config.DoorLock is missing')
    end
    
    if not doorLockLoaded then
        GlitchAbst.Utils.DebugLog('No supported door lock system found')
    end
    
    -- Load progression system
    local progressionLoaded = false
    if GetResourceState('pickle_xp') ~= 'missing' then
        GlitchAbst.Utils.DebugLog('Loading progression system: pickle_xp')
        
        -- Load pickle_xp module
        local status, err = pcall(function()
            local progressionModule = LoadResourceFile(GetCurrentResourceName(), 'client/progression/pickle_xp.lua')
            if progressionModule then
                load(progressionModule)()
                GlitchAbst.Progression.Type = 'pickle_xp'
                progressionLoaded = true
            else
                error('Progression module not found')
            end
        end)
        
        if not status then
            GlitchAbst.Utils.DebugLog('Failed to load progression system: ' .. err)
        end
    end
    
    if not progressionLoaded then
        GlitchAbst.Utils.DebugLog('No supported progression system found')
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
            GlitchAbst.Utils.DebugLog('Using configured notification system: ' .. notifSystem)
            
            local status, err = pcall(function()
                local notifModule = LoadResourceFile(GetCurrentResourceName(), 'client/notifications/' .. string.lower(notifSystem) .. '.lua')
                if notifModule then
                    load(notifModule)()
                    GlitchAbst.Notifications.Type = notifSystem
                    notificationLoaded = true
                else
                    error('Notification module not found: ' .. notifSystem)
                end
            end)
            
            if not status then
                GlitchAbst.Utils.DebugLog('Failed to load notification system: ' .. err)
            end
        else
            GlitchAbst.Utils.DebugLog('Configured notification system ' .. notifSystem .. ' resource not available')
        end
    elseif Config and Config.Notifications then
        for _, notif in ipairs(Config.Notifications) do
            if GetResourceState(notif.resourceName) == 'started' then
                GlitchAbst.Utils.DebugLog('Loading notification system: ' .. notif.name)
                
                local status, err = pcall(function()
                    local notifModule = LoadResourceFile(GetCurrentResourceName(), 'client/notifications/' .. string.lower(notif.name) .. '.lua')
                    if notifModule then
                        load(notifModule)()
                        GlitchAbst.Notifications.Type = notif.name
                        notificationLoaded = true
                    else
                        error('Notification module not found: ' .. notif.name)
                    end
                end)
                
                if status then
                    break
                else
                    GlitchAbst.Utils.DebugLog('Failed to load notification system: ' .. err)
                end
            end
        end
    end

    if not notificationLoaded then
        GlitchAbst.Utils.DebugLog('No standalone notification system found, using framework notifications')
        
        GlitchAbst.Notifications.Show = function(params)
            GlitchAbst.Framework.Notify(params.description or params.message or params.title, params.type)
        end
        
        GlitchAbst.Notifications.Success = function(title, message, duration)
            GlitchAbst.Framework.Notify(message or title, 'success', duration)
        end
        
        GlitchAbst.Notifications.Error = function(title, message, duration)
            GlitchAbst.Framework.Notify(message or title, 'error', duration)
        end
        
        GlitchAbst.Notifications.Info = function(title, message, duration)
            GlitchAbst.Framework.Notify(message or title, 'info', duration)
        end
        
        GlitchAbst.Notifications.Warning = function(title, message, duration)
            GlitchAbst.Framework.Notify(message or title, 'warning', duration)
        end
        
        GlitchAbst.UI.Notify = function(params)
            GlitchAbst.Notifications.Show(params)
        end
        
        GlitchAbst.Notifications.Type = 'framework'
        notificationLoaded = true
    end

    local status, err = pcall(function()
        local scaleformModule = LoadResourceFile(GetCurrentResourceName(), 'client/scaleform/scaleform.lua')
        if scaleformModule then
            load(scaleformModule)()
            GlitchAbst.Utils.DebugLog('Scaleform module loaded')
        else
            error('Scaleform module not found, using empty functions')
        end
    end)

    if not status then
        GlitchAbst.Utils.DebugLog('Failed to load scaleform module: ' .. err)
        GlitchAbst.Scaleform = GlitchAbst.Scaleform or {}
        GlitchAbst.Scaleform.Active = {}
        GlitchAbst.Scaleform.Load = function() return nil end
        GlitchAbst.Scaleform.Unload = function() return false end
        GlitchAbst.Scaleform.CallFunction = function() return false end
        GlitchAbst.Scaleform.Render = function() return false end
        GlitchAbst.Scaleform.Render3D = function() return false end
    end

    local status, err = pcall(function()
        local cutsceneModule = LoadResourceFile(GetCurrentResourceName(), 'client/cutscene/cutscene.lua')
        if cutsceneModule then
            load(cutsceneModule)()
            GlitchAbst.Utils.DebugLog('Cutscene module loaded')
        else
            error('Cutscene module not found')
        end
    end)

    if not GlitchAbst.UI.Notify then
        print("WARNING: Setting up emergency notification fallback")
        GlitchAbst.UI.Notify = function(params)
            params = type(params) == 'table' and params or {message = tostring(params)}
            SetNotificationTextEntry('STRING')
            AddTextComponentString(params.message or params.description or "Notification")
            DrawNotification(false, true)
        end
    end
    
    GlitchAbst.IsReady = frameworkLoaded
    GlitchAbst.Utils.DebugLog('GlitchAbst initialization complete')
    
    TriggerEvent('GlitchAbst:ready')
    
    return true
end

-- Initialize when resource starts
CreateThread(function()
    Wait(500)
    InitializeLibrary()
end)

-- Expose public exports
exports('getAbstraction', function()
    return GlitchAbst
end)