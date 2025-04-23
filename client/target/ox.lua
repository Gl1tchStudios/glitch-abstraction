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