local function InitializeLibrary()
    GlitchLib.Utils.DebugLog('Initializing GlitchLib server...')
    
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
                local frameworkModule = LoadResourceFile(GetCurrentResourceName(), 'server/framework/' .. string.lower(implementationName) .. '.lua')
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
    
    local inventoryLoaded = false
    for _, inv in ipairs(Config.Inventory) do
        if GetResourceState(inv.resourceName) ~= 'missing' then
            GlitchLib.Utils.DebugLog('Loading inventory system: ' .. inv.name)
            
            local status, err = pcall(function()
                local invModule = LoadResourceFile(GetCurrentResourceName(), 'server/inventory/' .. string.lower(inv.name) .. '.lua')
                if invModule then
                    load(invModule)()
                    GlitchLib.Inventory.Type = inv.name
                    inventoryLoaded = true
                else
                    error('Inventory module not found')
                end
            end)
            
            if not status then
                GlitchLib.Utils.DebugLog('Failed to load inventory system: ' .. err)
            end
            
            break
        end
    end
    
    -- Load progression system
    local progressionLoaded = false
    if GetResourceState('pickle_xp') ~= 'missing' then
        GlitchLib.Utils.DebugLog('Loading progression system: pickle_xp')
        
        -- Load pickle_xp module
        local status, err = pcall(function()
            local progressionModule = LoadResourceFile(GetCurrentResourceName(), 'server/progression/pickle_xp.lua')
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

    -- Load door lock system
    local doorLockLoaded = false
    for _, dl in ipairs(Config.DoorLock) do
        if GetResourceState(dl.resourceName) ~= 'missing' then
            GlitchLib.Utils.DebugLog('Loading door lock system: ' .. dl.name)
            
            -- Load the appropriate door lock module
            local status, err = pcall(function()
                local doorLockModule = LoadResourceFile(GetCurrentResourceName(), 'server/doorlock/' .. string.lower(dl.name) .. '.lua')
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
    
    GlitchLib.IsReady = frameworkLoaded and inventoryLoaded
    GlitchLib.Utils.DebugLog('GlitchLib server initialization complete')
    
    TriggerEvent('glitchlib:ready')
end

CreateThread(function()
    Wait(500)
    InitializeLibrary()
end)

exports('GetLib', function()
    return GlitchLib
end)