-- OX Inventory Implementation
GlitchLib.Utils.DebugLog('OX Inventory module loaded')

-- Item Management
GlitchLib.Inventory.AddItem = function(source, item, count, metadata, slot)
    return exports.ox_inventory:AddItem(source, item, count, metadata, slot)
end

GlitchLib.Inventory.RemoveItem = function(source, item, count, metadata, slot)
    return exports.ox_inventory:RemoveItem(source, item, count, metadata, slot)
end

GlitchLib.Inventory.GetItem = function(source, item, metadata, slot)
    if slot then
        return exports.ox_inventory:GetSlot(source, slot)
    end
    return exports.ox_inventory:GetItem(source, item, metadata)
end

GlitchLib.Inventory.GetItemCount = function(source, item, metadata)
    local itemData = exports.ox_inventory:GetItem(source, item, metadata)
    return itemData and itemData.count or 0
end

GlitchLib.Inventory.CanCarryItem = function(source, item, count, metadata)
    return exports.ox_inventory:CanCarryItem(source, item, count, metadata)
end

GlitchLib.Inventory.CanSwapItem = function(source, firstItem, firstItemCount, toSlot)
    -- OX doesn't have a direct function for this but it handles swaps internally
    return true
end

GlitchLib.Inventory.SetInventory = function(source, items)
    -- OX doesn't have a simple set inventory function, would need to be implemented
    -- through a series of ox_inventory calls
    GlitchLib.Utils.DebugLog('SetInventory not directly supported in ox_inventory')
    return false
end

GlitchLib.Inventory.ClearInventory = function(source)
    -- Clear player inventory in ox_inventory
    local inventory = exports.ox_inventory:GetInventory(source)
    if inventory then
        for _, item in pairs(inventory.items) do
            if item then
                exports.ox_inventory:RemoveItem(source, item.name, item.count, item.metadata)
            end
        end
        return true
    end
    return false
end

-- Additional ox-specific functions
GlitchLib.Inventory.Search = function(source, search, item, metadata)
    return exports.ox_inventory:Search(source, search, item, metadata)
end

GlitchLib.Inventory.GetSlot = function(source, slot)
    return exports.ox_inventory:GetSlot(source, slot)
end

GlitchLib.Inventory.SwapSlots = function(source, fromSlot, toSlot)
    return exports.ox_inventory:SwapSlots(source, fromSlot, toSlot)
end

GlitchLib.Inventory.Confiscate = function(source)
    return exports.ox_inventory:ConfiscateInventory(source)
end

GlitchLib.Inventory.ReturnConfiscated = function(source)
    return exports.ox_inventory:ReturnInventory(source)
end