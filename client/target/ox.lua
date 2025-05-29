-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ox_target module^7")
    return false
end

-- Initialize target namespace
GlitchAbst.Target = GlitchAbst.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'ox' and Config.TargetSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ox_target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_target') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_target resource is not available')
    return false
end

GlitchAbst.Utils.DebugLog('ox_target module loaded')

-- Add a target entity
GlitchAbst.Target.AddTargetEntity = function(entities, options)
    return exports.ox_target:addLocalEntity(entities, options)
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    return exports.ox_target:addModel(models, options)
end

-- Add a target zones                  name, center, length, width, opt, targetoptions
GlitchAbst.Target.AddBoxZone = function(arg1, arg2, arg3, arg4, arg5, arg6)
    if type(arg1) == 'table' then
        local options = arg1
        return exports.ox_target:addBoxZone(options)
    end
    
    local name = arg1
    local center = arg2
    local length = arg3
    local width = arg4
    local options = arg5 or {}
    local targetOptions = arg6
    
    local boxZone = {
        name = name,
        coords = center,
        size = type(length) == 'vector3' and length or vector3(length, width, 2.0),
        rotation = options.heading or 0.0,
        debug = options.debugPoly or false,
        options = targetOptions
    }
    
    return exports.ox_target:addBoxZone(boxZone)
end


-- Add a sphere zone
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    local sphereZone = {
        coords = center,
        radius = radius,
        debug = options.debugPoly or false,
        options = targetOptions
    }
    return exports.ox_target:addSphereZone(sphereZone)
end

-- Remove target
GlitchAbst.Target.RemoveZone = function(id)
    exports.ox_target:removeZone(id)
end

-- Add target for all players
GlitchAbst.Target.AddGlobalPlayer = function(options)
    exports.ox_target:addGlobalPlayer(options)
end

-- Add target for all vehicles
GlitchAbst.Target.AddGlobalVehicle = function(options)
    exports.ox_target:addGlobalVehicle(options)
end

-- Add target for all objects
GlitchAbst.Target.AddGlobalObject = function(options)
    exports.ox_target:addGlobalObject(options)
end

-- Enable/disable the targeting system
GlitchAbst.Target.DisableTargeting = function(state)
    exports.ox_target:disableTargeting(state)
end

-- Add a global option that appears for all entities
GlitchAbst.Target.AddGlobalOption = function(options)
    return exports.ox_target:addGlobalOption(options)
end

-- Remove global options
GlitchAbst.Target.RemoveGlobalOption = function(optionNames)
    exports.ox_target:removeGlobalOption(optionNames)
end

-- Add target for all peds (except players)
GlitchAbst.Target.AddGlobalPed = function(options)
    exports.ox_target:addGlobalPed(options)
end

-- Remove target for all peds
GlitchAbst.Target.RemoveGlobalPed = function(optionNames)
    exports.ox_target:removeGlobalPed(optionNames)
end

-- Remove target for all players
GlitchAbst.Target.RemoveGlobalPlayer = function(optionNames)
    exports.ox_target:removeGlobalPlayer(optionNames)
end

-- Remove target for all vehicles
GlitchAbst.Target.RemoveGlobalVehicle = function(optionNames)
    exports.ox_target:removeGlobalVehicle(optionNames)
end

-- Remove target for all objects
GlitchAbst.Target.RemoveGlobalObject = function(optionNames)
    exports.ox_target:removeGlobalObject(optionNames)
end

-- Remove target model
GlitchAbst.Target.RemoveTargetModel = function(models, optionNames)
    exports.ox_target:removeModel(models, optionNames)
end

-- Add a target entity by network ID
GlitchAbst.Target.AddNetworkedEntity = function(netIds, options)
    return exports.ox_target:addEntity(netIds, options)
end

-- Remove a networked entity target
GlitchAbst.Target.RemoveNetworkedEntity = function(netIds, optionNames)
    exports.ox_target:removeEntity(netIds, optionNames)
end

-- Remove a local entity target
GlitchAbst.Target.RemoveLocalEntity = function(entities, optionNames)
    exports.ox_target:removeLocalEntity(entities, optionNames)
end

-- Add a polygon zone
GlitchAbst.Target.AddPolyZone = function(name, points, options, targetOptions)
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
GlitchAbst.Target.AddBoxTarget = GlitchAbst.Target.AddBoxZone
GlitchAbst.Target.AddSphereTarget = GlitchAbst.Target.AddSphereZone
GlitchAbst.Target.AddPolyTarget = GlitchAbst.Target.AddPolyZone
GlitchAbst.Target.RemoveTarget = GlitchAbst.Target.RemoveZone