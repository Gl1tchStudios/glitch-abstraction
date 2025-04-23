-- qb-doorlock Server Implementation
GlitchLib.Utils.DebugLog('qb-doorlock server module loaded')

local QBCore = exports['qb-core']:GetCoreObject()

-- Cache for door data
local doorCache = {}

-- Initialize doorCache on resource start
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    doorCache = exports['qb-doorlock']:getDoorStateTable()
end)

-- Get door state
GlitchLib.DoorLock.GetDoorState = function(door)
    if type(door) == 'number' then
        if doorCache[door] then
            return doorCache[door].locked
        end
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

-- Set door state
GlitchLib.DoorLock.SetDoorState = function(door, state, playerId)
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
        local player = playerId and playerId or 0
        TriggerEvent('qb-doorlock:server:updateState', doorId, state, player, false)
        return true
    end
    return false
end

-- Check if player has access to a door
GlitchLib.DoorLock.PlayerHasAccess = function(source, door)
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
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        
        local doorData = doorCache[doorId]
        
        -- Check for authorized jobs
        if doorData.authorizedJobs then
            if doorData.authorizedJobs[Player.PlayerData.job.name] then
                if not doorData.authorizedJobs[Player.PlayerData.job.name].min then 
                    return true
                else
                    if Player.PlayerData.job.grade.level >= doorData.authorizedJobs[Player.PlayerData.job.name].min then
                        return true
                    end
                end
            end
        end
        
        -- Check for authorized gang
        if doorData.authorizedGangs and Player.PlayerData.gang then
            if doorData.authorizedGangs[Player.PlayerData.gang.name] then
                if not doorData.authorizedGangs[Player.PlayerData.gang.name].min then
                    return true
                else
                    if Player.PlayerData.gang.grade.level >= doorData.authorizedGangs[Player.PlayerData.gang.name].min then
                        return true
                    end
                end
            end
        end
        
        -- Check for authorized citizenid
        if doorData.authorizedCitizenIDs and doorData.authorizedCitizenIDs[Player.PlayerData.citizenid] then
            return true
        end
        
        -- Check for items
        if doorData.items then
            for _, item in pairs(doorData.items) do
                local hasItem = Player.Functions.GetItemByName(item)
                if hasItem and hasItem.amount > 0 then
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
    GlitchLib.Utils.DebugLog('Adding new doors in qb-doorlock requires manual config update')
    return false
end

-- Remove a door (requires config update)
GlitchLib.DoorLock.RemoveDoor = function(door)
    GlitchLib.Utils.DebugLog('Removing doors in qb-doorlock requires manual config update')
    return false
end