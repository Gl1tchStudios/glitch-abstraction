-- Make sure GlitchAbst is initialized
if GlitchAbst == nil then
    print('[ERROR] GlitchAbst initialization failed in shared scripts - attempting emergency initialization')
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
        Database = {},
        Utils = {},
        IsReady = false
    }
    
    -- Add emergency debug function
    GlitchAbst.Utils.DebugLog = function(message)
        print('[GlitchAbst] ' .. message)
    end
end

-- Utility function to check if a resource is actually available
local function IsResourceAvailable(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started'
end

-- Export handling function with better error handling
local function GetResourceExport(resourceName, exportNames)
    if not IsResourceAvailable(resourceName) then
        GlitchAbst.Utils.DebugLog('Resource not available: ' .. resourceName)
        return nil
    end
    
    for _, exportName in ipairs(exportNames) do
        local success, result = pcall(function()
            return exports[resourceName][exportName]()
        end)
        
        if success and result then
            GlitchAbst.Utils.DebugLog('Successfully loaded export ' .. resourceName .. ':' .. exportName)
            return result
        end
    end
    
    GlitchAbst.Utils.DebugLog('Failed to find valid export in ' .. resourceName)
    return nil
end

-- Function to detect available resources and their versions
local function DetectResources()
    GlitchAbst.Utils.DebugLog('Detecting available resources...')
    
    local available = {
        frameworks = {},
        inventories = {},
        doorlocks = {},
        targets = {},
        progression = {}
    }
    
    -- Check frameworks
    for _, fw in ipairs(Config.Framework) do
        if IsResourceAvailable(fw.resourceName) then
            table.insert(available.frameworks, {
                name = fw.name,
                resourceName = fw.resourceName
            })
            GlitchAbst.Utils.DebugLog('Detected framework: ' .. fw.name)
        end
    end
    
    -- Check inventory systems
    for _, inv in ipairs(Config.Inventory or {}) do
        if IsResourceAvailable(inv.resourceName) then
            table.insert(available.inventories, {
                name = inv.name,
                resourceName = inv.resourceName
            })
            GlitchAbst.Utils.DebugLog('Detected inventory: ' .. inv.name)
        end
    end
    
    -- Check door lock systems
    for _, dl in ipairs(Config.DoorLock or {}) do
        if IsResourceAvailable(dl.resourceName) then
            local shouldInclude = true
            
            if dl.name == "qb" and not IsResourceAvailable('qb-core') then
                shouldInclude = false
            end
            
            if dl.name == "esx" and not IsResourceAvailable('es_extended') then
                shouldInclude = false
            end
            
            if shouldInclude then
                table.insert(available.doorlocks, {
                    name = dl.name,
                    resourceName = dl.resourceName
                })
            end
        end
    end
    
    -- Check target systems
    for _, target in ipairs(Config.Target or {}) do
        if IsResourceAvailable(target.resourceName) then
            table.insert(available.targets, {
                name = target.name,
                resourceName = target.resourceName
            })
            GlitchAbst.Utils.DebugLog('Detected target system: ' .. target.name)
        end
    end
    
    -- Check progression system
    if IsResourceAvailable('pickle_xp') then
        table.insert(available.progression, {
            name = 'pickle_xp',
            resourceName = 'pickle_xp'
        })
        GlitchAbst.Utils.DebugLog('Detected progression system: pickle_xp')
    end
    
    return available
end

-- Initialize the library with detected resources
local function InitializeLibrary()
    -- Print initialization header
    print("^2╔════════════════════════════════════════════╗^7")
    print("^2║             GLITCH LIB LOADING             ║^7")
    print("^2╚════════════════════════════════════════════╝^7")
    
    -- Detect available resources
    local available = DetectResources()
    
    -- Initialize framework
    local frameworkLoaded = false
    if #available.frameworks > 0 then
        local fw = available.frameworks[1] -- Use the first detected framework
        local frameworkName = fw.name
        
        local implementationName = frameworkName
        if Config.FrameworkMapping and Config.FrameworkMapping[frameworkName] then
            implementationName = Config.FrameworkMapping[frameworkName]
            GlitchAbst.Utils.DebugLog('Using ' .. implementationName .. ' implementation for ' .. frameworkName)
        end
        
        -- Load the appropriate framework module
        GlitchAbst.Utils.DebugLog('Loading framework module: ' .. string.lower(implementationName))
        
        local status, err = pcall(function()
            local frameworkModule = LoadResourceFile(GetCurrentResourceName(), 'server/framework/' .. string.lower(implementationName) .. '.lua')
            if frameworkModule then
                local fn, loadErr = load(frameworkModule)
                if fn then
                    fn() -- Execute the module
                    GlitchAbst.Framework.Type = frameworkName
                    frameworkLoaded = true
                else
                    error('Failed to load framework module: ' .. (loadErr or 'Unknown error'))
                end
            else
                error('Framework module file not found: server/framework/' .. string.lower(implementationName) .. '.lua')
            end
        end)
        
        if not status then
            GlitchAbst.Utils.DebugLog('Failed to load framework: ' .. err)
        else
            GlitchAbst.Utils.DebugLog('Successfully loaded framework: ' .. frameworkName)
        end
    end
    
    if not frameworkLoaded then
        GlitchAbst.Utils.DebugLog('No supported framework found or failed to load!')
    end
    
    -- Only initialize other systems if a framework was loaded successfully
    if frameworkLoaded then
        -- Initialize inventory system
        local inventoryLoaded = false
        if #available.inventories > 0 then
            local inv = available.inventories[1] -- Use the first detected inventory
            
            GlitchAbst.Utils.DebugLog('Loading inventory module: ' .. string.lower(inv.name))
            
            local status, err = pcall(function()
                local invModule = LoadResourceFile(GetCurrentResourceName(), 'server/inventory/' .. string.lower(inv.name) .. '.lua')
                if invModule then
                    local fn, loadErr = load(invModule)
                    if fn then
                        fn() -- Execute the module
                        GlitchAbst.Inventory.Type = inv.name
                        inventoryLoaded = true
                    else
                        error('Failed to load inventory module: ' .. (loadErr or 'Unknown error'))
                    end
                else
                    error('Inventory module file not found: server/inventory/' .. string.lower(inv.name) .. '.lua')
                end
            end)
            
            if not status then
                GlitchAbst.Utils.DebugLog('Failed to load inventory system: ' .. err)
            else
                GlitchAbst.Utils.DebugLog('Successfully loaded inventory: ' .. inv.name)
            end
        end
        
        -- Load progression system
        local progressionLoaded = false
        if #available.progression > 0 then
            local prog = available.progression[1]
            
            GlitchAbst.Utils.DebugLog('Loading progression module: ' .. string.lower(prog.name))
            
            local status, err = pcall(function()
                local progressionModule = LoadResourceFile(GetCurrentResourceName(), 'server/progression/' .. string.lower(prog.name) .. '.lua')
                if progressionModule then
                    local fn, loadErr = load(progressionModule)
                    if fn then
                        fn() -- Execute the module
                        GlitchAbst.Progression.Type = prog.name
                        progressionLoaded = true
                    else
                        error('Failed to load progression module: ' .. (loadErr or 'Unknown error'))
                    end
                else
                    error('Progression module file not found: server/progression/' .. string.lower(prog.name) .. '.lua')
                end
            end)
            
            if not status then
                GlitchAbst.Utils.DebugLog('Failed to load progression system: ' .. err)
            else
                GlitchAbst.Utils.DebugLog('Successfully loaded progression system: ' .. prog.name)
            end
        end
    
        -- Load door lock system
        local doorLockLoaded = false
        if #available.doorlocks > 0 then
            local dl = available.doorlocks[1] -- Use the first detected door lock system
            
            GlitchAbst.Utils.DebugLog('Loading door lock module: ' .. string.lower(dl.name))
            
            local status, err = pcall(function()
                local doorLockModule = LoadResourceFile(GetCurrentResourceName(), 'server/doorlock/' .. string.lower(dl.name) .. '.lua')
                if doorLockModule then
                    local fn, loadErr = load(doorLockModule)
                    if fn then
                        fn() -- Execute the module
                        GlitchAbst.DoorLock.Type = dl.name
                        doorLockLoaded = true
                    else
                        error('Failed to load door lock module: ' .. (loadErr or 'Unknown error'))
                    end
                else
                    error('Door lock module file not found: server/doorlock/' .. string.lower(dl.name) .. '.lua')
                end
            end)
            
            if not status then
                GlitchAbst.Utils.DebugLog('Failed to load door lock system: ' .. err)
            else
                GlitchAbst.Utils.DebugLog('Successfully loaded door lock system: ' .. dl.name)
            end
        end
    end
    
    GlitchAbst.IsReady = frameworkLoaded
    
    print("^2╔════════════════════════════════════════════╗^7")
    print("^2║           GLITCH LIB LOADED: " .. (GlitchAbst.IsReady and "^2YES" or "^1NO ") .. "           ║^7")
    print("^2╚════════════════════════════════════════════╝^7")
    
    TriggerEvent('GlitchAbst:ready', GlitchAbst.IsReady)
end

-- Wait a moment for other resources to start
CreateThread(function()
    Wait(1000) -- Allow time for other resources to initialize
    InitializeLibrary()
end)

-- Export the library
exports('getAbstraction', function()
    return GlitchAbst
end)


