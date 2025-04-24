GlitchLib.Utils.DebugLog('ox_lib UI module loaded')

-- Input dialog
GlitchLib.UI.Input = function(header, inputs)
    return lib.inputDialog(header, inputs)
end

-- Context menu (right-click style menu)
GlitchLib.UI.ContextMenu = function(id, title, options, position)
    return lib.showContext(id)
end

GlitchLib.UI.CreateContextMenu = function(id, title, options)
    return lib.registerContext({
        id = id,
        title = title,
        options = options
    })
end

-- Progress bar
GlitchLib.UI.ProgressBar = function(params)
    return lib.progressBar({
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
    return lib.progressCircle({
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
    lib.showTextUI(message, options)
end

GlitchLib.UI.HideTextUI = function()
    lib.hideTextUI()
end

-- Alert dialog
GlitchLib.UI.Alert = function(title, message, type, icon)
    return lib.alertDialog({
        header = title,
        content = message,
        centered = true,
        cancel = true,
        type = type or 'info',
        icon = icon
    })
end