if not GlitchAbst then
    print('[GlitchAbst] ERROR: GlitchAbst global is not initialized yet!')
    return false
end

GlitchAbst.Utils = GlitchAbst.Utils or {}
GlitchAbst.Utils.DebugLog = GlitchAbst.Utils.DebugLog or function(message) print('[GlitchAbst] ' .. message) end

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
    -- Method 2: Via event (legacy ESX support)
    TriggerEvent('esx:getSharedObject', function(obj) 
        ESX = obj
    end)
    
    -- Give it a moment to complete
    Wait(100)
    
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

-- Framework Functions

-- Get all online players
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
    return ESX.GetPlayerFromId(source)
end

-- Register a server callback
GlitchAbst.Framework.RegisterCallback = function(name, cb)
    -- Directly use ESX.RegisterServerCallback
    ESX.RegisterServerCallback(name, cb)
    
    -- Verify the callback was registered
    if not ESX.DoesServerCallbackExist(name) then
        GlitchAbst.Utils.DebugLog('WARNING: Failed to register callback: ' .. name)
        return false
    end
    
    GlitchAbst.Utils.DebugLog('Registered server callback: ' .. name)
    return true
end

-- Add a function to check if callback exists
GlitchAbst.Framework.DoesCallbackExist = function(name)
    return ESX.DoesServerCallbackExist(name)
end

-- Trigger client callback
GlitchAbst.Framework.TriggerClientCallback = function(source, name, cb, ...)
    if not source or type(source) ~= "number" then
        GlitchAbst.Utils.DebugLog('ERROR: Invalid source provided to TriggerClientCallback')
        return false
    end
    
    ESX.TriggerClientCallback(name, source, function(...)
        if cb then cb(...) end
    end, ...)
    
    return true
end

-- Money Management
GlitchAbst.Framework.GetMoney = function(source, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        if type == 'bank' then
            return xPlayer.getAccount('bank').money
        elseif type == 'cash' then
            return xPlayer.getMoney()
        elseif type == 'dirty' then
            return xPlayer.getAccount('black_money').money
        else
            return xPlayer.getAccount(type).money
        end
    end
    return
end

GlitchAbst.Framework.AddMoney = function(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addAccountMoney(type, amount)
        return true
    end
    return false
end

GlitchAbst.Framework.RemoveMoney = function(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeAccountMoney(type, amount)
        return true
    end
    return false
end

-- Job Management
GlitchAbst.Framework.GetJob = function(source)
    local player = ESX.GetPlayerFromId(source)
    if player then
        return player.getJob()
    end
    return {name = 'unemployed', grade = 0}
end

GlitchAbst.Framework.SetJob = function(source, job, grade)
    local player = ESX.GetPlayerFromId(source)
    if player then
        player.setJob(job, grade)
        return true
    end
    return false
end

-- Inventory Management
GlitchAbst.Framework.RegisterUsableItem = function(item, cb)
    ESX.RegisterUsableItem(item, cb)
    return true
end

GlitchAbst.Framework.UseItem = function(source, item)
    ESX.UseItem(source, item)
    return true
end

GlitchAbst.Framework.HasItem = function(source, item, count)
    count = count or 1
    
    if GlitchAbst.Inventory and GlitchAbst.Inventory.GetItemCount then
        -- Use dedicated inventory system if available
        return GlitchAbst.Inventory.GetItemCount(source, item) >= count
    end
    
    local player = ESX.GetPlayerFromId(source)
    if player then
        local esxItem = player.getInventoryItem(item)
        return esxItem and esxItem.count >= count
    end
    return false
end

GlitchAbst.Framework.Notify = function(source, message, type, length)
    TriggerClientEvent('esx:showNotification', source, message)
    return true
end

GlitchAbst.Utils.DebugLog('ESX Framework module loaded')