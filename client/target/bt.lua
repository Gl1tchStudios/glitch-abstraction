-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading bt-target module^7")
    return false
end

-- Initialize target namespace
GlitchLib.Target = GlitchLib.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'esx' and Config.TargetSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping bt-target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
local targetResource = 'bt-target' -- or 'qtarget' depending on your ESX setup
if GetResourceState(targetResource) ~= 'started' then
    GlitchLib.Utils.DebugLog(targetResource .. ' resource is not available')
    return false
end

GlitchLib.Utils.DebugLog('ESX target module loaded')

GlitchLib.Utils.DebugLog('bt-target module loaded')

-- Add a target entity
GlitchLib.Target.AddTargetEntity = function(entities, options)
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
GlitchLib.Target.AddTargetModel = function(models, options)
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
GlitchLib.Target.AddBoxZone = function(name, center, length, width, options, targetOptions)
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

-- Add a sphere zone
GlitchLib.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
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
GlitchLib.Target.RemoveZone = function(name)
    exports['bt-target']:RemoveZone(name)
end

-- Add target for all players
GlitchLib.Target.AddGlobalPlayer = function(options)
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