-- qb-doorlock Implementation
GlitchLib.Utils.DebugLog('qb-doorlock module loaded')

-- Local cache for QBCore door information
local doorCache = {}

-- Initialize the door cache
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    TriggerEvent('qb-doorlock:client:setState', function(doorList)
        doorCache = doorList
    end)
end)

-- Listen for door state updates
RegisterNetEvent('qb-doorlock:client:setState')
AddEventHandler('qb-doorlock:client:setState', function(doorId, state)
    if doorCache[doorId] then
        doorCache[doorId].locked = state
    end
end)

-- Check if a door is locked
GlitchLib.DoorLock.IsDoorLocked = function(door)
    if type(door) == 'number' and doorCache[door] then
        return doorCache[door].locked
    elseif type(door) == 'string' then
        -- Try to find door by name/id string
        for id, doorData in pairs(doorCache) do
            if doorData.doorLabel == door or doorData.doorId == door then
                return doorData.locked
            end
        end
    end
    return nil
end

-- Lock a door
GlitchLib.DoorLock.SetDoorLocked = function(door, state)
    local doorId = door
    if type(door) == 'string' then
        -- Try to find door by name/id string
        for id, doorData in pairs(doorCache) do
            if doorData.doorLabel == door or doorData.doorId == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        TriggerServerEvent('qb-doorlock:server:updateState', doorId, state, false, false, true, true)
        return true
    end
    return false
end

-- Get nearby doors
GlitchLib.DoorLock.GetNearbyDoors = function()
    local playerPos = GetEntityCoords(PlayerPedId())
    local nearbyDoors = {}
    
    for doorId, door in pairs(doorCache) do
        local distance = #(playerPos - vector3(door.doorCoords.x, door.doorCoords.y, door.doorCoords.z))
        if distance <= 10.0 then
            door.id = doorId
            table.insert(nearbyDoors, door)
        end
    end
    
    return nearbyDoors
end

-- Get all doors
GlitchLib.DoorLock.GetAllDoors = function()
    local doors = {}
    for id, door in pairs(doorCache) do
        door.id = id
        table.insert(doors, door)
    end
    return doors
end

-- Check if player has access to a door
GlitchLib.DoorLock.HasAccess = function(door)
    local doorId = door
    if type(door) == 'string' then
        -- Try to find door by name/id string
        for id, doorData in pairs(doorCache) do
            if doorData.doorLabel == door or doorData.doorId == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        local playerData = exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
        local doorData = doorCache[doorId]
        
        -- Check for authorized jobs
        if doorData.authorizedJobs and doorData.authorizedJobs[playerData.job.name] then
            return true
        end
        
        -- Check for authorized citizenid
        if doorData.authorizedCitizenIDs and doorData.authorizedCitizenIDs[playerData.citizenid] then
            return true
        end
        
        -- Check for lockpick item
        if doorData.items then
            for _, item in pairs(doorData.items) do
                local hasItem = exports['qb-inventory']:HasItem(item, 1)
                if hasItem then
                    return true
                end
            end
        end
    end
    
    return false
end