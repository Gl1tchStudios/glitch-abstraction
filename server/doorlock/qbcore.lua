-- qb-doorlock Server
GlitchLib.Utils.DebugLog('qb-doorlock server module loaded')

-- Check if the resource is actually available before proceeding
local function IsResourceAvailable(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started'
end

-- Early exit if qb-doorlock isn't available
if not IsResourceAvailable('qb-doorlock') then
    GlitchLib.Utils.DebugLog('WARNING: qb-doorlock resource is not available')
    
    -- Set up placeholder functions
    GlitchLib.DoorLock.GetDoorState = function(door) return nil end
    GlitchLib.DoorLock.SetDoorState = function(door, state, source) return false end
    GlitchLib.DoorLock.PlayerHasAccess = function(source, door) return false end
    GlitchLib.DoorLock.GetAllDoors = function() return {} end
    GlitchLib.DoorLock.AddDoor = function(door) return false end
    GlitchLib.DoorLock.RemoveDoor = function(door) return false end
    
    return  -- Exit early
end

-- Try to initialize QBCore
local QBCore = nil
local function initQBCore()
    if not IsResourceAvailable('qb-core') then
        return false
    end
    
    local success, result = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    
    if not success then
        success, result = pcall(function()
            return exports['qb-core']:GetSharedObject()
        end)
    end
    
    if not success then
        success, result = pcall(function()
            return exports['qb-core']:getCore()
        end)
    end
    
    if not success or result == nil then
        GlitchLib.Utils.DebugLog('ERROR: Failed to initialize QBCore for doorlock - export not found')
        return false
    end
    
    return result
end

QBCore = initQBCore()

-- Cache for door data
local doorCache = {}

-- Try to get door data with multiple possible export names
local function getDoorData()
    -- Try different export names that qb-doorlock might use
    local exportNames = {
        'getDoorStateTable', 
        'GetDoorStateTable',
        'getDoors',
        'GetDoors',
        'getAllDoors',
        'getDoorList'
    }
    
    for _, exportName in ipairs(exportNames) do
        local success, result = pcall(function()
            return exports['qb-doorlock'][exportName]()
        end)
        
        if success and result then
            GlitchLib.Utils.DebugLog('Successfully got door data using export: ' .. exportName)
            return result
        end
    end
    
    -- If exports fail, try to access door data through events
    local doorData = nil
    RegisterNetEvent('qb-doorlock:server:getDoors')
    AddEventHandler('qb-doorlock:server:getDoors', function(doors)
        doorData = doors
    end)
    
    TriggerEvent('qb-doorlock:server:requestDoors')
    
    -- Wait briefly for event response
    local startTime = os.time()
    while doorData == nil and os.time() - startTime < 3 do
        Wait(100)
    end
    
    if doorData then
        GlitchLib.Utils.DebugLog('Successfully got door data using event')
        return doorData
    end
    
    GlitchLib.Utils.DebugLog('WARNING: Could not get door data from qb-doorlock')
    return {}
end

-- Initialize doorCache on resource start
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    doorCache = getDoorData()
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
        local Player = QBCore and QBCore.Functions.GetPlayer(source)
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