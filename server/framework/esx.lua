if not GlitchAbst then
    print('[GlitchAbst] ERROR: GlitchAbst global is not initialized yet!')
    return false
end

GlitchAbst.Utils = GlitchAbst.Utils or {}
GlitchAbst.Utils.DebugLog = GlitchAbst.Utils.DebugLog or function(message) print('[GlitchAbst] ' .. tostring(message)) end

-- Check proper framework
if GlitchAbst.FrameworkName ~= 'ESX' then
    GlitchAbst.Utils.DebugLog('Skipping ESX server framework module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end

-- Try to get the ESX object
local ESX = nil

-- Method 1: Via export
local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

if success and result then
    ESX = result
    GlitchAbst.Utils.DebugLog('ESX server framework module loaded (via export)')
else
    -- Method 2: Via event (legacy ESX). TriggerEvent runs the handler straight away,
    -- so no wait is needed (and none is allowed while the resource is loading).
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)

    if ESX then
        GlitchAbst.Utils.DebugLog('ESX server framework module loaded (via event)')
    else
        GlitchAbst.Utils.DebugLog('WARNING: Failed to get ESX object, server functions will not work')
        return false
    end
end

-- Store ESX object and set framework type
GlitchAbst.Framework = GlitchAbst.Framework or {}
GlitchAbst.Framework.ESX = ESX
GlitchAbst.Framework.Type = 'ESX'
GlitchAbst.Utils.DebugLog('ESX server framework module loaded successfully')

local MoneyArgs = GlitchAbst.Utils.MoneyArgs

-- Account names used by other frameworks -> ESX account names
local ACCOUNTS = { cash = 'money', money = 'money', bank = 'bank', dirty = 'black_money', black_money = 'black_money', blackmoney = 'black_money' }
local function Account(name)
    if not name then return 'money' end
    return ACCOUNTS[name] or name
end

local function GetPlayer(source)
    source = tonumber(source)
    if not source then return nil end
    return ESX.GetPlayerFromId(source)
end

local function Balance(xPlayer, account)
    if account == 'money' and xPlayer.getMoney then
        return tonumber(xPlayer.getMoney()) or 0
    end
    local acc = xPlayer.getAccount and xPlayer.getAccount(account)
    return acc and tonumber(acc.money) or 0
end

-- Framework Functions

-- Get all online players (ESX player objects)
GlitchAbst.Framework.GetPlayers = function()
    local players = {}
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local player = ESX.GetPlayerFromId(playerId)
        if player then
            table.insert(players, player)
        end
    end
    return players
end

-- Get player by server ID
GlitchAbst.Framework.GetPlayer = function(source)
    return GetPlayer(source)
end

-- Get player from identifier
GlitchAbst.Framework.GetPlayerFromIdentifier = function(identifier)
    if ESX.GetPlayerFromIdentifier then
        return ESX.GetPlayerFromIdentifier(identifier)
    end
    return nil
end

-- Register a server callback
GlitchAbst.Framework.RegisterCallback = function(name, cb)
    ESX.RegisterServerCallback(name, cb)

    -- Verify the callback was registered (older ESX has no way to check)
    if ESX.DoesServerCallbackExist and not ESX.DoesServerCallbackExist(name) then
        GlitchAbst.Utils.DebugLog('WARNING: Failed to register callback: ' .. name)
        return false
    end

    GlitchAbst.Utils.DebugLog('Registered server callback: ' .. name)
    return true
end

-- Add a function to check if callback exists
GlitchAbst.Framework.DoesCallbackExist = function(name)
    if ESX.DoesServerCallbackExist then
        return ESX.DoesServerCallbackExist(name)
    end
    return nil
end

-- Trigger client callback
GlitchAbst.Framework.TriggerClientCallback = function(source, name, cb, ...)
    if not source or type(source) ~= "number" then
        GlitchAbst.Utils.DebugLog('ERROR: Invalid source provided to TriggerClientCallback')
        return false
    end
    if not ESX.TriggerClientCallback then
        GlitchAbst.Utils.DebugLog('ERROR: this ESX version has no TriggerClientCallback')
        return false
    end

    ESX.TriggerClientCallback(source, name, function(...)
        if cb then cb(...) end
    end, ...)

    return true
end

-- Money Management
-- Every money function takes (source, amount) or (source, account, amount).
-- Account defaults to cash ('money'); 'cash' and 'dirty' are accepted as well.

GlitchAbst.Framework.GetMoney = function(source, account)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return 0 end
    return Balance(xPlayer, Account(account))
end

GlitchAbst.Framework.AddMoney = function(source, a, b)
    local account, amount = MoneyArgs(a, b)
    if not amount or amount < 0 then return false end
    if amount == 0 then return true end
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    account = Account(account)
    if account == 'money' and xPlayer.addMoney then
        xPlayer.addMoney(amount, 'GlitchAbst AddMoney')
    else
        xPlayer.addAccountMoney(account, amount, 'GlitchAbst AddMoney')
    end
    return true
end

-- Returns false when the player cannot pay (ESX itself would let the balance go negative)
GlitchAbst.Framework.RemoveMoney = function(source, a, b)
    local account, amount = MoneyArgs(a, b)
    if not amount or amount < 0 then return false end
    if amount == 0 then return true end
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    account = Account(account)
    if Balance(xPlayer, account) < amount then return false end
    if account == 'money' and xPlayer.removeMoney then
        xPlayer.removeMoney(amount, 'GlitchAbst RemoveMoney')
    else
        xPlayer.removeAccountMoney(account, amount, 'GlitchAbst RemoveMoney')
    end
    return true
end

GlitchAbst.Framework.GetBankMoney = function(source)
    return GlitchAbst.Framework.GetMoney(source, 'bank')
end

GlitchAbst.Framework.AddBankMoney = function(source, amount)
    return GlitchAbst.Framework.AddMoney(source, 'bank', amount)
end

GlitchAbst.Framework.RemoveBankMoney = function(source, amount)
    return GlitchAbst.Framework.RemoveMoney(source, 'bank', amount)
end

-- Job Management
GlitchAbst.Framework.GetJob = function(source)
    local player = GetPlayer(source)
    if player then
        local job = player.getJob and player.getJob() or player.job
        if job then return job end
    end
    return {name = 'unemployed', grade = 0}
end

GlitchAbst.Framework.SetJob = function(source, job, grade)
    local player = GetPlayer(source)
    if player and ESX.DoesJobExist and not ESX.DoesJobExist(job, grade) then
        return false
    end
    if player then
        player.setJob(job, grade)
        return true
    end
    return false
end

-- Inventory Management
GlitchAbst.Framework.RegisterUsableItem = function(item, cb)
    if not item or not cb then return false end
    -- If ox_inventory is running it handles usable items exclusively.
    -- server/inventory/ox.lua replaces this function when that module loads, so this
    -- version only runs when ox_inventory is NOT present.
    if GetResourceState('ox_inventory') == 'started' then
        GlitchAbst.Utils.DebugLog('RegisterUsableItem: ox_inventory active, deferring to inventory module override for: ' .. tostring(item))
        return false
    end
    ESX.RegisterUsableItem(item, cb)
    return true
end

GlitchAbst.Framework.UseItem = function(source, item)
    ESX.UseItem(source, item)
    return true
end

GlitchAbst.Framework.HasItem = function(source, item, count)
    count = tonumber(count) or 1

    if GlitchAbst.Inventory and GlitchAbst.Inventory.GetItemCount then
        -- Use dedicated inventory system if available
        return (tonumber(GlitchAbst.Inventory.GetItemCount(source, item)) or 0) >= count
    end

    local player = GetPlayer(source)
    if player then
        local esxItem = player.getInventoryItem(item)
        return esxItem ~= nil and (tonumber(esxItem.count) or 0) >= count
    end
    return false
end

GlitchAbst.Framework.Notify = function(source, message, type, length)
    if source then
        TriggerClientEvent('esx:showNotification', source, message, type, length)
    end
    return true
end

GlitchAbst.Utils.DebugLog('ESX Framework module loaded')
return true
