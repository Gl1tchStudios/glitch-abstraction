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
- bt-target

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
4. Reference the library in your scripts: `local Lib = exports['glitch-lib']:GetLib()` (You may change lib to whatever you want if lib)

## Function Reference

### Framework Functions

#### Client-Side
```lua
-- Player Data
Lib.Framework.GetPlayerData() -- Returns player data
Lib.Framework.TriggerCallback(name, callback, ...) -- Trigger a server callback
Lib.Framework.Notify(message, type, duration) -- Show notification
Lib.Framework.ShowHelpNotification(message, thisFrame) -- Show help notification (ESX)
Lib.Framework.SpawnPlayer(coords, callback) -- Spawn player at coordinates
Lib.Framework.DrawText(x, y, text) -- Draw 2D text on screen
Lib.Framework.Draw3DText(coords, text) -- Draw 3D text in world
Lib.Framework.GetClosestPlayer() -- Returns closest player and distance
Lib.Framework.GetVehicleProperties(vehicle) -- Get vehicle properties
Lib.Framework.SetVehicleProperties(vehicle, props) -- Set vehicle properties
```

#### Server-Side
```lua
-- Player Management
Lib.Framework.GetPlayer(source) -- Get player object
Lib.Framework.GetPlayerFromIdentifier(identifier) -- Get player from identifier/citizenid
Lib.Framework.GetPlayers() -- Get all online players

-- Money Management
Lib.Framework.GetMoney(source) -- Get player's cash
Lib.Framework.AddMoney(source, amount) -- Add cash to player
Lib.Framework.RemoveMoney(source, amount) -- Remove cash from player
Lib.Framework.GetBankMoney(source) -- Get player's bank balance
Lib.Framework.AddBankMoney(source, amount) -- Add to player's bank balance
Lib.Framework.RemoveBankMoney(source, amount) -- Remove from player's bank balance

-- Job Management
Lib.Framework.GetJob(source) -- Get player's job
Lib.Framework.SetJob(source, job, grade) -- Set player's job and grade

-- Notification & Callbacks
Lib.Framework.RegisterCallback(name, callback) -- Register a server callback
Lib.Framework.Notify(source, message, type, length) -- Send notification to player
```

### Inventory Functions

#### Server-Side
```lua
-- Item Management
Lib.Inventory.AddItem(source, item, count, metadata, slot) -- Add item to player
Lib.Inventory.RemoveItem(source, item, count, metadata, slot) -- Remove item from player
Lib.Inventory.GetItem(source, item, metadata) -- Get item data for player
Lib.Inventory.GetItemCount(source, item, metadata) -- Get count of item player has
Lib.Inventory.CanCarryItem(source, item, count) -- Check if player can carry item
Lib.Inventory.CanSwapItem(source, item, count, toSlot) -- Check if player can swap item slots
Lib.Inventory.SetInventory(source, items) -- Set player's entire inventory
Lib.Inventory.ClearInventory(source) -- Clear player's inventory

-- OX-Specific Functions
Lib.Inventory.Search(source, search, item, metadata) -- Search inventory (ox-inventory)
Lib.Inventory.GetSlot(source, slot) -- Get item in specific slot (ox-inventory)
Lib.Inventory.SwapSlots(source, fromSlot, toSlot) -- Swap inventory slots (ox-inventory)
Lib.Inventory.Confiscate(source) -- Confiscate inventory (ox-inventory)
Lib.Inventory.ReturnConfiscated(source) -- Return confiscated inventory (ox-inventory)
```

### UI Functions

#### Client-Side
```lua
-- Notifications
Lib.UI.Notify(params) -- Show notification with parameters: title, description, type, duration, etc.

-- Progress Indicators
Lib.UI.ProgressBar(params) -- Show progress bar with parameters: duration, label, anim, prop, etc.
Lib.UI.ProgressCircle(params) -- Show circular progress indicator (ox_lib)

-- Input & Dialogs
Lib.UI.Input(header, inputs) -- Display input dialog with multiple field types
Lib.UI.Alert(title, message, type, icon) -- Show alert dialog with confirm/cancel

-- Menus
Lib.UI.CreateContextMenu(id, title, options) -- Create a context menu
Lib.UI.ContextMenu(id, title, options, position) -- Display a context menu

-- Text UI
Lib.UI.ShowTextUI(message, options) -- Show persistent text UI element
Lib.UI.HideTextUI() -- Hide text UI element
```

### Notification Functions (Client-Side)
```lua
-- Basic Notifications
Lib.Notifications.Show(params) -- Show notification with parameters
Lib.Notifications.Success(title, message, duration) -- Show success notification
Lib.Notifications.Error(title, message, duration) -- Show error notification
Lib.Notifications.Info(title, message, duration) -- Show info notification
Lib.Notifications.Warning(title, message, duration) -- Show warning notification
```

### Target System Functions

#### Client-Side
```lua
-- Entity Targeting
Lib.Target.AddTargetEntity(entities, options) -- Add options to specific entities
Lib.Target.AddTargetModel(models, options) -- Add options to all entities of specified models

-- Zone Targeting
Lib.Target.AddBoxZone(name, center, length, width, options, targetOptions) -- Create box interaction zone
Lib.Target.AddSphereZone(name, center, radius, options, targetOptions) -- Create spherical interaction zone
Lib.Target.RemoveZone(id) -- Remove interaction zone

-- Global Targeting
Lib.Target.AddGlobalPlayer(options) -- Add options to all players
Lib.Target.AddGlobalVehicle(options) -- Add options to all vehicles
Lib.Target.AddGlobalObject(options) -- Add options to all objects
```

### Door Lock Functions

#### Client-Side
```lua
Lib.DoorLock.IsDoorLocked(door) -- Check if door is locked (id or name)
Lib.DoorLock.SetDoorLocked(door, state) -- Lock/unlock a door
Lib.DoorLock.GetNearbyDoors() -- Get doors near the player
Lib.DoorLock.GetAllDoors() -- Get all doors
Lib.DoorLock.HasAccess(door) -- Check if player has access to door
```

#### Server-Side
```lua
Lib.DoorLock.GetDoorState(door) -- Get door state (locked/unlocked)
Lib.DoorLock.SetDoorState(door, state, playerId) -- Set door state
Lib.DoorLock.PlayerHasAccess(source, door) -- Check if player has access to door
Lib.DoorLock.GetAllDoors() -- Get all doors
Lib.DoorLock.AddDoor(door) -- Add a new door (if supported)
Lib.DoorLock.RemoveDoor(door) -- Remove a door (if supported)
```

#### Cutscenes Functions (Client-Side)
```lua
-- Appearance Management
Lib.Cutscene.SavePlayerAppearance() -- Save current player appearance
Lib.Cutscene.RestorePlayerAppearance() -- Restore saved player appearance

-- Cutscene Control
Lib.Cutscene.Play(cutsceneName, options) -- Play cutscene with options
Lib.Cutscene.Stop(immediate) -- Stop current cutscene
Lib.Cutscene.IsActive() -- Check if a cutscene is active
Lib.Cutscene.IsPlaying() -- Check if a cutscene is currently playing
Lib.Cutscene.GetTime() -- Get current cutscene time (ms)
Lib.Cutscene.SkipToTime(time) -- Skip to specific time in cutscene (ms)
```

### Progression Functions (pickle_xp)

#### Client-Side
```lua
-- Experience & Levels
Lib.Progression.GetXP() -- Get player's current XP
Lib.Progression.GetLevel() -- Get player's current level
Lib.Progression.GetRankData() -- Get detailed rank data
Lib.Progression.GetUserData() -- Get user's progression data
Lib.Progression.HasRank(rank) -- Check if player has specific rank

-- UI Functions
Lib.Progression.DrawXPBar(show) -- Show/hide XP bar
Lib.Progression.ShowRank(state) -- Show/hide rank display
```

#### Server-Side
```lua
-- Experience Management
Lib.Progression.GetXP(source) -- Get player's XP
Lib.Progression.AddXP(source, amount, reason) -- Add XP to player
Lib.Progression.SetXP(source, amount) -- Set player's XP
Lib.Progression.GetLevel(source) -- Get player's level
Lib.Progression.SetLevel(source, level) -- Set player's level
Lib.Progression.AddLevels(source, amount) -- Add levels to player

-- XP Sources
Lib.Progression.RegisterXPSource(name, min, max, notify) -- Register XP source
Lib.Progression.AwardXPFromSource(source, sourceName) -- Award XP from source

-- Rank Management
Lib.Progression.GetRankData(source) -- Get player's rank data
Lib.Progression.GetUserData(source) -- Get player's user data
Lib.Progression.HasRank(source, rank) -- Check if player has specific rank
```

### Scaleform Functions (Client-Side)
```lua
-- Basic Scaleform Management
Lib.Scaleform.Load(name) -- Load a scaleform by name, returns handle
Lib.Scaleform.Unload(nameOrHandle) -- Unload a scaleform by name or handle
Lib.Scaleform.CallFunction(handleOrName, returnValue, funcName, ...) -- Call function on scaleform
Lib.Scaleform.Render(handleOrName, x, y, width, height, r, g, b, a, scale) -- Render scaleform 2D
Lib.Scaleform.Render3D(handleOrName, x, y, z, rx, ry, rz, scale) -- Render scaleform in 3D world

-- Common Scaleform UIs
Lib.Scaleform.SetupInstructionalButtons(buttons) -- Create instructional buttons UI
Lib.Scaleform.ShowMessageBox(title, subtitle, footer) -- Show a large message box
Lib.Scaleform.ShowMissionPassed(title, subtitle, rp, money) -- Show mission passed UI
Lib.Scaleform.ShowCountdown(number, message) -- Show a countdown UI
Lib.Scaleform.ShowCredits(items) -- Show scrolling credits UI
```

## Basic Usage
```lua
local Lib = exports['glitch-lib']:GetLib()

CreateThread(function()
    while not Lib.IsReady do Wait(100) end
    
    Lib.UI.Notify({
        title = "Library Loaded",
        description = "GlitchLib loaded successfully!",
        type = "success"
    })
end)
```