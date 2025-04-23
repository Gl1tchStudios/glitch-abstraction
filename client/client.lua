local function InitializeLibrary()
    GlitchLib.Utils.DebugLog('Initializing GlitchLib client...')
    
    -- Load framework
    local frameworkLoaded = false
    for _, fw in ipairs(Config.Framework) do
        if GetResourceState(fw.resourceName) ~= 'missing' then
            local frameworkName = fw.name
            GlitchLib.Utils.DebugLog('Detected framework: ' .. frameworkName)
            
            local implementationName = frameworkName
            if GetResourceState('qbox-core') ~= 'missing' and frameworkName == 'QBCore' then
                GlitchLib.Utils.DebugLog('QBox detected, using QBCore implementation')
                frameworkName = 'QBox'
                implementationName = 'QBCore'
            elseif Config.FrameworkMapping[frameworkName] then
                implementationName = Config.FrameworkMapping[frameworkName]
                GlitchLib.Utils.DebugLog('Using ' .. implementationName .. ' implementation for ' .. frameworkName)
            end
            
            -- Load the appropriate framework module
            local status, err = pcall(function()
                local frameworkModule = LoadResourceFile(GetCurrentResourceName(), 'client/framework/' .. string.lower(implementationName) .. '.lua')
                if frameworkModule then
                    load(frameworkModule)()
                    GlitchLib.Framework.Type = frameworkName
                    frameworkLoaded = true
                else
                    error('Framework module not found')
                end
            end)
            
            if not status then
                GlitchLib.Utils.DebugLog('Failed to load framework: ' .. err)
            end
            
            break
        end
    end
    
    if not frameworkLoaded then
        GlitchLib.Utils.DebugLog('No supported framework found!')
    end
    
    -- Load UI system
    local uiLoaded = false
    local status, err = pcall(function()
        local uiModule = LoadResourceFile(GetCurrentResourceName(), 'client/ui/' .. string.lower(Config.UISystem) .. '.lua')
        if uiModule then
            load(uiModule)()
            uiLoaded = true
        else
            error('UI module not found')
        end
    end)
    
    if not status then
        GlitchLib.Utils.DebugLog('Failed to load UI system: ' .. err)
    end
    
    -- Load target system
    local targetLoaded = false
    for _, tg in ipairs(Config.Target) do
        if GetResourceState(tg.resourceName) ~= 'missing' then
            GlitchLib.Utils.DebugLog('Loading target system: ' .. tg.name)
            -- Load the appropriate target module
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
            
            if not status then
                GlitchLib.Utils.DebugLog('Failed to load target system: ' .. err)
            end
            
            break
        end
    end
    
    -- Load door lock system
    local doorLockLoaded = false
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

    -- Load notification system
    local notificationLoaded = false

    -- First check if config specifies a system
    if Config.NotificationSystem ~= 'auto' then
        local notifSystem = Config.NotificationSystem
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
        -- Auto-detect notification system
        for _, notif in ipairs(Config.Notifications) do
            if GetResourceState(notif.resourceName) ~= 'missing' then
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
                
                if not status then
                    GlitchLib.Utils.DebugLog('Failed to load notification system: ' .. err)
                end
                
                break
            end
        end
    end

    if not notificationLoaded then
        -- Fallback to framework notifications
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
        
        -- For backward compatibility
        GlitchLib.UI.Notify = function(params)
            GlitchLib.Notifications.Show(params)
        end
        
        GlitchLib.Notifications.Type = 'framework'
        notificationLoaded = true
    end

    -- Load scaleform module
    local status, err = pcall(function()
        local scaleformModule = LoadResourceFile(GetCurrentResourceName(), 'client/scaleform.lua')
        if scaleformModule then
            load(scaleformModule)()
            GlitchLib.Utils.DebugLog('Scaleform module loaded')
        else
            error('Scaleform module not found')
        end
    end)

    if not status then
        GlitchLib.Utils.DebugLog('Failed to load scaleform module: ' .. err)
    end
    
    GlitchLib.IsReady = frameworkLoaded
    GlitchLib.Utils.DebugLog('GlitchLib initialization complete')
    
    -- Trigger event to notify that the library is ready
    TriggerEvent('glitchlib:ready')
end

-- Initialize when resource starts
CreateThread(function()
    Wait(500) -- Give other resources time to load
    InitializeLibrary()
end)

-- Expose public exports
exports('GetLib', function()
    return GlitchLib
end)