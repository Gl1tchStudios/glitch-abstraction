-- First check if we should load this module
if GlitchLib.FrameworkName ~= 'QBCore' then
    GlitchLib.Utils.DebugLog('Skipping QBCore UI module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

-- Safe way to get QBCore
local QBCore = nil
local success, result = pcall(function()
    return exports['qb-core']:GetCoreObject()
end)

if not success or not result then
    GlitchLib.Utils.DebugLog('WARNING: Failed to get QBCore object, skipping QBCore UI')
    return false
end

QBCore = result
GlitchLib.Utils.DebugLog('QBCore UI module loaded')

-- Input dialog (using qb-input)
GlitchLib.UI.Input = function(header, inputs)
    local inputData = {
        header = header,
        inputs = {}
    }
    
    for _, input in ipairs(inputs) do
        table.insert(inputData.inputs, {
            type = input.type or "text",
            name = input.name,
            text = input.label,
            isRequired = input.required or false,
            default = input.default
        })
    end
    
    local p = promise.new()
    
    exports['qb-input']:ShowInput(inputData, function(result)
        if not result then
            return p:resolve(nil)
        end
        p:resolve(result)
    end)
    
    return Citizen.Await(p)
end

-- Menu (using qb-menu)
GlitchLib.UI.ContextMenu = function(id, title, options, position)
    local menuOptions = {
        {
            header = title,
            isMenuHeader = true
        }
    }
    
    for _, option in ipairs(options) do
        table.insert(menuOptions, {
            header = option.title,
            txt = option.description,
            icon = option.icon,
            params = {
                event = option.event,
                args = option.args,
                isServer = option.isServer,
                isAction = option.isAction,
                action = option.action
            }
        })
    end
    
    exports['qb-menu']:openMenu(menuOptions)
end

GlitchLib.UI.CreateContextMenu = function(id, title, options)
    -- QB doesn't need pre-registration, just store for later
    GlitchLib.UI._menus = GlitchLib.UI._menus or {}
    GlitchLib.UI._menus[id] = {
        title = title,
        options = options
    }
    return true
end

-- Progress bar
GlitchLib.UI.ProgressBar = function(params)
    local p = promise.new()
    
    QBCore.Functions.Progressbar(params.name or "random_progressbar", params.label, params.duration, params.useWhileDead or false, params.canCancel or true, {
        disableMovement = params.disable and params.disable.movement or false,
        disableCarMovement = params.disable and params.disable.car or false,
        disableMouse = params.disable and params.disable.mouse or false,
        disableCombat = params.disable and params.disable.combat or false,
    }, {
        animDict = params.anim and params.anim.dict,
        anim = params.anim and params.anim.name,
        flags = params.anim and params.anim.flags or 0,
    }, {}, {}, function()
        -- Finished
        p:resolve(true)
    end, function()
        -- Cancelled
        p:resolve(false)
    end)
    
    return Citizen.Await(p)
end

-- Text UI (using DrawText3D)
GlitchLib.UI.ShowTextUI = function(message, options)
    -- QB doesn't have a built-in text UI, using a simplified approach
    GlitchLib.UI._textUI = {
        message = message,
        position = options and options.position or "right-center",
        active = true
    }
    
    CreateThread(function()
        while GlitchLib.UI._textUI and GlitchLib.UI._textUI.active do
            DrawText3D(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, GlitchLib.UI._textUI.message)
            Wait(0)
        end
    end)
end

GlitchLib.UI.HideTextUI = function()
    if GlitchLib.UI._textUI then
        GlitchLib.UI._textUI.active = false
    end
end

-- Alert dialog (using phone notification as fallback)
GlitchLib.UI.Alert = function(title, message, type, icon)
    -- QB doesn't have built-in alerts, using notification
    QBCore.Functions.Notify(title .. "\n" .. message, type or "primary", 5000)
    return true -- No way to wait for user response in basic QB
end

-- Helper function for DrawText3D
function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 41, 41, 126)
end