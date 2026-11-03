-- bt-target module (older ESX servers)
-- bt-target only knows zones and models, and its options fire events. Function
-- callbacks (onSelect / action) are wrapped in a local event so they still work.

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
if GetResourceState('bt-target') ~= 'started' then
    GlitchAbst.Utils.DebugLog('bt-target resource is not available')
    return false
end

GlitchAbst.Utils.DebugLog('bt-target module loaded')

local BT = exports['bt-target']
local callbackCount = 0
local zoneCount = 0

local function ZoneName(prefix)
    zoneCount = zoneCount + 1
    return ('glitchabst_%s_%d'):format(prefix, zoneCount)
end

-- Convert ox / qb style options to bt-target options. Returns options, distance.
local function Convert(options)
    if type(options) ~= 'table' then return {}, 2.5 end
    local distance = nil
    if options.options and type(options.options) == 'table' then
        distance = options.distance
        options = options.options
    elseif options.label or options.name or options.onSelect or options.action or options.event then
        options = { options }
    end

    local out = {}
    for _, o in ipairs(options) do
        local event = o.event
        local fn = o.onSelect or o.action
        if type(fn) == 'function' then
            callbackCount = callbackCount + 1
            event = ('glitchabst:bt:%d'):format(callbackCount)
            local isOnSelect = o.onSelect ~= nil
            AddEventHandler(event, function(data)
                if isOnSelect then fn(data) else fn(type(data) == 'table' and data.entity or data) end
            end)
        elseif o.serverEvent and not event then
            local serverEvent = o.serverEvent
            callbackCount = callbackCount + 1
            event = ('glitchabst:bt:%d'):format(callbackCount)
            AddEventHandler(event, function(data) TriggerServerEvent(serverEvent, data) end)
        end

        local job = o.job or o.groups
        if type(job) == 'string' then job = { job } end
        if type(job) == 'table' and job[1] == nil then
            local list = {}
            for name in pairs(job) do list[#list + 1] = name end
            job = list
        end

        out[#out + 1] = {
            event = event,
            icon = o.icon,
            label = o.label,
            job = job or { 'all' }
        }
        if o.distance and (not distance or o.distance > distance) then distance = o.distance end
    end
    return out, distance or 2.5
end

-- Add a box zone (ox table style or qb positional style). Returns the zone name.
GlitchAbst.Target.AddBoxZone = function(arg1, arg2, arg3, arg4, arg5, arg6)
    local name, center, length, width, options, targetOptions

    if type(arg1) == 'table' then
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

    BT:AddBoxZone(name, center, length, width, {
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

-- Add a sphere zone (bt-target circle zone). Returns the zone name.
GlitchAbst.Target.AddSphereZone = function(name, center, radius, options, targetOptions)
    if type(name) == 'table' then
        local params = name
        name, center, radius, options, targetOptions = params.name, params.coords, params.radius, { debugPoly = params.debug }, params.options
    end
    name = name or ZoneName('sphere')
    options = options or {}
    local opts, distance = Convert(targetOptions)
    BT:AddCircleZone(name, center, radius or 1.0, {
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

-- Add a polygon zone (vector2 points with minZ/maxZ). Returns the zone name.
GlitchAbst.Target.AddPolyZone = function(name, points, options, targetOptions)
    name = name or ZoneName('poly')
    options = options or {}
    local pts = {}
    for i, p in ipairs(points or {}) do pts[i] = vector2(p.x, p.y) end
    local opts, distance = Convert(targetOptions)
    BT:AddPolyZone(name, pts, {
        name = name,
        debugPoly = options.debugPoly or false,
        minZ = options.minZ,
        maxZ = options.maxZ
    }, {
        options = opts,
        distance = distance
    })
    return name
end

-- Add a target model
GlitchAbst.Target.AddTargetModel = function(models, options)
    local opts, distance = Convert(options)
    return BT:AddTargetModel(models, {
        options = opts,
        distance = distance
    })
end

-- bt-target cannot remove model options; this only logs
GlitchAbst.Target.RemoveTargetModel = function(models, optionNames)
    GlitchAbst.Utils.DebugLog('bt-target cannot remove model targets')
end

-- bt-target has no entity targets: a small circle zone follows where the entity is now
-- (fine for parked NPCs and props, not for things that move)
local entityZones = {}

GlitchAbst.Target.AddTargetEntity = function(entities, options)
    if type(entities) ~= 'table' then entities = { entities } end
    for _, entity in ipairs(entities) do
        if DoesEntityExist(entity) then
            local zone = 'glitchabst_ent_' .. tostring(entity)
            if entityZones[entity] then BT:RemoveZone(zone) end
            local coords = GetEntityCoords(entity)
            GlitchAbst.Target.AddSphereZone(zone, coords, 1.5, {}, options)
            entityZones[entity] = zone
        end
    end
    return true
end

GlitchAbst.Target.RemoveLocalEntity = function(entities, optionNames)
    if type(entities) ~= 'table' then entities = { entities } end
    for _, entity in ipairs(entities) do
        if entityZones[entity] then
            BT:RemoveZone(entityZones[entity])
            entityZones[entity] = nil
        end
    end
end
GlitchAbst.Target.RemoveTargetEntity = GlitchAbst.Target.RemoveLocalEntity

GlitchAbst.Target.AddNetworkedEntity = function(netIds, options)
    if type(netIds) ~= 'table' then netIds = { netIds } end
    local list = {}
    for _, id in ipairs(netIds) do
        local ent = NetworkDoesNetworkIdExist(id) and NetworkGetEntityFromNetworkId(id) or 0
        if ent ~= 0 then list[#list + 1] = ent end
    end
    return GlitchAbst.Target.AddTargetEntity(list, options)
end

GlitchAbst.Target.RemoveNetworkedEntity = function(netIds, optionNames)
    if type(netIds) ~= 'table' then netIds = { netIds } end
    local list = {}
    for _, id in ipairs(netIds) do
        local ent = NetworkDoesNetworkIdExist(id) and NetworkGetEntityFromNetworkId(id) or 0
        if ent ~= 0 then list[#list + 1] = ent end
    end
    GlitchAbst.Target.RemoveLocalEntity(list, optionNames)
end

-- Remove zone (name, or the table some callers keep)
GlitchAbst.Target.RemoveZone = function(name)
    if name == nil then return end
    if type(name) == 'table' then name = name.name or name.id end
    BT:RemoveZone(name)
end

-- bt-target has no global (all players / all vehicles ...) targets
local function Unsupported(what)
    return function()
        GlitchAbst.Utils.DebugLog('bt-target does not support ' .. what)
        return false
    end
end

GlitchAbst.Target.AddGlobalPlayer = Unsupported('global player targets')
GlitchAbst.Target.AddGlobalVehicle = Unsupported('global vehicle targets')
GlitchAbst.Target.AddGlobalObject = Unsupported('global object targets')
GlitchAbst.Target.AddGlobalPed = Unsupported('global ped targets')
GlitchAbst.Target.AddGlobalOption = Unsupported('global targets')
GlitchAbst.Target.RemoveGlobalPlayer = Unsupported('global player targets')
GlitchAbst.Target.RemoveGlobalVehicle = Unsupported('global vehicle targets')
GlitchAbst.Target.RemoveGlobalObject = Unsupported('global object targets')
GlitchAbst.Target.RemoveGlobalPed = Unsupported('global ped targets')
GlitchAbst.Target.RemoveGlobalOption = Unsupported('global targets')
GlitchAbst.Target.DisableTargeting = Unsupported('disabling targeting')

-- Add aliases for consistency with other naming conventions
GlitchAbst.Target.AddBoxTarget = GlitchAbst.Target.AddBoxZone
GlitchAbst.Target.AddSphereTarget = GlitchAbst.Target.AddSphereZone
GlitchAbst.Target.AddPolyTarget = GlitchAbst.Target.AddPolyZone
GlitchAbst.Target.RemoveTarget = GlitchAbst.Target.RemoveZone

return true
