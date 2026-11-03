-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ox_doorlock module^7")
    return false
end

-- Skip if doorlock system doesn't match
if Config and Config.DoorlockSystem and Config.DoorlockSystem ~= 'ox' and Config.DoorlockSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ox_doorlock module (using ' .. Config.DoorlockSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_doorlock') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_doorlock resource is not available')
    return false
end

-- Initialize doorlock namespace
GlitchAbst.DoorLock = GlitchAbst.DoorLock or {}

GlitchAbst.Utils.DebugLog('ox_doorlock module loaded')

-- ox_doorlock door state: 1 = locked, 0 = unlocked.
-- The client only knows the doors it has seen change; ox_doorlock keeps its door list
-- private on the client, so the full list lives on the server (GlitchAbst.DoorLock.GetAllDoors there).
local stateCache = {}

-- ox_doorlock broadcasts every change with this event (id, state, source, data)
AddEventHandler('ox_doorlock:setState', function(id, state)
    if id ~= nil then stateCache[id] = state end
end)

local function ClosestDoor()
    local ok, door = pcall(function() return exports.ox_doorlock:getClosestDoor() end)
    if ok and type(door) == 'table' then return door end
    return nil
end

-- Closest door the player is near (ox_doorlock door table) or nil
GlitchAbst.DoorLock.GetClosestDoor = ClosestDoor

-- Door id for a door entity (or nil)
GlitchAbst.DoorLock.GetDoorIdFromEntity = function(entity)
    local ok, id = pcall(function() return exports.ox_doorlock:getDoorIdFromEntity(entity) end)
    return ok and id or nil
end

-- Get all doors the client knows about: { [id] = state }
GlitchAbst.DoorLock.GetAllDoors = function()
    local doors = {}
    for id, state in pairs(stateCache) do
        doors[#doors + 1] = { id = id, state = state }
    end
    return doors
end

-- Get door state: 'locked', 'unlocked' or nil when this client does not know the door
GlitchAbst.DoorLock.GetDoorState = function(doorId)
    local state = stateCache[doorId]
    if state == nil then
        local door = ClosestDoor()
        if door and (door.id == doorId or door.name == doorId) then state = door.state end
    end
    if state == nil then return nil end
    return state == 1 and 'locked' or 'unlocked'
end

-- Lock / unlock: the server checks that this player is allowed to
GlitchAbst.DoorLock.LockDoor = function(doorId)
    if doorId == nil then return false end
    TriggerServerEvent('ox_doorlock:setState', doorId, 1)
    return true
end

GlitchAbst.DoorLock.UnlockDoor = function(doorId)
    if doorId == nil then return false end
    TriggerServerEvent('ox_doorlock:setState', doorId, 0)
    return true
end

GlitchAbst.DoorLock.SetDoorLocked = function(doorId, state)
    if state then return GlitchAbst.DoorLock.LockDoor(doorId) end
    return GlitchAbst.DoorLock.UnlockDoor(doorId)
end

return true
