# Glitch Abstraction

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
3. Add `ensure glitch-abstraction` to your `server.cfg` (make sure it loads before any resources that use it)
4. Reference the library in your scripts: `local GlitchAbst = exports['glitch-abstraction']:GetLib()`

## Function Reference

### Framework Functions
> **Required Resources:** One of: ESX Legacy, QBCore, or QBox

#### Client-Side
```lua
-- Player Data
GlitchAbst.Framework.GetPlayerData() -- Returns player data
GlitchAbst.Framework.TriggerCallback(name, callback, ...) -- Trigger a server callback
GlitchAbst.Framework.Notify(message, type, duration) -- Show notification
GlitchAbst.Framework.ShowHelpNotification(message, thisFrame) -- Show help notification (ESX)
GlitchAbst.Framework.SpawnPlayer(coords, callback) -- Spawn player at coordinates
GlitchAbst.Framework.DrawText(x, y, text) -- Draw 2D text on screen
GlitchAbst.Framework.Draw3DText(coords, text) -- Draw 3D text in world
GlitchAbst.Framework.GetClosestPlayer() -- Returns closest player and distance
GlitchAbst.Framework.GetVehicleProperties(vehicle) -- Get vehicle properties
GlitchAbst.Framework.SetVehicleProperties(vehicle, props) -- Set vehicle properties
```

#### Server-Side
```lua
-- Player Management
GlitchAbst.Framework.GetPlayer(source) -- Get player object
GlitchAbst.Framework.GetPlayerFromIdentifier(identifier) -- Get player from identifier/citizenid
GlitchAbst.Framework.GetPlayers() -- Get all online players

-- Money Management
GlitchAbst.Framework.GetMoney(source) -- Get player's cash
GlitchAbst.Framework.AddMoney(source, amount) -- Add cash to player
GlitchAbst.Framework.RemoveMoney(source, amount) -- Remove cash from player
GlitchAbst.Framework.GetBankMoney(source) -- Get player's bank balance
GlitchAbst.Framework.AddBankMoney(source, amount) -- Add to player's bank balance
GlitchAbst.Framework.RemoveBankMoney(source, amount) -- Remove from player's bank balance

-- Job Management
GlitchAbst.Framework.GetJob(source) -- Get player's job
GlitchAbst.Framework.SetJob(source, job, grade) -- Set player's job and grade

-- Notification & Callbacks
GlitchAbst.Framework.RegisterCallback(name, callback) -- Register a server callback
GlitchAbst.Framework.Notify(source, message, type, length) -- Send notification to player
```

### Inventory Functions
> **Required Resources:** One of: ox_inventory, qb-inventory, or ESX inventory

#### Client-Side
```lua
-- Item Management
GlitchAbst.Inventory.GetItems(itemName) -- Get an item or all items definition
GlitchAbst.Inventory.UseItem(data, cb) -- Use an item with callback
GlitchAbst.Inventory.UseSlot(slot) -- Use item in specific slot

-- Inventory Access
GlitchAbst.Inventory.OpenInventory() -- Open player inventory
GlitchAbst.Inventory.CloseInventory() -- Close player inventory
GlitchAbst.Inventory.SetStashTarget(id, owner) -- Set stash target for interactions

-- Weapon Handling
GlitchAbst.Inventory.GetCurrentWeapon() -- Get current weapon data
GlitchAbst.Inventory.WeaponWheel(state) -- Enable/disable weapon wheel

-- Item Lookup
GlitchAbst.Inventory.GetSlotWithItem(itemName, metadata, strict) -- Get first slot containing item
GlitchAbst.Inventory.GetSlotsWithItem(itemName, metadata, strict) -- Get all slots containing item

-- Inventory States
GlitchAbst.Inventory.IsInventoryBusy() -- Check if inventory is in use
GlitchAbst.Inventory.SetInventoryBusy(state) -- Set inventory busy state
GlitchAbst.Inventory.AreHotkeysEnabled() -- Check if inventory hotkeys are enabled
GlitchAbst.Inventory.SetHotkeysEnabled(state) -- Enable/disable inventory hotkeys
GlitchAbst.Inventory.IsInventoryOpen() -- Check if inventory is open
GlitchAbst.Inventory.CanUseWeapons() -- Check if weapons can be used
GlitchAbst.Inventory.SetCanUseWeapons(state) -- Enable/disable weapon usage
```

#### Server-Side
```lua
-- Item Management
GlitchAbst.Inventory.AddItem(source, item, amount, metadata, slot, info, reason) -- Add item to player | QB does NOT use metadata and OX does NOT use info, or reason
GlitchAbst.Inventory.RemoveItem(source, item, count, metadata, slot) -- Remove item from player
GlitchAbst.Inventory.GetItem(source, item, metadata) -- Get item data for player
GlitchAbst.Inventory.GetItemCount(source, item, metadata) -- Get count of item player has
GlitchAbst.Inventory.CanAddItem(source, item, amount) -- Check if player can carry item
GlitchAbst.Inventory.CanCarryItem(source, item, count) -- Check if player can carry item
GlitchAbst.Inventory.CanSwapItem(source, item, count, toSlot) -- Check if player can swap item slots
GlitchAbst.Inventory.SetInventory(source, items) -- Set player's entire inventory
GlitchAbst.Inventory.ClearInventory(source) -- Clear player's inventory
GlitchAbst.Inventory.SetItemData(source, itemName, key, val) -- Set specific data for an item
GlitchAbst.Inventory.UseItem(itemName, callback) -- Register item usage handler

-- Inventory Management
GlitchAbst.Inventory.OpenInventory(source, invType, data) -- Open inventory for player
GlitchAbst.Inventory.CloseInventory(source, identifier) -- Close inventory for player
GlitchAbst.Inventory.OpenInventoryById(source, playerId) -- Open another player's inventory
GlitchAbst.Inventory.ConfiscateInventory(source) -- Confiscate player inventory (ox)
GlitchAbst.Inventory.ReturnInventory(source) -- Return confiscated inventory (ox)
GlitchAbst.Inventory.ClearInventory(inv, keep) -- Clear specific inventory with optional keeps

-- Stash Management
GlitchAbst.Inventory.RegisterStash(id, label, slots, maxWeight, owner, groups, coords) -- Register stash
GlitchAbst.Inventory.CreateTemporaryStash(properties) -- Create temporary stash (ox)
GlitchAbst.Inventory.OpenShop(source, name) -- Open shop menu
GlitchAbst.Inventory.CreateShop(shopData) -- Create custom shop

-- Drop Management
GlitchAbst.Inventory.CustomDrop(prefix, items, coords, slots, maxWeight, instance, model) -- Create drop
GlitchAbst.Inventory.CreateDropFromPlayer(playerId) -- Create drop from player inventory

-- Item Lookup
GlitchAbst.Inventory.GetFreeWeight(source) -- Get remaining weight capacity
GlitchAbst.Inventory.GetSlots(identifier) -- Get slot data for inventory
GlitchAbst.Inventory.GetSlotsByItem(items, itemName) -- Get all slots containing specific item
GlitchAbst.Inventory.GetFirstSlotByItem(items, itemName) -- Get first slot with specific item
GlitchAbst.Inventory.GetItemBySlot(source, slot) -- Get item in specific slot
GlitchAbst.Inventory.GetItemByName(source, item) -- Get first instance of item
GlitchAbst.Inventory.GetItemsByName(source, item) -- Get all instances of item
GlitchAbst.Inventory.Search(source, search, item, metadata) -- Search inventory (ox)
GlitchAbst.Inventory.GetSlot(source, slot) -- Get item in specific slot (ox)
GlitchAbst.Inventory.SwapSlots(source, fromSlot, toSlot) -- Swap inventory slots (ox)

-- Inventory State Control
GlitchAbst.Inventory.SetBusy(source, state) -- Set inventory busy state
GlitchAbst.Inventory.LockInventory(source) -- Lock player inventory
GlitchAbst.Inventory.UnlockInventory(source) -- Unlock player inventory
```

### UI Functions
> **Required Resources:** ox_lib for most advanced features

#### Client-Side Input Dialog
> **Required Resource:** ox_lib
```lua
-- Basic Input Dialog
GlitchAbst.UI.Input(header, inputs, options) -- Show input dialog window
GlitchAbst.UI.CloseInputDialog() -- Force close open input dialog
GlitchAbst.UI.InputForm(title, fields, options) -- Advanced dialog with typed fields
GlitchAbst.UI.BuildForm(title, fields, options) -- Convenience method for form building

-- Input Field Constructors
GlitchAbst.UI.Inputs.Text(label, options) -- Create text input field
GlitchAbst.UI.Inputs.Number(label, options) -- Create number input field
GlitchAbst.UI.Inputs.Checkbox(label, options) -- Create checkbox input
GlitchAbst.UI.Inputs.Select(label, optionsList, options) -- Create dropdown select
GlitchAbst.UI.Inputs.MultiSelect(label, optionsList, options) -- Create multi-select dropdown
GlitchAbst.UI.Inputs.Slider(label, options) -- Create slider input
GlitchAbst.UI.Inputs.Color(label, options) -- Create color picker input
GlitchAbst.UI.Inputs.Date(label, options) -- Create date picker input
GlitchAbst.UI.Inputs.DateRange(label, options) -- Create date range picker input
GlitchAbst.UI.Inputs.Time(label, options) -- Create time picker input
GlitchAbst.UI.Inputs.TextArea(label, options) -- Create textarea input
```

#### Client-Side Context Menu
> **Required Resource:** ox_lib
```lua
-- Context Menu Management
GlitchAbst.UI.RegisterContext(context) -- Register a context menu
GlitchAbst.UI.ShowContext(id) -- Show a registered context menu
GlitchAbst.UI.HideContext(onExit) -- Hide visible context menu
GlitchAbst.UI.GetOpenContext() -- Get ID of open context menu
GlitchAbst.UI.OpenContextMenu(id, title, options, menu, canClose) -- Create and show in one step
GlitchAbst.UI.ContextMenu(id, title, options, position) -- Legacy context menu display
GlitchAbst.UI.CreateContextMenu(id, title, options) -- Legacy context menu registration
GlitchAbst.UI.BuildMenuStructure(menuTree) -- Helper for building nested menus
GlitchAbst.UI.ConfirmContextMenu(id, title, message, onConfirm, onCancel, confirmText, cancelText) -- Show confirmation dialog
```

#### Client-Side Keyboard Navigation Menu
> **Required Resource:** ox_lib
```lua
-- Menu Management
GlitchAbst.UI.RegisterMenu(data, cb) -- Register a keyboard navigation menu
GlitchAbst.UI.ShowMenu(id) -- Show a registered menu
GlitchAbst.UI.HideMenu(onExit) -- Hide current menu
GlitchAbst.UI.GetOpenMenu() -- Get ID of open menu
GlitchAbst.UI.SetMenuOptions(id, options, index) -- Update menu options
GlitchAbst.UI.CreateMenuOption(label, options) -- Helper for creating menu options
GlitchAbst.UI.OpenMenu(id, title, options, position, callbacks) -- Create and show in one step
GlitchAbst.UI.ConfirmMenu(id, title, message, onConfirm, onCancel) -- Show confirmation menu
```

#### Client-Side Radial Menu
> **Required Resource:** ox_lib
```lua
-- Radial Menu Management
GlitchAbst.UI.AddRadialItem(items) -- Add items to global radial menu
GlitchAbst.UI.RemoveRadialItem(id) -- Remove item from radial menu
GlitchAbst.UI.ClearRadialItems() -- Remove all items from radial menu
GlitchAbst.UI.RegisterRadial(radial) -- Register a sub-menu
GlitchAbst.UI.HideRadial() -- Hide current radial menu
GlitchAbst.UI.DisableRadial(state) -- Enable/disable radial menu
GlitchAbst.UI.GetCurrentRadialId() -- Get ID of current radial menu
GlitchAbst.UI.CreateRadialItem(id, label, icon, options) -- Helper for creating radial items
GlitchAbst.UI.CreateRadialMenu(id, items) -- Create and register a radial menu
GlitchAbst.UI.QuickRadial(id, label, icon, onSelect) -- Add a single radial item
GlitchAbst.UI.RadialSubmenu(parentId, parentLabel, parentIcon, submenuId, submenuItems) -- Create linked submenus
```

#### Client-Side Progress Indicators
> **Required Resource:** ox_lib
```lua
-- Progress Bar
GlitchAbst.UI.ProgressBar(params) -- Show progress bar with full parameter support
GlitchAbst.UI.ProgressCircle(params) -- Show circular progress indicator
GlitchAbst.UI.IsProgressActive() -- Check if progress bar is active
GlitchAbst.UI.CancelProgress() -- Cancel active progress
GlitchAbst.UI.CreateAnimation(dict, clip, options) -- Helper for creating animation parameters
GlitchAbst.UI.CreateScenario(scenario, options) -- Helper for creating scenario parameters
GlitchAbst.UI.CreateProp(model, options) -- Helper for creating prop parameters
GlitchAbst.UI.DrinkProgress(duration, label, item) -- Show drinking animation progress
GlitchAbst.UI.EatProgress(duration, label, item) -- Show eating animation progress
```

#### Client-Side Text UI
> **Required Resource:** ox_lib
```lua
-- Text UI Management
GlitchAbst.UI.ShowTextUI(text, options) -- Show text UI with full options
GlitchAbst.UI.HideTextUI() -- Hide visible text UI
GlitchAbst.UI.IsTextUIOpen() -- Check if text UI is visible and get text
GlitchAbst.UI.StyledTextUI(text, position, icon, iconColor, style) -- Show styled text UI
GlitchAbst.UI.AnimatedTextUI(text, icon, animation, position, iconColor) -- Show text UI with animated icon

-- Text UI Style Presets
GlitchAbst.UI.TextUIStyles.Success -- Green success style
GlitchAbst.UI.TextUIStyles.Error -- Red error style
GlitchAbst.UI.TextUIStyles.Info -- Blue info style
GlitchAbst.UI.TextUIStyles.Warning -- Orange warning style
GlitchAbst.UI.TextUIStyles.Custom(bgColor, textColor, borderRadius) -- Custom style creator

-- Text UI Templates
GlitchAbst.UI.ShowInteractionTextUI(text, key) -- Show interaction prompt
GlitchAbst.UI.ShowSuccessTextUI(text) -- Show success message
GlitchAbst.UI.ShowErrorTextUI(text) -- Show error message
GlitchAbst.UI.ShowWarningTextUI(text) -- Show warning message
```

#### Client-Side Skill Check
> **Required Resource:** ox_lib
```lua
-- Skill Check System
GlitchAbst.UI.SkillCheck(difficulty, inputs) -- Run a skill check with defined difficulty
GlitchAbst.UI.IsSkillCheckActive() -- Check if a skill check is active
GlitchAbst.UI.CancelSkillCheck() -- Cancel ongoing skill check
GlitchAbst.UI.CustomDifficulty(areaSize, speedMultiplier) -- Create custom difficulty
GlitchAbst.UI.SkillCheckSequence(difficulties, inputs, onComplete, onFail) -- Run sequence of checks
GlitchAbst.UI.Lockpick(difficulty, callback) -- Convenience function for lockpicking
GlitchAbst.UI.Hack(difficulty, inputs, callback) -- Convenience function for hacking
```

#### Client-Side Alert Dialog
> **Required Resource:** ox_lib
```lua
-- Alert Dialog
GlitchAbst.UI.Alert(titleOrParams, message, typeParam, icon) -- Show alert dialog
```

### Notification Functions
> **Required Resources:** One of: ox_lib, ESX, QBCore, or internal Glitch Notifications

#### Client-Side
```lua
-- Basic Notifications
GlitchAbst.Notifications.Show(params) -- Show notification with parameters
GlitchAbst.Notifications.Success(title, message, duration, options) -- Show success notification
GlitchAbst.Notifications.Error(title, message, duration, options) -- Show error notification
GlitchAbst.Notifications.Info(title, message, duration, options) -- Show info notification
GlitchAbst.Notifications.Warning(title, message, duration, options) -- Show warning notification

-- Direct Access to Specific Systems
GlitchAbst.Notifications.Glitch.Show(params) -- Show Glitch notification (no external dependency)
GlitchAbst.Notifications.Glitch.Success(title, message, duration) -- Show Glitch success notification
GlitchAbst.Notifications.Glitch.Error(title, message, duration) -- Show Glitch error notification
GlitchAbst.Notifications.Glitch.Toggle(id, title, message, color) -- Toggle persistent notification

GlitchAbst.Notifications.Ox.Show(params) -- Show ox_lib notification (requires ox_lib)
GlitchAbst.Notifications.Ox.Success(title, message, duration, options) -- Show ox_lib success notification
GlitchAbst.Notifications.Ox.Error(title, message, duration, options) -- Show ox_lib error notification
GlitchAbst.Notifications.Ox.Info(title, message, duration, options) -- Show ox_lib info notification
GlitchAbst.Notifications.Ox.Warning(title, message, duration, options) -- Show ox_lib warning notification
GlitchAbst.Notifications.Ox.Custom(params) -- Show custom styled ox_lib notification
GlitchAbst.Notifications.Ox.WithSound(params, soundBank, soundSet, soundName) -- Show notification with sound
GlitchAbst.Notifications.Ox.WithAnimation(params, animation, iconAlign) -- Show notification with animated icon
```

#### Server-Side
> **Required Resources:** ox_lib for server-side notifications
```lua
-- Basic Notifications
GlitchAbst.ServerNotifications.Show(playerId, params) -- Send notification to specific player
GlitchAbst.ServerNotifications.Broadcast(params) -- Send notification to all players
GlitchAbst.ServerNotifications.Success(playerId, title, message, duration, options) -- Send success notification
GlitchAbst.ServerNotifications.Error(playerId, title, message, duration, options) -- Send error notification
GlitchAbst.ServerNotifications.Info(playerId, title, message, duration, options) -- Send info notification
GlitchAbst.ServerNotifications.Warning(playerId, title, message, duration, options) -- Send warning notification

-- Broadcast Helpers
GlitchAbst.ServerNotifications.BroadcastSuccess(title, message, duration, options) -- Broadcast success
GlitchAbst.ServerNotifications.BroadcastError(title, message, duration, options) -- Broadcast error
GlitchAbst.ServerNotifications.BroadcastInfo(title, message, duration, options) -- Broadcast info
GlitchAbst.ServerNotifications.BroadcastWarning(title, message, duration, options) -- Broadcast warning

-- Direct Access to ox_lib Notifications
GlitchAbst.ServerNotifications.Ox.Show(playerId, params) -- Send ox_lib notification to player
GlitchAbst.ServerNotifications.Ox.Broadcast(params) -- Broadcast ox_lib notification to all
GlitchAbst.ServerNotifications.Ox.Success(playerId, title, message, duration, options) -- Send ox success
GlitchAbst.ServerNotifications.Ox.Error(playerId, title, message, duration, options) -- Send ox error
GlitchAbst.ServerNotifications.Ox.Info(playerId, title, message, duration, options) -- Send ox info
GlitchAbst.ServerNotifications.Ox.Warning(playerId, title, message, duration, options) -- Send ox warning
GlitchAbst.ServerNotifications.Ox.Custom(playerId, params) -- Send custom ox notification
GlitchAbst.ServerNotifications.Ox.WithSound(playerId, params, soundBank, soundSet, soundName) -- Send with sound
GlitchAbst.ServerNotifications.Ox.BroadcastSuccess(title, message, duration, options) -- Broadcast ox success
GlitchAbst.ServerNotifications.Ox.BroadcastError(title, message, duration, options) -- Broadcast ox error
GlitchAbst.ServerNotifications.Ox.BroadcastInfo(title, message, duration, options) -- Broadcast ox info
GlitchAbst.ServerNotifications.Ox.BroadcastWarning(title, message, duration, options) -- Broadcast ox warning
```

### Target System Functions
> **Required Resources:** One of: ox_target, qb-target, or bt-target

#### Client-Side
```lua
-- Entity Targeting
GlitchAbst.Target.AddTargetEntity(entities, options) -- Add options to specific entities
GlitchAbst.Target.AddTargetModel(models, options) -- Add options to all entities of specified models

-- Zone Targeting
GlitchAbst.Target.AddBoxZone(name, center, length, width, options, targetOptions) -- Create box interaction zone | Alternative for ox: AddBoxZone({parameters})
GlitchAbst.Target.AddSphereZone(name, center, radius, options, targetOptions) -- Create spherical interaction zone
GlitchAbst.Target.RemoveZone(id) -- Remove interaction zone

-- Global Targeting
GlitchAbst.Target.AddGlobalPlayer(options) -- Add options to all players
GlitchAbst.Target.AddGlobalVehicle(options) -- Add options to all vehicles
GlitchAbst.Target.AddGlobalObject(options) -- Add options to all objects
```

### Door Lock Functions
> **Required Resources:** One of: ox_doorlock, qb-doorlock, or esx_doorlock

#### Client-Side
```lua
GlitchAbst.DoorLock.IsDoorLocked(door) -- Check if door is locked (id or name)
GlitchAbst.DoorLock.SetDoorLocked(door, state) -- Lock/unlock a door
GlitchAbst.DoorLock.GetNearbyDoors() -- Get doors near the player
GlitchAbst.DoorLock.GetAllDoors() -- Get all doors
GlitchAbst.DoorLock.HasAccess(door) -- Check if player has access to door
```

#### Server-Side
```lua
GlitchAbst.DoorLock.GetDoorState(door) -- Get door state (locked/unlocked)
GlitchAbst.DoorLock.SetDoorState(door, state, playerId) -- Set door state
GlitchAbst.DoorLock.PlayerHasAccess(source, door) -- Check if player has access to door
GlitchAbst.DoorLock.GetAllDoors() -- Get all doors
GlitchAbst.DoorLock.AddDoor(door) -- Add a new door (if supported)
GlitchAbst.DoorLock.RemoveDoor(door) -- Remove a door (if supported)
```

### Cutscenes Functions (Client-Side)
> **Required Resources:** None (uses native GTA functions)
```lua
-- Appearance Management
GlitchAbst.Cutscene.SavePlayerAppearance() -- Save current player appearance
GlitchAbst.Cutscene.RestorePlayerAppearance() -- Restore saved player appearance

-- Cutscene Control
GlitchAbst.Cutscene.Play(cutsceneName, options) -- Play cutscene with options
GlitchAbst.Cutscene.Stop(immediate) -- Stop current cutscene
GlitchAbst.Cutscene.IsActive() -- Check if a cutscene is active
GlitchAbst.Cutscene.IsPlaying() -- Check if a cutscene is currently playing
GlitchAbst.Cutscene.GetTime() -- Get current cutscene time (ms)
GlitchAbst.Cutscene.SkipToTime(time) -- Skip to specific time in cutscene (ms)
```

### Progression Functions
> **Required Resources:** pickle_xp

#### Client-Side
```lua
-- Experience & Levels
GlitchAbst.Progression.GetXP() -- Get player's current XP
GlitchAbst.Progression.GetLevel() -- Get player's current level
GlitchAbst.Progression.GetRankData() -- Get detailed rank data
GlitchAbst.Progression.GetUserData() -- Get user's progression data
GlitchAbst.Progression.HasRank(rank) -- Check if player has specific rank

-- UI Functions
GlitchAbst.Progression.DrawXPBar(show) -- Show/hide XP bar
GlitchAbst.Progression.ShowRank(state) -- Show/hide rank display
```

#### Server-Side
```lua
-- Experience Management
GlitchAbst.Progression.GetXP(source) -- Get player's XP
GlitchAbst.Progression.AddXP(source, amount, reason) -- Add XP to player
GlitchAbst.Progression.SetXP(source, amount) -- Set player's XP
GlitchAbst.Progression.GetLevel(source) -- Get player's level
GlitchAbst.Progression.SetLevel(source, level) -- Set player's level
GlitchAbst.Progression.AddLevels(source, amount) -- Add levels to player

-- XP Sources
GlitchAbst.Progression.RegisterXPSource(name, min, max, notify) -- Register XP source
GlitchAbst.Progression.AwardXPFromSource(source, sourceName) -- Award XP from source

-- Rank Management
GlitchAbst.Progression.GetRankData(source) -- Get player's rank data
GlitchAbst.Progression.GetUserData(source) -- Get player's user data
GlitchAbst.Progression.HasRank(source, rank) -- Check if player has specific rank
```

### Scaleform Functions (Client-Side)
> **Required Resources:** None (uses native GTA functions)
```lua
-- Basic Scaleform Management
GlitchAbst.Scaleform.Load(name) -- Load a scaleform by name, returns handle
GlitchAbst.Scaleform.Unload(nameOrHandle) -- Unload a scaleform by name or handle
GlitchAbst.Scaleform.CallFunction(handleOrName, returnValue, funcName, ...) -- Call function on scaleform
GlitchAbst.Scaleform.Render(handleOrName, x, y, width, height, r, g, b, a, scale) -- Render scaleform 2D
GlitchAbst.Scaleform.Render3D(handleOrName, x, y, z, rx, ry, rz, scale) -- Render scaleform in 3D world

-- Common Scaleform UIs
GlitchAbst.Scaleform.SetupInstructionalButtons(buttons) -- Create instructional buttons UI
GlitchAbst.Scaleform.ShowMessageBox(title, subtitle, footer) -- Show a large message box
GlitchAbst.Scaleform.ShowMissionPassed(title, subtitle, rp, money) -- Show mission passed UI
GlitchAbst.Scaleform.ShowCountdown(number, message) -- Show a countdown UI
GlitchAbst.Scaleform.ShowCredits(items) -- Show scrolling credits UI
```

## Basic Usage
```lua
local Lib = exports['glitch-abstraction']:GetLib()

CreateThread(function()
    while not GlitchAbst.IsReady do Wait(100) end
    
    GlitchAbst.Notifications.Success("Library Loaded", "GlitchAbst loaded successfully!")
    
    -- Show input dialog (requires ox_lib)
    local result = GlitchAbst.UI.Input("Enter Information", {
        GlitchAbst.UI.Inputs.Text("Name", {required = true}),
        GlitchAbst.UI.Inputs.Number("Age", {min = 18, max = 100})
    })
    
    if result then
        -- Use context menu (requires ox_lib)
        GlitchAbst.UI.RegisterContext({
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
                        GlitchAbst.UI.ProgressCircle({
                            duration = 3000,
                            label = 'Loading...',
                            position = 'middle'
                        })
                    end
                }
            }
        })
        
        GlitchAbst.UI.ShowContext('example_menu')
    end
end)
```
