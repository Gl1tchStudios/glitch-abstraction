-- Cutscenes played ON a player, with the map streamed where the scene happens (glitch-admin Troll tab and
-- /cutsceneadmin both end up here, through server/cutscene/cutscene.lua).
--
-- The server has already moved them to a bucket of their own. Here:
--   1. fade to black, remember exactly where they stand (and get them out of a vehicle)
--   2. PRIME: load the scene, start it for a moment only to read where its camera is, stop it again
--   3. hide + freeze their ped there, focus the streaming on it and wait for the map to load
--   4. load it again, cast their ped as MP_1 (online / DLC scenes) + filler characters or invisible dummies in
--      MP_2..MP_4, start it, fade in; the streaming focus follows the camera from shot to shot
--   5. at the end, on Stop, or on any error: fade, drop everything, put the ped back where it stood (same spot,
--      same heading), tell the server (it gives the bucket back), wait for the ground there, wake-up or fade in.
-- Step 5 always runs: the play function runs inside pcall and the cleanup comes after it.
-- Nothing here ever shows text to the player (it is also used as a troll).

if not GlitchAbst or not GlitchAbst.Utils then return false end
GlitchAbst.Cutscene = GlitchAbst.Cutscene or {}

local C = (Config and Config.Cutscenes) or {}
local FREEMODE_M, FREEMODE_F = joaat('mp_m_freemode_01'), joaat('mp_f_freemode_01') -- no backtick hashes: modules go through load()

local run = 0          -- token of the cutscene playing here (a stop or a newer one bumps it)
local busy = false     -- the play thread is still between start and cleanup
local spawned = {}     -- dummies + fillers to delete

local function log(msg) GlitchAbst.Utils.DebugLog('[cutscene] ' .. msg) end

local function waitFor(test, ms, mine)
    local t = GetGameTimer() + ms
    while not test() and GetGameTimer() < t do
        if mine and run ~= mine then return false end
        Wait(0)
    end
    return test()
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    return waitFor(function() return HasModelLoaded(model) end, 3000)
end

-- Cast looks. Once it starts, a cutscene puts its own default clothes and hair on every ped it casts (bald, white
-- tee). Each cast ped's drawables are read before the start, the full look (tattoos, overlays, hair colour) goes
-- back on once it plays, and the clothes are held every frame after that.
local castList = {} -- { { ped, look, snap } }

local function snapLook(ped)
    local s = { c = {}, p = {}, hair = { GetPedHairColor(ped), GetPedHairHighlightColor(ped) } }
    for i = 0, 11 do s.c[i] = { GetPedDrawableVariation(ped, i), GetPedTextureVariation(ped, i), GetPedPaletteVariation(ped, i) } end
    for i = 0, 7 do s.p[i] = { GetPedPropIndex(ped, i), GetPedPropTextureIndex(ped, i) } end
    return s
end

local function holdLook(ped, s)
    for i = 0, 11 do
        local v = s.c[i]
        if GetPedDrawableVariation(ped, i) ~= v[1] or GetPedTextureVariation(ped, i) ~= v[2] then SetPedComponentVariation(ped, i, v[1], v[2], v[3]) end
    end
    for i = 0, 7 do
        local v = s.p[i]
        if GetPedPropIndex(ped, i) ~= v[1] then
            if v[1] == -1 then ClearPedProp(ped, i) else SetPedPropIndex(ped, i, v[1], v[2], true) end
        end
    end
    if GetPedHairColor(ped) ~= s.hair[1] then SetPedHairColor(ped, s.hair[1], s.hair[2]) end
end

local function appearanceUp() return GetResourceState('glitch-appearance') == 'started' end

local function restoreCast()
    for _, m in ipairs(castList) do
        if DoesEntityExist(m.ped) then
            if type(m.look) == 'table' and appearanceUp() then
                pcall(function() exports['glitch-appearance']:setPedAppearance(m.ped, m.look) end)
            end
            holdLook(m.ped, m.snap)
        end
    end
end

local function holdCast()
    for _, m in ipairs(castList) do
        if DoesEntityExist(m.ped) then holdLook(m.ped, m.snap) end
    end
end

-- the server asks for this player's look as it is right now (a filler in someone else's cutscene)
RegisterNetEvent('glitch-abstraction:cutscene:lookReq', function(id)
    if GetInvokingResource() then return end
    local look = false
    if appearanceUp() then
        local ok, a = pcall(function() return exports['glitch-appearance']:getPedAppearance(PlayerPedId()) end)
        if ok and type(a) == 'table' then look = a end
    end
    TriggerServerEvent('glitch-abstraction:cutscene:look', id, look)
end)

-- Their own look from before anything happened: held in the scene and put back once it is gone, so they walk away
-- in exactly what they wore (the cutscene leaves its default clothes / hair on the ped it cast).
local ownLook -- { look, snap }

local function restoreOwnLook(saved)
    if not saved then return end
    local ped = PlayerPedId()
    if type(saved.look) == 'table' and appearanceUp() then
        pcall(function() exports['glitch-appearance']:setPedAppearance(ped, saved.look) end)
    end
    holdLook(ped, saved.snap)
    CreateThread(function()
        local t = GetGameTimer() + 3000
        while GetGameTimer() < t do
            local p = PlayerPedId()
            if DoesEntityExist(p) then holdLook(p, saved.snap) end
            Wait(0)
        end
    end)
end

local function dropScene()
    if IsCutsceneActive() then StopCutsceneImmediately() end
    RemoveCutscene()
    for _, p in ipairs(spawned) do if DoesEntityExist(p) then DeleteEntity(p) end end
    spawned = {}
    castList = {}
end

-- A filler character in a saved look (glitch-appearance setPedAppearance does not wait, safe through an export)
local function fillerPed(f, at)
    local model = joaat(tostring(f.model or ''))
    if model ~= FREEMODE_M and model ~= FREEMODE_F then return nil end
    if not loadModel(model) then return nil end
    local p = CreatePed(4, model, at.x, at.y, at.z - 200.0, 0.0, false, true)
    SetModelAsNoLongerNeeded(model)
    if p == 0 then return nil end
    SetEntityCollision(p, false, false)
    FreezeEntityPosition(p, true)
    SetBlockingOfNonTemporaryEvents(p, true)
    if type(f.skin) == 'table' and GetResourceState('glitch-appearance') == 'started' then
        pcall(function() exports['glitch-appearance']:setPedAppearance(p, f.skin) end)
    else
        SetPedDefaultComponentVariation(p)
    end
    return p, model
end

-- Their own ped as MP_1 in their own clothes; fillers (or invisible dummies, so no default bald extras) in MP_2..4
local function cast(ped, fillers)
    local at = GetEntityCoords(ped)
    loadModel(FREEMODE_M)
    for i, slot in ipairs({ 'MP_2', 'MP_3', 'MP_4' }) do
        local f = type(fillers) == 'table' and fillers[i] or nil
        local p, model
        if type(f) == 'table' then p, model = fillerPed(f, at) end
        if p then
            RegisterEntityForCutscene(p, slot, 0, model, 64)
            SetCutscenePedComponentVariationFromPed(slot, p, model)
            castList[#castList + 1] = { ped = p, look = f.skin, snap = snapLook(p) }
        else
            p = CreatePed(4, FREEMODE_M, at.x, at.y, at.z - 200.0, 0.0, false, true)
            if p ~= 0 then
                SetEntityVisible(p, false, false)
                SetEntityCollision(p, false, false)
                FreezeEntityPosition(p, true)
                RegisterEntityForCutscene(p, slot, 0, FREEMODE_M, 64)
            end
        end
        if p and p ~= 0 then spawned[#spawned + 1] = p end
    end
    SetModelAsNoLongerNeeded(FREEMODE_M)
    if ownLook then holdLook(ped, ownLook.snap) end -- the camera prime may have touched it: their own clothes first
    RegisterEntityForCutscene(ped, 'MP_1', 0, GetEntityModel(ped), 64)
    SetCutscenePedComponentVariationFromPed('MP_1', ped, GetEntityModel(ped))
    castList[#castList + 1] = { ped = ped, look = ownLook and ownLook.look, snap = ownLook and ownLook.snap or snapLook(ped) }
end

local function hide(ped, on)
    SetEntityVisible(ped, not on, false)
    FreezeEntityPosition(ped, on)
    SetEntityCollision(ped, not on, not on)
    SetEntityInvincible(ped, on)
end

local function stream(pos, mine)
    SetFocusPosAndVel(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0)
    NewLoadSceneStartSphere(pos.x, pos.y, pos.z, 150.0, 0)
    waitFor(function() return IsNewLoadSceneLoaded() end, C.StreamTimeoutMs or 8000, mine)
    NewLoadSceneStop()
end

local function request(name, flags, mine)
    RequestCutscene(name, flags)
    return waitFor(function() return HasCutsceneLoaded() end, C.LoadTimeoutMs or 20000, mine)
end

-- The play part. Returns why it ended ('ended', 'stopped', 'did not load', ...). Cleanup is the caller's.
local function play(d, mine, origin)
    local name = d.name
    local flags = d.online and 8 or 0
    local ped = PlayerPedId()

    -- 2. prime: where does the camera start?
    if not request(name, flags, mine) then return run ~= mine and 'stopped' or 'did not load' end
    StartCutscene(0)
    if not waitFor(function() return IsCutscenePlaying() end, 4000, mine) then
        return run ~= mine and 'stopped' or 'did not start'
    end
    Wait(0) Wait(0)
    local cam = GetFinalRenderedCamCoord()
    StopCutsceneImmediately()
    RemoveCutscene()
    waitFor(function() return not IsCutsceneActive() end, 2000)
    if run ~= mine then return 'stopped' end
    if #(cam - origin.xyz) < 1.0 then cam = origin.xyz end -- no camera found: stream where they are

    -- North Yankton (prologue scenes) is not part of the normal map: the server puts glitch-mapHandler's
    -- north_yankton world on this player's cutscene bucket (the same way anyone sent there gets it) and this waits
    -- until mapHandler has loaded it here. The server takes it off the bucket when they are put back.
    if cam.x > 2500.0 and cam.x < 6500.0 and cam.y > -6500.0 and cam.y < -3800.0 and GetResourceState('glitch-mapHandler') == 'started' then
        TriggerServerEvent('glitch-abstraction:cutscene:status', d.token, 'world', 'north_yankton')
        waitFor(function()
            local ok, w = pcall(function() return exports['glitch-mapHandler']:GetWorld() end)
            return ok and w == 'north_yankton'
        end, 6000, mine)
        if run ~= mine then return 'stopped' end
        Wait(1000) -- the IPLs are requested; give them a moment before the load scene
    end

    -- 3. hidden ped at the camera, map streamed around it
    ped = PlayerPedId()
    SetEntityCoords(ped, cam.x, cam.y, cam.z - 1.0, false, false, false, false)
    stream(cam, mine)
    if run ~= mine then return 'stopped' end
    Wait(300)

    -- 4. the real thing
    if not request(name, flags, mine) then return run ~= mine and 'stopped' or 'did not load' end
    ped = PlayerPedId()
    if d.online then
        hide(ped, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        cast(ped, d.fillers)
    end
    StartCutscene(0)
    if not waitFor(function() return IsCutscenePlaying() end, 5000, mine) then
        return run ~= mine and 'stopped' or 'did not start'
    end
    restoreCast() -- their own looks back on: the cutscene just put its defaults on them
    DoScreenFadeIn(500)
    TriggerServerEvent('glitch-abstraction:cutscene:status', d.token, 'playing')

    local stopAt = GetGameTimer() + (C.MaxMinutes or 6) * 60000 - 20000
    local nextFocus = 0
    while run == mine and IsCutsceneActive() and not HasCutsceneFinished() and GetGameTimer() < stopAt do
        local now = GetGameTimer()
        if now >= nextFocus then
            nextFocus = now + 250
            local c = GetFinalRenderedCamCoord()
            SetFocusPosAndVel(c.x, c.y, c.z, 0.0, 0.0, 0.0) -- streaming follows the camera to every shot
            if not d.online then SetEntityCoordsNoOffset(PlayerPedId(), c.x, c.y, c.z - 1.0, false, false, false) end
        end
        if d.preview and IsControlJustPressed(0, 177) then break end -- the staff member's own copy: Backspace
        holdCast() -- every frame: the cutscene keeps putting its default clothes back on its cast
        Wait(0)
    end
    return run ~= mine and 'stopped' or 'ended'
end

-- 5. always: back exactly where they stood
local function cleanup(d, origin, wasInvincible)
    if not IsScreenFadedOut() then
        DoScreenFadeOut(500)
        waitFor(function() return IsScreenFadedOut() end, 1500)
    end
    dropScene()
    restoreOwnLook(ownLook) -- the scene's default clothes / hair off again
    ownLook = nil
    ClearFocus()
    NewLoadSceneStop()
    local ped = PlayerPedId()
    ClearPedTasksImmediately(ped)
    SetEntityCoords(ped, origin.x, origin.y, origin.z, false, false, false, false)
    SetEntityHeading(ped, origin.w)
    hide(ped, false)
    FreezeEntityPosition(ped, true) -- until the ground there is back
    if not wasInvincible then SetEntityInvincible(ped, false) end
    TriggerServerEvent('glitch-abstraction:cutscene:done', d.token)
    Wait(700) -- the bucket change
    NewLoadSceneStartSphere(origin.x, origin.y, origin.z, 60.0, 0)
    waitFor(function() return IsNewLoadSceneLoaded() end, 5000)
    NewLoadSceneStop()
    ped = PlayerPedId()
    SetEntityCoords(ped, origin.x, origin.y, origin.z, false, false, false, false)
    SetEntityHeading(ped, origin.w)
    FreezeEntityPosition(ped, false)
    if not d.preview and GetResourceState('glitch-cloudsLoading') == 'started' then
        local ok = pcall(function() exports['glitch-cloudsLoading']:WakeUpAt(origin, 600) end)
        if ok then return end
    end
    Wait(300)
    DoScreenFadeIn(600)
end

-- d = { name, online, fillers, preview, token } (from the server)
GlitchAbst.Cutscene.PlayStreamed = function(d)
    if type(d) ~= 'table' or type(d.name) ~= 'string' or not d.name:match('^[%w_]+$') then return false end
    run = run + 1
    local mine = run
    CreateThread(function()
        -- one at a time: a newer one waits for the older cleanup, so the first origin is the one kept
        local t = GetGameTimer() + 15000
        while busy and GetGameTimer() < t do Wait(50) end
        if run ~= mine then return end
        busy = true
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then TaskLeaveVehicle(ped, veh, 16) Wait(400) ped = PlayerPedId() end
        local c = GetEntityCoords(ped)
        local origin = vector4(c.x, c.y, c.z, GetEntityHeading(ped))
        local wasInvincible = GetPlayerInvincible(PlayerId())
        ownLook = { snap = snapLook(ped) }
        if appearanceUp() then
            local okLook, a = pcall(function() return exports['glitch-appearance']:getPedAppearance(ped) end)
            ownLook.look = okLook and type(a) == 'table' and a or nil
        end
        -- the server keeps it too: if this resource stops mid-scene it puts them back there itself
        TriggerServerEvent('glitch-abstraction:cutscene:status', d.token, 'origin', nil, { x = origin.x, y = origin.y, z = origin.z, w = origin.w })
        DoScreenFadeOut(500)
        waitFor(function() return IsScreenFadedOut() end, 1500)
        hide(PlayerPedId(), true)
        local ok, why = pcall(play, d, mine, origin)
        if not ok then log(('%s failed: %s'):format(d.name, tostring(why))) why = 'error' end
        log(('%s: %s'):format(d.name, tostring(why)))
        TriggerServerEvent('glitch-abstraction:cutscene:status', d.token, 'end', why)
        cleanup(d, origin, wasInvincible)
        busy = false
    end)
    return true
end

GlitchAbst.Cutscene.StopStreamed = function() run = run + 1 end
GlitchAbst.Cutscene.IsStreamedBusy = function() return busy end

RegisterNetEvent('glitch-abstraction:cutscene:play', function(d)
    if GetInvokingResource() then return end
    GlitchAbst.Cutscene.PlayStreamed(d)
end)

RegisterNetEvent('glitch-abstraction:cutscene:stop', function()
    if GetInvokingResource() then return end
    run = run + 1
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() or not busy then return end
    -- no threads or waits here: drop the scene, show them, the server puts the bucket back on its own stop
    dropScene()
    ClearFocus()
    local ped = PlayerPedId()
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetEntityCollision(ped, true, true)
    DoScreenFadeIn(0)
end)

log('stream module loaded')
return true
