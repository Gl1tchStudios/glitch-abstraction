-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading QBCore doorlock module^7")
    return false
end

-- Skip if doorlock system doesn't match
if Config and Config.DoorlockSystem and Config.DoorlockSystem ~= 'qb' and Config.DoorlockSystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore doorlock module (using ' .. Config.DoorlockSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-doorlock') ~= 'started' then
    GlitchAbst.Utils.DebugLog('qb-doorlock resource is not available')
    return false
end

local okCore, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
if not okCore or not QBCore then
    GlitchAbst.Utils.DebugLog('qb-doorlock module needs qb-core')
    return false
end

-- Initialize doorlock namespace
GlitchAbst.DoorLock = GlitchAbst.DoorLock or {}

GlitchAbst.Utils.DebugLog('QBCore doorlock module loaded')

-- Local cache for QBCore door information
local doorCache = {}

-- Fill the cache from qb-doorlock (its setup callback returns Config.DoorList)
CreateThread(function()
    Wait(1000) -- Wait for doors to be loaded
    QBCore.Functions.TriggerCallback('qb-doorlock:server:setupDoors', function(doorList)
        if type(doorList) == 'table' then doorCache = doorList end
    end)
end)

-- Listen for door state updates.
-- qb-doorlock v2 sends (serverId, doorId, state, ...); older versions send (doorId, state).
AddEventHandler('qb-doorlock:client:setState', function(a, b, c)
    local doorId, state = b, c
    if c == nil and (b == true or b == false) then doorId, state = a, b end
    if doorId ~= nil and doorCache[doorId] then
        doorCache[doorId].locked = state
    end
end)

local function FindId(door)
    if type(door) == 'string' and not doorCache[door] then
        for id, doorData in pairs(doorCache) do
            if doorData.doorLabel == door or doorData.doorId == door then
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

-- Lock / unlock a door (qb-doorlock checks access on the server)
GlitchAbst.DoorLock.SetDoorLocked = function(door, state)
    local doorId = FindId(door)

    if doorId ~= nil and doorCache[doorId] then
        TriggerServerEvent('qb-doorlock:server:updateState', doorId, state and true or false, false, false, true, true)
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

local function DoorCoords(door)
    return door.doorCoords or door.objCoords or door.textCoords
        or (door.doors and door.doors[1] and door.doors[1].objCoords)
end

-- Get nearby doors
GlitchAbst.DoorLock.GetNearbyDoors = function()
    local playerPos = GetEntityCoords(PlayerPedId())
    local nearbyDoors = {}

    for doorId, door in pairs(doorCache) do
        local c = DoorCoords(door)
        if c then
            local distance = #(playerPos - vector3(c.x, c.y, c.z))
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
        local playerData = QBCore.Functions.GetPlayerData() or {}
        if not playerData.job then return false end
        local doorData = doorCache[doorId]

        -- Check for authorized jobs
        if doorData.authorizedJobs and doorData.authorizedJobs[playerData.job.name] ~= nil then
            return true
        end

        -- Check for authorized gangs
        if doorData.authorizedGangs and playerData.gang and doorData.authorizedGangs[playerData.gang.name] ~= nil then
            return true
        end

        -- Check for authorized citizenid
        if doorData.authorizedCitizenIDs and doorData.authorizedCitizenIDs[playerData.citizenid] then
            return true
        end

        -- Check for items
        if doorData.items then
            for _, item in pairs(doorData.items) do
                local name = type(item) == 'table' and item.name or item
                local hasItem = (GlitchAbst.Inventory.HasItem and GlitchAbst.Inventory.HasItem(name, 1))
                    or (QBCore.Functions.HasItem and QBCore.Functions.HasItem(name, 1))
                if hasItem then
                    return true
                end
            end
        end
    end

    return false
end

return true
