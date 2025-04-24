if GlitchLib.FrameworkName ~= 'QBCore' then
    GlitchLib.Utils.DebugLog('Skipping QBCore server framework module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchLib.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore integration')
    return false
end

QBCore = result
GlitchLib.Framework.QBCore = QBCore
GlitchLib.Framework.Type = 'QBCore'
GlitchLib.Utils.DebugLog('QBCore server framework module loaded')

-- Framework Functions

-- Get all online players
GlitchLib.Framework.GetPlayers = function()
    return QBCore.Functions.GetPlayers()
end

-- Get player by server ID
GlitchLib.Framework.GetPlayer = function(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Register a server callback
GlitchLib.Framework.RegisterCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

-- Get player from identifier
GlitchLib.Framework.GetPlayerFromIdentifier = function(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier)
end

-- Money Management
GlitchLib.Framework.GetMoney = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        return player.Functions.GetMoney('cash')
    end
    return 0
end

GlitchLib.Framework.AddMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.AddMoney('cash', amount, 'GlitchLib AddMoney')
        return true
    end
    return false
end

GlitchLib.Framework.RemoveMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.RemoveMoney('cash', amount, 'GlitchLib RemoveMoney')
        return true
    end
    return false
end

GlitchLib.Framework.GetBankMoney = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        return player.Functions.GetMoney('bank')
    end
    return 0
end

GlitchLib.Framework.AddBankMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.AddMoney('bank', amount, 'GlitchLib AddBankMoney')
        return true
    end
    return false
end

GlitchLib.Framework.RemoveBankMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.RemoveMoney('bank', amount, 'GlitchLib RemoveBankMoney')
        return true
    end
    return false
end

-- Job Management
GlitchLib.Framework.GetJob = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        local job = player.PlayerData.job
        -- Convert to ESX-like format for consistency
        return {
            name = job.name,
            label = job.label,
            grade = job.grade.level,
            grade_name = job.grade.name,
            grade_label = job.grade.name
        }
    end
    return {name = 'unemployed', grade = 0}
end

GlitchLib.Framework.SetJob = function(source, job, grade)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.SetJob(job, grade)
        return true
    end
    return false
end

-- Inventory Management
GlitchLib.Framework.RegisterUsableItem = function(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
    return true
end

GlitchLib.Framework.UseItem = function(source, item)
    -- QBCore doesn't have a direct UseItem function
    TriggerClientEvent('inventory:client:UseItem', source, item)
    return true
end

GlitchLib.Framework.HasItem = function(source, item, count)
    count = count or 1

    if GlitchLib.Inventory and GlitchLib.Inventory.GetItemCount then
        -- Use dedicated inventory system if available
        return GlitchLib.Inventory.GetItemCount(source, item) >= count
    end

    local player = QBCore.Functions.GetPlayer(source)
    if player then
        local hasItem = player.Functions.GetItemByName(item)
        return hasItem and hasItem.amount >= count
    end
    return false
end

GlitchLib.Framework.Notify = function(source, message, type, length)
    if source then
        TriggerClientEvent('QBCore:Notify', source, message, type, length)
    end
    return true
end

GlitchLib.Utils.DebugLog('QBCore Framework module loaded successfully')