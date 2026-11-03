-- QBCore Inventory Client Module (qb-inventory)

-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading qb-inventory module^7")
    return false
end

-- Skip if inventory system doesn't match
if Config and Config.InventorySystem and Config.InventorySystem ~= 'qb' and Config.InventorySystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping qb-inventory module (using ' .. Config.InventorySystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('qb-inventory') ~= 'started' then
    GlitchAbst.Utils.DebugLog('qb-inventory resource is not available')
    return false
end

local okCore, QBCore = pcall(function() return exports['qb-core']:GetCoreObject() end)
if not okCore or not QBCore then
    GlitchAbst.Utils.DebugLog('qb-inventory module needs qb-core')
    return false
end

-- Initialize inventory namespace
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

GlitchAbst.Utils.DebugLog('Loading qb-inventory client module')

local function Items()
    local data = QBCore.Functions.GetPlayerData() or {}
    return data.items or {}
end

-- Check if player has an item (single name, list of names or { [name] = amount })
GlitchAbst.Inventory.HasItem = function(items, amount)
    if type(amount) ~= 'number' then amount = 1 end
    if QBCore.Functions.HasItem then
        return QBCore.Functions.HasItem(items, amount)
    end
    return exports['qb-inventory']:HasItem(items, amount)
end

-- Count of an item the player is carrying (read from the player data)
GlitchAbst.Inventory.GetItemCount = function(itemName)
    local count = 0
    for _, item in pairs(Items()) do
        if item and item.name == itemName then
            count = count + (tonumber(item.amount or item.count) or 0)
        end
    end
    return count
end

-- Player items (slot -> item)
GlitchAbst.Inventory.GetPlayerItems = function()
    return Items()
end

-- Item definitions (same shape as ox: Items() = all, Items(name) = one)
GlitchAbst.Inventory.GetItems = function(itemName)
    local shared = (QBCore.Shared and QBCore.Shared.Items) or {}
    if itemName then return shared[itemName] end
    return shared
end

-- Inventory state control
GlitchAbst.Inventory.SetBusy = function(state)
    if state == nil then state = true end
    LocalPlayer.state:set('inv_busy', state, true)
end

GlitchAbst.Inventory.IsBusy = function()
    return LocalPlayer.state.inv_busy or false
end

-- Close inventory
GlitchAbst.Inventory.Close = function()
    TriggerEvent('inventory:client:CloseInventory')
    ExecuteCommand('closeinv')
    return true
end

-- Use an item from a specific slot
GlitchAbst.Inventory.UseSlot = function(slot)
    if not slot then return false end
    TriggerServerEvent('inventory:server:UseItemSlot', slot)
    return true
end

-- Same as ox_inventory's Search: 'count' -> number, 'slots' -> list of slot items.
-- itemName may be a single name or a list of names (then a table keyed by name is returned).
-- metadata is used by ox_inventory only and is ignored here.
GlitchAbst.Inventory.Search = function(search, itemName, metadata)
    local function slotsOf(name)
        local list = {}
        for _, item in pairs(Items()) do
            if item and item.name == name then list[#list + 1] = item end
        end
        return list
    end

    if type(itemName) == 'table' then
        local result = {}
        for _, name in ipairs(itemName) do
            if search == 'count' then
                result[name] = GlitchAbst.Inventory.GetItemCount(name)
            else
                result[name] = slotsOf(name)
            end
        end
        return result
    end

    if search == 'count' then
        return GlitchAbst.Inventory.GetItemCount(itemName)
    elseif search == 'slots' then
        return slotsOf(itemName)
    end
    return {}
end

-- Use a specific item
GlitchAbst.Inventory.UseItem = function(item)
    if not item then return false end
    TriggerServerEvent('inventory:server:UseItem', item)
    return true
end

-- Create aliases for consistent function naming
GlitchAbst.Inventory.CloseInventory = GlitchAbst.Inventory.Close
GlitchAbst.Inventory.IsInventoryBusy = GlitchAbst.Inventory.IsBusy
GlitchAbst.Inventory.SetInventoryBusy = GlitchAbst.Inventory.SetBusy
GlitchAbst.Inventory.LockInventory = function() GlitchAbst.Inventory.SetBusy(true) end
GlitchAbst.Inventory.UnlockInventory = function() GlitchAbst.Inventory.SetBusy(false) end

GlitchAbst.Utils.DebugLog('qb-inventory client module loaded')
return true
