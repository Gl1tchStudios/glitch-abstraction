-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading bt-target module^7")
    return false
end

-- Initialize target namespace
GlitchAbst.Target = GlitchAbst.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'esx' and Config.TargetSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping bt-target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
local targetResource = 'bt-target' -- or 'qtarget' depending on your ESX setup
if GetResourceState(targetResource) ~= 'started' then
    GlitchAbst.Utils.DebugLog(targetResource .. ' resource is not available')
    return false
end

GlitchAbst.Utils.DebugLog('ESX target module loaded')

GlitchAbst.Utils.DebugLog('bt-target module loaded')

-- Add a target entity
GlitchAbst.Target.AddTargetEntity = function(entities, options)
    -- bt-target has different structure
    for _, entity in pairs(entities) do
        for _, option in pairs(options) do
            exports['bt-target']:AddTargetEntity(entity, {
                options = {
                    {
                        label = option.label,
                        icon = option.icon,
                        action = option.action,
                        canInteract = option.canInteract,
                        job = option.job
                    }
                },
                distance = option.distance or 2.5
            })
        end
    end
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    -- Transform options to bt-target format
    local btOptions = {}
    for _, option in pairs(options) do
        table.insert(btOptions, {
            label = option.label,
            icon = option.icon,
            action = option.action,
            canInteract = option.canInteract,
            job = option.job
        })
    end
    
    return exports['bt-target']:AddTargetModel(models, {
        options = btOptions,
        distance = options[1].distance or 2.5
    })
end

-- Add a box zone
GlitchAbst.Target.AddBoxZone = function(name, center, length, width, options, targetOptions)
    -- Transform options to bt-target format
    local btOptions = {}

    if not center and not length and not width and not options and not targetOptions then -- fixes issue of using AddBoxZone({parameters}) for ox
        center = name.coords
        length = name.size.x
        width = name.size.x
        options = {
            heading = nil,
            debugPoly = name.debug
        }
        targetOptions = name.options
    else
        for _, option in pairs(targetOptions) do
            table.insert(btOptions, {
                label = option.label,
                icon = option.icon,
                action = option.action,
                canInteract = option.canInteract,
                job = option.job
            })
        end
    end
    
    return exports['bt-target']:AddBoxZone(name, center, length, width, {
        name = name,
        heading = options.heading or 0.0,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = btOptions,
        distance = targetOptions[1].distance or 2.5
    })
end

-- BT Target Implementation for GlitchAbst
-- This file handles the BT target system

-- Initialize GlitchAbst and Target namespace if they don't exist
GlitchAbst = GlitchAbst or {}
GlitchAbst.Target = GlitchAbst.Target or {}

-- Check if bt-target resource is running
if GetResourceState('bt-target') ~= 'started' then
    return
end

-- Register the BT Target implementation
GlitchAbst.Target.AddBoxZone = function(arg1, arg2, arg3, arg4, arg5, arg6)
    local name, center, length, width, options, targetOptions
    
    if type(arg1) == 'table' then
        -- Handle table-style input (from ox format)
        local params = arg1
        name = params.name
        center = params.coords
        
        if type(params.size) == 'vector3' then
            length = params.size.x
            width = params.size.y
        else
            length = params.size
            width = params.size
        end
        
        options = {
            heading = params.rotation,
            debugPoly = params.debug,
            minZ = params.minZ,
            maxZ = params.maxZ
        }
        
        targetOptions = params.options
        
        if targetOptions and not targetOptions[1] and type(targetOptions) == 'table' then
            targetOptions = {targetOptions}
        end
    else
        name = arg1
        center = arg2
        length = arg3
        width = arg4
        options = arg5 or {}
        targetOptions = arg6
    end

    local btOptions = {}
    
    if targetOptions then
        for i, option in pairs(type(targetOptions) == 'table' and targetOptions or {}) do
            table.insert(btOptions, {
                label = option.label,
                icon = option.icon,
                action = option.onSelect or option.action, -- Support both naming conventions
                canInteract = option.canInteract,
                job = option.job
            })
        end
    end
    
    local distance = 2.5 
    if targetOptions then
        if type(targetOptions) == 'table' then
            if targetOptions.distance then
                distance = targetOptions.distance
            elseif targetOptions[1] and targetOptions[1].distance then
                distance = targetOptions[1].distance
            end
        end
    end
    
    return exports['bt-target']:AddBoxZone(name, center, length, width, {
        name = name,
        heading = options.heading or 0.0,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = btOptions,
        distance = distance
    })
end

-- Add a sphere zone
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    -- Transform options to bt-target format
    local btOptions = {}
    for _, option in pairs(targetOptions) do
        table.insert(btOptions, {
            label = option.label,
            icon = option.icon,
            action = option.action,
            canInteract = option.canInteract,
            job = option.job
        })
    end
    
    return exports['bt-target']:AddSphereZone(name, center, radius, {
        name = name,
        debugPoly = options.debugPoly or false
    }, {
        options = btOptions,
        distance = targetOptions[1].distance or 2.5
    })
end

-- Remove zone
GlitchAbst.Target.RemoveZone = function(name)
    exports['bt-target']:RemoveZone(name)
end

-- Add target for all players
GlitchAbst.Target.AddGlobalPlayer = function(options)
    -- Transform options to bt-target format
    local btOptions = {}
    for _, option in pairs(options) do
        table.insert(btOptions, {
            label = option.label,
            icon = option.icon,
            action = option.action,
            canInteract = option.canInteract,
            job = option.job
        })
    end
    
    exports['bt-target']:AddGlobalPlayer({
        options = btOptions,
        distance = options[1].distance or 2.5
    })
end