-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ox_inventory module^7")
    return false
end

-- Skip if inventory system doesn't match
if Config and Config.InventorySystem and Config.InventorySystem ~= 'ox' and Config.InventorySystem ~= 'auto' then
    GlitchAbst.Utils.DebugLog('Skipping ox_inventory module (using ' .. Config.InventorySystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_inventory') ~= 'started' then
    GlitchAbst.Utils.DebugLog('ox_inventory resource is not available')
    return false
end

-- Initialize inventory namespace
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

-- Basic inventory functions
GlitchAbst.Inventory.OpenInventory = function(invType, data)
    return exports.ox_inventory:openInventory(invType, data)
end

GlitchAbst.Inventory.OpenNearbyInventory = function()
    return exports.ox_inventory:openNearbyInventory()
end

GlitchAbst.Inventory.CloseInventory = function()
    return exports.ox_inventory:closeInventory()
end

GlitchAbst.Inventory.GetItems = function(itemName)
    return exports.ox_inventory:Items(itemName)
end

GlitchAbst.Inventory.UseItem = function(data, cb)
    return exports.ox_inventory:useItem(data, cb)
end

GlitchAbst.Inventory.UseSlot = function(slot)
    return exports.ox_inventory:useSlot(slot)
end

GlitchAbst.Inventory.SetStashTarget = function(id, owner)
    return exports.ox_inventory:setStashTarget(id, owner)
end

GlitchAbst.Inventory.GetCurrentWeapon = function()
    return exports.ox_inventory:getCurrentWeapon()
end

GlitchAbst.Inventory.DisplayMetadata = function(metadata, value)
    return exports.ox_inventory:displayMetadata(metadata, value)
end

GlitchAbst.Inventory.GiveItemToTarget = function(serverId, slotId, count)
    return exports.ox_inventory:giveItemToTarget(serverId, slotId, count)
end

GlitchAbst.Inventory.WeaponWheel = function(state)
    return exports.ox_inventory:weaponWheel(state)
end

GlitchAbst.Inventory.Search = function(search, item, metadata)
    return exports.ox_inventory:Search(search, item, metadata)
end

GlitchAbst.Inventory.GetItemCount = function(itemName, metadata, strict)
    return exports.ox_inventory:GetItemCount(itemName, metadata, strict)
end

GlitchAbst.Inventory.GetPlayerItems = function()
    return exports.ox_inventory:GetPlayerItems()
end

GlitchAbst.Inventory.GetPlayerWeight = function()
    return exports.ox_inventory:GetPlayerWeight()
end

GlitchAbst.Inventory.GetPlayerMaxWeight = function()
    return exports.ox_inventory:GetPlayerMaxWeight()
end

GlitchAbst.Inventory.GetSlotIdWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdWithItem(itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotIdsWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdsWithItem(itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotWithItem(itemName, metadata, strict)
end

GlitchAbst.Inventory.GetSlotsWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotsWithItem(itemName, metadata, strict)
end

-- State bag helpers
GlitchAbst.Inventory.IsInventoryBusy = function()
    return LocalPlayer.state.invBusy or false
end

GlitchAbst.Inventory.SetInventoryBusy = function(state)
    LocalPlayer.state.invBusy = state
end

GlitchAbst.Inventory.AreHotkeysEnabled = function()
    return LocalPlayer.state.invHotkeys ~= false
end

GlitchAbst.Inventory.SetHotkeysEnabled = function(state)
    LocalPlayer.state.invHotkeys = state
end

GlitchAbst.Inventory.IsInventoryOpen = function()
    return LocalPlayer.state.invOpen or false
end

GlitchAbst.Inventory.CanUseWeapons = function()
    return LocalPlayer.state.canUseWeapons ~= false
end

GlitchAbst.Inventory.SetCanUseWeapons = function(state)
    LocalPlayer.state.canUseWeapons = state
end

-- Create aliases for consistent function naming across the library
GlitchAbst.Inventory.Open = GlitchAbst.Inventory.OpenInventory
GlitchAbst.Inventory.Close = GlitchAbst.Inventory.CloseInventory
GlitchAbst.Inventory.OpenNearby = GlitchAbst.Inventory.OpenNearbyInventory

-- Add event handler for current weapon
AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon)
    GlitchAbst.Inventory.CurrentWeapon = currentWeapon
end)

GlitchAbst.Utils.DebugLog('ox_inventory client module loaded')
return true