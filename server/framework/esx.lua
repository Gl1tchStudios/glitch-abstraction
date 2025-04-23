-- ESX Legacy Framework
local ESX = exports['es_extended']:getSharedObject()
GlitchLib.Utils.DebugLog('ESX Framework module loaded')

-- Player Management
GlitchLib.Framework.GetPlayer = function(source)
    return ESX.GetPlayerFromId(source)
end

GlitchLib.Framework.GetPlayerFromIdentifier = function(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

GlitchLib.Framework.GetPlayers = function()
    return ESX.GetPlayers()
end

-- Money Management
GlitchLib.Framework.GetMoney = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getMoney()
    end
    return 0
end

GlitchLib.Framework.AddMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.addMoney(amount)
    end
    return false
end

GlitchLib.Framework.RemoveMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.removeMoney(amount)
    end
    return false
end

-- Bank Management
GlitchLib.Framework.GetBankMoney = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getAccount('bank').money
    end
    return 0
end

GlitchLib.Framework.AddBankMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.addAccountMoney('bank', amount)
    end
    return false
end

GlitchLib.Framework.RemoveBankMoney = function(source, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.removeAccountMoney('bank', amount)
    end
    return false
end

-- Job Management
GlitchLib.Framework.GetJob = function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getJob()
    end
    return nil
end

GlitchLib.Framework.SetJob = function(source, job, grade)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.setJob(job, grade)
        return true
    end
    return false
end

-- Callback Registration
GlitchLib.Framework.RegisterCallback = function(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

-- Notification
GlitchLib.Framework.Notify = function(source, message, type, length)
    TriggerClientEvent('esx:showNotification', source, message)
end