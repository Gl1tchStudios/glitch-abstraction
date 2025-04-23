-- QB Inventory Implementation
GlitchLib.Utils.DebugLog('QB Inventory module loaded')

local QBCore = exports['qb-core']:GetCoreObject()

-- Item Management
GlitchLib.Inventory.AddItem = function(source, item, count, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.AddItem(item, count, nil, metadata)
    end
    return false
end

GlitchLib.Inventory.RemoveItem = function(source, item, count, slot, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.RemoveItem(item, count, slot, metadata)
    end
    return false
end

GlitchLib.Inventory.GetItem = function(source, item, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local items = Player.Functions.GetItemsByName(item)
        if metadata then
            for _, itemData in pairs(items) do
                if itemData.info == metadata then
                    return itemData
                end
            end
            return nil
        end
        return Player.Functions.GetItemByName(item)
    end
    return nil
end

GlitchLib.Inventory.GetItemCount = function(source, item, metadata)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        if metadata then
            local count = 0
            local items = Player.Functions.GetItemsByName(item)
            for _, itemData in pairs(items) do
                if itemData.info == metadata then
                    count = count + itemData.amount
                end
            end
            return count
        end
        return Player.Functions.GetItemByName(item)?.amount or 0
    end
    return 0
end

GlitchLib.Inventory.CanCarryItem = function(source, item, count)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.CanCarryItem(item, count)
    end
    return false
end

GlitchLib.Inventory.CanSwapItem = function(source, item, count, toSlot)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        return Player.Functions.CanCarryItem(item, count) -- QB doesn't have a direct swap check
    end
    return false
end

GlitchLib.Inventory.SetInventory = function(source, items)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and items then
        Player.Functions.SetInventory(items)
        return true
    end
    return false
end

GlitchLib.Inventory.ClearInventory = function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        Player.Functions.ClearInventory()
        return true
    end
    return false
end