# GlitchLib

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
- ox_lib
- QBCore
- ESX

### Supported Notifications Systems
- ox_lib
- QBCore
- ESX
- Glitch Notifications

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
4. Reference the library in your scripts: `local Lib = exports['glitch-lib']:GetLib()`

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

#### Client-Side
```lua
-- Item Management
Lib.Inventory.GetItems(itemName) -- Get an item or all items definition
Lib.Inventory.UseItem(data, cb) -- Use an item with callback
Lib.Inventory.UseSlot(slot) -- Use item in specific slot

-- Inventory Access
Lib.Inventory.OpenInventory() -- Open player inventory
Lib.Inventory.CloseInventory() -- Close player inventory
Lib.Inventory.SetStashTarget(id, owner) -- Set stash target for interactions

-- Weapon Handling
Lib.Inventory.GetCurrentWeapon() -- Get current weapon data
Lib.Inventory.WeaponWheel(state) -- Enable/disable weapon wheel

-- Item Lookup
Lib.Inventory.GetSlotWithItem(itemName, metadata, strict) -- Get first slot containing item
Lib.Inventory.GetSlotsWithItem(itemName, metadata, strict) -- Get all slots containing item

-- Inventory States
Lib.Inventory.IsInventoryBusy() -- Check if inventory is in use
Lib.Inventory.SetInventoryBusy(state) -- Set inventory busy state
Lib.Inventory.AreHotkeysEnabled() -- Check if inventory hotkeys are enabled
Lib.Inventory.SetHotkeysEnabled(state) -- Enable/disable inventory hotkeys
Lib.Inventory.IsInventoryOpen() -- Check if inventory is open
Lib.Inventory.CanUseWeapons() -- Check if weapons can be used
Lib.Inventory.SetCanUseWeapons(state) -- Enable/disable weapon usage
```

#### Server-Side
```lua
-- Item Management
Lib.Inventory.AddItem(source, item, count, metadata, slot) -- Add item to player
Lib.Inventory.RemoveItem(source, item, count, metadata, slot) -- Remove item from player
Lib.Inventory.GetItem(source, item, metadata) -- Get item data for player
Lib.Inventory.GetItemCount(source, item, metadata) -- Get count of item player has
Lib.Inventory.CanAddItem(source, item, amount) -- Check if player can carry item
Lib.Inventory.CanCarryItem(source, item, count) -- Check if player can carry item
Lib.Inventory.CanSwapItem(source, item, count, toSlot) -- Check if player can swap item slots
Lib.Inventory.SetInventory(source, items) -- Set player's entire inventory
Lib.Inventory.ClearInventory(source) -- Clear player's inventory
Lib.Inventory.SetItemData(source, itemName, key, val) -- Set specific data for an item
Lib.Inventory.UseItem(itemName, callback) -- Register item usage handler

-- Inventory Management
Lib.Inventory.OpenInventory(source, invType, data) -- Open inventory for player
Lib.Inventory.CloseInventory(source, identifier) -- Close inventory for player
Lib.Inventory.OpenInventoryById(source, playerId) -- Open another player's inventory
Lib.Inventory.ConfiscateInventory(source) -- Confiscate player inventory (ox)
Lib.Inventory.ReturnInventory(source) -- Return confiscated inventory (ox)
Lib.Inventory.ClearInventory(inv, keep) -- Clear specific inventory with optional keeps

-- Stash Management
Lib.Inventory.RegisterStash(id, label, slots, maxWeight, owner, groups, coords) -- Register stash
Lib.Inventory.CreateTemporaryStash(properties) -- Create temporary stash (ox)
Lib.Inventory.OpenShop(source, name) -- Open shop menu
Lib.Inventory.CreateShop(shopData) -- Create custom shop

-- Drop Management
Lib.Inventory.CustomDrop(prefix, items, coords, slots, maxWeight, instance, model) -- Create drop
Lib.Inventory.CreateDropFromPlayer(playerId) -- Create drop from player inventory

-- Item Lookup
Lib.Inventory.GetFreeWeight(source) -- Get remaining weight capacity
Lib.Inventory.GetSlots(identifier) -- Get slot data for inventory
Lib.Inventory.GetSlotsByItem(items, itemName) -- Get all slots containing specific item
Lib.Inventory.GetFirstSlotByItem(items, itemName) -- Get first slot with specific item
Lib.Inventory.GetItemBySlot(source, slot) -- Get item in specific slot
Lib.Inventory.GetItemByName(source, item) -- Get first instance of item
Lib.Inventory.GetItemsByName(source, item) -- Get all instances of item
Lib.Inventory.Search(source, search, item, metadata) -- Search inventory (ox)
Lib.Inventory.GetSlot(source, slot) -- Get item in specific slot (ox)
Lib.Inventory.SwapSlots(source, fromSlot, toSlot) -- Swap inventory slots (ox)

-- Inventory State Control
Lib.Inventory.SetBusy(source, state) -- Set inventory busy state
Lib.Inventory.LockInventory(source) -- Lock player inventory
Lib.Inventory.UnlockInventory(source) -- Unlock player inventory
```

### UI Functions

#### Client-Side Input Dialog
```lua
-- Basic Input Dialog
Lib.UI.Input(header, inputs, options) -- Show input dialog window
Lib.UI.CloseInputDialog() -- Force close open input dialog
Lib.UI.InputForm(title, fields, options) -- Advanced dialog with typed fields
Lib.UI.BuildForm(title, fields, options) -- Convenience method for form building

-- Input Field Constructors
Lib.UI.Inputs.Text(label, options) -- Create text input field
Lib.UI.Inputs.Number(label, options) -- Create number input field
Lib.UI.Inputs.Checkbox(label, options) -- Create checkbox input
Lib.UI.Inputs.Select(label, optionsList, options) -- Create dropdown select
Lib.UI.Inputs.MultiSelect(label, optionsList, options) -- Create multi-select dropdown
Lib.UI.Inputs.Slider(label, options) -- Create slider input
Lib.UI.Inputs.Color(label, options) -- Create color picker input
Lib.UI.Inputs.Date(label, options) -- Create date picker input
Lib.UI.Inputs.DateRange(label, options) -- Create date range picker input
Lib.UI.Inputs.Time(label, options) -- Create time picker input
Lib.UI.Inputs.TextArea(label, options) -- Create textarea input
```

#### Client-Side Context Menu
```lua
-- Context Menu Management
Lib.UI.RegisterContext(context) -- Register a context menu
Lib.UI.ShowContext(id) -- Show a registered context menu
Lib.UI.HideContext(onExit) -- Hide visible context menu
Lib.UI.GetOpenContext() -- Get ID of open context menu
Lib.UI.OpenContextMenu(id, title, options, menu, canClose) -- Create and show in one step
Lib.UI.ContextMenu(id, title, options, position) -- Legacy context menu display
Lib.UI.CreateContextMenu(id, title, options) -- Legacy context menu registration
Lib.UI.BuildMenuStructure(menuTree) -- Helper for building nested menus
Lib.UI.ConfirmContextMenu(id, title, message, onConfirm, onCancel, confirmText, cancelText) -- Show confirmation dialog
```

#### Client-Side Keyboard Navigation Menu
```lua
-- Menu Management
Lib.UI.RegisterMenu(data, cb) -- Register a keyboard navigation menu
Lib.UI.ShowMenu(id) -- Show a registered menu
Lib.UI.HideMenu(onExit) -- Hide current menu
Lib.UI.GetOpenMenu() -- Get ID of open menu
Lib.UI.SetMenuOptions(id, options, index) -- Update menu options
Lib.UI.CreateMenuOption(label, options) -- Helper for creating menu options
Lib.UI.OpenMenu(id, title, options, position, callbacks) -- Create and show in one step
Lib.UI.ConfirmMenu(id, title, message, onConfirm, onCancel) -- Show confirmation menu
```

#### Client-Side Radial Menu
```lua
-- Radial Menu Management
Lib.UI.AddRadialItem(items) -- Add items to global radial menu
Lib.UI.RemoveRadialItem(id) -- Remove item from radial menu
Lib.UI.ClearRadialItems() -- Remove all items from radial menu
Lib.UI.RegisterRadial(radial) -- Register a sub-menu
Lib.UI.HideRadial() -- Hide current radial menu
Lib.UI.DisableRadial(state) -- Enable/disable radial menu
Lib.UI.GetCurrentRadialId() -- Get ID of current radial menu
Lib.UI.CreateRadialItem(id, label, icon, options) -- Helper for creating radial items
Lib.UI.CreateRadialMenu(id, items) -- Create and register a radial menu
Lib.UI.QuickRadial(id, label, icon, onSelect) -- Add a single radial item
Lib.UI.RadialSubmenu(parentId, parentLabel, parentIcon, submenuId, submenuItems) -- Create linked submenus
```

#### Client-Side Progress Indicators
```lua
-- Progress Bar
Lib.UI.ProgressBar(params) -- Show progress bar with full parameter support
Lib.UI.ProgressCircle(params) -- Show circular progress indicator
Lib.UI.IsProgressActive() -- Check if progress bar is active
Lib.UI.CancelProgress() -- Cancel active progress
Lib.UI.CreateAnimation(dict, clip, options) -- Helper for creating animation parameters
Lib.UI.CreateScenario(scenario, options) -- Helper for creating scenario parameters
Lib.UI.CreateProp(model, options) -- Helper for creating prop parameters
Lib.UI.DrinkProgress(duration, label, item) -- Show drinking animation progress
Lib.UI.EatProgress(duration, label, item) -- Show eating animation progress
```

#### Client-Side Text UI
```lua
-- Text UI Management
Lib.UI.ShowTextUI(text, options) -- Show text UI with full options
Lib.UI.HideTextUI() -- Hide visible text UI
Lib.UI.IsTextUIOpen() -- Check if text UI is visible and get text
Lib.UI.StyledTextUI(text, position, icon, iconColor, style) -- Show styled text UI
Lib.UI.AnimatedTextUI(text, icon, animation, position, iconColor) -- Show text UI with animated icon

-- Text UI Style Presets
Lib.UI.TextUIStyles.Success -- Green success style
Lib.UI.TextUIStyles.Error -- Red error style
Lib.UI.TextUIStyles.Info -- Blue info style
Lib.UI.TextUIStyles.Warning -- Orange warning style
Lib.UI.TextUIStyles.Custom(bgColor, textColor, borderRadius) -- Custom style creator

-- Text UI Templates
Lib.UI.ShowInteractionTextUI(text, key) -- Show interaction prompt
Lib.UI.ShowSuccessTextUI(text) -- Show success message
Lib.UI.ShowErrorTextUI(text) -- Show error message
Lib.UI.ShowWarningTextUI(text) -- Show warning message
```

#### Client-Side Skill Check
```lua
-- Skill Check System
Lib.UI.SkillCheck(difficulty, inputs) -- Run a skill check with defined difficulty
Lib.UI.IsSkillCheckActive() -- Check if a skill check is active
Lib.UI.CancelSkillCheck() -- Cancel ongoing skill check
Lib.UI.CustomDifficulty(areaSize, speedMultiplier) -- Create custom difficulty
Lib.UI.SkillCheckSequence(difficulties, inputs, onComplete, onFail) -- Run sequence of checks
Lib.UI.Lockpick(difficulty, callback) -- Convenience function for lockpicking
Lib.UI.Hack(difficulty, inputs, callback) -- Convenience function for hacking
```

#### Client-Side Alert Dialog
```lua
-- Alert Dialog
Lib.UI.Alert(titleOrParams, message, typeParam, icon) -- Show alert dialog
```

### Notification Functions

#### Client-Side
```lua
-- Basic Notifications
Lib.Notifications.Show(params) -- Show notification with parameters
Lib.Notifications.Success(title, message, duration, options) -- Show success notification
Lib.Notifications.Error(title, message, duration, options) -- Show error notification
Lib.Notifications.Info(title, message, duration, options) -- Show info notification
Lib.Notifications.Warning(title, message, duration, options) -- Show warning notification

-- Direct Access to Specific Systems
Lib.Notifications.Glitch.Show(params) -- Show Glitch notification
Lib.Notifications.Glitch.Success(title, message, duration) -- Show Glitch success notification
Lib.Notifications.Glitch.Error(title, message, duration) -- Show Glitch error notification
Lib.Notifications.Glitch.Toggle(id, title, message, color) -- Toggle persistent notification

Lib.Notifications.Ox.Show(params) -- Show ox_lib notification
Lib.Notifications.Ox.Success(title, message, duration, options) -- Show ox_lib success notification
Lib.Notifications.Ox.Error(title, message, duration, options) -- Show ox_lib error notification
Lib.Notifications.Ox.Info(title, message, duration, options) -- Show ox_lib info notification
Lib.Notifications.Ox.Warning(title, message, duration, options) -- Show ox_lib warning notification
Lib.Notifications.Ox.Custom(params) -- Show custom styled ox_lib notification
Lib.Notifications.Ox.WithSound(params, soundBank, soundSet, soundName) -- Show notification with sound
Lib.Notifications.Ox.WithAnimation(params, animation, iconAlign) -- Show notification with animated icon
```

#### Server-Side
```lua
-- Basic Notifications
Lib.ServerNotifications.Show(playerId, params) -- Send notification to specific player
Lib.ServerNotifications.Broadcast(params) -- Send notification to all players
Lib.ServerNotifications.Success(playerId, title, message, duration, options) -- Send success notification
Lib.ServerNotifications.Error(playerId, title, message, duration, options) -- Send error notification
Lib.ServerNotifications.Info(playerId, title, message, duration, options) -- Send info notification
Lib.ServerNotifications.Warning(playerId, title, message, duration, options) -- Send warning notification

-- Broadcast Helpers
Lib.ServerNotifications.BroadcastSuccess(title, message, duration, options) -- Broadcast success
Lib.ServerNotifications.BroadcastError(title, message, duration, options) -- Broadcast error
Lib.ServerNotifications.BroadcastInfo(title, message, duration, options) -- Broadcast info
Lib.ServerNotifications.BroadcastWarning(title, message, duration, options) -- Broadcast warning

-- Direct Access to ox_lib Notifications
Lib.ServerNotifications.Ox.Show(playerId, params) -- Send ox_lib notification to player
Lib.ServerNotifications.Ox.Broadcast(params) -- Broadcast ox_lib notification to all
Lib.ServerNotifications.Ox.Success(playerId, title, message, duration, options) -- Send ox success
Lib.ServerNotifications.Ox.Error(playerId, title, message, duration, options) -- Send ox error
Lib.ServerNotifications.Ox.Info(playerId, title, message, duration, options) -- Send ox info
Lib.ServerNotifications.Ox.Warning(playerId, title, message, duration, options) -- Send ox warning
Lib.ServerNotifications.Ox.Custom(playerId, params) -- Send custom ox notification
Lib.ServerNotifications.Ox.WithSound(playerId, params, soundBank, soundSet, soundName) -- Send with sound
Lib.ServerNotifications.Ox.BroadcastSuccess(title, message, duration, options) -- Broadcast ox success
Lib.ServerNotifications.Ox.BroadcastError(title, message, duration, options) -- Broadcast ox error
Lib.ServerNotifications.Ox.BroadcastInfo(title, message, duration, options) -- Broadcast ox info
Lib.ServerNotifications.Ox.BroadcastWarning(title, message, duration, options) -- Broadcast ox warning
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

### Cutscenes Functions (Client-Side)
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
    
    -- Show input dialog
    local result = Lib.UI.Input("Enter Information", {
        Lib.UI.Inputs.Text("Name", {required = true}),
        Lib.UI.Inputs.Number("Age", {min = 18, max = 100})
    })
    
    if result then
        -- Use context menu
        Lib.UI.RegisterContext({
            id = 'example_menu',
            title = 'Example Menu',
            options = {
                {
                    title = 'Welcome ' .. result[1],
                    description = 'You are ' .. result[2] .. ' years old',
                    icon = 'user'
                },
                {
                    title = 'Continue',
                    icon = 'check',
                    onSelect = function()
                        Lib.UI.ProgressCircle({
                            duration = 3000,
                            label = 'Loading...',
                            position = 'middle'
                        })
                    end
                }
            }
        })
        
        Lib.UI.ShowContext('example_menu')
    end
end)
```