if not GlitchLib then
    print('[GlitchLib] ERROR: GlitchLib global is not initialized yet!')
    return false
end

GlitchLib.Utils = GlitchLib.Utils or {}
GlitchLib.Utils.DebugLog = GlitchLib.Utils.DebugLog or function(message) print('[GlitchLib] ' .. message) end

-- Check proper framework
if GlitchLib.FrameworkName ~= 'ESX' then
    GlitchLib.Utils.DebugLog('Skipping ESX server framework module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
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
    GlitchLib.Utils.DebugLog('ESX server framework module loaded (via export)')
else
    -- Method 2: Via event (legacy ESX support)
    TriggerEvent('esx:getSharedObject', function(obj) 
        ESX = obj
    end)
    
    -- Give it a moment to complete
    Wait(100)
    
    if ESX then
        GlitchLib.Utils.DebugLog('ESX server framework module loaded (via event)')
    else
        GlitchLib.Utils.DebugLog('WARNING: Failed to get ESX object, server functions will not work')
        return false
    end
end

-- Store ESX object and set framework type
GlitchLib.Framework = GlitchLib.Framework or {}
GlitchLib.Framework.ESX = ESX
GlitchLib.Framework.Type = 'ESX'
GlitchLib.Utils.DebugLog('ESX server framework module loaded successfully')

-- Framework Functions

-- Get all online players
GlitchLib.Framework.GetPlayers = function()
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
GlitchLib.Framework.GetPlayer = function(source)
    return ESX.GetPlayerFromId(source)
end

-- Register a server callback
GlitchLib.Framework.RegisterCallback = function(name, cb)
    ESX.RegisterServerCallback(name, cb)
end

-- Trigger client callback
GlitchLib.Framework.TriggerClientCallback = function(source, name, cb, ...)
    ESX.TriggerClientCallback(name, source, cb, ...)
end

-- Money Management
GlitchLib.Framework.GetMoney = function(source, type)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        return xPlayer.getAccount(type).money
    end
    return 0
end

GlitchLib.Framework.AddMoney = function(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addAccountMoney(type, amount)
        return true
    end
    return false
end

GlitchLib.Framework.RemoveMoney = function(source, type, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.removeAccountMoney(type, amount)
        return true
    end
    return false
end

-- Job Management
GlitchLib.Framework.GetJob = function(source)
    local player = ESX.GetPlayerFromId(source)
    if player then
        return player.getJob()
    end
    return {name = 'unemployed', grade = 0}
end

GlitchLib.Framework.SetJob = function(source, job, grade)
    local player = ESX.GetPlayerFromId(source)
    if player then
        player.setJob(job, grade)
        return true
    end
    return false
end

-- Inventory Management
GlitchLib.Framework.RegisterUsableItem = function(item, cb)
    ESX.RegisterUsableItem(item, cb)
    return true
end

GlitchLib.Framework.UseItem = function(source, item)
    ESX.UseItem(source, item)
    return true
end

GlitchLib.Framework.HasItem = function(source, item, count)
    count = count or 1
    
    if GlitchLib.Inventory and GlitchLib.Inventory.GetItemCount then
        -- Use dedicated inventory system if available
        return GlitchLib.Inventory.GetItemCount(source, item) >= count
    end
    
    local player = ESX.GetPlayerFromId(source)
    if player then
        local esxItem = player.getInventoryItem(item)
        return esxItem and esxItem.count >= count
    end
    return false
end

GlitchLib.Framework.Notify = function(source, message, type, length)
    TriggerClientEvent('esx:showNotification', source, message)
    return true
end

GlitchLib.Utils.DebugLog('ESX Framework module loaded')