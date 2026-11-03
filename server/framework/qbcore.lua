-- QBCore / Qbox server framework module
-- Qbox (qbx_core) provides 'qb-core' and its GetCoreObject() bridge, so this file covers both.

if GlitchAbst.FrameworkName ~= 'QBCore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore server framework module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end

local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)
if not success or not result then
    -- Qbox without its 'qb-core' provide: the same export lives under qbx_core
    success, result = pcall(function() return exports['qbx_core']:GetCoreObject() end)
end

if not success or not result then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore integration')
    return false
end

QBCore = result
GlitchAbst.Framework.QBCore = QBCore
GlitchAbst.Framework.Type = 'QBCore'
GlitchAbst.Utils.DebugLog('QBCore server framework module loaded' .. (GlitchAbst.IsQbox and ' (Qbox)' or ''))

local MoneyArgs = GlitchAbst.Utils.MoneyArgs

-- Account names used by other frameworks -> QBCore account names
local ACCOUNTS = { money = 'cash', cash = 'cash', bank = 'bank' }
local function Account(name)
    if not name then return 'cash' end
    return ACCOUNTS[name] or name
end

local function Reason(what)
    return ('GlitchAbst %s (%s)'):format(what, GetInvokingResource() or '?')
end

local function GetPlayer(source)
    source = tonumber(source)
    if not source then return nil end
    return QBCore.Functions.GetPlayer(source)
end

-- Framework Functions

-- Get all online players (server ids)
GlitchAbst.Framework.GetPlayers = function()
    return QBCore.Functions.GetPlayers()
end

-- Get player by server ID
GlitchAbst.Framework.GetPlayer = function(source)
    return GetPlayer(source)
end

-- Register a server callback
GlitchAbst.Framework.RegisterCallback = function(name, cb)
    QBCore.Functions.CreateCallback(name, cb)
    return true
end

-- Get player from identifier (citizenid)
GlitchAbst.Framework.GetPlayerFromIdentifier = function(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier)
end

-- Money Management
-- Every money function takes (source, amount) or (source, account, amount).
-- Account defaults to cash; 'money' is treated as cash so ESX style calls work too.

GlitchAbst.Framework.GetMoney = function(source, account)
    local player = GetPlayer(source)
    if not player then return 0 end
    return player.Functions.GetMoney(Account(account)) or 0
end

GlitchAbst.Framework.AddMoney = function(source, a, b)
    local account, amount = MoneyArgs(a, b)
    if not amount or amount < 0 then return false end
    if amount == 0 then return true end
    local player = GetPlayer(source)
    if not player then return false end
    return player.Functions.AddMoney(Account(account), amount, Reason('AddMoney')) ~= false
end

-- Returns false when the player could not pay (QBCore refuses to go below zero)
GlitchAbst.Framework.RemoveMoney = function(source, a, b)
    local account, amount = MoneyArgs(a, b)
    if not amount or amount < 0 then return false end
    if amount == 0 then return true end
    local player = GetPlayer(source)
    if not player then return false end
    return player.Functions.RemoveMoney(Account(account), amount, Reason('RemoveMoney')) == true
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
    local job = player and player.PlayerData and player.PlayerData.job
    if job then
        local grade = type(job.grade) == 'table' and job.grade or { level = tonumber(job.grade) or 0 }
        -- Converted to the ESX-like format for consistency
        return {
            name = job.name,
            label = job.label,
            grade = grade.level or 0,
            grade_name = grade.name,
            grade_label = grade.name,
            onduty = job.onduty,
            isboss = job.isboss,
            type = job.type
        }
    end
    return {name = 'unemployed', grade = 0}
end

GlitchAbst.Framework.SetJob = function(source, job, grade)
    local player = GetPlayer(source)
    if player then
        return player.Functions.SetJob(job, grade) ~= false
    end
    return false
end

-- Inventory Management
-- (server/inventory/ox.lua replaces this when ox_inventory is running)
GlitchAbst.Framework.RegisterUsableItem = function(item, cb)
    if not item or not cb then return false end
    QBCore.Functions.CreateUseableItem(item, cb)
    return true
end

GlitchAbst.Framework.UseItem = function(source, item)
    -- QBCore doesn't have a direct UseItem function
    TriggerClientEvent('inventory:client:UseItem', source, item)
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
        local hasItem = player.Functions.GetItemByName(item)
        return hasItem ~= nil and (tonumber(hasItem.amount or hasItem.count) or 0) >= count
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
return true
