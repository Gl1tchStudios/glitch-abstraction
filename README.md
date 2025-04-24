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
4. Reference the library in your scripts: `local GlitchLib = exports['glitch-lib']:GetLib()`

## Function Reference

### Framework Functions
> **Required Resources:** One of: ESX Legacy, QBCore, or QBox

#### Client-Side
```lua
-- Player Data
GlitchLib.Framework.GetPlayerData() -- Returns player data
GlitchLib.Framework.TriggerCallback(name, callback, ...) -- Trigger a server callback
GlitchLib.Framework.Notify(message, type, duration) -- Show notification
GlitchLib.Framework.ShowHelpNotification(message, thisFrame) -- Show help notification (ESX)
GlitchLib.Framework.SpawnPlayer(coords, callback) -- Spawn player at coordinates
GlitchLib.Framework.DrawText(x, y, text) -- Draw 2D text on screen
GlitchLib.Framework.Draw3DText(coords, text) -- Draw 3D text in world
GlitchLib.Framework.GetClosestPlayer() -- Returns closest player and distance
GlitchLib.Framework.GetVehicleProperties(vehicle) -- Get vehicle properties
GlitchLib.Framework.SetVehicleProperties(vehicle, props) -- Set vehicle properties
```

#### Server-Side
```lua
-- Player Management
GlitchLib.Framework.GetPlayer(source) -- Get player object
GlitchLib.Framework.GetPlayerFromIdentifier(identifier) -- Get player from identifier/citizenid
GlitchLib.Framework.GetPlayers() -- Get all online players

-- Money Management
GlitchLib.Framework.GetMoney(source) -- Get player's cash
GlitchLib.Framework.AddMoney(source, amount) -- Add cash to player
GlitchLib.Framework.RemoveMoney(source, amount) -- Remove cash from player
GlitchLib.Framework.GetBankMoney(source) -- Get player's bank balance
GlitchLib.Framework.AddBankMoney(source, amount) -- Add to player's bank balance
GlitchLib.Framework.RemoveBankMoney(source, amount) -- Remove from player's bank balance

-- Job Management
GlitchLib.Framework.GetJob(source) -- Get player's job
GlitchLib.Framework.SetJob(source, job, grade) -- Set player's job and grade

-- Notification & Callbacks
GlitchLib.Framework.RegisterCallback(name, callback) -- Register a server callback
GlitchLib.Framework.Notify(source, message, type, length) -- Send notification to player
```

### Inventory Functions
> **Required Resources:** One of: ox_inventory, qb-inventory, or ESX inventory

#### Client-Side
```lua
-- Item Management
GlitchLib.Inventory.GetItems(itemName) -- Get an item or all items definition
GlitchLib.Inventory.UseItem(data, cb) -- Use an item with callback
GlitchLib.Inventory.UseSlot(slot) -- Use item in specific slot

-- Inventory Access
GlitchLib.Inventory.OpenInventory() -- Open player inventory
GlitchLib.Inventory.CloseInventory() -- Close player inventory
GlitchLib.Inventory.SetStashTarget(id, owner) -- Set stash target for interactions

-- Weapon Handling
GlitchLib.Inventory.GetCurrentWeapon() -- Get current weapon data
GlitchLib.Inventory.WeaponWheel(state) -- Enable/disable weapon wheel

-- Item Lookup
GlitchLib.Inventory.GetSlotWithItem(itemName, metadata, strict) -- Get first slot containing item
GlitchLib.Inventory.GetSlotsWithItem(itemName, metadata, strict) -- Get all slots containing item

-- Inventory States
GlitchLib.Inventory.IsInventoryBusy() -- Check if inventory is in use
GlitchLib.Inventory.SetInventoryBusy(state) -- Set inventory busy state
GlitchLib.Inventory.AreHotkeysEnabled() -- Check if inventory hotkeys are enabled
GlitchLib.Inventory.SetHotkeysEnabled(state) -- Enable/disable inventory hotkeys
GlitchLib.Inventory.IsInventoryOpen() -- Check if inventory is open
GlitchLib.Inventory.CanUseWeapons() -- Check if weapons can be used
GlitchLib.Inventory.SetCanUseWeapons(state) -- Enable/disable weapon usage
```

#### Server-Side
```lua
-- Item Management
GlitchLib.Inventory.AddItem(source, item, count, metadata, slot) -- Add item to player
GlitchLib.Inventory.RemoveItem(source, item, count, metadata, slot) -- Remove item from player
GlitchLib.Inventory.GetItem(source, item, metadata) -- Get item data for player
GlitchLib.Inventory.GetItemCount(source, item, metadata) -- Get count of item player has
GlitchLib.Inventory.CanAddItem(source, item, amount) -- Check if player can carry item
GlitchLib.Inventory.CanCarryItem(source, item, count) -- Check if player can carry item
GlitchLib.Inventory.CanSwapItem(source, item, count, toSlot) -- Check if player can swap item slots
GlitchLib.Inventory.SetInventory(source, items) -- Set player's entire inventory
GlitchLib.Inventory.ClearInventory(source) -- Clear player's inventory
GlitchLib.Inventory.SetItemData(source, itemName, key, val) -- Set specific data for an item
GlitchLib.Inventory.UseItem(itemName, callback) -- Register item usage handler

-- Inventory Management
GlitchLib.Inventory.OpenInventory(source, invType, data) -- Open inventory for player
GlitchLib.Inventory.CloseInventory(source, identifier) -- Close inventory for player
GlitchLib.Inventory.OpenInventoryById(source, playerId) -- Open another player's inventory
GlitchLib.Inventory.ConfiscateInventory(source) -- Confiscate player inventory (ox)
GlitchLib.Inventory.ReturnInventory(source) -- Return confiscated inventory (ox)
GlitchLib.Inventory.ClearInventory(inv, keep) -- Clear specific inventory with optional keeps

-- Stash Management
GlitchLib.Inventory.RegisterStash(id, label, slots, maxWeight, owner, groups, coords) -- Register stash
GlitchLib.Inventory.CreateTemporaryStash(properties) -- Create temporary stash (ox)
GlitchLib.Inventory.OpenShop(source, name) -- Open shop menu
GlitchLib.Inventory.CreateShop(shopData) -- Create custom shop

-- Drop Management
GlitchLib.Inventory.CustomDrop(prefix, items, coords, slots, maxWeight, instance, model) -- Create drop
GlitchLib.Inventory.CreateDropFromPlayer(playerId) -- Create drop from player inventory

-- Item Lookup
GlitchLib.Inventory.GetFreeWeight(source) -- Get remaining weight capacity
GlitchLib.Inventory.GetSlots(identifier) -- Get slot data for inventory
GlitchLib.Inventory.GetSlotsByItem(items, itemName) -- Get all slots containing specific item
GlitchLib.Inventory.GetFirstSlotByItem(items, itemName) -- Get first slot with specific item
GlitchLib.Inventory.GetItemBySlot(source, slot) -- Get item in specific slot
GlitchLib.Inventory.GetItemByName(source, item) -- Get first instance of item
GlitchLib.Inventory.GetItemsByName(source, item) -- Get all instances of item
GlitchLib.Inventory.Search(source, search, item, metadata) -- Search inventory (ox)
GlitchLib.Inventory.GetSlot(source, slot) -- Get item in specific slot (ox)
GlitchLib.Inventory.SwapSlots(source, fromSlot, toSlot) -- Swap inventory slots (ox)

-- Inventory State Control
GlitchLib.Inventory.SetBusy(source, state) -- Set inventory busy state
GlitchLib.Inventory.LockInventory(source) -- Lock player inventory
GlitchLib.Inventory.UnlockInventory(source) -- Unlock player inventory
```

### UI Functions
> **Required Resources:** ox_lib for most advanced features

#### Client-Side Input Dialog
> **Required Resource:** ox_lib
```lua
-- Basic Input Dialog
GlitchLib.UI.Input(header, inputs, options) -- Show input dialog window
GlitchLib.UI.CloseInputDialog() -- Force close open input dialog
GlitchLib.UI.InputForm(title, fields, options) -- Advanced dialog with typed fields
GlitchLib.UI.BuildForm(title, fields, options) -- Convenience method for form building

-- Input Field Constructors
GlitchLib.UI.Inputs.Text(label, options) -- Create text input field
GlitchLib.UI.Inputs.Number(label, options) -- Create number input field
GlitchLib.UI.Inputs.Checkbox(label, options) -- Create checkbox input
GlitchLib.UI.Inputs.Select(label, optionsList, options) -- Create dropdown select
GlitchLib.UI.Inputs.MultiSelect(label, optionsList, options) -- Create multi-select dropdown
GlitchLib.UI.Inputs.Slider(label, options) -- Create slider input
GlitchLib.UI.Inputs.Color(label, options) -- Create color picker input
GlitchLib.UI.Inputs.Date(label, options) -- Create date picker input
GlitchLib.UI.Inputs.DateRange(label, options) -- Create date range picker input
GlitchLib.UI.Inputs.Time(label, options) -- Create time picker input
GlitchLib.UI.Inputs.TextArea(label, options) -- Create textarea input
```

#### Client-Side Context Menu
> **Required Resource:** ox_lib
```lua
-- Context Menu Management
GlitchLib.UI.RegisterContext(context) -- Register a context menu
GlitchLib.UI.ShowContext(id) -- Show a registered context menu
GlitchLib.UI.HideContext(onExit) -- Hide visible context menu
GlitchLib.UI.GetOpenContext() -- Get ID of open context menu
GlitchLib.UI.OpenContextMenu(id, title, options, menu, canClose) -- Create and show in one step
GlitchLib.UI.ContextMenu(id, title, options, position) -- Legacy context menu display
GlitchLib.UI.CreateContextMenu(id, title, options) -- Legacy context menu registration
GlitchLib.UI.BuildMenuStructure(menuTree) -- Helper for building nested menus
GlitchLib.UI.ConfirmContextMenu(id, title, message, onConfirm, onCancel, confirmText, cancelText) -- Show confirmation dialog
```

#### Client-Side Keyboard Navigation Menu
> **Required Resource:** ox_lib
```lua
-- Menu Management
GlitchLib.UI.RegisterMenu(data, cb) -- Register a keyboard navigation menu
GlitchLib.UI.ShowMenu(id) -- Show a registered menu
GlitchLib.UI.HideMenu(onExit) -- Hide current menu
GlitchLib.UI.GetOpenMenu() -- Get ID of open menu
GlitchLib.UI.SetMenuOptions(id, options, index) -- Update menu options
GlitchLib.UI.CreateMenuOption(label, options) -- Helper for creating menu options
GlitchLib.UI.OpenMenu(id, title, options, position, callbacks) -- Create and show in one step
GlitchLib.UI.ConfirmMenu(id, title, message, onConfirm, onCancel) -- Show confirmation menu
```

#### Client-Side Radial Menu
> **Required Resource:** ox_lib
```lua
-- Radial Menu Management
GlitchLib.UI.AddRadialItem(items) -- Add items to global radial menu
GlitchLib.UI.RemoveRadialItem(id) -- Remove item from radial menu
GlitchLib.UI.ClearRadialItems() -- Remove all items from radial menu
GlitchLib.UI.RegisterRadial(radial) -- Register a sub-menu
GlitchLib.UI.HideRadial() -- Hide current radial menu
GlitchLib.UI.DisableRadial(state) -- Enable/disable radial menu
GlitchLib.UI.GetCurrentRadialId() -- Get ID of current radial menu
GlitchLib.UI.CreateRadialItem(id, label, icon, options) -- Helper for creating radial items
GlitchLib.UI.CreateRadialMenu(id, items) -- Create and register a radial menu
GlitchLib.UI.QuickRadial(id, label, icon, onSelect) -- Add a single radial item
GlitchLib.UI.RadialSubmenu(parentId, parentLabel, parentIcon, submenuId, submenuItems) -- Create linked submenus
```

#### Client-Side Progress Indicators
> **Required Resource:** ox_lib
```lua
-- Progress Bar
GlitchLib.UI.ProgressBar(params) -- Show progress bar with full parameter support
GlitchLib.UI.ProgressCircle(params) -- Show circular progress indicator
GlitchLib.UI.IsProgressActive() -- Check if progress bar is active
GlitchLib.UI.CancelProgress() -- Cancel active progress
GlitchLib.UI.CreateAnimation(dict, clip, options) -- Helper for creating animation parameters
GlitchLib.UI.CreateScenario(scenario, options) -- Helper for creating scenario parameters
GlitchLib.UI.CreateProp(model, options) -- Helper for creating prop parameters
GlitchLib.UI.DrinkProgress(duration, label, item) -- Show drinking animation progress
GlitchLib.UI.EatProgress(duration, label, item) -- Show eating animation progress
```

#### Client-Side Text UI
> **Required Resource:** ox_lib
```lua
-- Text UI Management
GlitchLib.UI.ShowTextUI(text, options) -- Show text UI with full options
GlitchLib.UI.HideTextUI() -- Hide visible text UI
GlitchLib.UI.IsTextUIOpen() -- Check if text UI is visible and get text
GlitchLib.UI.StyledTextUI(text, position, icon, iconColor, style) -- Show styled text UI
GlitchLib.UI.AnimatedTextUI(text, icon, animation, position, iconColor) -- Show text UI with animated icon

-- Text UI Style Presets
GlitchLib.UI.TextUIStyles.Success -- Green success style
GlitchLib.UI.TextUIStyles.Error -- Red error style
GlitchLib.UI.TextUIStyles.Info -- Blue info style
GlitchLib.UI.TextUIStyles.Warning -- Orange warning style
GlitchLib.UI.TextUIStyles.Custom(bgColor, textColor, borderRadius) -- Custom style creator

-- Text UI Templates
GlitchLib.UI.ShowInteractionTextUI(text, key) -- Show interaction prompt
GlitchLib.UI.ShowSuccessTextUI(text) -- Show success message
GlitchLib.UI.ShowErrorTextUI(text) -- Show error message
GlitchLib.UI.ShowWarningTextUI(text) -- Show warning message
```

#### Client-Side Skill Check
> **Required Resource:** ox_lib
```lua
-- Skill Check System
GlitchLib.UI.SkillCheck(difficulty, inputs) -- Run a skill check with defined difficulty
GlitchLib.UI.IsSkillCheckActive() -- Check if a skill check is active
GlitchLib.UI.CancelSkillCheck() -- Cancel ongoing skill check
GlitchLib.UI.CustomDifficulty(areaSize, speedMultiplier) -- Create custom difficulty
GlitchLib.UI.SkillCheckSequence(difficulties, inputs, onComplete, onFail) -- Run sequence of checks
GlitchLib.UI.Lockpick(difficulty, callback) -- Convenience function for lockpicking
GlitchLib.UI.Hack(difficulty, inputs, callback) -- Convenience function for hacking
```

#### Client-Side Alert Dialog
> **Required Resource:** ox_lib
```lua
-- Alert Dialog
GlitchLib.UI.Alert(titleOrParams, message, typeParam, icon) -- Show alert dialog
```

### Notification Functions
> **Required Resources:** One of: ox_lib, ESX, QBCore, or internal Glitch Notifications

#### Client-Side
```lua
-- Basic Notifications
GlitchLib.Notifications.Show(params) -- Show notification with parameters
GlitchLib.Notifications.Success(title, message, duration, options) -- Show success notification
GlitchLib.Notifications.Error(title, message, duration, options) -- Show error notification
GlitchLib.Notifications.Info(title, message, duration, options) -- Show info notification
GlitchLib.Notifications.Warning(title, message, duration, options) -- Show warning notification

-- Direct Access to Specific Systems
GlitchLib.Notifications.Glitch.Show(params) -- Show Glitch notification (no external dependency)
GlitchLib.Notifications.Glitch.Success(title, message, duration) -- Show Glitch success notification
GlitchLib.Notifications.Glitch.Error(title, message, duration) -- Show Glitch error notification
GlitchLib.Notifications.Glitch.Toggle(id, title, message, color) -- Toggle persistent notification

GlitchLib.Notifications.Ox.Show(params) -- Show ox_lib notification (requires ox_lib)
GlitchLib.Notifications.Ox.Success(title, message, duration, options) -- Show ox_lib success notification
GlitchLib.Notifications.Ox.Error(title, message, duration, options) -- Show ox_lib error notification
GlitchLib.Notifications.Ox.Info(title, message, duration, options) -- Show ox_lib info notification
GlitchLib.Notifications.Ox.Warning(title, message, duration, options) -- Show ox_lib warning notification
GlitchLib.Notifications.Ox.Custom(params) -- Show custom styled ox_lib notification
GlitchLib.Notifications.Ox.WithSound(params, soundBank, soundSet, soundName) -- Show notification with sound
GlitchLib.Notifications.Ox.WithAnimation(params, animation, iconAlign) -- Show notification with animated icon
```

#### Server-Side
> **Required Resources:** ox_lib for server-side notifications
```lua
-- Basic Notifications
GlitchLib.ServerNotifications.Show(playerId, params) -- Send notification to specific player
GlitchLib.ServerNotifications.Broadcast(params) -- Send notification to all players
GlitchLib.ServerNotifications.Success(playerId, title, message, duration, options) -- Send success notification
GlitchLib.ServerNotifications.Error(playerId, title, message, duration, options) -- Send error notification
GlitchLib.ServerNotifications.Info(playerId, title, message, duration, options) -- Send info notification
GlitchLib.ServerNotifications.Warning(playerId, title, message, duration, options) -- Send warning notification

-- Broadcast Helpers
GlitchLib.ServerNotifications.BroadcastSuccess(title, message, duration, options) -- Broadcast success
GlitchLib.ServerNotifications.BroadcastError(title, message, duration, options) -- Broadcast error
GlitchLib.ServerNotifications.BroadcastInfo(title, message, duration, options) -- Broadcast info
GlitchLib.ServerNotifications.BroadcastWarning(title, message, duration, options) -- Broadcast warning

-- Direct Access to ox_lib Notifications
GlitchLib.ServerNotifications.Ox.Show(playerId, params) -- Send ox_lib notification to player
GlitchLib.ServerNotifications.Ox.Broadcast(params) -- Broadcast ox_lib notification to all
GlitchLib.ServerNotifications.Ox.Success(playerId, title, message, duration, options) -- Send ox success
GlitchLib.ServerNotifications.Ox.Error(playerId, title, message, duration, options) -- Send ox error
GlitchLib.ServerNotifications.Ox.Info(playerId, title, message, duration, options) -- Send ox info
GlitchLib.ServerNotifications.Ox.Warning(playerId, title, message, duration, options) -- Send ox warning
GlitchLib.ServerNotifications.Ox.Custom(playerId, params) -- Send custom ox notification
GlitchLib.ServerNotifications.Ox.WithSound(playerId, params, soundBank, soundSet, soundName) -- Send with sound
GlitchLib.ServerNotifications.Ox.BroadcastSuccess(title, message, duration, options) -- Broadcast ox success
GlitchLib.ServerNotifications.Ox.BroadcastError(title, message, duration, options) -- Broadcast ox error
GlitchLib.ServerNotifications.Ox.BroadcastInfo(title, message, duration, options) -- Broadcast ox info
GlitchLib.ServerNotifications.Ox.BroadcastWarning(title, message, duration, options) -- Broadcast ox warning
```

### Target System Functions
> **Required Resources:** One of: ox_target, qb-target, or bt-target

#### Client-Side
```lua
-- Entity Targeting
GlitchLib.Target.AddTargetEntity(entities, options) -- Add options to specific entities
GlitchLib.Target.AddTargetModel(models, options) -- Add options to all entities of specified models

-- Zone Targeting
GlitchLib.Target.AddBoxZone(name, center, length, width, options, targetOptions) -- Create box interaction zone
GlitchLib.Target.AddSphereZone(name, center, radius, options, targetOptions) -- Create spherical interaction zone
GlitchLib.Target.RemoveZone(id) -- Remove interaction zone

-- Global Targeting
GlitchLib.Target.AddGlobalPlayer(options) -- Add options to all players
GlitchLib.Target.AddGlobalVehicle(options) -- Add options to all vehicles
GlitchLib.Target.AddGlobalObject(options) -- Add options to all objects
```

### Door Lock Functions
> **Required Resources:** One of: ox_doorlock, qb-doorlock, or esx_doorlock

#### Client-Side
```lua
GlitchLib.DoorLock.IsDoorLocked(door) -- Check if door is locked (id or name)
GlitchLib.DoorLock.SetDoorLocked(door, state) -- Lock/unlock a door
GlitchLib.DoorLock.GetNearbyDoors() -- Get doors near the player
GlitchLib.DoorLock.GetAllDoors() -- Get all doors
GlitchLib.DoorLock.HasAccess(door) -- Check if player has access to door
```

#### Server-Side
```lua
GlitchLib.DoorLock.GetDoorState(door) -- Get door state (locked/unlocked)
GlitchLib.DoorLock.SetDoorState(door, state, playerId) -- Set door state
GlitchLib.DoorLock.PlayerHasAccess(source, door) -- Check if player has access to door
GlitchLib.DoorLock.GetAllDoors() -- Get all doors
GlitchLib.DoorLock.AddDoor(door) -- Add a new door (if supported)
GlitchLib.DoorLock.RemoveDoor(door) -- Remove a door (if supported)
```

### Cutscenes Functions (Client-Side)
> **Required Resources:** None (uses native GTA functions)
```lua
-- Appearance Management
GlitchLib.Cutscene.SavePlayerAppearance() -- Save current player appearance
GlitchLib.Cutscene.RestorePlayerAppearance() -- Restore saved player appearance

-- Cutscene Control
GlitchLib.Cutscene.Play(cutsceneName, options) -- Play cutscene with options
GlitchLib.Cutscene.Stop(immediate) -- Stop current cutscene
GlitchLib.Cutscene.IsActive() -- Check if a cutscene is active
GlitchLib.Cutscene.IsPlaying() -- Check if a cutscene is currently playing
GlitchLib.Cutscene.GetTime() -- Get current cutscene time (ms)
GlitchLib.Cutscene.SkipToTime(time) -- Skip to specific time in cutscene (ms)
```

### Progression Functions
> **Required Resources:** pickle_xp

#### Client-Side
```lua
-- Experience & Levels
GlitchLib.Progression.GetXP() -- Get player's current XP
GlitchLib.Progression.GetLevel() -- Get player's current level
GlitchLib.Progression.GetRankData() -- Get detailed rank data
GlitchLib.Progression.GetUserData() -- Get user's progression data
GlitchLib.Progression.HasRank(rank) -- Check if player has specific rank

-- UI Functions
GlitchLib.Progression.DrawXPBar(show) -- Show/hide XP bar
GlitchLib.Progression.ShowRank(state) -- Show/hide rank display
```

#### Server-Side
```lua
-- Experience Management
GlitchLib.Progression.GetXP(source) -- Get player's XP
GlitchLib.Progression.AddXP(source, amount, reason) -- Add XP to player
GlitchLib.Progression.SetXP(source, amount) -- Set player's XP
GlitchLib.Progression.GetLevel(source) -- Get player's level
GlitchLib.Progression.SetLevel(source, level) -- Set player's level
GlitchLib.Progression.AddLevels(source, amount) -- Add levels to player

-- XP Sources
GlitchLib.Progression.RegisterXPSource(name, min, max, notify) -- Register XP source
GlitchLib.Progression.AwardXPFromSource(source, sourceName) -- Award XP from source

-- Rank Management
GlitchLib.Progression.GetRankData(source) -- Get player's rank data
GlitchLib.Progression.GetUserData(source) -- Get player's user data
GlitchLib.Progression.HasRank(source, rank) -- Check if player has specific rank
```

### Scaleform Functions (Client-Side)
> **Required Resources:** None (uses native GTA functions)
```lua
-- Basic Scaleform Management
GlitchLib.Scaleform.Load(name) -- Load a scaleform by name, returns handle
GlitchLib.Scaleform.Unload(nameOrHandle) -- Unload a scaleform by name or handle
GlitchLib.Scaleform.CallFunction(handleOrName, returnValue, funcName, ...) -- Call function on scaleform
GlitchLib.Scaleform.Render(handleOrName, x, y, width, height, r, g, b, a, scale) -- Render scaleform 2D
GlitchLib.Scaleform.Render3D(handleOrName, x, y, z, rx, ry, rz, scale) -- Render scaleform in 3D world

-- Common Scaleform UIs
GlitchLib.Scaleform.SetupInstructionalButtons(buttons) -- Create instructional buttons UI
GlitchLib.Scaleform.ShowMessageBox(title, subtitle, footer) -- Show a large message box
GlitchLib.Scaleform.ShowMissionPassed(title, subtitle, rp, money) -- Show mission passed UI
GlitchLib.Scaleform.ShowCountdown(number, message) -- Show a countdown UI
GlitchLib.Scaleform.ShowCredits(items) -- Show scrolling credits UI
```

## Basic Usage
```lua
local Lib = exports['glitch-lib']:GetLib()

CreateThread(function()
    while not GlitchLib.IsReady do Wait(100) end
    
    GlitchLib.Notifications.Success("Library Loaded", "GlitchLib loaded successfully!")
    
    -- Show input dialog (requires ox_lib)
    local result = GlitchLib.UI.Input("Enter Information", {
        GlitchLib.UI.Inputs.Text("Name", {required = true}),
        GlitchLib.UI.Inputs.Number("Age", {min = 18, max = 100})
    })
    
    if result then
        -- Use context menu (requires ox_lib)
        GlitchLib.UI.RegisterContext({
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
                        GlitchLib.UI.ProgressCircle({
                            duration = 3000,
                            label = 'Loading...',
                            position = 'middle'
                        })
                    end
                }
            }
        })
        
        GlitchLib.UI.ShowContext('example_menu')
    end
end)
```