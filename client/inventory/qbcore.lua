-- QBCore Inventory Client Module

GlitchLib.Utils.DebugLog('Loading qb-inventory client module')

-- Check if resource is actually available
if GetResourceState('qb-inventory') ~= 'started' then
    GlitchLib.Utils.DebugLog('qb-inventory resource is not available')
    return false
end

-- Ensure inventory namespace exists
GlitchLib.Inventory = GlitchLib.Inventory or {}

-- Check if player has an item (both single item and multiple items)
GlitchLib.Inventory.HasItem = function(items, amount)
    if type(items) == 'string' then
        -- For a single item
        return exports['qb-inventory']:HasItem(items, amount or 1)
    elseif type(items) == 'table' and not items.name then
        -- For multiple items
        return exports['qb-inventory']:HasItem(items, amount or 1)
    end
    return false
end

-- Inventory state control
GlitchLib.Inventory.SetBusy = function(state)
    if state == nil then state = true end
    LocalPlayer.state:set('inv_busy', state, true)
end

GlitchLib.Inventory.IsBusy = function()
    return LocalPlayer.state.inv_busy or false
end

-- Close inventory
GlitchLib.Inventory.Close = function()
    TriggerEvent('inventory:client:CloseInventory')
    return true
end

-- Use an item from a specific slot
GlitchLib.Inventory.UseSlot = function(slot)
    if not slot then return false end
    TriggerServerEvent('inventory:server:UseItemSlot', slot)
    return true
end

-- Use a specific item
GlitchLib.Inventory.UseItem = function(item)
    if not item then return false end
    TriggerServerEvent('inventory:server:UseItem', item)
    return true
end

-- Create aliases for consistent function naming
GlitchLib.Inventory.CloseInventory = GlitchLib.Inventory.Close
GlitchLib.Inventory.IsInventoryBusy = GlitchLib.Inventory.IsBusy
GlitchLib.Inventory.LockInventory = function() GlitchLib.Inventory.SetBusy(true) end
GlitchLib.Inventory.UnlockInventory = function() GlitchLib.Inventory.SetBusy(false) end

-- Register events
RegisterNetEvent('inventory:client:ItemBox', function(itemData, type)
    -- Optional: You could add a callback registration system here
    -- to handle item box notifications
end)

GlitchLib.Utils.DebugLog('qb-inventory client module loaded')
return true