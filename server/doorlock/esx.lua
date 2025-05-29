-- esx_doorlock Server
GlitchAbst.Utils.DebugLog('esx_doorlock server module loaded')

local ESX = exports['es_extended']:getSharedObject()

local function IsResourceAvailable(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started'
end

if not IsResourceAvailable('esx_doorlock') then
    GlitchAbst.Utils.DebugLog('WARNING: esx_doorlock resource is not available')
    
    GlitchAbst.DoorLock.GetDoorState = function(door) return nil end
    GlitchAbst.DoorLock.SetDoorState = function(door, state, source) return false end
    GlitchAbst.DoorLock.PlayerHasAccess = function(source, door) return false end
    GlitchAbst.DoorLock.GetAllDoors = function() return {} end
    
    return  -- Exit early
end

-- Try to get doors using multiple methods
local doors = nil
local function GetDoors()
    -- Try direct exports first
    local exportNames = {'getDoors', 'GetDoors', 'getAllDoors', 'fetchDoors'}
    
    for _, exportName in ipairs(exportNames) do
        local success, result = pcall(function()
            return exports['esx_doorlock'][exportName]()
        end)
        
        if success and result then
            GlitchAbst.Utils.DebugLog('Successfully got doors using export: ' .. exportName)
            return result
        end
    end
    
    -- Try events as fallback
    local eventDoors = nil
    RegisterNetEvent('esx_doorlock:returnDoors')
    AddEventHandler('esx_doorlock:returnDoors', function(doorList)
        eventDoors = doorList
    end)
    
    TriggerEvent('esx_doorlock:getDoors')
    
    -- Wait briefly for event response
    local startTime = os.time()
    while eventDoors == nil and os.time() - startTime < 3 do
        Wait(100)
    end
    
    if eventDoors then
        GlitchAbst.Utils.DebugLog('Successfully got doors using event')
        return eventDoors
    end
    
    -- Last resort - try to access _G.doorList which some versions use
    if _G.doorList then
        GlitchAbst.Utils.DebugLog('Using global doorList variable')
        return _G.doorList
    end
    
    GlitchAbst.Utils.DebugLog('ERROR: Failed to get doors from esx_doorlock')
    return {}
end

-- Get the doors
doors = GetDoors()

-- Set up doorCache
local doorCache = doors or {}

-- Door lock functions
GlitchAbst.DoorLock.GetDoorState = function(door)
    if type(door) == 'number' and doorCache[door] then
        return doorCache[door].locked
    elseif type(door) == 'string' then
        -- Find door by name/id
        for id, doorData in pairs(doorCache) do
            if doorData.textCoords and doorData.label == door then
                return doorData.locked
            end
        end
    end
    return nil
end

GlitchAbst.DoorLock.SetDoorState = function(door, state, playerId)
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

GlitchAbst.DoorLock.PlayerHasAccess = function(source, door)
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

GlitchAbst.DoorLock.GetAllDoors = function()
    return doorCache
end

GlitchAbst.DoorLock.AddDoor = function(door)
    GlitchAbst.Utils.DebugLog('Adding new doors in esx_doorlock requires manual config update')
    return false
end

GlitchAbst.DoorLock.RemoveDoor = function(door)
    GlitchAbst.Utils.DebugLog('Removing doors in esx_doorlock requires manual config update')
    return false
end

GlitchAbst.Utils.DebugLog('ESX Doorlock module loaded')