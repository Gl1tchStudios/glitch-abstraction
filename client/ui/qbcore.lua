-- QBCore UI module: qb-input, qb-menu, the qb-core progress bar and DrawText.
-- Only used when QB is the chosen UI (Qbox and most QB servers run ox_lib, which wins).

-- First check if we should load this module
if GlitchAbst.FrameworkName ~= 'QBCore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore UI module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
    return false
end
if GlitchAbst.UISystem ~= 'qb' and GlitchAbst.UISystem ~= 'qbcore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore UI module (UI system is ' .. tostring(GlitchAbst.UISystem) .. ')')
    return false
end

-- Safe way to get QBCore
local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchAbst.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore UI')
    return false
end

QBCore = result
GlitchAbst.Utils.DebugLog('QBCore UI module loaded')

local function Started(name) return GetResourceState(name) == 'started' end
local function HasOx() return Started('ox_lib') end

-- ox_lib input types -> qb-input types
local INPUT_TYPES = { input = 'text', text = 'text', textarea = 'text', number = 'number', select = 'select',
    ['multi-select'] = 'checkbox', checkbox = 'checkbox', color = 'color', password = 'password', radio = 'radio' }

-- Input dialog (qb-input). Returns the values as an array in field order, like ox_lib.
GlitchAbst.UI.Input = function(header, inputs, options)
    inputs = inputs or {}
    if not Started('qb-input') then
        if HasOx() then return exports['ox_lib']:inputDialog(header, inputs, options) end
        GlitchAbst.Utils.DebugLog('UI.Input: neither qb-input nor ox_lib is running')
        return nil
    end

    local inputData = { header = header, submitText = options and options.submitText or 'Confirm', inputs = {} }
    local names = {}

    for i, input in ipairs(inputs) do
        local name = input.name or ('field' .. i)
        names[i] = name
        local qbType = input.password and 'password' or INPUT_TYPES[input.type or 'input'] or 'text'
        local qbOptions
        if type(input.options) == 'table' then
            qbOptions = {}
            for _, opt in ipairs(input.options) do
                qbOptions[#qbOptions + 1] = { value = opt.value, text = opt.label or opt.text or tostring(opt.value) }
            end
        end
        table.insert(inputData.inputs, {
            type = qbType,
            name = name,
            text = input.label or input.text or name,
            isRequired = input.required or false,
            default = input.default,
            options = qbOptions
        })
    end

    -- qb-input's ShowInput blocks and returns { [name] = value } (nil when cancelled)
    local ok, res = pcall(function() return exports['qb-input']:ShowInput(inputData) end)
    if not ok or not res then return nil end

    local values = {}
    for i, name in ipairs(names) do
        local v = res[name]
        if inputs[i].type == 'number' then v = tonumber(v) end
        if inputs[i].type == 'checkbox' then v = (v == true or v == 'true' or v == 'on') end
        values[i] = v
    end
    return values
end
GlitchAbst.UI.InputForm = GlitchAbst.UI.Input
GlitchAbst.UI.BuildForm = GlitchAbst.UI.Input

GlitchAbst.UI.CloseInputDialog = function()
    if HasOx() then return exports['ox_lib']:closeInputDialog() end
    return false
end

-- Context menus (qb-menu), registered by id like ox_lib context menus
GlitchAbst.UI._menus = GlitchAbst.UI._menus or {}

local ShowContext

local function MenuItems(menu)
    local items = { { header = menu.title or '', isMenuHeader = true } }
    for _, option in ipairs(menu.options or {}) do
        local params
        if option.onSelect then
            local fn, args = option.onSelect, option.args
            params = { isAction = true, event = function() fn(args) end }
        elseif option.menu then
            local target = option.menu
            params = { isAction = true, event = function() ShowContext(target) end }
        elseif option.serverEvent then
            params = { isServer = true, event = option.serverEvent, args = option.args }
        elseif option.event then
            params = { event = option.event, args = option.args, isServer = option.isServer, isAction = option.isAction }
        elseif option.action then
            params = { isAction = true, event = option.action, args = option.args }
        end
        items[#items + 1] = {
            header = option.title or option.header or '',
            txt = option.description or option.txt,
            icon = option.icon,
            disabled = option.disabled,
            isMenuHeader = option.readOnly or option.isMenuHeader or (params == nil),
            params = params
        }
    end
    return items
end

ShowContext = function(id)
    local menu = GlitchAbst.UI._menus[id]
    if not menu then return false end
    if not Started('qb-menu') then
        if HasOx() then
            exports['ox_lib']:registerContext({ id = id, title = menu.title, options = menu.options, menu = menu.menu })
            return exports['ox_lib']:showContext(id)
        end
        GlitchAbst.Utils.DebugLog('Context menu: neither qb-menu nor ox_lib is running')
        return false
    end
    exports['qb-menu']:openMenu(MenuItems(menu))
    return true
end

GlitchAbst.UI.RegisterContext = function(context)
    if type(context) ~= 'table' or not context.id then return false end
    GlitchAbst.UI._menus[context.id] = context
    return true
end

GlitchAbst.UI.ShowContext = ShowContext

GlitchAbst.UI.HideContext = function()
    if Started('qb-menu') then exports['qb-menu']:closeMenu() end
end

GlitchAbst.UI.CreateContextMenu = function(id, title, options)
    return GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options })
end

GlitchAbst.UI.OpenContextMenu = function(id, title, options, menu, canClose)
    GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options, menu = menu, canClose = canClose })
    return ShowContext(id)
end

GlitchAbst.UI.ContextMenu = function(id, title, options, position)
    if options then GlitchAbst.UI.RegisterContext({ id = id, title = title, options = options }) end
    return ShowContext(id)
end

-- Progress bar (qb-core progressbar). Call from a thread: waits until it ends.
local progressActive = false

GlitchAbst.UI.ProgressBar = function(params)
    params = params or {}
    local disable = params.disable or {}
    local anim = params.anim or {}
    local prop = params.prop or {}
    local p = promise.new()
    progressActive = true

    QBCore.Functions.Progressbar(params.name or ('glitchabst_' .. GetGameTimer()), params.label or '', params.duration or 1000,
        params.useWhileDead or false, params.canCancel ~= false, {
        disableMovement = disable.move or disable.movement or false,
        disableCarMovement = disable.car or false,
        disableMouse = disable.mouse or false,
        disableCombat = disable.combat or false,
    }, {
        animDict = anim.dict,
        anim = anim.clip or anim.name,
        flags = anim.flag or anim.flags or 0,
        task = anim.scenario,
    }, prop.model and {
        model = prop.model,
        bone = prop.bone,
        coords = prop.pos,
        rotation = prop.rot,
    } or {}, {}, function()
        progressActive = false
        p:resolve(true)
    end, function()
        progressActive = false
        p:resolve(false)
    end)

    return Citizen.Await(p)
end

GlitchAbst.UI.ProgressCircle = GlitchAbst.UI.ProgressBar

GlitchAbst.UI.IsProgressActive = function()
    return progressActive
end

GlitchAbst.UI.CancelProgress = function()
    if not progressActive then return false end
    TriggerEvent('progressbar:client:cancel')
    return true
end

-- Text UI (qb-core DrawText)
local TEXT_POSITIONS = { ['right-center'] = 'right', ['left-center'] = 'left', ['top-center'] = 'top', ['bottom-center'] = 'top' }
local textOpen = false

GlitchAbst.UI.ShowTextUI = function(message, options)
    local position = TEXT_POSITIONS[options and options.position or 'right-center'] or 'right'
    local ok = pcall(function() exports['qb-core']:DrawText(message, position) end)
    if not ok then
        TriggerEvent('qb-core:client:DrawText', message, position)
    end
    textOpen = true
end

GlitchAbst.UI.HideTextUI = function()
    local ok = pcall(function() exports['qb-core']:HideText() end)
    if not ok then TriggerEvent('qb-core:client:HideText') end
    textOpen = false
end

GlitchAbst.UI.IsTextUIOpen = function()
    return textOpen
end

-- Alert dialog: ox_lib when it is running, otherwise a notification (always 'confirm')
GlitchAbst.UI.Alert = function(titleOrParams, message, alertType, icon)
    local params = type(titleOrParams) == 'table' and titleOrParams or { header = titleOrParams, content = message, type = alertType }
    if HasOx() then
        return exports['ox_lib']:alertDialog({
            header = params.header or params.title,
            content = params.content or params.message or params.description,
            centered = params.centered ~= false,
            cancel = params.cancel ~= false
        })
    end
    local text = tostring(params.header or params.title or '') .. ' ' .. tostring(params.content or params.message or params.description or '')
    QBCore.Functions.Notify(text, params.type or 'primary', 5000)
    return 'confirm'
end

-- Skill check: ox_lib, then qb-minigames; passes when neither exists
GlitchAbst.UI.SkillCheck = function(difficulty, inputs)
    if HasOx() then return exports['ox_lib']:skillCheck(difficulty, inputs) end
    if Started('qb-minigames') then
        local level = type(difficulty) == 'table' and difficulty[#difficulty] or difficulty
        if type(level) ~= 'string' then level = 'medium' end
        local keys = type(inputs) == 'table' and table.concat(inputs, '') or '1234'
        local ok, res = pcall(function() return exports['qb-minigames']:Skillbar(level, keys) end)
        if ok then return res and true or false end
    end
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

return true
