# Glitch Library

A comprehensive abstraction layer for FiveM that seamlessly integrates multiple frameworks, inventory systems, UIs, targeting systems, and more under one unified API.

## Features

### Supported Frameworks
- ESX Legacy
- QBCore 
- QBox

### Supported Inventory Systems
- ox_inventory
- qb-inventory
- ESX inventory

### Supported UI Systems
- ox_lib UI
- QB UI
- ESX UI

### Supported Target Systems
- ox_target
- qb-target
- bt-target (ESX)

### Supported Door Lock Systems
- ox_doorlock
- qb-doorlock
- esx_doorlock

### Supported Progression Systems
- pickle_xp

## Installation

1. Download or clone this repository
2. Place it in your server's `resources` folder
3. Add `ensure glitch-lib` to your `server.cfg` (make sure it loads before any resources that use it)
4. Reference the library in your scripts: `local Lib = exports['glitch-lib']:GetLib()`

## Framework Examples

### Player Management

```lua
local Lib = exports['glitch-lib']:GetLib()

-- Get player data (works across all frameworks)
local playerData = Lib.Framework.GetPlayerData()
print('Player ID: ' .. playerData.source)

-- Server-side player data
RegisterCommand('checkplayer', function(source, args)
    local target = tonumber(args[1]) or source
    local player = Lib.Framework.GetPlayer(target)
    
    if player then
        -- Works with all frameworks
        local money = Lib.Framework.GetMoney(target)
        local bank = Lib.Framework.GetBankMoney(target)
        local job = Lib.Framework.GetJob(target)
        
        Lib.Framework.Notify(source, 'Player has $' .. money .. ' cash and $' .. bank .. ' in bank', 'info')
        Lib.Framework.Notify(source, 'Job: ' .. job.name .. ' (Grade ' .. job.grade .. ')', 'info')
    end
end, false)
```

### Money Operations

```lua
-- Server-side money management
RegisterNetEvent('banking:deposit', function(amount)
    local source = source
    local cash = Lib.Framework.GetMoney(source)
    
    if cash >= amount then
        Lib.Framework.RemoveMoney(source, amount)
        Lib.Framework.AddBankMoney(source, amount)
        Lib.Framework.Notify(source, 'Deposited $' .. amount, 'success')
    else
        Lib.Framework.Notify(source, 'Not enough cash', 'error')
    end
end)

-- Admin give money command
RegisterCommand('givemoney', function(source, args)
    local target = tonumber(args[1])
    local amount = tonumber(args[2])
    local type = args[3] or 'cash' -- cash or bank
    
    if target and amount and amount > 0 then
        if type == 'cash' then
            Lib.Framework.AddMoney(target, amount)
        else
            Lib.Framework.AddBankMoney(target, amount)
        end
        
        Lib.Framework.Notify(source, 'Gave $' .. amount .. ' to ID: ' .. target, 'success')
        Lib.Framework.Notify(target, 'You received $' .. amount, 'success')
    end
end, true) -- Admin only
```

### Job Management

```lua
-- Server-side
RegisterCommand('setjob', function(source, args)
    local target = tonumber(args[1])
    local job = args[2]
    local grade = tonumber(args[3]) or 0
    
    if target and job then
        local success = Lib.Framework.SetJob(target, job, grade)
        if success then
            Lib.Framework.Notify(target, 'Your job was set to ' .. job .. ' (grade ' .. grade .. ')', 'info')
            Lib.Framework.Notify(source, 'Job set successfully', 'success')
        else
            Lib.Framework.Notify(source, 'Failed to set job', 'error')
        end
    end
end, true) -- Admin only

-- Client-side job check
function checkJobAccess(requiredJob, requiredGrade)
    local playerData = Lib.Framework.GetPlayerData()
    local jobName = playerData.job.name
    local jobGrade = playerData.job.grade
    
    if jobName == requiredJob and jobGrade >= requiredGrade then
        return true
    end
    return false
end
```

## Inventory System Examples

### Basic Item Operations

```lua
-- Server-side
local Lib = exports['glitch-lib']:GetLib()

-- Add item to player
RegisterNetEvent('inventory:giveItem')
AddEventHandler('inventory:giveItem', function(target, item, count)
    local source = source
    -- Admin check
    if IsPlayerAceAllowed(source, "admin.items") then
        -- Works with ox_inventory, qb-inventory and ESX inventory
        local success = Lib.Inventory.AddItem(target, item, count)
        if success then
            Lib.Framework.Notify(target, 'You received ' .. count .. 'x ' .. item, 'success')
            Lib.Framework.Notify(source, 'Gave ' .. count .. 'x ' .. item .. ' to ID: ' .. target, 'success')
        else
            Lib.Framework.Notify(source, 'Failed to give item', 'error')
        end
    end
end)

-- Check if player can carry item
RegisterNetEvent('inventory:canCarry')
AddEventHandler('inventory:canCarry', function(item, count)
    local source = source
    local canCarry = Lib.Inventory.CanCarryItem(source, item, count)
    
    if canCarry then
        Lib.Framework.Notify(source, 'You can carry this item', 'success')
    else
        Lib.Framework.Notify(source, 'You cannot carry this item', 'error')
    end
end)
```

### Inventory Check and Remove

```lua
-- Server-side inventory check example
RegisterNetEvent('inventory:useItem')
AddEventHandler('inventory:useItem', function(item)
    local source = source
    local itemData = Lib.Inventory.GetItem(source, item)
    
    if itemData and itemData.count > 0 then
        -- Remove one of the item
        Lib.Inventory.RemoveItem(source, item, 1)
        
        -- Perform item use effect
        Lib.Framework.Notify(source, 'You used ' .. item, 'success')
        
        -- For specific items, trigger special effects
        if item == 'medkit' then
            -- Heal player
            TriggerClientEvent('inventory:useHealth', source)
        elseif item == 'armor' then
            -- Add armor
            TriggerClientEvent('inventory:useArmor', source)
        end
    else
        Lib.Framework.Notify(source, 'You don\'t have this item', 'error')
    end
end)
```

### Crafting System Example

```lua
-- Server-side crafting
local craftingRecipes = {
    lockpick = {
        ingredients = {
            ['metal_scrap'] = 4,
            ['plastic'] = 3
        },
        result = {
            item = 'lockpick',
            count = 1
        }
    },
    bandage = {
        ingredients = {
            ['cloth'] = 3,
            ['alcohol'] = 1
        },
        result = {
            item = 'bandage',
            count = 2
        }
    }
}

RegisterNetEvent('inventory:craftItem')
AddEventHandler('inventory:craftItem', function(recipe)
    local source = source
    local recipeData = craftingRecipes[recipe]
    
    if not recipeData then
        Lib.Framework.Notify(source, 'Invalid recipe', 'error')
        return
    end
    
    -- Check ingredients
    local hasAll = true
    for item, count in pairs(recipeData.ingredients) do
        if Lib.Inventory.GetItemCount(source, item) < count then
            hasAll = false
            break
        end
    end
    
    if hasAll then
        -- Remove ingredients
        for item, count in pairs(recipeData.ingredients) do
            Lib.Inventory.RemoveItem(source, item, count)
        end
        
        -- Add crafted item
        Lib.Inventory.AddItem(source, recipeData.result.item, recipeData.result.count)
        Lib.Framework.Notify(source, 'Crafted ' .. recipeData.result.count .. 'x ' .. recipeData.result.item, 'success')
    else
        Lib.Framework.Notify(source, 'Missing ingredients', 'error')
    end
end)
```

## UI System Examples

### Notifications

```lua
-- Client-side
local Lib = exports['glitch-lib']:GetLib()

-- Basic notification
Lib.UI.Notify({
    title = "System Message", 
    description = "This is a notification message",
    type = "info", -- info, success, error, warning
    duration = 5000
})

-- Different notification types
function showAllNotificationTypes()
    -- Success notification
    Lib.UI.Notify({
        title = "Success", 
        description = "Operation completed successfully",
        type = "success"
    })
    
    Wait(2000)
    
    -- Error notification
    Lib.UI.Notify({
        title = "Error", 
        description = "Failed to complete operation",
        type = "error"
    })
    
    Wait(2000)
    
    -- Warning notification
    Lib.UI.Notify({
        title = "Warning", 
        description = "This action may have consequences",
        type = "warning"
    })
    
    Wait(2000)
    
    -- Info notification
    Lib.UI.Notify({
        title = "Information", 
        description = "Here is some information",
        type = "info"
    })
end
```

### Progress Bars

```lua
-- Client-side progress bar
function repairVehicle()
    local success = Lib.UI.ProgressBar({
        duration = 10000,
        label = "Repairing Vehicle...",
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "mini@repair",
            name = "fixing_a_ped",
            flags = 49
        },
        prop = {
            model = `prop_tool_wrench`,
            bone = 60309,
            coords = { x = 0.1, y = 0.0, z = 0.0 },
            rotation = { x = 0.0, y = 0.0, z = 0.0 }
        },
        disable = {
            movement = true,
            car = true,
            combat = true,
            mouse = false
        }
    })
    
    if success then
        -- Repair the vehicle
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleFixed(vehicle)
            
            Lib.UI.Notify({
                title = "Vehicle Repair", 
                description = "Vehicle repaired successfully",
                type = "success"
            })
        end
    else
        Lib.UI.Notify({
            title = "Cancelled", 
            description = "Vehicle repair cancelled",
            type = "error"
        })
    end
end

-- Progress Circle (for ox_lib)
function lockpickDoor()
    local success = Lib.UI.ProgressCircle({
        duration = 5000,
        position = 'bottom',
        label = 'Lockpicking...',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = "veh@break_in@0h@p_m_one@",
            name = "low_force_entry_ds",
            flags = 49
        },
        prop = {
            model = `prop_tool_screwdvr01`,
            bone = 57005,
            coords = { x = 0.1, y = 0.0, z = 0.0 },
            rotation = { x = 0.0, y = 0.0, z = 0.0 }
        }
    })
    
    return success
end
```

### Input Dialogs

```lua
-- Client-side input dialog
function promptVehicleSpawn()
    local input = Lib.UI.Input("Vehicle Spawn", {
        {
            type = "text",
            name = "model",
            label = "Vehicle Model",
            required = true
        },
        {
            type = "color",
            name = "color",
            label = "Vehicle Color"
        },
        {
            type = "checkbox",
            name = "upgraded",
            label = "Fully Upgrade"
        }
    })
    
    if input and input.model then
        -- Spawn vehicle
        local modelHash = GetHashKey(input.model)
        
        if IsModelInCdimage(modelHash) and IsModelAVehicle(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(10)
            end
            
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            
            local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)
            SetPedIntoVehicle(playerPed, vehicle, -1)
            
            if input.upgraded and input.upgraded == true then
                -- Max out vehicle
                SetVehicleModKit(vehicle, 0)
                for i = 0, 49 do
                    local maxMod = GetNumVehicleMods(vehicle, i)
                    SetVehicleMod(vehicle, i, maxMod - 1, false)
                end
            end
            
            Lib.UI.Notify({
                title = "Vehicle Spawned",
                description = "Spawned " .. input.model,
                type = "success"
            })
            
            SetModelAsNoLongerNeeded(modelHash)
        else
            Lib.UI.Notify({
                title = "Invalid Model",
                description = "Vehicle model not found",
                type = "error"
            })
        end
    end
end
```

### Context Menus

```lua
-- Client-side context menu
function showVehicleMenu()
    -- Register the context menu
    Lib.UI.CreateContextMenu("vehicle_menu", "Vehicle Options", {
        {
            title = "Engine",
            description = "Toggle engine on/off",
            icon = "car",
            event = "vehicle:toggleEngine"
        },
        {
            title = "Doors",
            description = "Open/close doors",
            icon = "door-open",
            event = "vehicle:toggleDoors"
        },
        {
            title = "Repair",
            description = "Repair vehicle",
            icon = "wrench",
            action = function()
                repairVehicle()
            end
        },
        {
            title = "Lock",
            description = "Lock/unlock vehicle",
            icon = "lock",
            event = "vehicle:toggleLock"
        }
    })
    
    -- Show the menu
    Lib.UI.ContextMenu("vehicle_menu")
}

-- Event handler for context menu action
RegisterNetEvent('vehicle:toggleEngine')
AddEventHandler('vehicle:toggleEngine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        local engineState = GetIsVehicleEngineRunning(vehicle)
        SetVehicleEngineOn(vehicle, not engineState, false, true)
        
        local status = not engineState and "ON" or "OFF"
        Lib.UI.Notify({
            title = "Vehicle Engine",
            description = "Engine turned " .. status,
            type = "success"
        })
    end
end)
```

### Text UI

```lua
-- Client-side text UI (persistent text display)
function showHelpText()
    Lib.UI.ShowTextUI("Press [E] to interact", {
        position = "right-center",
        icon = "hand",
        style = {
            borderRadius = "5px",
            backgroundColor = "#1c1c1c",
            color = "white"
        }
    })
    
    -- Later, to hide:
    -- Lib.UI.HideTextUI()
}

-- Alert dialog example
function confirmPurchase(item, price)
    local result = Lib.UI.Alert(
        "Confirm Purchase", 
        "Do you want to buy " .. item .. " for $" .. price .. "?",
        "info",
        "shopping-cart"
    )
    
    if result then
        -- User confirmed
        TriggerServerEvent('shop:buyItem', item, price)
    else
        Lib.UI.Notify({
            title = "Purchase Cancelled",
            description = "You cancelled the purchase",
            type = "info"
        })
    end
end
```

## Target System Examples

```lua
-- Client-side target system
local Lib = exports['glitch-lib']:GetLib()

-- Add target to specified models
Lib.Target.AddTargetModel({'prop_atm_01', 'prop_atm_02', 'prop_atm_03'}, {
    {
        label = "Use ATM",
        icon = "credit-card",
        action = function()
            TriggerEvent('banking:openATM')
        end,
        canInteract = function()
            return true
        },
        distance = 2.0
    }
})

-- Add target to specific entity
function addTargetToVehicle(vehicle)
    Lib.Target.AddTargetEntity(vehicle, {
        {
            label = "Inspect Vehicle",
            icon = "magnifying-glass",
            action = function()
                TriggerEvent('vehicle:inspect')
            end,
            canInteract = function()
                return not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            distance = 3.0
        },
        {
            label = "Open Trunk",
            icon = "car-rear",
            action = function()
                TriggerEvent('vehicle:openTrunk')
            end,
            canInteract = function()
                return not IsPedInAnyVehicle(PlayerPedId(), false)
            },
            distance = 2.5
        }
    })
}

-- Add a zone at specific coordinates
function createShopZone(coords)
    Lib.Target.AddBoxZone("convenience_store", coords, 2.0, 2.0, {
        name = "shop_interaction",
        heading = 0.0,
        debugPoly = false,
        minZ = coords.z - 1.0,
        maxZ = coords.z + 2.0
    }, {
        {
            label = "Open Shop",
            icon = "shopping-basket",
            action = function()
                TriggerEvent('shop:open', 'convenience')
            end,
            canInteract = function()
                return true
            },
            distance = 2.0
        }
    })
}

-- Add target to all players
Lib.Target.AddGlobalPlayer({
    {
        label = "Check ID",
        icon = "id-card",
        action = function(data)
            TriggerEvent('player:checkId', data.entity)
        end,
        canInteract = function()
            return true
        },
        distance = 2.0
    },
    {
        label = "Frisk Person",
        icon = "hands",
        action = function(data)
            TriggerEvent('player:frisk', data.entity)
        end,
        canInteract = function()
            local playerData = Lib.Framework.GetPlayerData()
            return playerData.job.name == "police"
        },
        distance = 1.5
    }
})
```

## Door Lock System Examples

```lua
-- Client-side door lock interactions
local Lib = exports['glitch-lib']:GetLib()

-- Check if a door is locked
function checkDoorStatus(doorId)
    local isLocked = Lib.DoorLock.IsDoorLocked(doorId)
    if isLocked ~= nil then
        local status = isLocked and "locked" or "unlocked"
        Lib.UI.Notify({
            title = "Door Status",
            description = "Door is currently " .. status,
            type = "info"
        })
    else
        Lib.UI.Notify({
            title = "Invalid Door",
            description = "Door not found",
            type = "error"
        })
    end
end

-- Toggle door lock
function toggleDoorLock(doorId)
    local isLocked = Lib.DoorLock.IsDoorLocked(doorId)
    if isLocked ~= nil then
        local hasAccess = Lib.DoorLock.HasAccess(doorId)
        if hasAccess then
            Lib.DoorLock.SetDoorLocked(doorId, not isLocked)
            
            local newStatus = not isLocked and "locked" or "unlocked"
            Lib.UI.Notify({
                title = "Door Status",
                description = "Door is now " .. newStatus,
                type = "success"
            })
        else
            Lib.UI.Notify({
                title = "Access Denied",
                description = "You don't have access to this door",
                type = "error"
            })
        end
    end
end

-- Get nearby doors to add markers
CreateThread(function()
    while true do
        local playerPos = GetEntityCoords(PlayerPedId())
        local nearby = Lib.DoorLock.GetNearbyDoors()
        
        for _, door in pairs(nearby) do
            local doorCoords = type(door.coords) == 'vector3' and door.coords or 
                               vector3(door.coords.x, door.coords.y, door.coords.z)
            
            local isLocked = Lib.DoorLock.IsDoorLocked(door.id)
            local color = isLocked and {r = 255, g = 0, b = 0, a = 100} or {r = 0, g = 255, b = 0, a = 100}
            
            DrawMarker(2, doorCoords.x, doorCoords.y, doorCoords.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
                      0.3, 0.3, 0.3, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
        end
        
        Wait(0)
    end
end)

-- Command to toggle nearest door
RegisterCommand('toggledoor', function()
    local playerPos = GetEntityCoords(PlayerPedId())
    local nearbyDoors = Lib.DoorLock.GetNearbyDoors()
    
    local closestDoor = nil
    local minDistance = 3.0
    
    for _, door in pairs(nearbyDoors) do
        local doorCoords = type(door.coords) == 'vector3' and door.coords or 
                          vector3(door.coords.x, door.coords.y, door.coords.z)
        
        local distance = #(playerPos - doorCoords)
        if distance < minDistance then
            closestDoor = door
            minDistance = distance
        end
    end
    
    if closestDoor then
        toggleDoorLock(closestDoor.id)
    else
        Lib.UI.Notify({
            title = "No Door Found",
            description = "No doors nearby to interact with",
            type = "error"
        })
    end
end)
```

## Server-Side Door Lock Examples

```lua
-- Server-side door lock interactions
local Lib = exports['glitch-lib']:GetLib()

-- Check if player has access to a door
RegisterNetEvent('doorlock:checkAccess')
AddEventHandler('doorlock:checkAccess', function(doorId)
    local source = source
    local hasAccess = Lib.DoorLock.PlayerHasAccess(source, doorId)
    
    if hasAccess then
        -- Get current state and toggle it
        local doorState = Lib.DoorLock.GetDoorState(doorId)
        if doorState ~= nil then
            Lib.DoorLock.SetDoorState(doorId, not doorState, source)
            
            -- Notify the player
            local newState = not doorState and "locked" or "unlocked"
            Lib.Framework.Notify(source, 'Door is now ' .. newState, 'success')
        end
    else
        Lib.Framework.Notify(source, 'You do not have access to this door', 'error')
    end
end)

-- Admin command to get all doors
RegisterCommand('listdoors', function(source)
    if IsPlayerAceAllowed(source, "admin") then
        local doors = Lib.DoorLock.GetAllDoors()
        local doorCount = 0
        
        for _ in pairs(doors) do
            doorCount = doorCount + 1
        end
        
        Lib.Framework.Notify(source, 'Total doors: ' .. doorCount, 'info')
        print('Door list requested by ' .. GetPlayerName(source))
    else
        Lib.Framework.Notify(source, 'You do not have permission', 'error')
    end
end, false)
```

## Example Usage in Resources

```lua
-- In a client script:
local Lib = exports['glitch-lib']:GetLib()

-- Wait for the library to be ready
CreateThread(function()
    while not Lib.IsReady do
        Wait(100)
    end
    
    -- Now you can use the library
    Lib.UI.Notify({
        title = "Library Loaded",
        description = "GlitchLib loaded successfully!",
        type = "success"
    })
    
    -- Register keybinds, create menus, etc.
    RegisterCommand('showmenu', function()
        openMainMenu()
    end, false)
    
    RegisterKeyMapping('showmenu', 'Open Main Menu', 'keyboard', 'M')
end)

-- In a server script:
local Lib = exports['glitch-lib']:GetLib()

-- Define a callback for other resources to use
Lib.Framework.RegisterCallback('myresource:getPlayerMoney', function(source, cb)
    local cash = Lib.Framework.GetMoney(source)
    local bank = Lib.Framework.GetBankMoney(source)
    
    cb({
        cash = cash,
        bank = bank,
        total = cash + bank
    })
end)
```

## Contributing

Contributions are welcome! Feel free to submit pull requests with new features, bug fixes, or performance improvements.

## License

[MIT License](LICENSE)