-- QBCore Inventory Server Module

GlitchLib.Utils.DebugLog('Loading qb-inventory server module')

-- Check if resource is actually available
if GetResourceState('qb-inventory') ~= 'started' then
    GlitchLib.Utils.DebugLog('qb-inventory resource is not available')
    return false
end

-- Ensure inventory namespace exists
GlitchLib.Inventory = GlitchLib.Inventory or {}

-- Inventory Management
GlitchLib.Inventory.LoadInventory = function(source, citizenid)
    return exports['qb-inventory']:LoadInventory(source, citizenid)
end

GlitchLib.Inventory.SaveInventory = function(source, offline)
    return exports['qb-inventory']:SaveInventory(source, offline or false)
end

GlitchLib.Inventory.ClearInventory = function(source, filterItems)
    return exports['qb-inventory']:ClearInventory(source, filterItems)
end

-- Opening/closing inventories
GlitchLib.Inventory.OpenInventory = function(source, identifier, data)
    return exports['qb-inventory']:OpenInventory(source, identifier, data)
end

GlitchLib.Inventory.CloseInventory = function(source, identifier)
    return exports['qb-inventory']:CloseInventory(source, identifier)
end

GlitchLib.Inventory.OpenInventoryById = function(source, playerId)
    return exports['qb-inventory']:OpenInventoryById(source, playerId)
end

-- Shop functions
GlitchLib.Inventory.CreateShop = function(shopData)
    return exports['qb-inventory']:CreateShop(shopData)
end

GlitchLib.Inventory.OpenShop = function(source, name)
    return exports['qb-inventory']:OpenShop(source, name)
end

-- Item functions
GlitchLib.Inventory.CanAddItem = function(source, item, amount)
    return exports['qb-inventory']:CanAddItem(source, item, amount)
end

GlitchLib.Inventory.AddItem = function(source, item, amount, slot, info, reason)
    return exports['qb-inventory']:AddItem(source, item, amount, slot or false, info or false, reason or 'glitch-lib:addItem')
end

GlitchLib.Inventory.RemoveItem = function(source, item, amount, slot, reason)
    return exports['qb-inventory']:RemoveItem(source, item, amount, slot or false, reason or 'glitch-lib:removeItem')
end

GlitchLib.Inventory.SetInventory = function(source, items)
    return exports['qb-inventory']:SetInventory(source, items)
end

GlitchLib.Inventory.SetItemData = function(source, itemName, key, val)
    return exports['qb-inventory']:SetItemData(source, itemName, key, val)
end

GlitchLib.Inventory.UseItem = function(itemName, callback)
    return exports['qb-inventory']:UseItem(itemName, callback)
end

GlitchLib.Inventory.HasItem = function(source, items, amount)
    return exports['qb-inventory']:HasItem(source, items, amount)
end

-- Weight and slot information
GlitchLib.Inventory.GetFreeWeight = function(source)
    return exports['qb-inventory']:GetFreeWeight(source)
end

GlitchLib.Inventory.GetSlots = function(identifier)
    return exports['qb-inventory']:GetSlots(identifier)
end

-- Item retrieval
GlitchLib.Inventory.GetSlotsByItem = function(items, itemName)
    return exports['qb-inventory']:GetSlotsByItem(items, itemName)
end

GlitchLib.Inventory.GetFirstSlotByItem = function(items, itemName)
    return exports['qb-inventory']:GetFirstSlotByItem(items, itemName)
end

GlitchLib.Inventory.GetItemBySlot = function(source, slot)
    return exports['qb-inventory']:GetItemBySlot(source, slot)
end

GlitchLib.Inventory.GetItemByName = function(source, item)
    return exports['qb-inventory']:GetItemByName(source, item)
end

GlitchLib.Inventory.GetItemsByName = function(source, item)
    return exports['qb-inventory']:GetItemsByName(source, item)
end

GlitchLib.Inventory.GetItemCount = function(source, items)
    return exports['qb-inventory']:GetItemCount(source, items)
end

-- Inventory state control
GlitchLib.Inventory.SetBusy = function(source, state)
    if state == nil then state = true end
    local player = Player(source)
    if player then
        player.state.inv_busy = state
    end
    return true
end

GlitchLib.Inventory.IsBusy = function(source)
    local player = Player(source)
    return player and player.state.inv_busy or false
end

-- Helper functions
GlitchLib.Inventory.HasEnoughOfItem = function(source, itemName, amount)
    local count = GlitchLib.Inventory.GetItemCount(source, itemName)
    return count >= amount, count
end

GlitchLib.Inventory.GiveItemToPlayer = function(source, target, item, amount, info)
    if source == target then return false end
    
    if GlitchLib.Inventory.RemoveItem(source, item, amount, false, 'glitch-lib:giveItem') then
        if GlitchLib.Inventory.AddItem(target, item, amount, false, info, 'glitch-lib:receiveItem') then
            return true
        else
            -- Return the item if target couldn't receive it
            GlitchLib.Inventory.AddItem(source, item, amount, false, info, 'glitch-lib:returnItem')
            return false
        end
    end
    return false
end

-- Create aliases for consistent function naming across the library
GlitchLib.Inventory.LockInventory = function(source) GlitchLib.Inventory.SetBusy(source, true) end
GlitchLib.Inventory.UnlockInventory = function(source) GlitchLib.Inventory.SetBusy(source, false) end
GlitchLib.Inventory.Open = GlitchLib.Inventory.OpenInventory
GlitchLib.Inventory.Close = GlitchLib.Inventory.CloseInventory

GlitchLib.Utils.DebugLog('qb-inventory server module loaded')
return true