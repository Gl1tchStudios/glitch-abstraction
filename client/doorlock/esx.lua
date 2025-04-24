-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ESX doorlock module^7")
    return false
end

-- Skip if doorlock system doesn't match
if Config and Config.DoorlockSystem and Config.DoorlockSystem ~= 'esx' and Config.DoorlockSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping ESX doorlock module (using ' .. Config.DoorlockSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('esx_doorlock') ~= 'started' then
    GlitchLib.Utils.DebugLog('esx_doorlock resource is not available')
    return false
end

-- Initialize doorlock namespace
GlitchLib.DoorLock = GlitchLib.DoorLock or {}

GlitchLib.Utils.DebugLog('ESX doorlock module loaded')

-- Local cache to store door information
local doorCache = {}

-- Initialize the door cache
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    TriggerEvent('esx_doorlock:getDoors', function(doors)
        doorCache = doors
    end)
end)

-- Listen for door state updates
RegisterNetEvent('esx_doorlock:setState')
AddEventHandler('esx_doorlock:setState', function(doorIndex, state)
    if doorCache[doorIndex] then
        doorCache[doorIndex].locked = state
    end
end)

-- Check if a door is locked
GlitchLib.DoorLock.IsDoorLocked = function(door)
    if type(door) == 'number' and doorCache[door] then
        return doorCache[door].locked
    elseif type(door) == 'string' then
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.textCoords and doorData.label == door then
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
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.textCoords and doorData.label == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        TriggerServerEvent('esx_doorlock:updateState', doorId, state, false, false)
        return true
    end
    return false
end

-- Get nearby doors
GlitchLib.DoorLock.GetNearbyDoors = function()
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
        -- Try to find door by name
        for id, doorData in pairs(doorCache) do
            if doorData.textCoords and doorData.label == door then
                doorId = id
                break
            end
        end
    end
    
    if doorId and doorCache[doorId] then
        local ESX = exports['es_extended']:getSharedObject()
        local playerData = ESX.GetPlayerData()
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
                local hasItem = ESX.HasItem(item)
                if hasItem then
                    return true
                end
            end
        end
    end
    
    return false
end