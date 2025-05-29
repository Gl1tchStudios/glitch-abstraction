-- QBCore Inventory Server Module

GlitchAbst.Utils.DebugLog('Loading qb-inventory server module')

-- Check if resource is actually available
if GetResourceState('qb-inventory') ~= 'started' then
    GlitchAbst.Utils.DebugLog('qb-inventory resource is not available')
    return false
end

-- Ensure inventory namespace exists
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

-- Inventory Management
GlitchAbst.Inventory.LoadInventory = function(source, citizenid)
    return exports['qb-inventory']:LoadInventory(source, citizenid)
end

GlitchAbst.Inventory.SaveInventory = function(source, offline)
    return exports['qb-inventory']:SaveInventory(source, offline or false)
end

GlitchAbst.Inventory.ClearInventory = function(source, filterItems)
    return exports['qb-inventory']:ClearInventory(source, filterItems)
end

-- Opening/closing inventories
GlitchAbst.Inventory.OpenInventory = function(source, identifier, data)
    return exports['qb-inventory']:OpenInventory(source, identifier, data)
end

GlitchAbst.Inventory.CloseInventory = function(source, identifier)
    return exports['qb-inventory']:CloseInventory(source, identifier)
end

GlitchAbst.Inventory.OpenInventoryById = function(source, playerId)
    return exports['qb-inventory']:OpenInventoryById(source, playerId)
end

-- Shop functions
GlitchAbst.Inventory.CreateShop = function(shopData)
    return exports['qb-inventory']:CreateShop(shopData)
end

GlitchAbst.Inventory.OpenShop = function(source, name)
    return exports['qb-inventory']:OpenShop(source, name)
end

-- Item functions
GlitchAbst.Inventory.CanAddItem = function(source, item, amount)
    return exports['qb-inventory']:CanAddItem(source, item, amount)
end

GlitchAbst.Inventory.AddItem = function(source, item, amount, metadata, slot, info, reason)
    return exports['qb-inventory']:AddItem(source, item, amount, slot, info, reason or 'glitch-lib:addItem')
end

GlitchAbst.Inventory.RemoveItem = function(source, item, amount, slot, reason)
    return exports['qb-inventory']:RemoveItem(source, item, amount, slot or false, reason or 'glitch-lib:removeItem')
end

GlitchAbst.Inventory.SetInventory = function(source, items)
    return exports['qb-inventory']:SetInventory(source, items)
end

GlitchAbst.Inventory.SetItemData = function(source, itemName, key, val)
    return exports['qb-inventory']:SetItemData(source, itemName, key, val)
end

GlitchAbst.Inventory.UseItem = function(itemName, callback)
    return exports['qb-inventory']:UseItem(itemName, callback)
end

GlitchAbst.Inventory.HasItem = function(source, items, amount)
    return exports['qb-inventory']:HasItem(source, items, amount)
end

-- Weight and slot information
GlitchAbst.Inventory.GetFreeWeight = function(source)
    return exports['qb-inventory']:GetFreeWeight(source)
end

GlitchAbst.Inventory.GetSlots = function(identifier)
    return exports['qb-inventory']:GetSlots(identifier)
end

-- Item retrieval
GlitchAbst.Inventory.GetSlotsByItem = function(items, itemName)
    return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

GlitchAbst.Inventory.GetFirstSlotByItem = function(items, itemName)
    return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

GlitchAbst.Inventory.GetItemBySlot = function(source, slot)
    return exports['qb-inventory']:GetItemBySlot(source, slot)
end

GlitchAbst.Inventory.GetItemByName = function(source, item)
    return exports['qb-inventory']:GetItemByName(source, item)
end

GlitchAbst.Inventory.GetItemsByName = function(source, item)
    return exports['qb-inventory']:GetItemsByName(source, item)
end

GlitchAbst.Inventory.GetItemCount = function(source, items)
    return exports['qb-inventory']:GetItemCount(source, items)
end

-- Inventory state control
GlitchAbst.Inventory.SetBusy = function(source, state)
    if state == nil then state = true end
    local player = Player(source)
    if player then
        player.state.inv_busy = state
    end
    return true
end

GlitchAbst.Inventory.IsBusy = function(source)
    local player = Player(source)
    return player and player.state.inv_busy or false
end

-- Helper functions
GlitchAbst.Inventory.HasEnoughOfItem = function(source, itemName, amount)
    local count = GlitchAbst.Inventory.GetItemCount(source, itemName)
    return count >= amount, count
end

GlitchAbst.Inventory.GiveItemToPlayer = function(source, target, item, amount, info)
    if source == target then return false end
    
    if GlitchAbst.Inventory.RemoveItem(source, item, amount, false, 'glitch-lib:giveItem') then
        if GlitchAbst.Inventory.AddItem(target, item, amount, false, info, 'glitch-lib:receiveItem') then
            return true
        else
            -- Return the item if target couldn't receive it
            GlitchAbst.Inventory.AddItem(source, item, amount, false, info, 'glitch-lib:returnItem')
            return false
        end
    end
    return false
end

local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('glitch-lib:server:GetSlotsByItem', function(source, cb, itemName)
    local Player = QBCore.Functions.GetPlayer(source)
    local items = Player.PlayerData.Items
    cb(exports['qb-inventory']:GetSlotsByItem(items, itemName))
end)

QBCore.Functions.CreateCallback('glitch-lib:server:GetItemCount', function(source, cb, itemName)
    cb(exports['qb-inventory']:GetItemCount(source, itemName))
end)

-- Create aliases for consistent function naming across the library
GlitchAbst.Inventory.LockInventory = function(source) GlitchAbst.Inventory.SetBusy(source, true) end
GlitchAbst.Inventory.UnlockInventory = function(source) GlitchAbst.Inventory.SetBusy(source, false) end
GlitchAbst.Inventory.Open = GlitchAbst.Inventory.OpenInventory
GlitchAbst.Inventory.Close = GlitchAbst.Inventory.CloseInventory

GlitchAbst.Utils.DebugLog('qb-inventory server module loaded')
return true