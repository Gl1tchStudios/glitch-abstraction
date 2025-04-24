-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ox_target module^7")
    return false
end

-- Initialize target namespace
GlitchLib.Target = GlitchLib.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'ox' and Config.TargetSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping ox_target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_target') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_target resource is not available')
    return false
end

GlitchLib.Utils.DebugLog('ox_target module loaded')

-- Add a target entity
GlitchLib.Target.AddTargetEntity = function(entities, options)
    return exports.ox_target:addLocalEntity(entities, options)
end

-- Add a target model
GlitchLib.Target.AddTargetModel = function(models, options)
    return exports.ox_target:addModel(models, options)
end

-- Add a target zone (box, sphere, etc.)
GlitchLib.Target.AddBoxZone = function(name, center, length, width, options, targetOptions)
    local boxZone = {
        coords = center,
        size = vector3(length, width, 2.0),
        rotation = options.heading or 0.0,
        debug = options.debugPoly or false,
        options = targetOptions
    }
    return exports.ox_target:addBoxZone(boxZone)
end

-- Add a sphere zone
GlitchLib.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    local sphereZone = {
        coords = center,
        radius = radius,
        debug = options.debugPoly or false,
        options = targetOptions
    }
    return exports.ox_target:addSphereZone(sphereZone)
end

-- Remove target
GlitchLib.Target.RemoveZone = function(id)
    exports.ox_target:removeZone(id)
end

-- Add target for all players
GlitchLib.Target.AddGlobalPlayer = function(options)
    exports.ox_target:addGlobalPlayer(options)
end

-- Add target for all vehicles
GlitchLib.Target.AddGlobalVehicle = function(options)
    exports.ox_target:addGlobalVehicle(options)
end

-- Add target for all objects
GlitchLib.Target.AddGlobalObject = function(options)
    exports.ox_target:addGlobalObject(options)
end

-- Enable/disable the targeting system
GlitchLib.Target.DisableTargeting = function(state)
    exports.ox_target:disableTargeting(state)
end

-- Add a global option that appears for all entities
GlitchLib.Target.AddGlobalOption = function(options)
    return exports.ox_target:addGlobalOption(options)
end

-- Remove global options
GlitchLib.Target.RemoveGlobalOption = function(optionNames)
    exports.ox_target:removeGlobalOption(optionNames)
end

-- Add target for all peds (except players)
GlitchLib.Target.AddGlobalPed = function(options)
    exports.ox_target:addGlobalPed(options)
end

-- Remove target for all peds
GlitchLib.Target.RemoveGlobalPed = function(optionNames)
    exports.ox_target:removeGlobalPed(optionNames)
end

-- Remove target for all players
GlitchLib.Target.RemoveGlobalPlayer = function(optionNames)
    exports.ox_target:removeGlobalPlayer(optionNames)
end

-- Remove target for all vehicles
GlitchLib.Target.RemoveGlobalVehicle = function(optionNames)
    exports.ox_target:removeGlobalVehicle(optionNames)
end

-- Remove target for all objects
GlitchLib.Target.RemoveGlobalObject = function(optionNames)
    exports.ox_target:removeGlobalObject(optionNames)
end

-- Remove target model
GlitchLib.Target.RemoveTargetModel = function(models, optionNames)
    exports.ox_target:removeModel(models, optionNames)
end

-- Add a target entity by network ID
GlitchLib.Target.AddNetworkedEntity = function(netIds, options)
    return exports.ox_target:addEntity(netIds, options)
end

-- Remove a networked entity target
GlitchLib.Target.RemoveNetworkedEntity = function(netIds, optionNames)
    exports.ox_target:removeEntity(netIds, optionNames)
end

-- Remove a local entity target
GlitchLib.Target.RemoveLocalEntity = function(entities, optionNames)
    exports.ox_target:removeLocalEntity(entities, optionNames)
end

-- Add a polygon zone
GlitchLib.Target.AddPolyZone = function(name, points, options, targetOptions)
    local polyZone = {
        points = points,
        name = name,
        thickness = options.height or options.thickness or 4.0,
        debug = options.debugPoly or false,
        drawSprite = options.drawSprite,
        options = targetOptions
    }
    return exports.ox_target:addPolyZone(polyZone)
end

-- Add aliases for consistency with other naming conventions
GlitchLib.Target.AddBoxTarget = GlitchLib.Target.AddBoxZone
GlitchLib.Target.AddSphereTarget = GlitchLib.Target.AddSphereZone
GlitchLib.Target.AddPolyTarget = GlitchLib.Target.AddPolyZone
GlitchLib.Target.RemoveTarget = GlitchLib.Target.RemoveZone