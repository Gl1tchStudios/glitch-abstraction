<div align="center">

<img src="https://store.glitchstudios.dev/img/f0be725ae6efb6e8.png" alt="Abstraction" width="100%">

# glitch-abstraction

### One API for the framework, inventory, target, UI, door lock, notification and XP resources on your server.

**Write a script once and run it on ESX, QBCore or Qbox.**<br>
The library detects what is running, loads the matching module and hands your script a single `GlitchAbst` table. Money, items, players, callbacks, targets, menus, notifications, door locks and XP all go through the same function names.

![Version](https://img.shields.io/badge/version-1.2.0-blue)
![FiveM](https://img.shields.io/badge/FiveM-cerulean-F40552)
![Framework](https://img.shields.io/badge/framework-ESX%20%7C%20QBCore%20%7C%20Qbox-2d6a4f)
![Lua](https://img.shields.io/badge/Lua-5.4-2C2D72?logo=lua&logoColor=white)
![Database](https://img.shields.io/badge/database-none%20(oxmysql%20optional)-4479A1)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

[Features](#features) &middot; [What you need](#what-you-need) &middot; [Install](#install) &middot; [Usage](#usage) &middot; [Configuration](#configuration) &middot; [Cutscene tools](#cutscene-tools-optional) &middot; [Troubleshooting](#troubleshooting)

</div>

---

## Features

| | |
|---|---|
| **Frameworks** | ESX, QBCore and Qbox (qbx_core). Players, money, jobs, callbacks and usable items behave the same on each. |
| **Inventories** | ox_inventory, qb-inventory and the ESX inventory. Add, remove, count, metadata and hooks. |
| **Targets** | ox_target, qb-target and bt-target. qb-target style options are converted for ox_target. |
| **UI** | ox_lib, qb and ESX menus, input dialogs, progress bars, context menus and radial menus. |
| **Notifications** | glitch-notifications, ox_lib, qb or ESX, with one `Notify` call. |
| **Door locks** | ox_doorlock, qb-doorlock and esx_doorlock. |
| **XP** | glitch-xpSystem or pickle_xp behind one set of XP calls. With neither installed the calls return safe defaults. |
| **Scaleforms** | Load, draw and call scaleform movies from one helper. |
| **Cleanup** | ox_target zones, global target options and ox_inventory hooks added through the library are removed when the script that added them stops. |

## What you need

Required:

- FiveM server artifact with OneSync enabled
- ox_lib
- One supported framework: qbx_core, qb-core or es_extended

Tested with qbx_core 1.24.0, ox_lib 3.40.0, ox_inventory 2.48.0 and ox_target 1.17.2.

Detected at run time. Install what your server uses, the library skips the rest:

- ox_inventory, qb-inventory
- ox_target, qb-target, bt-target
- ox_doorlock, qb-doorlock, esx_doorlock
- glitch-notifications
- glitch-xpSystem, pickle_xp

Only for the optional [cutscene tools](#cutscene-tools-optional): oxmysql, glitch-mapHandler, glitch-appearance, glitch-photos, glitch-admin and glitch-cloudsLoading.

## Install

1. Copy the `glitch-abstraction` folder into your `resources` folder.
2. Add `ensure glitch-abstraction` to your `server.cfg` after ox_lib and your framework, and before every script that uses it.

```
ensure ox_lib
ensure qbx_core
ensure ox_inventory
ensure ox_target
ensure glitch-abstraction
ensure your-script-that-uses-it
```

3. Start the server. The console prints `GLITCH LIB LOADED: YES` once a framework is found.

No database tables and no items are needed. The files are open on purpose: the modules are read with `LoadResourceFile`, which cannot read escrowed files.

## Usage

Grab the table once and wait for it to be ready:

```lua
local GA = exports['glitch-abstraction']:getAbstraction()

AddEventHandler('GlitchAbst:ready', function(ready)
    if not ready then return end
    -- GA.Framework, GA.Inventory, GA.Target, GA.UI, GA.Notifications, GA.DoorLock, GA.Progression
end)
```

A few calls, server side:

```lua
GA.Framework.GetPlayer(source)
GA.Framework.RegisterCallback('myscript:getThing', function(source, respond, arg)
    respond({ ok = true })
end)
GA.Inventory.RegisterHook('swapItems', function(payload) return true end)
GA.Progression.AddXP(source, 'mining', 25)
```

And client side:

```lua
GA.Target.AddSphereZone('shop', vec3(25.7, -1347.3, 29.5), 1.5, {}, {
    { label = 'Open shop', onSelect = function() end },
})
GA.Framework.TriggerCallback('myscript:getThing', function(result) end, 'arg')
```

Money helpers accept `(source, amount)` or `(source, account, amount)`. Amounts must be finite numbers and are rounded down.

Callbacks registered with `RegisterCallback` run on `lib.callback`. The handler shape is the same as QBCore: `function(source, respond, ...)`. A handler that never answers is dropped after 15 seconds.

Cleanup: zones, global target options and inventory hooks are tracked per script. When that script stops, the library removes them from ox_target and ox_inventory. `RemoveAllHooks` removes only the hooks the calling script added.

Events and exports:

| Name | Side | Use |
|---|---|---|
| `getAbstraction` | both | Returns the `GlitchAbst` table. |
| `GlitchAbst:ready` | server event | Fires once with `true` when a framework is loaded. |
| `PlayCutsceneFor`, `StopCutsceneFor`, `IsInCutscene` | server | Cutscene tools, see below. |
| `glitch-abstraction:cutsceneStatus` | server event | `(target, by, state, why, name)` while a cutscene runs. |

## Configuration

Everything is in `shared/config.lua`.

| Option | Default | What it does |
|---|---|---|
| `Config.Debug` | `false` | Prints `[GlitchAbst]` debug lines. |
| `Config.UseFramework` | `'auto'` | `'auto'`, `'ESX'` or `'QBCore'`. Qbox counts as QBCore. |
| `Config.UISystem`, `NotificationSystem`, `InventorySystem`, `TargetSystem`, `DoorlockSystem` | `'auto'` | Force one module when several resources are running. |
| `Config.ProgressCircle` | `true` | Draws every ox_lib progress bar as the circle. |
| `Config.xpSystem` | `'auto'` | `'auto'`, `'glitch_xpSystem'` or `'pickle_xp'`. |
| `Config.UI`, `Inventory`, `Target`, `DoorLock`, `Notifications` | lists | Detection order for `'auto'`. |
| `Config.Cutscenes` | see file | The optional cutscene tools. |

## Cutscene tools (optional)

A staff tool for Glitch Studios servers: play a GTA cutscene on a player with the map streamed in, in a routing bucket of their own, and put them back where they stood afterwards. `/cutsceneadmin` opens a browser of every cutscene with photos and a "put this player in it" button.

It is off unless `Config.Cutscenes.Enabled` is `true`, or `'auto'` (the default) with glitch-mapHandler installed. Turn it on only if you want it.

- Open the browser with `/cutsceneadmin`. The ACE is `Config.Cutscenes.Admin.Ace` (default `admin`). Holders of `Config.Cutscenes.Admin.EditAce` (default `founder`) can change it from the gear in the panel. Make sure that ACE exists on your server, or change it.
- Filler characters for online scenes come from players' live looks, then from saved looks in the `Config.Cutscenes.Database` tables (needs oxmysql and a glitch-appearance style skins table).
- The previews use glitch-photos, the north_yankton scenes use glitch-mapHandler, the failed-scene list uses glitch-admin. Each one is checked at run time and skipped when it is missing.
- Server exports: `PlayCutsceneFor(target, name, opts)` returns `ok, message, info`. `StopCutsceneFor(target)` and `IsInCutscene(target)`.
- The return spot is read from the server, never from the client.
- Leave the cutscene files in place if you do not use the tool, the manifest lists them. With the tool off they cost nothing. Set `Config.Cutscenes.Admin.Enabled = false` to drop the chat command.
- `Config.Cutscenes.BucketBase` must not overlap routing buckets used by other resources.

## Troubleshooting

- **`GLITCH LIB LOADED: NO`**: no supported framework was running. Check `ensure` order and `Config.UseFramework`.
- **A module is missing**: set `Config.Debug = true` and read the `Skipping ... module` lines.
- **Targets stay after restarting my script**: update to 1.2.0 and make sure your script calls the library through `getAbstraction()`.
- **`/cutsceneadmin` does not exist**: set `Config.Cutscenes.Enabled = true`.
- **Saved looks never appear as fillers**: start oxmysql before this resource and check `Config.Cutscenes.Database`.

## Credits

Built by Glitch Studios. Released under the GNU General Public License v3.0, see `LICENSE`.
