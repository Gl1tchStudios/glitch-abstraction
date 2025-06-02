-- OX Inventory Server Module

GlitchAbst.Utils.DebugLog('Loading ox_inventory server module')

-- Check if resource is actually available
if GetResourceState('ox_inventory') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_inventory resource is not available')
    return false
end

-- Existing functions first
-- Item Management
GlitchAbst.Inventory.AddItem = function(source, item, amount, metadata, slot, info, reason)
    return exports.ox_inventory:AddItem(source, item, amount, metadata, slot)
end

GlitchAbst.Inventory.RemoveItem = function(source, item, count, metadata, slot, ignoreTotal)
    return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot, ignoreTotal)
end

GlitchAbst.Inventory.GetItem = function(source, item, metadata, returnsCount)
    if returnsCount == nil then returnsCount = false end
    return exports.ox_inventory:GetItem(source, item, metadata, returnsCount)
end

GlitchAbst.Inventory.GetItemCount = function(source, item, metadata, strict)
    return exports.ox_inventory:GetItemCount(source, item, metadata, strict)
end

GlitchAbst.Inventory.CanCarryItem = function(source, item, count, metadata)
    return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
end

-- Player inventory management
GlitchAbst.Inventory.SetPlayerInventory = function(player, data)
    return exports.ox_inventory:setPlayerInventory(player, data)
end

GlitchAbst.Inventory.ForceOpenInventory = function(playerId, invType, data)
    return exports.ox_inventory:forceOpenInventory(playerId, invType, data)
end

GlitchAbst.Inventory.UpdateVehicle = function(oldPlate, newPlate)
    return exports.ox_inventory:UpdateVehicle(oldPlate, newPlate)
end

-- Item data
GlitchAbst.Inventory.GetItems = function(itemName)
    return exports.ox_inventory:Items(itemName)
end

-- Weight and capacity functions
GlitchAbst.Inventory.CanCarryAmount = function(inv, item)
    return exports.ox_inventory:CanCarryAmount(inv, item)
end

GlitchAbst.Inventory.CanCarryWeight = function(inv, weight)
    return exports.ox_inventory:CanCarryWeight(inv, weight)
end

GlitchAbst.Inventory.SetMaxWeight = function(inv, maxWeight)
    return exports.ox_inventory:SetMaxWeight(inv, maxWeight)
end

-- Slot and item utility functions
GlitchAbst.Inventory.GetItemSlots = function(inv, item, metadata)
    return exports.ox_inventory:GetItemSlots(inv, item, metadata)
end

GlitchAbst.Inventory.GetSlotForItem = function(inv, itemName, metadata)
    return exports.ox_inventory:GetSlotForItem(inv, itemName, metadata)
end

GlitchAbst.Inventory.GetSlotIdWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdWithItem(inv, itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotIdsWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdsWithItem(inv, itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotWithItem(inv, itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotsWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotsWithItem(inv, itemName, metadata, strict)
end

GlitchAbst.Inventory.GetEmptySlot = function(inv)
    return exports.ox_inventory:GetEmptySlot(inv)
end

GlitchAbst.Inventory.GetContainerFromSlot = function(inv, slotId)
    return exports.ox_inventory:GetContainerFromSlot(inv, slotId)
end

GlitchAbst.Inventory.SetSlotCount = function(inv, slots)
    return exports.ox_inventory:SetSlotCount(inv, slots)
end

-- Inventory functions
GlitchAbst.Inventory.GetInventory = function(inv, owner)
    return exports.ox_inventory:GetInventory(inv, owner)
end

GlitchAbst.Inventory.GetInventoryItems = function(inv, owner)
    return exports.ox_inventory:GetInventoryItems(inv, owner)
end

GlitchAbst.Inventory.InspectInventory = function(target, source)
    return exports.ox_inventory:InspectInventory(target, source)
end

GlitchAbst.Inventory.ConfiscateInventory = function(source)
    return exports.ox_inventory:ConfiscateInventory(source)
end

GlitchAbst.Inventory.ReturnInventory = function(source)
    return exports.ox_inventory:ReturnInventory(source)
end

GlitchAbst.Inventory.ClearInventory = function(inv, keep)
    return exports.ox_inventory:ClearInventory(inv, keep)
end

-- Stash management
GlitchAbst.Inventory.RegisterStash = function(id, label, slots, maxWeight, owner, groups, coords)
    return exports.ox_inventory:RegisterStash(id, label, slots, maxWeight, owner, groups, coords)
end

GlitchAbst.Inventory.CreateTemporaryStash = function(properties)
    return exports.ox_inventory:CreateTemporaryStash(properties)
end

-- Drop management
GlitchAbst.Inventory.CustomDrop = function(prefix, items, coords, slots, maxWeight, instance, model)
    return exports.ox_inventory:CustomDrop(prefix, items, coords, slots, maxWeight, instance, model)
end

GlitchAbst.Inventory.CreateDropFromPlayer = function(playerId)
    return exports.ox_inventory:CreateDropFromPlayer(playerId)
end

-- Weapon management
GlitchAbst.Inventory.GetCurrentWeapon = function(inv)
    return exports.ox_inventory:GetCurrentWeapon(inv)
end

GlitchAbst.Inventory.SetDurability = function(inv, slot, durability)
    return exports.ox_inventory:SetDurability(inv, slot, durability)
end

-- Item metadata
GlitchAbst.Inventory.SetMetadata = function(inv, slot, metadata)
    return exports.ox_inventory:SetMetadata(inv, slot, metadata)
end

-- Data conversion
GlitchAbst.Inventory.ConvertItems = function(playerId, items)
    return exports.ox_inventory:ConvertItems(playerId, items)
end

-- Convenience aliases
GlitchAbst.Inventory.Confiscate = GlitchAbst.Inventory.ConfiscateInventory
GlitchAbst.Inventory.Return = GlitchAbst.Inventory.ReturnInventory
GlitchAbst.Inventory.OpenInventory = GlitchAbst.Inventory.ForceOpenInventory
GlitchAbst.Inventory.GetAllItems = GlitchAbst.Inventory.GetItems

-- Helper functions for common operations
GlitchAbst.Inventory.GiveItem = function(source, target, item, count, metadata)
    -- Simulate giving an item from one player to another
    if source == target then return false end
    
    if exports.ox_inventory:RemoveItem(source, item, count, metadata) then
        if exports.ox_inventory:AddItem(target, item, count, metadata) then
            return true
        else
            -- Roll back if target couldn't receive the item
            exports.ox_inventory:AddItem(source, item, count, metadata)
            return false
        end
    end
    return false
end

GlitchAbst.Inventory.HasItem = function(source, items, metadata)
    -- Simple check if player has an item or items
    if type(items) == 'string' then
        local count = GlitchAbst.Inventory.GetItemCount(source, items, metadata)
        return count > 0, count
    else
        local hasAll = true
        local results = {}
        
        for _, item in pairs(items) do
            local count = GlitchAbst.Inventory.GetItemCount(source, item, metadata)
            results[item] = count
            if count <= 0 then hasAll = false end
        end
        
        return hasAll, results
    end
end

-- Hook system for ox_inventory events
GlitchAbst.Inventory.Hooks = {}
GlitchAbst.Inventory.RegisteredHooks = {}

-- Register a hook for inventory events
GlitchAbst.Inventory.RegisterHook = function(eventName, callback, options)
    local hookId = exports.ox_inventory:registerHook(eventName, callback, options)
    
    -- Store the hook reference for later management
    GlitchAbst.Inventory.RegisteredHooks[hookId] = {
        id = hookId,
        event = eventName,
        options = options
    }
    
    return hookId
end

-- Remove hooks (single or all from this resource)
GlitchAbst.Inventory.RemoveHook = function(id)
    exports.ox_inventory:removeHooks(id)
    
    if id then
        GlitchAbst.Inventory.RegisteredHooks[id] = nil
    else
        GlitchAbst.Inventory.RegisteredHooks = {}
    end
    
    return true
end

-- Remove all hooks
GlitchAbst.Inventory.RemoveAllHooks = function()
    exports.ox_inventory:removeHooks()
    GlitchAbst.Inventory.RegisteredHooks = {}
    return true
end

-- Convenience alias
GlitchAbst.Inventory.Hooks.Register = GlitchAbst.Inventory.RegisterHook
GlitchAbst.Inventory.Hooks.Remove = GlitchAbst.Inventory.RemoveHook
GlitchAbst.Inventory.Hooks.RemoveAll = GlitchAbst.Inventory.RemoveAllHooks

-- Helper for common hooks
GlitchAbst.Inventory.Hooks.OnSwapItems = function(callback, options)
    return GlitchAbst.Inventory.RegisterHook('swapItems', callback, options)
end

GlitchAbst.Inventory.Hooks.OnOpenInventory = function(callback, options)
    return GlitchAbst.Inventory.RegisterHook('openInventory', callback, options)
end

GlitchAbst.Inventory.Hooks.OnCreateItem = function(callback, options)
    return GlitchAbst.Inventory.RegisterHook('createItem', callback, options)
end

GlitchAbst.Inventory.Hooks.OnBuyItem = function(callback, options)
    return GlitchAbst.Inventory.RegisterHook('buyItem', callback, options)
end

GlitchAbst.Inventory.Hooks.OnCraftItem = function(callback, options)
    return GlitchAbst.Inventory.RegisterHook('craftItem', callback, options)
end

GlitchAbst.Utils.DebugLog('ox_inventory server module loaded with hooks support')
return true