GlitchLib.Utils.DebugLog('ESX UI module loaded')

local ESX = exports['es_extended']:getSharedObject()

-- Input dialog (using ESX menu_dialog)
GlitchLib.UI.Input = function(header, inputs)
    local p = promise.new()
    
    if #inputs == 1 and inputs[1].type == "text" then
        -- Single text input can use ESX default dialog
        ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'glitch_input', {
            title = header
        }, function(data, menu)
            menu.close()
            
            if data.value then
                local result = {}
                result[inputs[1].name] = data.value
                p:resolve(result)
            else
                p:resolve(nil)
            end
        end, function(data, menu)
            menu.close()
            p:resolve(nil)
        end)
    else
        -- For more complex inputs, fallback to a list
        local elements = {}
        for _, input in ipairs(inputs) do
            table.insert(elements, {
                label = input.label,
                name = input.name,
                type = input.type or "text",
                value = input.default or ""
            })
        end
        
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'glitch_input_complex', {
            title = header,
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            local result = {}
            for _, element in ipairs(elements) do
                result[element.name] = element.value
            end
            menu.close()
            p:resolve(result)
        end, function(data, menu)
            menu.close()
            p:resolve(nil)
        end, function(data, element)
            for k, v in pairs(elements) do
                if v.name == element.name then
                    elements[k].value = element.value
                end
            end
        end)
    end
    
    return Citizen.Await(p)
end

-- Menu (using ESX menu_default)
GlitchLib.UI.ContextMenu = function(id, title, options, position)
    local elements = {}
    
    for _, option in ipairs(options) do
        table.insert(elements, {
            label = option.title,
            desc = option.description,
            value = option.value,
            action = option.action
        })
    end
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), id, {
        title = title,
        align = position or 'top-left',
        elements = elements
    }, function(data, menu)
        for _, option in ipairs(options) do
            if option.value == data.current.value then
                if option.event then
                    if option.isServer then
                        TriggerServerEvent(option.event, table.unpack(option.args or {}))
                    else
                        TriggerEvent(option.event, table.unpack(option.args or {}))
                    end
                end
                
                if option.action then
                    option.action()
                end
                
                if option.close then
                    menu.close()
                end
                
                break
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

GlitchLib.UI.CreateContextMenu = function(id, title, options)
    -- ESX doesn't need pre-registration, just store for later
    GlitchLib.UI._menus = GlitchLib.UI._menus or {}
    GlitchLib.UI._menus[id] = {
        title = title,
        options = options
    }
    return true
end

-- Progress bar (ESX doesn't have built-in, using mythic_progbar if available)
GlitchLib.UI.ProgressBar = function(params)
    local p = promise.new()
    
    if GetResourceState('mythic_progbar') ~= 'missing' then
        exports['mythic_progbar']:Progress({
            name = params.name or "glitch_progressbar",
            duration = params.duration,
            label = params.label,
            useWhileDead = params.useWhileDead or false,
            canCancel = params.canCancel or true,
            controlDisables = {
                disableMovement = params.disable and params.disable.movement or false,
                disableCarMovement = params.disable and params.disable.car or false,
                disableMouse = params.disable and params.disable.mouse or false,
                disableCombat = params.disable and params.disable.combat or false
            },
            animation = {
                animDict = params.anim and params.anim.dict,
                anim = params.anim and params.anim.name,
                flags = params.anim and params.anim.flags or 0
            }
        }, function(cancelled)
            if cancelled then
                p:resolve(false)
            else
                p:resolve(true)
            end
        end)
    else
        -- Simple fallback
        Citizen.CreateThread(function()
            if params.anim and params.anim.dict and params.anim.name then
                RequestAnimDict(params.anim.dict)
                while not HasAnimDictLoaded(params.anim.dict) do
                    Citizen.Wait(0)
                end
                TaskPlayAnim(PlayerPedId(), params.anim.dict, params.anim.name, 8.0, -8.0, -1, params.anim.flags or 0, 0, false, false, false)
            end
            
            local start = GetGameTimer()
            local finish = start + params.duration
            
            while GetGameTimer() < finish do
                Citizen.Wait(0)
                local remaining = finish - GetGameTimer()
                local percent = (params.duration - remaining) / params.duration * 100
                DrawText3D(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z + 0.3, params.label .. " - " .. math.floor(percent) .. "%")
                
                if params.canCancel and IsControlJustPressed(0, 200) then -- Escape key
                    if params.anim and params.anim.dict and params.anim.name then
                        ClearPedTasks(PlayerPedId())
                    end
                    p:resolve(false)
                    return
                end
            end
            
            if params.anim and params.anim.dict and params.anim.name then
                ClearPedTasks(PlayerPedId())
            end
            
            p:resolve(true)
        end)
    end
    
    return Citizen.Await(p)
end

-- Text UI (using custom implementation)
GlitchLib.UI.ShowTextUI = function(message, options)
    -- Basic implementation since ESX doesn't have built-in text UI
    GlitchLib.UI._textUI = {
        message = message,
        position = options and options.position or "right-center",
        active = true
    }
    
    CreateThread(function()
        while GlitchLib.UI._textUI and GlitchLib.UI._textUI.active do
            DrawText3D(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z + 0.15, GlitchLib.UI._textUI.message)
            Wait(0)
        end
    end)
end

GlitchLib.UI.HideTextUI = function()
    if GlitchLib.UI._textUI then
        GlitchLib.UI._textUI.active = false
    end
end

-- Alert dialog (using ESX notification as fallback)
GlitchLib.UI.Alert = function(title, message, type, icon)
    -- ESX doesn't have built-in alerts, using notification
    ESX.ShowNotification(title .. "\n" .. message)
    return true -- No way to wait for user response in basic ESX
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