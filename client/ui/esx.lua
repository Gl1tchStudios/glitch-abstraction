-- ESX UI module: esx_menu_default / esx_context / esx_progressbar / esx_textui.
-- Only used when ESX is the chosen UI (servers with ox_lib use the ox_lib module).

if GlitchAbst.FrameworkName ~= 'ESX' then
    GlitchAbst.Utils.DebugLog('Skipping ESX UI module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end
-- Only take over when ESX is the chosen UI
if GlitchAbst.UISystem ~= 'esx' then
    GlitchAbst.Utils.DebugLog('Skipping ESX UI module (UI system is ' .. tostring(GlitchAbst.UISystem) .. ')')
    return false
end

-- Safe way to get ESX
local ESX = GlitchAbst.Framework and GlitchAbst.Framework.ESX
if not ESX then
    local success, result = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if success and result then
        ESX = result
    else
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end

if not ESX then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get ESX object, skipping ESX UI')
    return false
end

GlitchAbst.Utils.DebugLog('ESX UI module loaded')

local RES = GetCurrentResourceName()
local function HasOx() return GetResourceState('ox_lib') == 'started' end
local function HasMenu() return ESX.UI and ESX.UI.Menu end

-- Basic menu functions (esx_menu_default)
GlitchAbst.UI.ShowMenu = function(params)
    params = params or {}
    if not HasMenu() then return false end
    ESX.UI.Menu.Open(
        'default', RES, params.id or 'default_menu',
        {
            title = params.title or 'Menu',
            align = params.position or 'top-left',
            elements = params.elements or {}
        },
        function(data, menu)
            if params.onSelect then
                params.onSelect(data.current, menu)
            end
        end,
        function(data, menu)
            menu.close()
            if params.onClose then
                params.onClose()
            end
        end
    )
    return true
end

-- Close all menus
GlitchAbst.UI.CloseMenu = function()
    if HasMenu() then
        ESX.UI.Menu.CloseAll()
    end
end

-- Input dialog: one esx dialog per field. Returns the values as an array, nil when cancelled.
GlitchAbst.UI.Input = function(header, inputs, options)
    inputs = inputs or {}
    if HasOx() then return exports['ox_lib']:inputDialog(header, inputs, options) end
    if not HasMenu() then
        GlitchAbst.Utils.DebugLog('UI.Input: no esx_menu_default or ox_lib')
        return nil
    end

    local values = {}
    for i, input in ipairs(inputs) do
        local p = promise.new()
        ESX.UI.Menu.Open('dialog', RES, 'glitchabst_input_' .. i, {
            title = (input.label or input.name or header or 'Input')
        }, function(data, menu)
            menu.close()
            p:resolve({ value = data.value })
        end, function(data, menu)
            menu.close()
            p:resolve(nil)
        end)
        local res = Citizen.Await(p)
        if not res then return nil end
        local v = res.value
        if input.type == 'number' then v = tonumber(v) end
        if (v == nil or v == '') and input.required then return nil end
        values[i] = v
    end
    return values
end
GlitchAbst.UI.InputForm = GlitchAbst.UI.Input
GlitchAbst.UI.BuildForm = GlitchAbst.UI.Input

GlitchAbst.UI.CloseInputDialog = function()
    if HasOx() then return exports['ox_lib']:closeInputDialog() end
    if HasMenu() then ESX.UI.Menu.CloseAll() end
    return true
end

-- Context menus (esx_context when available, otherwise esx_menu_default)
GlitchAbst.UI._menus = GlitchAbst.UI._menus or {}

local function RunOption(option)
    if not option then return end
    if option.onSelect then option.onSelect(option.args)
    elseif option.serverEvent then TriggerServerEvent(option.serverEvent, option.args)
    elseif option.event then TriggerEvent(option.event, option.args)
    elseif option.menu then GlitchAbst.UI.ShowContext(option.menu) end
end

GlitchAbst.UI.RegisterContext = function(context)
    if type(context) ~= 'table' or not context.id then return false end
    GlitchAbst.UI._menus[context.id] = context
    return true
end

GlitchAbst.UI.ShowContext = function(id)
    local menu = GlitchAbst.UI._menus[id]
    if not menu then return false end
    local options = menu.options or {}

    if ESX.OpenContext then
        local elements = { { unselectable = true, title = menu.title or '', icon = 'fas fa-bars' } }
        for i, option in ipairs(options) do
            elements[#elements + 1] = { title = option.title or '', description = option.description, icon = option.icon,
                unselectable = option.readOnly or option.disabled, glitchIndex = i }
        end
        ESX.OpenContext('right', elements, function(m, element)
            if ESX.CloseContext then ESX.CloseContext() end
            RunOption(options[element.glitchIndex])
        end)
        return true
    end

    if HasMenu() then
        local elements = {}
        for i, option in ipairs(options) do
            elements[#elements + 1] = { label = option.title or '', value = i }
        end
        ESX.UI.Menu.Open('default', RES, 'glitchabst_' .. tostring(id), { title = menu.title or '', align = 'top-left', elements = elements },
            function(data, m)
                m.close()
                RunOption(options[data.current.value])
            end,
            function(data, m) m.close() end)
        return true
    end

    GlitchAbst.Utils.DebugLog('Context menu: no esx_context or esx_menu_default')
    return false
end

GlitchAbst.UI.HideContext = function()
    if ESX.CloseContext then ESX.CloseContext() end
    if HasMenu() then ESX.UI.Menu.CloseAll() end
end

GlitchAbst.UI.CreateContextMenu = function(id, title, options)
    return GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options })
end

GlitchAbst.UI.OpenContextMenu = function(id, title, options, menu, canClose)
    GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options, menu = menu })
    return GlitchAbst.UI.ShowContext(id)
end

GlitchAbst.UI.ContextMenu = function(id, title, options)
    if options then GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options }) end
    return GlitchAbst.UI.ShowContext(id)
end

-- Progress bar (ESX.Progressbar from esx_progressbar). Call from a thread: waits until it ends.
local progressActive = false

GlitchAbst.UI.ProgressBar = function(params)
    params = params or {}
    local duration = params.duration or 1000
    progressActive = true

    if ESX.Progressbar then
        local p = promise.new()
        local anim = params.anim
        local animation
        if anim and anim.scenario then
            animation = { type = 'Scenario', Scenario = anim.scenario }
        elseif anim and anim.dict then
            animation = { type = 'anim', dict = anim.dict, lib = anim.clip or anim.name }
        end
        ESX.Progressbar(params.label or '', duration, {
            FreezePlayer = params.disable and (params.disable.move or params.disable.movement) or false,
            animation = animation,
            onFinish = function() p:resolve(true) end,
            onCancel = function() p:resolve(false) end
        })
        local res = Citizen.Await(p)
        progressActive = false
        return res
    end

    Wait(duration)
    progressActive = false
    return true
end

GlitchAbst.UI.ProgressCircle = GlitchAbst.UI.ProgressBar

GlitchAbst.UI.IsProgressActive = function()
    return progressActive
end

GlitchAbst.UI.CancelProgress = function()
    if ESX.CancelProgressbar then ESX.CancelProgressbar() return true end
    return false
end

-- Text UI (esx_textui)
local textOpen = false

GlitchAbst.UI.ShowTextUI = function(text, options)
    if ESX.TextUI then
        ESX.TextUI(text, options and options.type or 'info')
    else
        GlitchAbst.Framework.ShowHelpNotification(text, false)
    end
    textOpen = true
end

GlitchAbst.UI.HideTextUI = function()
    if ESX.HideUI then ESX.HideUI() end
    textOpen = false
end

GlitchAbst.UI.IsTextUIOpen = function()
    return textOpen
end

-- Alert dialog: ox_lib when it is running, otherwise a notification (always 'confirm')
GlitchAbst.UI.Alert = function(titleOrParams, message, alertType)
    local params = type(titleOrParams) == 'table' and titleOrParams or { header = titleOrParams, content = message, type = alertType }
    if HasOx() then
        return exports['ox_lib']:alertDialog({
            header = params.header or params.title,
            content = params.content or params.message or params.description,
            centered = params.centered ~= false,
            cancel = params.cancel ~= false
        })
    end
    ESX.ShowNotification(tostring(params.header or params.title or '') .. ' ' .. tostring(params.content or params.message or params.description or ''))
    return 'confirm'
end

-- Skill check: ox_lib when it is running; ESX has none of its own, so it passes
GlitchAbst.UI.SkillCheck = function(difficulty, inputs)
    if HasOx() then return exports['ox_lib']:skillCheck(difficulty, inputs) end
    GlitchAbst.Utils.DebugLog('UI.SkillCheck: no skill check resource, passing')
    return true
end

GlitchAbst.UI.IsSkillCheckActive = function()
    if HasOx() then return exports['ox_lib']:skillCheckActive() end
    return false
end

GlitchAbst.UI.CancelSkillCheck = function()
    if HasOx() then return exports['ox_lib']:cancelSkillCheck() end
    return false
end

-- Show / hide HUD elements (depends on the server's HUD; no-op here)
GlitchAbst.UI.ShowHUD = function(elements) end
GlitchAbst.UI.HideHUD = function(elements) end

return true
