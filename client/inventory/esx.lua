-- ESX built-in inventory client module (ESX without ox_inventory)

if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading ESX inventory module^7")
    return false
end

if GlitchAbst.FrameworkName ~= 'ESX' or not GlitchAbst.Framework.ESX then
    GlitchAbst.Utils.DebugLog('Skipping ESX inventory module (framework is ' .. tostring(GlitchAbst.FrameworkName) .. ')')
    return false
end

local ESX = GlitchAbst.Framework.ESX
GlitchAbst.Inventory = GlitchAbst.Inventory or {}

local function Items()
    local data = ESX.GetPlayerData() or {}
    return data.inventory or {}
end

GlitchAbst.Inventory.GetItemCount = function(itemName)
    local count = 0
    for _, item in pairs(Items()) do
        if item and item.name == itemName then
            count = count + (tonumber(item.count) or 0)
        end
    end
    return count
end

GlitchAbst.Inventory.HasItem = function(items, amount)
    if type(amount) ~= 'number' then amount = 1 end
    if type(items) == 'string' then
        return GlitchAbst.Inventory.GetItemCount(items) >= amount
    end
    for k, v in pairs(items or {}) do
        local name, need = v, amount
        if type(k) == 'string' then name, need = k, tonumber(v) or amount end
        if GlitchAbst.Inventory.GetItemCount(name) < need then return false end
    end
    return true
end

GlitchAbst.Inventory.GetPlayerItems = function()
    return Items()
end

-- Item definitions known to the client (from the player's inventory list)
GlitchAbst.Inventory.GetItems = function(itemName)
    local all = {}
    for _, item in pairs(Items()) do
        if item and item.name then all[item.name] = item end
    end
    if itemName then return all[itemName] end
    return all
end

GlitchAbst.Inventory.Search = function(search, itemName)
    local function slotsOf(name)
        local list = {}
        for _, item in pairs(Items()) do
            if item and item.name == name and (item.count or 0) > 0 then list[#list + 1] = item end
        end
        return list
    end
    if type(itemName) == 'table' then
        local result = {}
        for _, name in ipairs(itemName) do
            result[name] = search == 'count' and GlitchAbst.Inventory.GetItemCount(name) or slotsOf(name)
        end
        return result
    end
    if search == 'count' then return GlitchAbst.Inventory.GetItemCount(itemName) end
    if search == 'slots' then return slotsOf(itemName) end
    return {}
end

GlitchAbst.Utils.DebugLog('ESX inventory client module loaded')
return true
