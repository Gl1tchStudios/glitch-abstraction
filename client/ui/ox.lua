-- ox_lib UI module for GlitchLib

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Input dialog
GlitchLib.UI.Input = function(header, inputs)
    return exports['ox_lib']:inputDialog(header, inputs)
end

-- Context menu (right-click style menu)
GlitchLib.UI.ContextMenu = function(id, title, options, position)
    return exports['ox_lib']:showContext(id)
end

GlitchLib.UI.CreateContextMenu = function(id, title, options)
    return exports['ox_lib']:registerContext({
        id = id,
        title = title,
        options = options
    })
end

-- Progress bar
GlitchLib.UI.ProgressBar = function(params)
    return exports['ox_lib']:progressBar({
        duration = params.duration,
        label = params.label,
        useWhileDead = params.useWhileDead or false,
        canCancel = params.canCancel or true,
        anim = params.anim,
        prop = params.prop,
        disable = params.disable,
        position = params.position or 'bottom'
    })
end

-- Progress Circle (if enabled)
GlitchLib.UI.ProgressCircle = function(params)
    return exports['ox_lib']:progressCircle({
        duration = params.duration,
        label = params.label,
        position = params.position or 'bottom',
        useWhileDead = params.useWhileDead or false,
        canCancel = params.canCancel or true,
        anim = params.anim,
        prop = params.prop,
        disable = params.disable
    })
end

-- Text UI (persistent text display)
GlitchLib.UI.ShowTextUI = function(message, options)
    exports['ox_lib']:showTextUI(message, options)
end

GlitchLib.UI.HideTextUI = function()
    exports['ox_lib']:hideTextUI()
end

-- Alert dialog that works with ox_target callbacks
GlitchLib.UI.Alert = function(titleOrParams, message, typeParam, icon)
    local params
    if type(titleOrParams) == 'table' then
        params = {
            header = titleOrParams.header or titleOrParams.title,
            content = titleOrParams.content or titleOrParams.message or titleOrParams.description,
            centered = titleOrParams.centered ~= false,
            cancel = titleOrParams.cancel ~= false,
            type = titleOrParams.type or 'info',
            icon = titleOrParams.icon
        }
    else
        params = {
            header = titleOrParams,
            content = message,
            centered = true,
            cancel = true,
            type = typeParam or 'info',
            icon = icon
        }
    end
    

    if exports and exports['ox_lib'] then
        local result = exports['ox_lib']:alertDialog(params)
        return result
    else
        GlitchLib.Utils.DebugLog('Alert dialog failed - ox_lib not found')
        return "error" 
    end
end

GlitchLib.alertDialog = GlitchLib.UI.Alert
GlitchLib.Alert = GlitchLib.UI.Alert

GlitchLib.Utils.DebugLog('ox_lib UI module loaded')
return true