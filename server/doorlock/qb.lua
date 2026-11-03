-- qb-doorlock Server
GlitchAbst.Utils.DebugLog('qb-doorlock server module loaded')

-- Check if the resource is actually available before proceeding
local function IsResourceAvailable(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started'
end

-- Early exit if qb-doorlock isn't available
if not IsResourceAvailable('qb-doorlock') then
    GlitchAbst.Utils.DebugLog('WARNING: qb-doorlock resource is not available')
    return false
end

-- Try to initialize QBCore
local function initQBCore()
    if GlitchAbst.Framework.QBCore then return GlitchAbst.Framework.QBCore end
    if not IsResourceAvailable('qb-core') then
        return false
    end

    local success, result = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)

    if not success or result == nil then
        GlitchAbst.Utils.DebugLog('ERROR: Failed to initialize QBCore for doorlock - export not found')
        return false
    end

    return result
end

local QBCore = initQBCore()

-- Cache for door data
local doorCache = {}

-- Try to get door data with multiple possible export names
local function getDoorData()
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
            local e = exports['qb-doorlock']
            return e[exportName](e)
        end)

        if success and type(result) == 'table' then
            GlitchAbst.Utils.DebugLog('Successfully got door data using export: ' .. exportName)
            return result
        end
    end

    -- If exports fail, try to access door data through events
    local doorData = nil
    local handler = AddEventHandler('qb-doorlock:server:getDoors', function(doors)
        doorData = doors
    end)

    TriggerEvent('qb-doorlock:server:requestDoors')

    -- Wait briefly for event response
    local deadline = GetGameTimer() + 3000
    while doorData == nil and GetGameTimer() < deadline do
        Wait(100)
    end
    RemoveEventHandler(handler)

    if type(doorData) == 'table' then
        GlitchAbst.Utils.DebugLog('Successfully got door data using event')
        return doorData
    end

    GlitchAbst.Utils.DebugLog('WARNING: Could not get door data from qb-doorlock')
    return {}
end

-- Initialize doorCache on resource start
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    doorCache = getDoorData() or {}
end)

local function FindId(door)
    if type(door) == 'string' then
        for id, doorData in pairs(doorCache) do
            if doorData.doorLabel == door or doorData.doorId == door or id == door then
                return id
            end
        end
        return nil
    end
    return door
end

-- Get door state
GlitchAbst.DoorLock.GetDoorState = function(door)
    local id = FindId(door)
    if id ~= nil and doorCache[id] then
        return doorCache[id].locked
    end
    return nil
end

-- Set door state
GlitchAbst.DoorLock.SetDoorState = function(door, state, playerId)
    local doorId = FindId(door)

    if doorId ~= nil and doorCache[doorId] then
        local locked = (state == true or state == 1 or state == 'locked')
        TriggerEvent('qb-doorlock:server:updateState', doorId, locked, playerId or 0, false)
        doorCache[doorId].locked = locked
        return true
    end
    return false
end

-- Check if player has access to a door
GlitchAbst.DoorLock.PlayerHasAccess = function(source, door)
    local doorId = FindId(door)

    if doorId ~= nil and doorCache[doorId] then
        local Player = QBCore and QBCore.Functions.GetPlayer(source)
        if not Player then return false end

        local pd = Player.PlayerData
        local doorData = doorCache[doorId]

        local function Level(grade)
            if type(grade) == 'table' then return grade.level or 0 end
            return tonumber(grade) or 0
        end

        -- Check for authorized jobs (value is either true or a minimum grade / { min = n })
        if doorData.authorizedJobs and pd.job and doorData.authorizedJobs[pd.job.name] ~= nil then
            local rule = doorData.authorizedJobs[pd.job.name]
            local need = type(rule) == 'table' and (rule.min or 0) or tonumber(rule) or 0
            if Level(pd.job.grade) >= need then
                return true
            end
        end

        -- Check for authorized gang
        if doorData.authorizedGangs and pd.gang and doorData.authorizedGangs[pd.gang.name] ~= nil then
            local rule = doorData.authorizedGangs[pd.gang.name]
            local need = type(rule) == 'table' and (rule.min or 0) or tonumber(rule) or 0
            if Level(pd.gang.grade) >= need then
                return true
            end
        end

        -- Check for authorized citizenid
        if doorData.authorizedCitizenIDs and doorData.authorizedCitizenIDs[pd.citizenid] then
            return true
        end

        -- Check for items
        if doorData.items then
            for _, item in pairs(doorData.items) do
                local name = type(item) == 'table' and item.name or item
                local hasItem = Player.Functions.GetItemByName(name)
                if hasItem and (hasItem.amount or hasItem.count or 0) > 0 then
                    return true
                end
            end
        end
    end

    return false
end

-- Get all doors
GlitchAbst.DoorLock.GetAllDoors = function()
    return doorCache
end

-- Add a new door (requires config update)
GlitchAbst.DoorLock.AddDoor = function(door)
    GlitchAbst.Utils.DebugLog('Adding new doors in qb-doorlock requires manual config update')
    return false
end

-- Remove a door (requires config update)
GlitchAbst.DoorLock.RemoveDoor = function(door)
    GlitchAbst.Utils.DebugLog('Removing doors in qb-doorlock requires manual config update')
    return false
end

return true
