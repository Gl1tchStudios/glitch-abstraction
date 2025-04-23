-- ox_doorlock Implementation
GlitchLib.Utils.DebugLog('ox_doorlock module loaded')

-- Check if a door is locked
GlitchLib.DoorLock.IsDoorLocked = function(door)
    if type(door) == 'string' then
        return exports.ox_doorlock:getDoorState(door)
    elseif type(door) == 'number' then
        return exports.ox_doorlock:getDoorState(door)
    end
    return nil
end

-- Lock a door
GlitchLib.DoorLock.SetDoorLocked = function(door, state)
    if type(door) == 'string' then
        return exports.ox_doorlock:setDoorState(door, state)
    elseif type(door) == 'number' then
        return exports.ox_doorlock:setDoorState(door, state)
    end
    return false
end

-- Get nearby doors (if supported)
GlitchLib.DoorLock.GetNearbyDoors = function()
    if exports.ox_doorlock.getNearbyDoors then
        return exports.ox_doorlock:getNearbyDoors()
    end
    return {}
end

-- Get all doors
GlitchLib.DoorLock.GetAllDoors = function()
    if exports.ox_doorlock.getDoors then
        return exports.ox_doorlock:getDoors()
    end
    return {}
end

-- Check if player has access to a door
GlitchLib.DoorLock.HasAccess = function(door)
    if exports.ox_doorlock.hasAccess then
        if type(door) == 'string' then
            return exports.ox_doorlock:hasAccess(door)
        elseif type(door) == 'number' then
            return exports.ox_doorlock:hasAccess(door)
        end
    end
    return false
end