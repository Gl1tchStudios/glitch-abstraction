if GlitchLib.FrameworkName ~= 'ESX' then
    GlitchLib.Utils.DebugLog('Skipping ESX UI module (using ' .. (GlitchLib.FrameworkName or 'unknown') .. ')')
    return false
end

-- Safe way to get ESX
local ESX = nil
local success, result = pcall(function()
    return exports['es_extended']:getSharedObject()
end)

-- Define the initialization function BEFORE calling it
local function InitializeESXUI(eSXObj)
    GlitchLib.Utils.DebugLog('ESX UI module loaded')
    
    -- Basic menu functions
    GlitchLib.UI.ShowMenu = function(params)
        -- Implementation depends on your ESX menu system
        -- This is a placeholder based on common ESX menu patterns
        if ESX.UI.Menu then
            ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), params.id or 'default_menu',
                {
                    title = params.title or 'Menu',
                    align = params.position or 'top-left',
                    elements = params.elements or {}
                },
                function(data, menu)
                    -- Submit callback
                    if params.onSelect then
                        params.onSelect(data.current, menu)
                    end
                end,
                function(data, menu)
                    -- Cancel callback
                    menu.close()
                    if params.onClose then
                        params.onClose()
                    end
                end
            )
        end
    end
    
    -- Close all menus
    GlitchLib.UI.CloseMenu = function()
        if ESX.UI.Menu then
            ESX.UI.Menu.CloseAll()
        end
    end
    
    -- Show HUD elements
    GlitchLib.UI.ShowHUD = function(elements)
        -- Implementation depends on your HUD system
    end
    
    -- Hide HUD elements
    GlitchLib.UI.HideHUD = function(elements)
        -- Implementation depends on your HUD system
    end
end

if success and result then
    ESX = result
    InitializeESXUI(ESX)
else
    -- Try the event method as fallback
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
            if ESX then
                InitializeESXUI(ESX)
                break
            end
        end
    end)
end