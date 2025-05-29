-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading qb-target module^7")
    return false
end

-- Initialize target namespace
GlitchAbst.Target = GlitchAbst.Target or {}

-- Skip if target system doesn't match
if Config and Config.TargetSystem and Config.TargetSystem ~= 'qb' and Config.TargetSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping qb-target module (using ' .. Config.TargetSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-target') ~= 'started' then
    GlitchAbst.Utils.DebugLog('qb-target resource is not available')
    return false
end

GlitchAbst.Utils.DebugLog('qb-target module loaded')

-- Add a target entity
GlitchAbst.Target.AddTargetEntity = function(entities, options)
    return exports['qb-target']:AddTargetEntity(entities, {
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    return exports['qb-target']:AddTargetModel(models, {
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add a box zone
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

    local qbOptions = {}
    
    if targetOptions then
        for i, option in pairs(type(targetOptions) == 'table' and targetOptions or {}) do
            table.insert(qbOptions, {
                type = option.type or "client",
                event = option.event,
                icon = option.icon,
                label = option.label,
                job = option.job,
                canInteract = option.canInteract,
                action = option.onSelect or option.action
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
    
    return exports['qb-target']:AddBoxZone(name, center, length, width, {
        name = name,
        heading = options.heading or 0.0,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = qbOptions,
        distance = distance
    })
end

-- Add a sphere zone
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    return exports['qb-target']:AddSphereZone(name, center, radius, {
        name = name,
        debugPoly = options.debugPoly or false
    }, {
        options = targetOptions,
        distance = targetOptions[1].distance or 2.5
    })
end

-- Remove zone
GlitchAbst.Target.RemoveZone = function(name)
    exports['qb-target']:RemoveZone(name)
end

-- Add target for all players
GlitchAbst.Target.AddGlobalPlayer = function(options)
    exports['qb-target']:AddGlobalPlayer({
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add target for all vehicles
GlitchAbst.Target.AddGlobalVehicle = function(options)
    exports['qb-target']:AddGlobalVehicle({
        options = options,
        distance = options[1].distance or 2.5
    })
end

-- Add target for all objects
GlitchAbst.Target.AddGlobalObject = function(options)
    exports['qb-target']:AddGlobalObject({
        options = options,
        distance = options[1].distance or 2.5
    })
end