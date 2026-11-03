-- ESX built-in inventory server module (ESX without ox_inventory)

if GlitchAbst.FrameworkName ~= 'ESX' or not GlitchAbst.Framework.ESX then
    GlitchAbst.Utils.DebugLog('Skipping ESX inventory module (framework is ' .. tostring(GlitchAbst.FrameworkName) .. ')')
    return false
end

local ESX = GlitchAbst.Framework.ESX
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

local function GetPlayer(source)
    source = tonumber(source)
    return source and ESX.GetPlayerFromId(source) or nil
end

local function Count(xPlayer, item)
    local it = xPlayer.getInventoryItem(item)
    return it and tonumber(it.count) or 0
end

-- Item definitions (same shape as ox: Items() = all, Items(name) = one)
GlitchAbst.Inventory.GetItems = function(itemName)
    local items = ESX.Items or {}
    if itemName then
        local data = items[itemName]
        if data then
            data.name = data.name or itemName
            return data
        end
        if ESX.GetItemLabel then
            local label = ESX.GetItemLabel(itemName)
            if label then return { name = itemName, label = label } end
        end
        return nil
    end
    return items
end
GlitchAbst.Inventory.GetAllItems = GlitchAbst.Inventory.GetItems

GlitchAbst.Inventory.GetItemCount = function(source, item)
    local xPlayer = GetPlayer(source)
    if not xPlayer or not item then return 0 end
    return Count(xPlayer, item)
end

GlitchAbst.Inventory.GetItem = function(source, item, metadata, returnsCount)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return returnsCount and 0 or nil end
    if returnsCount then return Count(xPlayer, item) end
    return xPlayer.getInventoryItem(item)
end

GlitchAbst.Inventory.CanCarryItem = function(source, item, count)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    if xPlayer.canCarryItem then
        return xPlayer.canCarryItem(item, tonumber(count) or 1) and true or false
    end
    return true -- very old ESX (limit based) has no weight check
end
GlitchAbst.Inventory.CanAddItem = GlitchAbst.Inventory.CanCarryItem

GlitchAbst.Inventory.CanCarryWeight = function(source, weight)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    if not xPlayer.getWeight then return true end
    local maxWeight = (xPlayer.getMaxWeight and xPlayer.getMaxWeight()) or xPlayer.maxWeight or 0
    return (xPlayer.getWeight() + (tonumber(weight) or 0)) <= maxWeight
end

GlitchAbst.Inventory.AddItem = function(source, item, amount, metadata)
    local xPlayer = GetPlayer(source)
    amount = tonumber(amount) or 1
    if not xPlayer or amount <= 0 then return false end
    if xPlayer.canCarryItem and not xPlayer.canCarryItem(item, amount) then return false end
    xPlayer.addInventoryItem(item, amount)
    return true
end

GlitchAbst.Inventory.RemoveItem = function(source, item, amount)
    local xPlayer = GetPlayer(source)
    amount = tonumber(amount) or 1
    if not xPlayer or amount <= 0 then return false end
    if Count(xPlayer, item) < amount then return false end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

GlitchAbst.Inventory.HasItem = function(source, items, amount)
    amount = type(amount) == 'number' and amount or 1
    local xPlayer = GetPlayer(source)
    if not xPlayer then return false end
    if type(items) == 'string' then
        local count = Count(xPlayer, items)
        return count >= amount, count
    end
    local hasAll, results = true, {}
    for k, v in pairs(items or {}) do
        local name, need = v, amount
        if type(k) == 'string' then name, need = k, tonumber(v) or amount end
        local count = Count(xPlayer, name)
        results[name] = count
        if count < need then hasAll = false end
    end
    return hasAll, results
end

GlitchAbst.Inventory.GetInventoryItems = function(source)
    local xPlayer = GetPlayer(source)
    if not xPlayer then return {} end
    return xPlayer.getInventory and xPlayer.getInventory() or xPlayer.inventory or {}
end

GlitchAbst.Inventory.GiveItem = function(source, target, item, count)
    if source == target or not target then return false end
    count = tonumber(count) or 1
    if not GlitchAbst.Inventory.CanCarryItem(target, item, count) then return false end
    if GlitchAbst.Inventory.RemoveItem(source, item, count) then
        if GlitchAbst.Inventory.AddItem(target, item, count) then return true end
        GlitchAbst.Inventory.AddItem(source, item, count)
    end
    return false
end

GlitchAbst.Inventory.RegisterUsableItem = function(item, cb)
    return GlitchAbst.Framework.RegisterUsableItem(item, cb)
end

GlitchAbst.Utils.DebugLog('ESX inventory server module loaded')
return true
