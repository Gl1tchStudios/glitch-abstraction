-- Cutscenes played ON players (server side of client/cutscene/stream.lua) + /cutsceneadmin.
--
--   exports['glitch-abstraction']:PlayCutsceneFor(target, name, opts) -> ok, msg, info
--       opts = { watch = staff id (plays it on their screen too), fillers = 'off' | 'random' | 'pick',
--                picks = '1,5,9' (server ids, for 'pick'), by = who asked (gets the status) }
--   exports['glitch-abstraction']:StopCutsceneFor(target)
--
-- The player goes to a bucket of their own (Config.Cutscenes.BucketBase + id) for the scene and gets their old
-- bucket back when their client says it ended (token must match), after Config.Cutscenes.MaxMinutes at the latest,
-- or when this resource stops (then they are also put back at the spot the client reported).
-- Local server event for other resources: 'glitch-abstraction:cutsceneStatus' (target, by, state, why, name).

if not GlitchAbst or not GlitchAbst.Utils then return false end
if not GlitchAbst.Utils.CutscenesEnabled() then return false end -- Config.Cutscenes.Enabled
GlitchAbst.Cutscene = GlitchAbst.Cutscene or {}

local C = (Config and Config.Cutscenes) or {}
local A = C.Admin or {}
local runs = {}   -- [id] = { token, bucket = their own bucket before, by, name, origin, preview }
local tokens = 0

local function log(msg) GlitchAbst.Utils.DebugLog('[cutscene] ' .. msg) end

local function mapSync(id)
    if GetResourceState('glitch-mapHandler') ~= 'started' then return end
    pcall(function() exports['glitch-mapHandler']:Sync(id) end)
end

local function qbx(id)
    if GetResourceState('qbx_core') ~= 'started' then return nil end
    local ok, p = pcall(function() return exports.qbx_core:GetPlayer(id) end)
    return ok and p or nil
end

local function charName(p)
    local c = p and p.PlayerData and p.PlayerData.charinfo
    if not c then return nil end
    local n = (('%s %s'):format(c.firstname or '', c.lastname or ''):gsub('^%s+', ''):gsub('%s+$', ''))
    return n ~= '' and n or nil
end

local function nameOf(id) return charName(qbx(id)) or GetPlayerName(id) or ('#' .. tostring(id)) end

local function status(id, state, why)
    local r = runs[id]
    local by, name = r and r.by, r and r.name
    TriggerEvent('glitch-abstraction:cutsceneStatus', id, by, state, why, name)
    if by and by ~= id and GetPlayerName(by) and not (r and r.preview) then
        TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', by, { target = id, who = nameOf(id), name = name, state = state, why = why })
    end
end

-- a glitch-mapHandler world on a player's cutscene bucket (north_yankton for the prologue scenes); nil clears it
local function bucketWorld(id, world)
    if GetResourceState('glitch-mapHandler') ~= 'started' then return false end
    local ok, res = pcall(function()
        local bucket = (C.BucketBase or 6600) + id
        if world then return exports['glitch-mapHandler']:SetBucketWorld(bucket, world) end
        return exports['glitch-mapHandler']:ClearBucketWorld(bucket)
    end)
    return ok and res
end

local function giveBack(id, why, teleport)
    local r = runs[id]
    if not r then return end
    runs[id] = nil
    if r.world then bucketWorld(id, nil) end -- off the cutscene bucket before they leave it
    if not GetPlayerName(id) then return end
    SetPlayerRoutingBucket(id, r.bucket or 0)
    mapSync(id)
    if teleport and r.origin then
        local ped = GetPlayerPed(id)
        if ped ~= 0 then SetEntityCoords(ped, r.origin.x, r.origin.y, r.origin.z, false, false, false, false) SetEntityHeading(ped, r.origin.w or 0.0) end
    end
    log(('%s back in bucket %d (%s)'):format(nameOf(id), r.bucket or 0, why))
end

-- --- Filler characters --------------------------------------------------------------------------------------
-- MP_2..MP_4 of an online / DLC scene in a saved look (glitch-appearance playerskins, active row, freemode only).
-- 'pick' = only the picked players; 'random' = players in the city at random, then random characters from the
-- database. Never the target, never one character twice.
local FREEMODE = { mp_m_freemode_01 = true, mp_f_freemode_01 = true }

local DB = C.Database or {}
local function ident(v, default) v = tostring(v or default) return v:match('^[%w_]+$') and v or default end
local T_SKINS, T_PLAYERS = ident(DB.SkinsTable, 'playerskins'), ident(DB.PlayersTable, 'players')

local function dbReady() return GetResourceState('oxmysql') == 'started' end

local function dbSingle(q, params)
    local ok, row = pcall(function() return exports.oxmysql:single_async(q, params) end)
    return ok and row or nil
end

local function dbQuery(q, params)
    local ok, rows = pcall(function() return exports.oxmysql:query_async(q, params) end)
    return ok and rows or nil
end

local function skinOf(cid)
    if not dbReady() then return nil end
    local row = dbSingle(('SELECT model, skin FROM %s WHERE citizenid = ? AND active = 1 LIMIT 1'):format(T_SKINS), { cid })
    if not row or not FREEMODE[row.model] then return nil end
    local ok, skin = pcall(json.decode, row.skin or '')
    if not ok or type(skin) ~= 'table' then return nil end
    skin.model = row.model
    return { model = row.model, skin = skin }
end

-- A player's look exactly as it is right now: their client answers with glitch-appearance getPedAppearance
-- (clothes, hair, tattoos, overlays, unsaved changes). false after 3 s without an answer or for a non-freemode ped.
local lookReqs, lookId = {}, 0

-- A look from a client is forwarded to other clients, so only known keys survive and big values are cut.
local LOOK_KEYS = { model = 'string', components = 'table', props = 'table', headBlend = 'table', faceFeatures = 'table',
    headOverlays = 'table', hair = 'table', tattoos = 'table' }
local function cleanValue(v, depth)
    local t = type(v)
    if t == 'number' then return (v == v and v ~= math.huge and v ~= -math.huge) and v or nil end
    if t == 'boolean' then return v end
    if t == 'string' then return #v <= 64 and v or nil end
    if t ~= 'table' or depth > 4 then return nil end
    local out, n = {}, 0
    for k, x in pairs(v) do
        n = n + 1
        if n > 128 then break end
        if (type(k) == 'string' and #k <= 32) or type(k) == 'number' then
            local c = cleanValue(x, depth + 1)
            if c ~= nil then out[k] = c end
        end
    end
    return out
end
local function cleanLook(look)
    if type(look) ~= 'table' then return false end
    local out = {}
    for k, want in pairs(LOOK_KEYS) do
        if type(look[k]) == want then out[k] = cleanValue(look[k], 1) end
    end
    if not FREEMODE[tostring(out.model or '')] then return false end
    return out
end

RegisterNetEvent('glitch-abstraction:cutscene:look', function(id, look)
    local req = lookReqs[id]
    if not req or req.src ~= source then return end
    lookReqs[id] = nil
    req.finish(cleanLook(look))
end)

-- Ask several players for their look at once and wait for all of them under one 3 s deadline.
-- Returns { [id] = look or false }.
local function liveLooks(ids)
    local results, left, rids = {}, #ids, {}
    if left == 0 then return results end
    local p, done = promise.new(), false
    local function settle() if not done then done = true p:resolve(true) end end
    for _, id in ipairs(ids) do
        lookId = lookId + 1
        local rid = lookId
        rids[#rids + 1] = rid
        lookReqs[rid] = { src = id, finish = function(v)
            if results[id] == nil then
                results[id] = v
                left = left - 1
                if left <= 0 then settle() end
            end
        end }
        TriggerClientEvent('glitch-abstraction:cutscene:lookReq', id, rid)
    end
    SetTimeout(3000, function()
        for _, rid in ipairs(rids) do lookReqs[rid] = nil end
        settle()
    end)
    Citizen.Await(p)
    for _, id in ipairs(ids) do if results[id] == nil then results[id] = false end end
    return results
end

local function fillersFor(target, opts)
    local mode = tostring(opts.fillers or 'off')
    if mode ~= 'random' and mode ~= 'pick' then return nil end
    local slots = math.max(0, math.min(3, tonumber(C.FillerSlots) or 3))
    local out, used = {}, {}
    local tp = qbx(target)
    if tp then used[tp.PlayerData.citizenid] = true end
    local function add(cid, name)
        if #out >= slots or not cid or used[cid] then return end
        used[cid] = true
        local f = skinOf(cid)
        if f then f.name = name out[#out + 1] = f end
    end
    -- players in the city: their live look; the saved one only if their client does not answer
    local function onlineOne(id, looks)
        if not id or id == target then return end
        local p = qbx(id)
        if not p then return end
        local cid = p.PlayerData.citizenid
        if #out >= slots or used[cid] then return end
        local look = looks[id]
        if look then
            used[cid] = true
            out[#out + 1] = { model = look.model, skin = look, name = charName(p) or GetPlayerName(id) }
        else
            add(cid, charName(p) or GetPlayerName(id))
        end
    end
    if mode == 'pick' then
        local picked = {}
        for id in tostring(opts.picks or ''):gmatch('%d+') do
            id = tonumber(id)
            if id and id ~= target and GetPlayerName(id) and #picked < 8 then picked[#picked + 1] = id end
        end
        local looks = liveLooks(picked)
        for _, id in ipairs(picked) do onlineOne(id, looks) end
        return out
    end
    local ids = GetPlayers()
    for i = #ids, 2, -1 do local j = math.random(i) ids[i], ids[j] = ids[j], ids[i] end
    local cands = {}
    for _, id in ipairs(ids) do
        id = tonumber(id)
        if id and id ~= target and #cands < slots * 2 + 2 then cands[#cands + 1] = id end
    end
    local looks = liveLooks(cands)
    for _, id in ipairs(cands) do onlineOne(id, looks) end
    if #out < slots and dbReady() then
        local rows = dbQuery(([[SELECT s.citizenid, p.charinfo FROM %s s
            LEFT JOIN %s p ON p.citizenid = s.citizenid
            WHERE s.active = 1 AND s.model IN ('mp_m_freemode_01', 'mp_f_freemode_01')
            ORDER BY (p.last_updated > NOW() - INTERVAL 30 DAY) DESC, RAND() LIMIT ?]]):format(T_SKINS, T_PLAYERS), { (slots - #out) * 3 + 3 }) or {}
        for _, r in ipairs(rows) do
            local ok, ci = pcall(json.decode, r.charinfo or '')
            local n = ok and type(ci) == 'table' and (('%s %s'):format(ci.firstname or '', ci.lastname or ''):gsub('^%s+', ''):gsub('%s+$', '')) or ''
            add(r.citizenid, n ~= '' and n or r.citizenid)
        end
    end
    return out
end

-- --- Play / stop --------------------------------------------------------------------------------------------

local function isOnline(name)
    local info = GlitchAbst.Cutscene.GetInfo and GlitchAbst.Cutscene.GetInfo(name) or nil
    return name:sub(1, 3) == 'mp_' or (info ~= nil and info.lead ~= nil)
end

local function serverOrigin(id)
    local ped = GetPlayerPed(id)
    if not ped or ped == 0 then return nil end
    local c = GetEntityCoords(ped)
    return vector4(c.x, c.y, c.z, GetEntityHeading(ped))
end

local function startOn(id, name, online, fillers, preview, by)
    tokens = tokens + 1
    local mine = tokens
    local prev = runs[id]
    if prev and prev.world then bucketWorld(id, nil) end -- the next scene may not be in that world
    runs[id] = {
        token = mine, bucket = prev and prev.bucket or GetPlayerRoutingBucket(id), -- a second scene keeps the first bucket
        by = by, name = name, preview = preview,
        origin = prev and prev.origin or serverOrigin(id), -- read here, never taken from the client
    }
    SetPlayerRoutingBucket(id, (C.BucketBase or 6600) + id)
    mapSync(id)
    TriggerClientEvent('glitch-abstraction:cutscene:play', id, { name = name, online = online, fillers = fillers, preview = preview, token = mine })
    SetTimeout((C.MaxMinutes or 6) * 60000, function()
        if runs[id] and runs[id].token == mine then giveBack(id, 'took too long', true) end
    end)
end

function GlitchAbst.Cutscene.PlayFor(target, name, opts)
    target = tonumber(target)
    if not target or not GetPlayerName(target) then return false, 'They are not in the city' end
    name = tostring(name or ''):lower()
    if not name:match('^[%w_]+$') then return false, 'Cutscene names are letters, numbers and underscores' end
    opts = type(opts) == 'table' and opts or {}
    local online = isOnline(name)
    -- opts.fillerList: the caller already built them (glitch-admin: through an export nothing here may wait, and
    -- fillersFor waits on the database and on players' clients)
    local fillers
    if opts.fillerList ~= nil then
        fillers = online and type(opts.fillerList) == 'table' and #opts.fillerList > 0 and opts.fillerList or nil
    else
        fillers = online and fillersFor(target, opts) or nil
    end
    local by = tonumber(opts.by)
    startOn(target, name, online, fillers, false, by)
    local watch = tonumber(opts.watch)
    if watch and watch ~= target and GetPlayerName(watch) then startOn(watch, name, online, fillers, true, by) end
    local who = {}
    for _, f in ipairs(fillers or {}) do who[#who + 1] = f.name end
    return true, ('%s is in %s%s'):format(nameOf(target), name, #who > 0 and (' with ' .. table.concat(who, ', ')) or ''),
        { online = online, fillers = who, fillersAsked = fillers ~= nil }
end

function GlitchAbst.Cutscene.StopFor(target)
    target = tonumber(target)
    local r = target and runs[target]
    if not r then return false end
    local mine = r.token
    TriggerClientEvent('glitch-abstraction:cutscene:stop', target)
    -- the client puts them back and says so; if it never does, the bucket and the spot come back from here
    SetTimeout(20000, function()
        if runs[target] and runs[target].token == mine then giveBack(target, 'stop, no answer', true) end
    end)
    return true
end

exports('PlayCutsceneFor', function(target, name, opts) return GlitchAbst.Cutscene.PlayFor(target, name, opts) end)
exports('StopCutsceneFor', function(target) return GlitchAbst.Cutscene.StopFor(target) end)
exports('IsInCutscene', function(target) return runs[tonumber(target) or -1] ~= nil end)

RegisterNetEvent('glitch-abstraction:cutscene:status', function(token, state, why, origin)
    local src = source
    local r = runs[src]
    if not r or r.token ~= token then return end
    if state == 'origin' then return end -- the return spot is read server side in startOn
    -- the client found the scene is in a mapHandler world (only these are allowed): load it on their bucket
    if state == 'world' then
        if why == 'north_yankton' and bucketWorld(src, why) then
            r.world = why
            mapSync(src)
        end
        return
    end
    if state == 'playing' or state == 'end' then status(src, state, type(why) == 'string' and why:sub(1, 60) or nil) end
end)

RegisterNetEvent('glitch-abstraction:cutscene:done', function(token)
    local src = source
    local r = runs[src]
    if r and r.token == token then giveBack(src, 'ended') end
end)

AddEventHandler('playerDropped', function()
    local src = source
    local r = runs[src]
    if r and r.world then bucketWorld(src, nil) end
    runs[src] = nil
    for rid, req in pairs(lookReqs) do
        if req.src == src then lookReqs[rid] = nil req.finish(false) end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for id in pairs(runs) do giveBack(id, 'resource stopped', true) end
end)

-- --- /cutsceneadmin -----------------------------------------------------------------------------------------
-- The browser (html/cutscene) with Put in on any player. Who may open it: Config.Cutscenes.Admin.Ace, or the
-- value saved from the panel's gear by someone with EditAce (KVP, cleared = back to config).

local KVP = 'cutsceneadmin:ace'
local function aceNow()
    local v = GetResourceKvpString(KVP)
    return (v and v ~= '') and v or (A.Ace or 'admin')
end
local function allowed(src) return src and src > 0 and IsPlayerAceAllowed(src, aceNow()) end
local function canEditAce(src) return src and src > 0 and IsPlayerAceAllowed(src, A.EditAce or 'founder') end

local function photos()
    if GetResourceState('glitch-photos') ~= 'started' then return {} end
    local ok, map = pcall(function() return exports['glitch-photos']:GetCutscenePhotos() end)
    return ok and type(map) == 'table' and map or {}
end

local function failed()
    if GetResourceState('glitch-admin') ~= 'started' then return {} end
    local ok, map = pcall(function() return exports['glitch-admin']:GetCutsceneFailed() end)
    return ok and type(map) == 'table' and map or {}
end

local function adminData(src)
    local img, bad, featured = photos(), failed(), {}
    for i, n in ipairs(C.Featured or {}) do featured[n] = i end
    local list = {}
    for _, e in ipairs(GlitchAbst.Cutscene.GetCatalog and GlitchAbst.Cutscene.GetCatalog() or {}) do
        list[#list + 1] = {
            value = e.name, src = e.source, srcLabel = e.sourceLabel, set = e.set, mission = e.mission, part = e.part,
            desc = e.desc, guess = e.guess, img = img[e.name], bad = bad[e.name] and bad[e.name].why or nil, featured = featured[e.name],
        }
    end
    local players = {}
    for _, sid in ipairs(GetPlayers()) do
        local id = tonumber(sid)
        players[#players + 1] = { id = id, name = GetPlayerName(id), char = charName(qbx(id)), busy = runs[id] ~= nil }
    end
    table.sort(players, function(a, b) return a.id < b.id end)
    return { list = list, players = players, me = src, ace = aceNow(), aceDefault = A.Ace or 'admin', canEditAce = canEditAce(src),
        fillerSlots = C.FillerSlots or 3 }
end

local function openFor(src)
    if not allowed(src) then
        TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', src, { text = 'You do not have access to the cutscene browser.', kind = 'error' })
        return
    end
    TriggerLatentClientEvent('glitch-abstraction:cutscene:adminOpen', src, 2000000, adminData(src))
end

if A.Enabled then
    RegisterCommand(A.Command or 'cutsceneadmin', function(src) openFor(src) end, false)
end

-- One admin action per second per staff member (all of these are ACE gated as well)
local adminLast = {}
local function throttled(src)
    local now = GetGameTimer()
    if adminLast[src] and now - adminLast[src] < 1000 then return true end
    adminLast[src] = now
    return false
end
AddEventHandler('playerDropped', function() adminLast[source] = nil end)

RegisterNetEvent('glitch-abstraction:cutscene:adminRefresh', function()
    local src = source
    if not throttled(src) and allowed(src) then TriggerLatentClientEvent('glitch-abstraction:cutscene:adminData', src, 2000000, adminData(src)) end
end)

RegisterNetEvent('glitch-abstraction:cutscene:adminPlay', function(target, name, opts)
    local src = source
    if throttled(src) or not allowed(src) then return end
    opts = type(opts) == 'table' and opts or {}
    local ok, msg = GlitchAbst.Cutscene.PlayFor(target, name, {
        watch = opts.watch and src or nil, fillers = opts.fillers, picks = opts.picks, by = src,
    })
    TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', src, { text = msg, kind = ok and 'success' or 'error' })
    log(('%s put %s in %s'):format(GetPlayerName(src) or src, tostring(target), tostring(name)))
end)

RegisterNetEvent('glitch-abstraction:cutscene:adminStop', function(target)
    local src = source
    if throttled(src) or not allowed(src) then return end
    local ok = GlitchAbst.Cutscene.StopFor(target)
    if tonumber(target) ~= src and runs[src] and runs[src].preview then GlitchAbst.Cutscene.StopFor(src) end
    TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', src, {
        text = ok and ('Stopping the cutscene for %s, they go back where they stood.'):format(nameOf(tonumber(target) or 0)) or 'They are not in a cutscene.',
        kind = ok and 'success' or 'error' })
end)

RegisterNetEvent('glitch-abstraction:cutscene:adminSetAce', function(ace)
    local src = source
    if not canEditAce(src) then return end
    ace = tostring(ace or ''):gsub('%s', '')
    if ace ~= '' and not ace:match('^[%w_%.%-]+$') then
        return TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', src, { text = 'An ACE is letters, numbers, dots, dashes and underscores.', kind = 'error' })
    end
    if ace == '' then DeleteResourceKvp(KVP) else SetResourceKvp(KVP, ace) end
    TriggerClientEvent('glitch-abstraction:cutscene:adminStatus', src, { text = ('The cutscene browser now needs the ACE "%s".'):format(aceNow()), kind = 'success', ace = aceNow() })
    log(('%s set the /cutsceneadmin ACE to %s'):format(GetPlayerName(src) or src, aceNow()))
end)

log('server cutscene module loaded')
return true
