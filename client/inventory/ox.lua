-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading ox_inventory module^7")
    return false
end

-- Skip if inventory system doesn't match
if Config and Config.InventorySystem and Config.InventorySystem ~= 'ox' and Config.InventorySystem ~= 'auto' then
    GlitchLib.Utils.DebugLog('Skipping ox_inventory module (using ' .. Config.InventorySystem .. ')')
    return false
end

-- Check if resource is actually available
if GetResourceState('ox_inventory') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_inventory resource is not available')
    return false
end

-- Initialize inventory namespace
GlitchLib.Inventory = GlitchLib.Inventory or {}

-- Basic inventory functions
GlitchLib.Inventory.OpenInventory = function(invType, data)
    return exports.ox_inventory:openInventory(invType, data)
end

GlitchLib.Inventory.OpenNearbyInventory = function()
    return exports.ox_inventory:openNearbyInventory()
end

GlitchLib.Inventory.CloseInventory = function()
    return exports.ox_inventory:closeInventory()
end

GlitchLib.Inventory.GetItems = function(itemName)
    return exports.ox_inventory:Items(itemName)
end

GlitchLib.Inventory.UseItem = function(data, cb)
    return exports.ox_inventory:useItem(data, cb)
end

GlitchLib.Inventory.UseSlot = function(slot)
    return exports.ox_inventory:useSlot(slot)
end

GlitchLib.Inventory.SetStashTarget = function(id, owner)
    return exports.ox_inventory:setStashTarget(id, owner)
end

GlitchLib.Inventory.GetCurrentWeapon = function()
    return exports.ox_inventory:getCurrentWeapon()
end

GlitchLib.Inventory.DisplayMetadata = function(metadata, value)
    return exports.ox_inventory:displayMetadata(metadata, value)
end

GlitchLib.Inventory.GiveItemToTarget = function(serverId, slotId, count)
    return exports.ox_inventory:giveItemToTarget(serverId, slotId, count)
end

GlitchLib.Inventory.WeaponWheel = function(state)
    return exports.ox_inventory:weaponWheel(state)
end

GlitchLib.Inventory.Search = function(search, item, metadata)
    return exports.ox_inventory:Search(search, item, metadata)
end

GlitchLib.Inventory.GetItemCount = function(itemName, metadata, strict)
    return exports.ox_inventory:GetItemCount(itemName, metadata, strict)
end

GlitchLib.Inventory.GetPlayerItems = function()
    return exports.ox_inventory:GetPlayerItems()
end

GlitchLib.Inventory.GetPlayerWeight = function()
    return exports.ox_inventory:GetPlayerWeight()
end

GlitchLib.Inventory.GetPlayerMaxWeight = function()
    return exports.ox_inventory:GetPlayerMaxWeight()
end

GlitchLib.Inventory.GetSlotIdWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdWithItem(itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotIdsWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotIdsWithItem(itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotWithItem(itemName, metadata, strict)
end

GlitchLib.Inventory.GetSlotsWithItem = function(itemName, metadata, strict)
    return exports.ox_inventory:GetSlotsWithItem(itemName, metadata, strict)
end

-- State bag helpers
GlitchLib.Inventory.IsInventoryBusy = function()
    return LocalPlayer.state.invBusy or false
end

GlitchLib.Inventory.SetInventoryBusy = function(state)
    LocalPlayer.state.invBusy = state
end

GlitchLib.Inventory.AreHotkeysEnabled = function()
    return LocalPlayer.state.invHotkeys ~= false
end

GlitchLib.Inventory.SetHotkeysEnabled = function(state)
    LocalPlayer.state.invHotkeys = state
end

GlitchLib.Inventory.IsInventoryOpen = function()
    return LocalPlayer.state.invOpen or false
end

GlitchLib.Inventory.CanUseWeapons = function()
    return LocalPlayer.state.canUseWeapons ~= false
end

GlitchLib.Inventory.SetCanUseWeapons = function(state)
    LocalPlayer.state.canUseWeapons = state
end

-- Create aliases for consistent function naming across the library
GlitchLib.Inventory.Open = GlitchLib.Inventory.OpenInventory
GlitchLib.Inventory.Close = GlitchLib.Inventory.CloseInventory
GlitchLib.Inventory.OpenNearby = GlitchLib.Inventory.OpenNearbyInventory

-- Add event handler for current weapon
AddEventHandler('ox_inventory:currentWeapon', function(currentWeapon)
    GlitchLib.Inventory.CurrentWeapon = currentWeapon
end)

GlitchLib.Utils.DebugLog('ox_inventory client module loaded')
return true