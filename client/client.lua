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