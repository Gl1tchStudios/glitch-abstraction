-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ESX doorlock module^7")
    return false
end

-- Skip if doorlock system doesn't match
if Config and Config.DoorlockSystem and Config.DoorlockSystem ~= 'esx' and Config.DoorlockSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ESX doorlock module (using ' .. Config.DoorlockSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('esx_doorlock') ~= 'started' then
    GlitchAbst.Utils.DebugLog('esx_doorlock resource is not available')
    return false
end

-- Initialize doorlock namespace
GlitchAbst.DoorLock = GlitchAbst.DoorLock or {}

GlitchAbst.Utils.DebugLog('ESX doorlock module loaded')

local function GetESX()
    return GlitchAbst.Framework.ESX or exports['es_extended']:getSharedObject()
end

-- Local cache to store door information
local doorCache = {}

-- Initialize the door cache (esx_doorlock versions that answer this event fill it)
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    TriggerEvent('esx_doorlock:getDoors', function(doors)
        if type(doors) == 'table' then doorCache = doors end
    end)
end)

-- Listen for door state updates
AddEventHandler('esx_doorlock:setState', function(doorIndex, state)
    if doorIndex ~= nil and doorCache[doorIndex] then
        doorCache[doorIndex].locked = state
    end
end)

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

-- Check if a door is locked
GlitchAbst.DoorLock.IsDoorLocked = function(door)
    local id = FindId(door)
    if id ~= nil and doorCache[id] then
        return doorCache[id].locked
    end
    return nil
end

-- Lock / unlock a door
GlitchAbst.DoorLock.SetDoorLocked = function(door, state)
    local doorId = FindId(door)
    if doorId ~= nil and doorCache[doorId] then
        TriggerServerEvent('esx_doorlock:updateState', doorId, state and true or false, false, false)
        return true
    end
    return false
end

GlitchAbst.DoorLock.LockDoor = function(door) return GlitchAbst.DoorLock.SetDoorLocked(door, true) end
GlitchAbst.DoorLock.UnlockDoor = function(door) return GlitchAbst.DoorLock.SetDoorLocked(door, false) end
GlitchAbst.DoorLock.GetDoorState = function(door)
    local locked = GlitchAbst.DoorLock.IsDoorLocked(door)
    if locked == nil then return nil end
    return locked and 'locked' or 'unlocked'
end

-- Get nearby doors
GlitchAbst.DoorLock.GetNearbyDoors = function()
    local playerPos = GetEntityCoords(PlayerPedId())
    local nearbyDoors = {}

    for doorId, door in pairs(doorCache) do
        if door.textCoords then
            local distance = #(playerPos - vector3(door.textCoords.x, door.textCoords.y, door.textCoords.z))
            if distance <= 10.0 then
                door.id = doorId
                table.insert(nearbyDoors, door)
            end
        end
    end

    return nearbyDoors
end

-- Get all doors
GlitchAbst.DoorLock.GetAllDoors = function()
    local doors = {}
    for id, door in pairs(doorCache) do
        door.id = id
        table.insert(doors, door)
    end
    return doors
end

-- Check if player has access to a door
GlitchAbst.DoorLock.HasAccess = function(door)
    local doorId = FindId(door)

    if doorId ~= nil and doorCache[doorId] then
        local playerData = GetESX().GetPlayerData() or {}
        if not playerData.job then return false end
        local doorData = doorCache[doorId]

        -- Check for allowed jobs
        if doorData.authorizedJobs then
            for _, job in pairs(doorData.authorizedJobs) do
                if job == playerData.job.name then
                    return true
                end
            end
        end

        -- Check for items
        if doorData.items then
            for _, item in pairs(doorData.items) do
                for _, invItem in pairs(playerData.inventory or {}) do
                    if invItem.name == item and (invItem.count or 0) > 0 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

return true
