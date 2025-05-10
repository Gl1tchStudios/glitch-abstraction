-- OX Inventory Server Module

GlitchLib.Utils.DebugLog('Loading ox_inventory server module')

-- Check if resource is actually available
if GetResourceState('ox_inventory') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_inventory resource is not available')
    return false
end

-- Existing functions first
-- Item Management
GlitchLib.Inventory.AddItem = function(source, item, amount, metadata, slot, info, reason)
    return exports.ox_inventory:AddItem(source, item, count, metadata, slot)
end

GlitchLib.Inventory.RemoveItem = function(source, item, count, metadata, slot, ignoreTotal)
    return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot, ignoreTotal)
end

GlitchLib.Inventory.GetItem = function(source, item, metadata, returnsCount)
    if returnsCount == nil then returnsCount = false end
    return exports.ox_inventory:GetItem(source, item, metadata, returnsCount)
end

GlitchLib.Inventory.GetItemCount = function(source, item, metadata, strict)
    return exports.ox_inventory:GetItemCount(source, item, metadata, strict)
end

GlitchLib.Inventory.CanCarryItem = function(source, item, count, metadata)
    return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
end

-- Player inventory management
GlitchLib.Inventory.SetPlayerInventory = function(player, data)
    return exports.ox_inventory:setPlayerInventory(player, data)
end

GlitchLib.Inventory.ForceOpenInventory = function(playerId, invType, data)
    return exports.ox_inventory:forceOpenInventory(playerId, invType, data)
end

GlitchLib.Inventory.UpdateVehicle = function(oldPlate, newPlate)
    return exports.ox_inventory:UpdateVehicle(oldPlate, newPlate)
end

-- Item data
GlitchLib.Inventory.GetItems = function(itemName)
    return exports.ox_inventory:Items(itemName)
end

-- Weight and capacity functions
GlitchLib.Inventory.CanCarryAmount = function(inv, item)
    return exports.ox_inventory:CanCarryAmount(inv, item)
end

GlitchLib.Inventory.CanCarryWeight = function(inv, weight)
    return exports.ox_inventory:CanCarryWeight(inv, weight)
end

GlitchLib.Inventory.SetMaxWeight = function(inv, maxWeight)
    return exports.ox_inventory:SetMaxWeight(inv, maxWeight)
end

-- Slot and item utility functions
GlitchLib.Inventory.GetItemSlots = function(inv, item, metadata)
    return exports.ox_inventory:GetItemSlots(inv, item, metadata)
end

GlitchLib.Inventory.GetSlotForItem = function(inv, itemName, metadata)
    return exports.ox_inventory:GetSlotForItem(inv, itemName, metadata)
end

GlitchLib.Inventory.GetSlotIdWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdWithItem(inv, itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotIdsWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdsWithItem(inv, itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotWithItem(inv, itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotsWithItem = function(inv, itemName, metadata, strict)
    return exports.ox_inventory:GetSlotsWithItem(inv, itemName, metadata, strict)
end

GlitchLib.Inventory.GetEmptySlot = function(inv)
    return exports.ox_inventory:GetEmptySlot(inv)
end

GlitchLib.Inventory.GetContainerFromSlot = function(inv, slotId)
    return exports.ox_inventory:GetContainerFromSlot(inv, slotId)
end

GlitchLib.Inventory.SetSlotCount = function(inv, slots)
    return exports.ox_inventory:SetSlotCount(inv, slots)
end

-- Inventory functions
GlitchLib.Inventory.GetInventory = function(inv, owner)
    return exports.ox_inventory:GetInventory(inv, owner)
end

GlitchLib.Inventory.GetInventoryItems = function(inv, owner)
    return exports.ox_inventory:GetInventoryItems(inv, owner)
end

GlitchLib.Inventory.InspectInventory = function(target, source)
    return exports.ox_inventory:InspectInventory(target, source)
end

GlitchLib.Inventory.ConfiscateInventory = function(source)
    return exports.ox_inventory:ConfiscateInventory(source)
end

GlitchLib.Inventory.ReturnInventory = function(source)
    return exports.ox_inventory:ReturnInventory(source)
end

GlitchLib.Inventory.ClearInventory = function(inv, keep)
    return exports.ox_inventory:ClearInventory(inv, keep)
end

-- Stash management
GlitchLib.Inventory.RegisterStash = function(id, label, slots, maxWeight, owner, groups, coords)
    return exports.ox_inventory:RegisterStash(id, label, slots, maxWeight, owner, groups, coords)
end

GlitchLib.Inventory.CreateTemporaryStash = function(properties)
    return exports.ox_inventory:CreateTemporaryStash(properties)
end

-- Drop management
GlitchLib.Inventory.CustomDrop = function(prefix, items, coords, slots, maxWeight, instance, model)
    return exports.ox_inventory:CustomDrop(prefix, items, coords, slots, maxWeight, instance, model)
end

GlitchLib.Inventory.CreateDropFromPlayer = function(playerId)
    return exports.ox_inventory:CreateDropFromPlayer(playerId)
end

-- Weapon management
GlitchLib.Inventory.GetCurrentWeapon = function(inv)
    return exports.ox_inventory:GetCurrentWeapon(inv)
end

GlitchLib.Inventory.SetDurability = function(inv, slot, durability)
    return exports.ox_inventory:SetDurability(inv, slot, durability)
end

-- Item metadata
GlitchLib.Inventory.SetMetadata = function(inv, slot, metadata)
    return exports.ox_inventory:SetMetadata(inv, slot, metadata)
end

-- Data conversion
GlitchLib.Inventory.ConvertItems = function(playerId, items)
    return exports.ox_inventory:ConvertItems(playerId, items)
end

-- Convenience aliases
GlitchLib.Inventory.Confiscate = GlitchLib.Inventory.ConfiscateInventory
GlitchLib.Inventory.Return = GlitchLib.Inventory.ReturnInventory
GlitchLib.Inventory.OpenInventory = GlitchLib.Inventory.ForceOpenInventory
GlitchLib.Inventory.GetAllItems = GlitchLib.Inventory.GetItems

-- Helper functions for common operations
GlitchLib.Inventory.GiveItem = function(source, target, item, count, metadata)
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

GlitchLib.Inventory.HasItem = function(source, items, metadata)
    -- Simple check if player has an item or items
    if type(items) == 'string' then
        local count = GlitchLib.Inventory.GetItemCount(source, items, metadata)
        return count > 0, count
    else
        local hasAll = true
        local results = {}
        
        for _, item in pairs(items) do
            local count = GlitchLib.Inventory.GetItemCount(source, item, metadata)
            results[item] = count
            if count <= 0 then hasAll = false end
        end
        
        return hasAll, results
    end
end

-- Hook system for ox_inventory events
GlitchLib.Inventory.Hooks = {}
GlitchLib.Inventory.RegisteredHooks = {}

-- Register a hook for inventory events
GlitchLib.Inventory.RegisterHook = function(eventName, callback, options)
    local hookId = exports.ox_inventory:registerHook(eventName, callback, options)
    
    -- Store the hook reference for later management
    GlitchLib.Inventory.RegisteredHooks[hookId] = {
        id = hookId,
        event = eventName,
        options = options
    }
    
    return hookId
end

-- Remove hooks (single or all from this resource)
GlitchLib.Inventory.RemoveHook = function(id)
    exports.ox_inventory:removeHooks(id)
    
    if id then
        GlitchLib.Inventory.RegisteredHooks[id] = nil
    else
        GlitchLib.Inventory.RegisteredHooks = {}
    end
    
    return true
end

-- Remove all hooks
GlitchLib.Inventory.RemoveAllHooks = function()
    exports.ox_inventory:removeHooks()
    GlitchLib.Inventory.RegisteredHooks = {}
    return true
end

-- Convenience alias
GlitchLib.Inventory.Hooks.Register = GlitchLib.Inventory.RegisterHook
GlitchLib.Inventory.Hooks.Remove = GlitchLib.Inventory.RemoveHook
GlitchLib.Inventory.Hooks.RemoveAll = GlitchLib.Inventory.RemoveAllHooks

-- Helper for common hooks
GlitchLib.Inventory.Hooks.OnSwapItems = function(callback, options)
    return GlitchLib.Inventory.RegisterHook('swapItems', callback, options)
end

GlitchLib.Inventory.Hooks.OnOpenInventory = function(callback, options)
    return GlitchLib.Inventory.RegisterHook('openInventory', callback, options)
end

GlitchLib.Inventory.Hooks.OnCreateItem = function(callback, options)
    return GlitchLib.Inventory.RegisterHook('createItem', callback, options)
end

GlitchLib.Inventory.Hooks.OnBuyItem = function(callback, options)
    return GlitchLib.Inventory.RegisterHook('buyItem', callback, options)
end

GlitchLib.Inventory.Hooks.OnCraftItem = function(callback, options)
    return GlitchLib.Inventory.RegisterHook('craftItem', callback, options)
end

GlitchLib.Utils.DebugLog('ox_inventory server module loaded with hooks support')
return true