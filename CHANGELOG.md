# Changelog

## 1.2.1

- The startup banner and the emergency initialisation block are gone. A one-line summary prints with `Config.Debug` or when no framework is found.
- `Config.EventGuard = false` turns off the event counter in `server/guard.lua` completely.
- Cutscene admin events allow one action per second per staff member. Dropped the meaningless `GetInvokingResource` checks on server-to-client events.

## 1.2.0

- The cutscene tools are optional. `Config.Cutscenes.Enabled` is `'auto'` and turns on only when glitch-mapHandler is installed. The saved-look tables are config values and oxmysql is reached through its exports, so the database fallback for filler characters works.
- The cutscene return spot is read on the server. A dropped player's map world is cleared, and a look sent by a client is cut down to known keys. Fillers are asked for their look all at once under one 3 second wait.
- ox_target zones, global target options and ox_inventory hooks are removed when the script that added them stops. `RemoveAllHooks` removes only the caller's hooks.
- `RegisterCallback` and `TriggerCallback` use `lib.callback`. Money amounts must be finite and are rounded down.
- `UseItem` is a no-op without qb-inventory. Reviving on Qbox uses qbx_medical.
- One plain `shared/config.lua`. Detection code moved to `shared/utils.lua`. `Config.xpSystem` is `'auto'`. The event counter in `server/guard.lua` does nothing unless glitch-poolcleaning is installed.
- The cutscene search box waits 150 ms before it redraws. Empty debug files removed.
- Manifest gets a name, `@ox_lib/init.lua` and `escrow_ignore`. README and CHANGELOG rewritten.

## 1.1.0

- Cutscene streaming and the `/cutsceneadmin` browser.
