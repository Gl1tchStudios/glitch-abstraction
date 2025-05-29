-- ox_doorlock Server
GlitchAbst.Utils.DebugLog('ox_doorlock server module loaded')

-- Get door state
GlitchAbst.DoorLock.GetDoorState = function(door)
    if exports.ox_doorlock.getDoorState then
        return exports.ox_doorlock:getDoorState(door)
    end
    return nil
end

-- Set door state
GlitchAbst.DoorLock.SetDoorState = function(door, state, playerId)
    if exports.ox_doorlock.setDoorState then
        return exports.ox_doorlock:setDoorState(door, state, playerId)
    end
    return false
end

-- Check if player has access to a door
GlitchAbst.DoorLock.PlayerHasAccess = function(source, door)
    if exports.ox_doorlock.playerHasAccess then
        return exports.ox_doorlock:playerHasAccess(source, door)
    end
    return false
end

-- Get all doors
GlitchAbst.DoorLock.GetAllDoors = function()
    if exports.ox_doorlock.getDoors then
        return exports.ox_doorlock:getDoors()
    end
    return {}
end

-- Add a new door
GlitchAbst.DoorLock.AddDoor = function(door)
    if exports.ox_doorlock.addDoor then
        return exports.ox_doorlock:addDoor(door)
    end
    return false
end

-- Remove a door
GlitchAbst.DoorLock.RemoveDoor = function(door)
    if exports.ox_doorlock.removeDoor then
        return exports.ox_doorlock:removeDoor(door)
    end
    return false
end