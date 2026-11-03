-- ox_doorlock Server
-- ox_doorlock door state: 1 = locked, 0 = unlocked.
-- Exports used: getDoor(id), getDoorFromName(name), getAllDoors(), setDoorState(id, state), createDoor(data)

if GetResourceState('ox_doorlock') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_doorlock resource is not available')
    return false
end

GlitchAbst.DoorLock = GlitchAbst.DoorLock or {}
GlitchAbst.Utils.DebugLog('ox_doorlock server module loaded')

-- Door id, name or door table -> door table (or nil)
local function FindDoor(door)
    if type(door) == 'table' then return door end
    local id = tonumber(door)
    local ok, res
    if id then
        ok, res = pcall(function() return exports.ox_doorlock:getDoor(id) end)
    elseif type(door) == 'string' then
        ok, res = pcall(function() return exports.ox_doorlock:getDoorFromName(door) end)
    end
    if ok and type(res) == 'table' then return res end
    return nil
end

-- true / 'locked' / 1 -> 1, false / 'unlocked' / 0 -> 0
local function ToState(state)
    if state == 1 or state == true or state == 'locked' or state == 'lock' then return 1 end
    return 0
end

GlitchAbst.DoorLock.GetDoor = FindDoor

-- Returns true (locked), false (unlocked) or nil (no such door)
GlitchAbst.DoorLock.GetDoorState = function(door)
    local d = FindDoor(door)
    if not d then return nil end
    return d.state == 1
end

-- Server side changes are not permission checked by ox_doorlock
GlitchAbst.DoorLock.SetDoorState = function(door, state, playerId)
    local d = FindDoor(door)
    if not d or not d.id then return false end
    local ok, res = pcall(function() return exports.ox_doorlock:setDoorState(d.id, ToState(state)) end)
    return ok and res ~= false
end

GlitchAbst.DoorLock.LockDoor = function(door) return GlitchAbst.DoorLock.SetDoorState(door, 1) end
GlitchAbst.DoorLock.UnlockDoor = function(door) return GlitchAbst.DoorLock.SetDoorState(door, 0) end

-- ox_doorlock keeps its own access check private, so this mirrors it:
-- groups (job or gang with a minimum grade), characters (citizenid / identifier), items.
GlitchAbst.DoorLock.PlayerHasAccess = function(source, door)
    local d = FindDoor(door)
    if not d then return false end
    local fw = GlitchAbst.Framework
    local player = fw.GetPlayer and fw.GetPlayer(source)
    if not player then return false end

    local jobName, jobGrade, gangName, gangGrade, charId
    if player.PlayerData then -- QBCore / Qbox
        local pd = player.PlayerData
        if pd.job then jobName, jobGrade = pd.job.name, (type(pd.job.grade) == 'table' and pd.job.grade.level or tonumber(pd.job.grade) or 0) end
        if pd.gang then gangName, gangGrade = pd.gang.name, (type(pd.gang.grade) == 'table' and pd.gang.grade.level or tonumber(pd.gang.grade) or 0) end
        charId = pd.citizenid
    else -- ESX
        local job = player.getJob and player.getJob() or player.job
        if job then jobName, jobGrade = job.name, tonumber(job.grade) or 0 end
        charId = player.identifier
    end

    if type(d.groups) == 'table' then
        for group, minGrade in pairs(d.groups) do
            local need = tonumber(minGrade) or 0
            if type(group) == 'number' then group, need = minGrade, 0 end
            if (group == jobName and (jobGrade or 0) >= need) or (group == gangName and (gangGrade or 0) >= need) then
                return true
            end
        end
    end

    if type(d.characters) == 'table' and charId then
        for _, id in pairs(d.characters) do
            if id == charId then return true end
        end
    end

    if type(d.items) == 'table' then
        for _, item in pairs(d.items) do
            local name = type(item) == 'table' and item.name or item
            if name and (exports.ox_inventory:GetItemCount(source, name) or 0) > 0 then
                return true
            end
        end
    end

    return false
end

-- Get all doors
GlitchAbst.DoorLock.GetAllDoors = function()
    local ok, res = pcall(function() return exports.ox_doorlock:getAllDoors() end)
    return ok and res or {}
end

-- Add a new door (ox_doorlock createDoor export; returns the door id)
GlitchAbst.DoorLock.AddDoor = function(door)
    local ok, res = pcall(function() return exports.ox_doorlock:createDoor(door) end)
    if not ok then
        GlitchAbst.Utils.DebugLog('AddDoor failed: ' .. tostring(res))
        return false
    end
    return res
end

-- ox_doorlock has no export to delete a door (only its admin menu can)
GlitchAbst.DoorLock.RemoveDoor = function(door)
    GlitchAbst.Utils.DebugLog('RemoveDoor: ox_doorlock has no delete export, remove the door with /doorlock')
    return false
end

return true
