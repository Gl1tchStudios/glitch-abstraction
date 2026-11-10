-- /cutsceneadmin browser (html/cutscene). The server checks the ACE on opening and on every action; this only
-- shows the page and passes clicks on. Statuses ("did not load", "playing") show in the page, or as a notification
-- when it is closed. Only the staff member who asked ever sees these.

if not GlitchAbst or not GlitchAbst.Utils then return false end

local open = false

local function close()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'close' })
end

local function notify(text, kind)
    if GlitchAbst.UI and GlitchAbst.UI.Notify then
        pcall(GlitchAbst.UI.Notify, { title = 'Cutscenes', description = text, type = kind or 'inform', message = text })
    end
end

RegisterNetEvent('glitch-abstraction:cutscene:adminOpen', function(data)
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ type = 'open', data = data })
end)

RegisterNetEvent('glitch-abstraction:cutscene:adminData', function(data)
    SendNUIMessage({ type = 'data', data = data })
end)

-- { text, kind } or { target, who, name, state = 'playing' | 'end', why }
RegisterNetEvent('glitch-abstraction:cutscene:adminStatus', function(m)
    if type(m) ~= 'table' then return end
    local text, kind = m.text, m.kind
    if not text and m.state == 'playing' then text, kind = ('%s is watching %s.'):format(m.who or '?', m.name or '?'), 'success' end
    if not text and m.state == 'end' then
        local why = m.why or 'ended'
        if why == 'ended' or why == 'stopped' then text, kind = ('%s is back where they stood (%s).'):format(m.who or '?', why), 'inform'
        else text, kind = ('%s: %s %s, they are back where they stood.'):format(m.who or '?', m.name or '?', why), 'error' end
    end
    if not text then return end
    if open then SendNUIMessage({ type = 'toast', text = text, kind = kind, ace = m.ace }) else notify(text, kind) end
end)

RegisterNUICallback('cut_close', function(_, cb) close() cb({}) end)

RegisterNUICallback('cut_refresh', function(_, cb)
    TriggerServerEvent('glitch-abstraction:cutscene:adminRefresh')
    cb({})
end)

-- { target, name, watch, fillers, picks }: the page closes so a cutscene on this screen (Me / watch) is seen
RegisterNUICallback('cut_play', function(d, cb)
    cb({})
    if type(d) ~= 'table' then return end
    TriggerServerEvent('glitch-abstraction:cutscene:adminPlay', tonumber(d.target), tostring(d.name or ''),
        { watch = d.watch == true, fillers = d.fillers, picks = d.picks })
    if d.watch or tonumber(d.target) == GetPlayerServerId(PlayerId()) then close() end
end)

RegisterNUICallback('cut_stop', function(d, cb)
    cb({})
    if type(d) == 'table' then TriggerServerEvent('glitch-abstraction:cutscene:adminStop', tonumber(d.target)) end
end)

RegisterNUICallback('cut_setAce', function(d, cb)
    cb({})
    if type(d) == 'table' then TriggerServerEvent('glitch-abstraction:cutscene:adminSetAce', tostring(d.ace or '')) end
end)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and open then SetNuiFocus(false, false) end
end)

return true
