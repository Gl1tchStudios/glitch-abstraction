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

-- Accept qb-target style options as well as ox_target ones:
--   action(entity) -> onSelect, job -> groups, item -> items, type = 'server'/'command' + event.
-- A single option table (not a list) is wrapped in a list.
local function Normalize(options)
    if type(options) ~= 'table' then return {} end
    if options.label or options.name or options.onSelect or options.action or options.event or options.serverEvent then
        options = { options }
    elseif options.options and type(options.options) == 'table' then
        -- qb style { options = {...}, distance = n }
        local distance = options.distance
        options = options.options
        if distance then
            for _, o in ipairs(options) do o.distance = o.distance or distance end
        end
    end

    local out = {}
    for i, o in ipairs(options) do
        local opt = {}
        for k, v in pairs(o) do opt[k] = v end

        if not opt.onSelect and type(o.action) == 'function' then
            local act = o.action
            opt.onSelect = function(data)
                act(type(data) == 'table' and data.entity or data, data)
            end
        end
        opt.action = nil

        if o.type == 'server' and o.event and not o.serverEvent then
            opt.serverEvent, opt.event = o.event, nil
        elseif o.type == 'command' and o.event and not o.command then
            opt.command, opt.event = o.event, nil
        end
        opt.type = nil

        if opt.groups == nil and o.job ~= nil then opt.groups = o.job end
        if opt.groups == nil and o.gang ~= nil then opt.groups = o.gang end
        if opt.items == nil and o.item ~= nil then opt.items = o.item end

        opt.name = opt.name or opt.label
        out[i] = opt
    end
    return out
end
GlitchAbst.Target.NormalizeOptions = Normalize

-- Option names (ox removes by name; a single name or a list)
local function Names(optionNames)
    return optionNames
end

-- ox_target attributes everything added here to glitch-abstraction, so zones and global options are
-- tracked per requesting resource and removed when that resource stops.
local ownedZones = {}   -- [resource] = { zone ids }
local ownedGlobals = {} -- [resource] = { { remove = export name, names = {...} } }

local function trackZone(owner, id)
    if owner and id ~= nil then
        ownedZones[owner] = ownedZones[owner] or {}
        ownedZones[owner][#ownedZones[owner] + 1] = id
    end
    return id
end

local function trackGlobal(owner, remove, options)
    if not owner or type(options) ~= 'table' then return end
    local names = {}
    for _, o in ipairs(options) do if type(o) == 'table' and o.name then names[#names + 1] = o.name end end
    if #names == 0 then return end
    ownedGlobals[owner] = ownedGlobals[owner] or {}
    ownedGlobals[owner][#ownedGlobals[owner] + 1] = { remove = remove, names = names }
end

AddEventHandler('onClientResourceStop', function(res)
    for _, id in ipairs(ownedZones[res] or {}) do pcall(function() exports.ox_target:removeZone(id) end) end
    ownedZones[res] = nil
    for _, g in ipairs(ownedGlobals[res] or {}) do
        pcall(function() exports.ox_target[g.remove](exports.ox_target, g.names) end)
    end
    ownedGlobals[res] = nil
end)

-- Add a target entity
GlitchAbst.Target.AddTargetEntity = function(entities, options)
    return exports.ox_target:addLocalEntity(entities, Normalize(options))
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    return exports.ox_target:addModel(models, Normalize(options))
end

-- Add a box zone. Either ox style AddBoxZone({ coords, size, rotation, options })
-- or qb style AddBoxZone(name, center, length, width, { heading, minZ, maxZ, debugPoly }, targetOptions)
GlitchAbst.Target.AddBoxZone = function(arg1, arg2, arg3, arg4, arg5, arg6)
    if type(arg1) == 'table' then
        local zone = {}
        for k, v in pairs(arg1) do zone[k] = v end
        zone.options = Normalize(arg1.options)
        return trackZone(GetInvokingResource(), exports.ox_target:addBoxZone(zone))
    end

    local name = arg1
    local center = arg2
    local length = arg3
    local width = arg4
    local options = arg5 or {}
    local targetOptions = arg6

    local height = 2.0
    local coords = center
    if options.minZ and options.maxZ then
        height = math.abs(options.maxZ - options.minZ)
        coords = vector3(center.x, center.y, (options.minZ + options.maxZ) / 2)
    end

    local boxZone = {
        name = name,
        coords = coords,
        size = type(length) == 'vector3' and length or vector3(tonumber(length) or 1.0, tonumber(width) or 1.0, height),
        rotation = options.heading or 0.0,
        debug = options.debugPoly or false,
        options = Normalize(targetOptions)
    }

    return trackZone(GetInvokingResource(), exports.ox_target:addBoxZone(boxZone))
end

-- Add a sphere zone: AddSphereZone({ coords, radius, options }) or AddSphereZone(name, center, radius, options, targetOptions)
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    if type(name) == 'table' then
        local zone = {}
        for k, v in pairs(name) do zone[k] = v end
        zone.options = Normalize(name.options)
        return trackZone(GetInvokingResource(), exports.ox_target:addSphereZone(zone))
    end
    options = options or {}
    local sphereZone = {
        name = name,
        coords = center,
        radius = radius,
        debug = options.debugPoly or false,
        options = Normalize(targetOptions)
    }
    return trackZone(GetInvokingResource(), exports.ox_target:addSphereZone(sphereZone))
end

-- Remove a zone by the id AddBoxZone/AddSphereZone/AddPolyZone returned, or by name
GlitchAbst.Target.RemoveZone = function(id)
    if id == nil then return end
    if type(id) == 'table' then id = id.id or id.name end
    exports.ox_target:removeZone(id)
end

-- Add target for all players
GlitchAbst.Target.AddGlobalPlayer = function(options)
    options = Normalize(options)
    trackGlobal(GetInvokingResource(), 'removeGlobalPlayer', options)
    exports.ox_target:addGlobalPlayer(options)
end

-- Add target for all vehicles
GlitchAbst.Target.AddGlobalVehicle = function(options)
    options = Normalize(options)
    trackGlobal(GetInvokingResource(), 'removeGlobalVehicle', options)
    exports.ox_target:addGlobalVehicle(options)
end

-- Add target for all objects
GlitchAbst.Target.AddGlobalObject = function(options)
    options = Normalize(options)
    trackGlobal(GetInvokingResource(), 'removeGlobalObject', options)
    exports.ox_target:addGlobalObject(options)
end

-- Enable/disable the targeting system
GlitchAbst.Target.DisableTargeting = function(state)
    exports.ox_target:disableTargeting(state)
end

-- Add a global option that appears for all entities
GlitchAbst.Target.AddGlobalOption = function(options)
    options = Normalize(options)
    trackGlobal(GetInvokingResource(), 'removeGlobalOption', options)
    return exports.ox_target:addGlobalOption(options)
end

-- Remove global options
GlitchAbst.Target.RemoveGlobalOption = function(optionNames)
    exports.ox_target:removeGlobalOption(Names(optionNames))
end

-- Add target for all peds (except players)
GlitchAbst.Target.AddGlobalPed = function(options)
    options = Normalize(options)
    trackGlobal(GetInvokingResource(), 'removeGlobalPed', options)
    exports.ox_target:addGlobalPed(options)
end

-- Remove target for all peds
GlitchAbst.Target.RemoveGlobalPed = function(optionNames)
    exports.ox_target:removeGlobalPed(Names(optionNames))
end

-- Remove target for all players
GlitchAbst.Target.RemoveGlobalPlayer = function(optionNames)
    exports.ox_target:removeGlobalPlayer(Names(optionNames))
end

-- Remove target for all vehicles
GlitchAbst.Target.RemoveGlobalVehicle = function(optionNames)
    exports.ox_target:removeGlobalVehicle(Names(optionNames))
end

-- Remove target for all objects
GlitchAbst.Target.RemoveGlobalObject = function(optionNames)
    exports.ox_target:removeGlobalObject(Names(optionNames))
end

-- Remove target model
GlitchAbst.Target.RemoveTargetModel = function(models, optionNames)
    exports.ox_target:removeModel(models, Names(optionNames))
end

-- Add a target entity by network ID
GlitchAbst.Target.AddNetworkedEntity = function(netIds, options)
    return exports.ox_target:addEntity(netIds, Normalize(options))
end

-- Remove a networked entity target
GlitchAbst.Target.RemoveNetworkedEntity = function(netIds, optionNames)
    exports.ox_target:removeEntity(netIds, Names(optionNames))
end

-- Remove a local entity target
GlitchAbst.Target.RemoveLocalEntity = function(entities, optionNames)
    exports.ox_target:removeLocalEntity(entities, Names(optionNames))
end
GlitchAbst.Target.RemoveTargetEntity = GlitchAbst.Target.RemoveLocalEntity

-- Add a polygon zone. ox needs vec3 points; qb style vector2 points use minZ/maxZ.
GlitchAbst.Target.AddPolyZone = function(name, points, options, targetOptions)
    if type(name) == 'table' then
        local zone = {}
        for k, v in pairs(name) do zone[k] = v end
        zone.options = Normalize(name.options)
        return trackZone(GetInvokingResource(), exports.ox_target:addPolyZone(zone))
    end
    options = options or {}
    local thickness = options.height or options.thickness or 4.0
    local z = nil
    if options.minZ and options.maxZ then
        thickness = math.abs(options.maxZ - options.minZ)
        z = (options.minZ + options.maxZ) / 2
    end
    local pts = {}
    for i, p in ipairs(points or {}) do
        pts[i] = vector3(p.x, p.y, z or p.z or 0.0)
    end
    local polyZone = {
        points = pts,
        name = name,
        thickness = thickness,
        debug = options.debugPoly or false,
        drawSprite = options.drawSprite,
        options = Normalize(targetOptions)
    }
    return trackZone(GetInvokingResource(), exports.ox_target:addPolyZone(polyZone))
end

-- Add aliases for consistency with other naming conventions
GlitchAbst.Target.AddBoxTarget = GlitchAbst.Target.AddBoxZone
GlitchAbst.Target.AddSphereTarget = GlitchAbst.Target.AddSphereZone
GlitchAbst.Target.AddCircleZone = GlitchAbst.Target.AddSphereZone
GlitchAbst.Target.AddPolyTarget = GlitchAbst.Target.AddPolyZone
GlitchAbst.Target.RemoveTarget = GlitchAbst.Target.RemoveZone

return true
