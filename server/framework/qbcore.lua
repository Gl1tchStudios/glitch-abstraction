if GlitchAbst.FrameworkName ~= 'QBCore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore server framework module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end

local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore integration')
    return false
end

QBCore = result
GlitchAbst.Framework.QBCore = QBCore
GlitchAbst.Framework.Type = 'QBCore'
GlitchAbst.Utils.DebugLog('QBCore server framework module loaded')

-- Framework Functions

-- Get all online players
GlitchAbst.Framework.GetPlayers = function()
    return QBCore.Functions.GetPlayers()
end

-- Get player by server ID
GlitchAbst.Framework.GetPlayer = function(source)
    return QBCore.Functions.GetPlayer(source)
end

-- Register a server callback
GlitchAbst.Framework.RegisterCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

-- Get player from identifier
GlitchAbst.Framework.GetPlayerFromIdentifier = function(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier)
end

-- Money Management
GlitchAbst.Framework.GetMoney = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        return player.Functions.GetMoney('cash')
    end
    return 0
end

GlitchAbst.Framework.AddMoney = function(source, amount)
    print('addMoney from lib', source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.AddMoney('cash', amount, 'GlitchAbst AddMoney')
        return true
    else
        print('player false')
    end
    return false
end

GlitchAbst.Framework.RemoveMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.RemoveMoney('cash', amount, 'GlitchAbst RemoveMoney')
        return true
    end
    return false
end

GlitchAbst.Framework.GetBankMoney = function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        return player.Functions.GetMoney('bank')
    end
    return 0
end

GlitchAbst.Framework.AddBankMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.AddMoney('bank', amount, 'GlitchAbst AddBankMoney')
        return true
    end
    return false
end

GlitchAbst.Framework.RemoveBankMoney = function(source, amount)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.RemoveMoney('bank', amount, 'GlitchAbst RemoveBankMoney')
        return true
    end
    return false
end

-- Job Management
GlitchAbst.Framework.GetJob = function(source)
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

GlitchAbst.Framework.SetJob = function(source, job, grade)
    local player = QBCore.Functions.GetPlayer(source)
    if player then
        player.Functions.SetJob(job, grade)
        return true
    end
    return false
end

-- Inventory Management
GlitchAbst.Framework.RegisterUsableItem = function(item, cb)
    QBCore.Functions.CreateUseableItem(item, cb)
    return true
end

GlitchAbst.Framework.UseItem = function(source, item)
    -- QBCore doesn't have a direct UseItem function
    TriggerClientEvent('inventory:client:UseItem', source, item)
    return true
end

GlitchAbst.Framework.HasItem = function(source, item, count)
    count = count or 1

    if GlitchAbst.Inventory and GlitchAbst.Inventory.GetItemCount then
        -- Use dedicated inventory system if available
        return GlitchAbst.Inventory.GetItemCount(source, item) >= count
    end

    local player = QBCore.Functions.GetPlayer(source)
    if player then
        local hasItem = player.Functions.GetItemByName(item)
        return hasItem and hasItem.amount >= count
    end
    return false
end

GlitchAbst.Framework.Notify = function(source, message, type, length)
    if source then
        TriggerClientEvent('QBCore:Notify', source, message, type, length)
    end
    return true
end

GlitchAbst.Utils.DebugLog('QBCore Framework module loaded successfully')