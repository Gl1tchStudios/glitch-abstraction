-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ox_doorlock module^7")
    return false
end

-- Skip if doorlock system doesn't match
if Config and Config.DoorlockSystem and Config.DoorlockSystem ~= 'ox' and Config.DoorlockSystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping ox_doorlock module (using ' .. Config.DoorlockSystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_doorlock') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_doorlock resource is not available')
    return false
end

-- Initialize doorlock namespace
GlitchLib.DoorLock = GlitchLib.DoorLock or {}

GlitchLib.Utils.DebugLog('ox_doorlock module loaded')

-- Check if exports exist before using them
local hasExport = function(resource, exportName)
    if not GetResourceState(resource) == 'started' then return false end
    local resourceExports = exports[resource]
    if not resourceExports then return false end
    
    -- We can't directly check if the export exists, but we can use pcall to safely attempt to call it
    local success = pcall(function() 
        local _ = resourceExports[exportName]
    end)
    return success
end

-- Get all doors
GlitchLib.DoorLock.GetAllDoors = function()
    if hasExport('ox_doorlock', 'getDoors') then
        return exports['ox_doorlock']:getDoors()
    elseif hasExport('ox_doorlock', 'getDoorFromName') then
        -- Some versions might use a different export format
        GlitchLib.Utils.DebugLog('Using alternative method to get doors')
        -- Return empty table as fallback
        return {}
    else
        GlitchLib.Utils.DebugLog('ox_doorlock exports not available')
        return {}
    end
end

-- Get door state
GlitchLib.DoorLock.GetDoorState = function(doorId)
    if hasExport('ox_doorlock', 'getDoorFromName') then
        local door = exports['ox_doorlock']:getDoorFromName(doorId)
        return door and (door.state == 1 and 'unlocked' or 'locked') or nil
    end
    return nil
end

-- Lock door
GlitchLib.DoorLock.LockDoor = function(doorId)
    TriggerEvent('ox_doorlock:setState', doorId, 0)
    return true
end

-- Unlock door
GlitchLib.DoorLock.UnlockDoor = function(doorId)
    TriggerEvent('ox_doorlock:setState', doorId, 1)
    return true
end