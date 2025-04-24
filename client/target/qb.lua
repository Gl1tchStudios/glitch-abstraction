-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading qb-target module^7")
    return false
end

-- Initialize target namespace
GlitchLib.Target = GlitchLib.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'qb' and Config.TargetSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping qb-target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-target') ~= 'started' then
    GlitchLib.Utils.DebugLog('qb-target resource is not available')
    return false
end

GlitchLib.Utils.DebugLog('qb-target module loaded')

-- Add a target entity
GlitchLib.Target.AddTargetEntity = function(entities, options)
    return exports['qb-target']:AddTargetEntity(entities, {
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add a target model
GlitchLib.Target.AddTargetModel = function(models, options)
    return exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add a box zone
GlitchLib.Target.AddBoxZone = function(name, center, length, width, options, targetOptions)
    return exports['qb-target']:AddBoxZone(name, center, length, width, {
        name = name,
        heading = options.heading or 0.0,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = targetOptions,
        distance = targetOptions[1].distance or 2.5
    })
end

-- Add a sphere zone
GlitchLib.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    return exports['qb-target']:AddSphereZone(name, center, radius, {
        name = name,
        debugPoly = options.debugPoly or false
    }, {
        options = targetOptions,
        distance = targetOptions[1].distance or 2.5
    })
end

-- Remove zone
GlitchLib.Target.RemoveZone = function(name)
    exports['qb-target']:RemoveZone(name)
end

-- Add target for all players
GlitchLib.Target.AddGlobalPlayer = function(options)
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add target for all vehicles
GlitchLib.Target.AddGlobalVehicle = function(options)
    exports['qb-target']:AddGlobalVehicle({
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add target for all objects
GlitchLib.Target.AddGlobalObject = function(options)
    exports['qb-target']:AddGlobalObject({
        options = options,
        distance = options[1].distance or 2.5
    })
end