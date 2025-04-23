-- QBCore Framework (QBox uses the same functions)
local QBCore = exports['qb-core']:GetCoreObject()
GlitchLib.Utils.DebugLog('QBCore Framework module loaded')

-- Player Management
GlitchLib.Framework.GetPlayer = function(source)
    return QBCore.Functions.GetPlayer(source)
end

GlitchLib.Framework.GetPlayerFromIdentifier = function(citizenid)
    return QBCore.Functions.GetPlayerByCitizenId(citizenid)
end

GlitchLib.Framework.GetPlayers = function()
    return QBCore.Functions.GetPlayers()
end

-- Money Management
GlitchLib.Framework.GetMoney = function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.money['cash']
    end
    return 0
end

GlitchLib.Framework.AddMoney = function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.AddMoney('cash', amount)
    end
    return false
end

GlitchLib.Framework.RemoveMoney = function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.RemoveMoney('cash', amount)
    end
    return false
end

-- Bank Management
GlitchLib.Framework.GetBankMoney = function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.money['bank']
    end
    return 0
end

GlitchLib.Framework.AddBankMoney = function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.AddMoney('bank', amount)
    end
    return false
end

GlitchLib.Framework.RemoveBankMoney = function(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.RemoveMoney('bank', amount)
    end
    return false
end

-- Job Management
GlitchLib.Framework.GetJob = function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.job
    end
    return nil
end

GlitchLib.Framework.SetJob = function(source, job, grade)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.SetJob(job, grade)
        return true
    end
    return false
end

-- Callback Registration
GlitchLib.Framework.RegisterCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
end

-- Notification
GlitchLib.Framework.Notify = function(source, message, type, length)
    TriggerClientEvent('QBCore:Notify', source, message, type or 'primary', length or 5000)
end