-- First check if we should load this module
if GlitchAbst.FrameworkName ~= 'QBCore' then
    GlitchAbst.Utils.DebugLog('Skipping QBCore UI module (using ' .. (GlitchAbst.FrameworkName or 'unknown') .. ')')
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

-- Input dialog (using qb-input)
GlitchAbst.UI.Input = function(header, inputs)
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
GlitchAbst.UI.ContextMenu = function(id, title, options, position)
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

GlitchAbst.UI.CreateContextMenu = function(id, title, options)
    -- QB doesn't need pre-registration, just store for later
    GlitchAbst.UI._menus = GlitchAbst.UI._menus or {}
    GlitchAbst.UI._menus[id] = {
        title = title,
        options = options
    }
    return true
end

-- Progress bar
GlitchAbst.UI.ProgressBar = function(params)
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
GlitchAbst.UI.ShowTextUI = function(message, options)
    -- QB doesn't have a built-in text UI, using a simplified approach
    GlitchAbst.UI._textUI = {
        message = message,
        position = options and options.position or "right-center",
        active = true
    }
    
    CreateThread(function()
        while GlitchAbst.UI._textUI and GlitchAbst.UI._textUI.active do
            DrawText3D(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z, GlitchAbst.UI._textUI.message)
            Wait(0)
        end
    end)
end

GlitchAbst.UI.HideTextUI = function()
    if GlitchAbst.UI._textUI then
        GlitchAbst.UI._textUI.active = false
    end
end

if GetResourceState('ox_lib') ~= 'started' then
    -- Alert dialog (using phone notification as fallback)
    GlitchAbst.UI.Alert = function(title, message, type, icon)
        -- QB doesn't have built-in alerts, using notification
        QBCore.Functions.Notify(title .. "\n" .. message, type or "primary", 5000)
        return true -- No way to wait for user response in basic QB
    end
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