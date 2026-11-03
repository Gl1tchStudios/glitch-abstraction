-- esx_doorlock Server
GlitchAbst.Utils.DebugLog('esx_doorlock server module loaded')

local function IsResourceAvailable(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started'
end

if not IsResourceAvailable('esx_doorlock') or not IsResourceAvailable('es_extended') then
    GlitchAbst.Utils.DebugLog('WARNING: esx_doorlock resource is not available')
    return false
end

-- Door data, filled in a thread below (waiting is not allowed while the resource loads)
local doorCache = {}

local function GetDoors()
    -- Try direct exports first
    local exportNames = {'getDoors', 'GetDoors', 'getAllDoors', 'fetchDoors'}

    for _, exportName in ipairs(exportNames) do
        local success, result = pcall(function()
            local e = exports['esx_doorlock']
            return e[exportName](e)
        end)

        if success and type(result) == 'table' then
            GlitchAbst.Utils.DebugLog('Successfully got doors using export: ' .. exportName)
            return result
        end
    end

    -- Try events as fallback
    local eventDoors = nil
    local handler = AddEventHandler('esx_doorlock:returnDoors', function(doorList)
        eventDoors = doorList
    end)

    TriggerEvent('esx_doorlock:getDoors')

    -- Wait briefly for event response
    local deadline = GetGameTimer() + 3000
    while eventDoors == nil and GetGameTimer() < deadline do
        Wait(100)
    end
    RemoveEventHandler(handler)

    if type(eventDoors) == 'table' then
        GlitchAbst.Utils.DebugLog('Successfully got doors using event')
        return eventDoors
    end

    -- Last resort - try to access _G.doorList which some versions use
    if type(_G.doorList) == 'table' then
        GlitchAbst.Utils.DebugLog('Using global doorList variable')
        return _G.doorList
    end

    GlitchAbst.Utils.DebugLog('ERROR: Failed to get doors from esx_doorlock')
    return {}
end

CreateThread(function()
    doorCache = GetDoors() or {}
end)

local function GetESX()
    return GlitchAbst.Framework.ESX or exports['es_extended']:getSharedObject()
end

local function FindId(door)
    if type(door) == 'string' then
        for id, doorData in pairs(doorCache) do
            if doorData.label == door then
                return id
            end
        end
        return nil
    end
    return door
end

-- Door lock functions
GlitchAbst.DoorLock.GetDoorState = function(door)
    local id = FindId(door)
    if id and doorCache[id] then
        return doorCache[id].locked
    end
    return nil
end

GlitchAbst.DoorLock.SetDoorState = function(door, state, playerId)
    local doorId = FindId(door)
    if doorId and doorCache[doorId] then
        local locked = (state == true or state == 1 or state == 'locked')
        TriggerEvent('esx_doorlock:updateState', doorId, locked, playerId or 0, false)
        doorCache[doorId].locked = locked
        return true
    end
    return false
end

GlitchAbst.DoorLock.PlayerHasAccess = function(source, door)
    local doorId = FindId(door)

    if doorId and doorCache[doorId] then
        local xPlayer = GetESX().GetPlayerFromId(source)
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
                local it = xPlayer.getInventoryItem(item)
                if it and (it.count or 0) > 0 then
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
return true
