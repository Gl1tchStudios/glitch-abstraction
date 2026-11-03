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

local QB = exports['qb-target']

-- ox removes options by name, qb-target by label: remember which label each name got
local labelOf = {}

local function Labels(optionNames)
    if optionNames == nil then return nil end
    if type(optionNames) ~= 'table' then optionNames = { optionNames } end
    local labels = {}
    for i, n in ipairs(optionNames) do labels[i] = labelOf[n] or n end
    return labels
end

-- Accept ox_target style options as well as qb-target ones:
--   onSelect(data) -> action(entity), serverEvent/command -> type + event, groups -> job, items -> item.
-- Returns qb options list, distance.
local function Convert(options)
    if type(options) ~= 'table' then return {}, 2.5 end
    local distance = nil
    if options.options and type(options.options) == 'table' then
        distance = options.distance
        options = options.options
    elseif options.label or options.name or options.onSelect or options.action or options.event or options.serverEvent then
        options = { options }
    end

    local out = {}
    for _, o in ipairs(options) do
        local opt = {}
        for k, v in pairs(o) do opt[k] = v end

        if not opt.action and type(o.onSelect) == 'function' then
            local fn = o.onSelect
            opt.action = function(entity)
                fn({ entity = entity, coords = entity and GetEntityCoords(entity) or nil, distance = 0.0 })
            end
        end
        opt.onSelect = nil

        if o.serverEvent and not o.event then
            opt.type, opt.event = 'server', o.serverEvent
        elseif o.command and not o.event then
            opt.type, opt.event = 'command', o.command
        else
            opt.type = o.type or 'client'
        end
        opt.serverEvent, opt.command = nil, nil

        if opt.job == nil and o.groups ~= nil then opt.job = o.groups end
        if opt.item == nil and o.items ~= nil then opt.item = o.items end

        if o.name and o.label then labelOf[o.name] = o.label end
        if o.distance and (not distance or o.distance > distance) then distance = o.distance end
        out[#out + 1] = opt
    end
    return out, distance or 2.5
end

local function Entities(netIds)
    if type(netIds) ~= 'table' then netIds = { netIds } end
    local list = {}
    for _, id in ipairs(netIds) do
        local ent = NetworkDoesNetworkIdExist(id) and NetworkGetEntityFromNetworkId(id) or 0
        if ent ~= 0 then list[#list + 1] = ent end
    end
    return list
end

local zoneCount = 0
local function ZoneName(prefix)
    zoneCount = zoneCount + 1
    return ('glitchabst_%s_%d'):format(prefix, zoneCount)
end

-- Add a target entity
GlitchAbst.Target.AddTargetEntity = function(entities, options)
    local opts, distance = Convert(options)
    return QB:AddTargetEntity(entities, { options = opts, distance = distance })
end

-- Remove a local entity target
GlitchAbst.Target.RemoveLocalEntity = function(entities, optionNames)
    QB:RemoveTargetEntity(entities, Labels(optionNames))
end
GlitchAbst.Target.RemoveTargetEntity = GlitchAbst.Target.RemoveLocalEntity

-- Networked entities (by network id)
GlitchAbst.Target.AddNetworkedEntity = function(netIds, options)
    local list = Entities(netIds)
    if #list == 0 then return false end
    return GlitchAbst.Target.AddTargetEntity(list, options)
end

GlitchAbst.Target.RemoveNetworkedEntity = function(netIds, optionNames)
    local list = Entities(netIds)
    if #list == 0 then return end
    QB:RemoveTargetEntity(list, Labels(optionNames))
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    local opts, distance = Convert(options)
    return QB:AddTargetModel(models, { options = opts, distance = distance })
end

GlitchAbst.Target.RemoveTargetModel = function(models, optionNames)
    QB:RemoveTargetModel(models, Labels(optionNames))
end

-- Add a box zone. Either ox style AddBoxZone({ coords, size, rotation, options })
-- or qb style AddBoxZone(name, center, length, width, { heading, minZ, maxZ, debugPoly }, targetOptions).
-- Returns the zone name (pass it to RemoveZone).
GlitchAbst.Target.AddBoxZone = function(arg1, arg2, arg3, arg4, arg5, arg6)
    local name, center, length, width, options, targetOptions

    if type(arg1) == 'table' then
        -- ox format
        local params = arg1
        name = params.name or ZoneName('box')
        center = params.coords

        local size = params.size
        local height = 2.0
        if type(size) == 'vector3' or type(size) == 'table' then
            length, width, height = size.x or 1.0, size.y or 1.0, size.z or 2.0
        else
            length = tonumber(size) or 1.0
            width = length
        end

        options = {
            heading = params.rotation,
            debugPoly = params.debug,
            minZ = params.minZ or (center and center.z - height / 2),
            maxZ = params.maxZ or (center and center.z + height / 2)
        }
        targetOptions = params.options
    else
        name = arg1 or ZoneName('box')
        center = arg2
        length = arg3
        width = arg4
        options = arg5 or {}
        targetOptions = arg6
    end

    local opts, distance = Convert(targetOptions)

    QB:AddBoxZone(name, center, length, width, {
        name = name,
        heading = options.heading or 0.0,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = opts,
        distance = distance
    })
    return name
end

-- Add a sphere zone (qb-target calls it a circle zone). Returns the zone name.
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    if type(name) == 'table' then
        local params = name
        name, center, radius, options, targetOptions = params.name, params.coords, params.radius, { debugPoly = params.debug }, params.options
    end
    name = name or ZoneName('sphere')
    options = options or {}
    local opts, distance = Convert(targetOptions)
    QB:AddCircleZone(name, center, radius or 1.0, {
        name = name,
        debugPoly = options.debugPoly or false,
        useZ = true
    }, {
        options = opts,
        distance = distance
    })
    return name
end
GlitchAbst.Target.AddCircleZone = GlitchAbst.Target.AddSphereZone

-- Add a polygon zone (qb-target takes vector2 points with minZ/maxZ). Returns the zone name.
GlitchAbst.Target.AddPolyZone = function(name, points, options, targetOptions)
    if type(name) == 'table' then
        local params = name
        name, points, options, targetOptions = params.name, params.points, { debugPoly = params.debug, thickness = params.thickness }, params.options
    end
    name = name or ZoneName('poly')
    options = options or {}
    local pts, minZ, maxZ = {}, options.minZ, options.maxZ
    for i, p in ipairs(points or {}) do
        pts[i] = vector2(p.x, p.y)
        if p.z and not options.minZ then
            local half = (options.thickness or 4.0) / 2
            minZ = math.min(minZ or p.z - half, p.z - half)
            maxZ = math.max(maxZ or p.z + half, p.z + half)
        end
    end
    local opts, distance = Convert(targetOptions)
    QB:AddPolyZone(name, pts, {
        name = name,
        debugPoly = options.debugPoly or false,
        minZ = minZ,
        maxZ = maxZ
    }, {
        options = opts,
        distance = distance
    })
    return name
end

-- Remove zone (name, or the table some callers keep)
GlitchAbst.Target.RemoveZone = function(name)
    if name == nil then return end
    if type(name) == 'table' then name = name.name or name.id end
    QB:RemoveZone(name)
end

-- Global targets
local function Global(fnName)
    return function(options)
        local opts, distance = Convert(options)
        QB[fnName](QB, { options = opts, distance = distance })
    end
end

local function RemoveGlobal(fnName)
    return function(optionNames)
        QB[fnName](QB, Labels(optionNames))
    end
end

GlitchAbst.Target.AddGlobalPlayer = Global('AddGlobalPlayer')
GlitchAbst.Target.AddGlobalVehicle = Global('AddGlobalVehicle')
GlitchAbst.Target.AddGlobalObject = Global('AddGlobalObject')
GlitchAbst.Target.AddGlobalPed = Global('AddGlobalPed')
GlitchAbst.Target.RemoveGlobalPlayer = RemoveGlobal('RemoveGlobalPlayer')
GlitchAbst.Target.RemoveGlobalVehicle = RemoveGlobal('RemoveGlobalVehicle')
GlitchAbst.Target.RemoveGlobalObject = RemoveGlobal('RemoveGlobalObject')
GlitchAbst.Target.RemoveGlobalPed = RemoveGlobal('RemoveGlobalPed')

-- ox's "all entities" option: peds, players, vehicles and objects
GlitchAbst.Target.AddGlobalOption = function(options)
    GlitchAbst.Target.AddGlobalPed(options)
    GlitchAbst.Target.AddGlobalPlayer(options)
    GlitchAbst.Target.AddGlobalVehicle(options)
    GlitchAbst.Target.AddGlobalObject(options)
end

GlitchAbst.Target.RemoveGlobalOption = function(optionNames)
    GlitchAbst.Target.RemoveGlobalPed(optionNames)
    GlitchAbst.Target.RemoveGlobalPlayer(optionNames)
    GlitchAbst.Target.RemoveGlobalVehicle(optionNames)
    GlitchAbst.Target.RemoveGlobalObject(optionNames)
end

-- Enable/disable the targeting system
GlitchAbst.Target.DisableTargeting = function(state)
    pcall(function() QB:AllowTargeting(not state) end)
end

-- Add aliases for consistency with other naming conventions
GlitchAbst.Target.AddBoxTarget = GlitchAbst.Target.AddBoxZone
GlitchAbst.Target.AddSphereTarget = GlitchAbst.Target.AddSphereZone
GlitchAbst.Target.AddPolyTarget = GlitchAbst.Target.AddPolyZone
GlitchAbst.Target.RemoveTarget = GlitchAbst.Target.RemoveZone

return true
