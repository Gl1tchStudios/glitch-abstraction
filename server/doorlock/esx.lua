-- esx_doorlock Server Implementation
GlitchLib.Utils.DebugLog('esx_doorlock server module loaded')

local ESX = exports['es_extended']:getSharedObject()

-- Cache for door data
local doorCache = {}

-- Initialize doorCache on resource start
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    doorCache = exports['esx_doorlock']:getDoors()
end)

-- Get door state
GlitchLib.DoorLock.GetDoorState = function(door)
    if type(door) == 'number' then
        if doorCache[door] then
            return doorCache[door].locked
        end
    elseif type(door) == 'string' then
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.label == door then
                return doorData.locked
            end
        end
    end
    return nil
end

-- Set door state
GlitchLib.DoorLock.SetDoorState = function(door, state, playerId)
    local doorId = door
    if type(door) == 'string' then
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.label == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        local player = playerId or 0
        TriggerEvent('esx_doorlock:updateState', doorId, state, player, false)
        return true
    end
    return false
end

-- Check if player has access to a door
GlitchLib.DoorLock.PlayerHasAccess = function(source, door)
    local doorId = door
    if type(door) == 'string' then
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.label == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        local xPlayer = ESX.GetPlayerFromId(source)
        if not xPlayer then return false end
        
        local doorData = doorCache[doorId]
        
        -- Check for authorized jobs
        if doorData.authorizedJobs then
            for _, job in pairs(doorData.authorizedJobs) do
                if job == xPlayer.job.name then
                    if not doorData.authorizedJobGrades then
                        return true
                    else
                        for _, grade in pairs(doorData.authorizedJobGrades) do
                            if grade == xPlayer.job.grade then
                                return true
                            end
                        end
                    end
                end
            end
        end
        
        -- Check for items
        if doorData.items then
            for _, item in pairs(doorData.items) do
                if xPlayer.getInventoryItem(item).count > 0 then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Get all doors
GlitchLib.DoorLock.GetAllDoors = function()
    return doorCache
end

-- Add a new door (requires config update)
GlitchLib.DoorLock.AddDoor = function(door)
    GlitchLib.Utils.DebugLog('Adding new doors in esx_doorlock requires manual config update')
    return false
end

-- Remove a door (requires config update)
GlitchLib.DoorLock.RemoveDoor = function(door)
    GlitchLib.Utils.DebugLog('Removing doors in esx_doorlock requires manual config update')
    return false
end