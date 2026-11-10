-- QBCore Inventory Server Module (qb-inventory)

GlitchAbst.Utils.DebugLog('Loading qb-inventory server module')

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

-- Ensure inventory namespace exists
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

local function SharedItems()
    return (QBCore.Shared and QBCore.Shared.Items) or {}
end

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
    return exports['qb-inventory']:CanAddItem(source, item, tonumber(amount) or 1)
end

-- Same name as the ox_inventory module, so callers work on both
GlitchAbst.Inventory.CanCarryItem = function(source, item, count)
    return GlitchAbst.Inventory.CanAddItem(source, item, count)
end

GlitchAbst.Inventory.CanCarryWeight = function(source, weight)
    local free = exports['qb-inventory']:GetFreeWeight(source)
    return (tonumber(free) or 0) >= (tonumber(weight) or 0)
end

-- Accepts the ox style (source, item, amount, metadata, slot) and the qb style
-- (source, item, amount, slot, info, reason): a table in the 4th place is metadata.
GlitchAbst.Inventory.AddItem = function(source, item, amount, metadata, slot, info, reason)
    if type(metadata) ~= 'table' and metadata ~= nil and slot == nil then
        slot = metadata
        metadata = nil
    end
    local itemInfo = info or metadata
    return exports['qb-inventory']:AddItem(source, item, tonumber(amount) or 1, slot or false, itemInfo, reason or 'glitch-abstraction:addItem')
end

-- Accepts (source, item, amount, slot, reason) and the ox style (source, item, amount, metadata, slot)
GlitchAbst.Inventory.RemoveItem = function(source, item, amount, slot, reason)
    if type(slot) == 'table' then
        -- ox style call: 4th is metadata (qb-inventory cannot match on it), 5th is the slot
        slot = tonumber(reason)
        reason = nil
    end
    return exports['qb-inventory']:RemoveItem(source, item, tonumber(amount) or 1, slot or false, type(reason) == 'string' and reason or 'glitch-abstraction:removeItem')
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
    if type(amount) ~= 'number' then amount = nil end -- ox style passes metadata here
    return exports['qb-inventory']:HasItem(source, items, amount)
end

-- Item definitions (same shape as ox: Items() = all, Items(name) = one)
GlitchAbst.Inventory.GetItems = function(itemName)
    local items = SharedItems()
    if itemName then return items[itemName] end
    return items
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
    return tonumber(exports['qb-inventory']:GetItemCount(source, items)) or 0
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
    return count >= (tonumber(amount) or 1), count
end

GlitchAbst.Inventory.GiveItemToPlayer = function(source, target, item, amount, info)
    if source == target or not target then return false end
    if not GlitchAbst.Inventory.CanAddItem(target, item, amount) then return false end

    if GlitchAbst.Inventory.RemoveItem(source, item, amount, false, 'glitch-abstraction:giveItem') then
        if GlitchAbst.Inventory.AddItem(target, item, amount, nil, false, info, 'glitch-abstraction:receiveItem') then
            return true
        else
            -- Return the item if target couldn't receive it
            GlitchAbst.Inventory.AddItem(source, item, amount, nil, false, info, 'glitch-abstraction:returnItem')
            return false
        end
    end
    return false
end
GlitchAbst.Inventory.GiveItem = GlitchAbst.Inventory.GiveItemToPlayer

-- Used by the client module's Search()
QBCore.Functions.CreateCallback('glitch-abstraction:server:GetSlotsByItem', function(source, cb, itemName)
    local player = QBCore.Functions.GetPlayer(source)
    local items = player and player.PlayerData and player.PlayerData.items or {}
    cb(exports['qb-inventory']:GetSlotsByItem(items, itemName))
end)

QBCore.Functions.CreateCallback('glitch-abstraction:server:GetItemCount', function(source, cb, itemName)
    cb(tonumber(exports['qb-inventory']:GetItemCount(source, itemName)) or 0)
end)

-- Create aliases for consistent function naming across the library
GlitchAbst.Inventory.LockInventory = function(source) GlitchAbst.Inventory.SetBusy(source, true) end
GlitchAbst.Inventory.UnlockInventory = function(source) GlitchAbst.Inventory.SetBusy(source, false) end
GlitchAbst.Inventory.Open = GlitchAbst.Inventory.OpenInventory
GlitchAbst.Inventory.Close = GlitchAbst.Inventory.CloseInventory

GlitchAbst.Utils.DebugLog('qb-inventory server module loaded')
return true
