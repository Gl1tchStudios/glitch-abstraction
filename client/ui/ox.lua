-- ox_lib UI module for GlitchLib

-- Check if resource is actually available
if GetResourceState('ox_lib') ~= 'started' then
    GlitchLib.Utils.DebugLog('ox_lib resource is not available')
    return false
end

-- Input dialog
GlitchLib.UI.Input = function(header, inputs, options)
    if options then
        -- Modern usage with options
        return exports['ox_lib']:inputDialog(header, inputs, options)
    else
        -- Legacy usage without options
        return exports['ox_lib']:inputDialog(header, inputs)
    end
end

-- Force close an open input dialog
GlitchLib.UI.CloseInputDialog = function()
    return exports['ox_lib']:closeInputDialog()
end

-- Advanced input dialog with typed fields
GlitchLib.UI.InputForm = function(title, fields, options)
    return GlitchLib.UI.Input(title, fields, options)
end

-- Helper functions for specific input types
GlitchLib.UI.Inputs = {
    -- Create a text input field
    Text = function(label, options)
        options = options or {}
        return {
            type = 'input',
            label = label,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            password = options.password,
            min = options.min,
            max = options.max
        }
    end,
    
    -- Create a number input field
    Number = function(label, options)
        options = options or {}
        return {
            type = 'number',
            label = label,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            min = options.min,
            max = options.max,
            precision = options.precision,
            step = options.step
        }
    end,
    
    -- Create a checkbox input
    Checkbox = function(label, options)
        options = options or {}
        return {
            type = 'checkbox',
            label = label,
            checked = options.checked,
            disabled = options.disabled,
            required = options.required
        }
    end,
    
    -- Create a dropdown select input
    Select = function(label, optionsList, options)
        options = options or {}
        return {
            type = 'select',
            label = label,
            options = optionsList,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            clearable = options.clearable,
            searchable = options.searchable
        }
    end,
    
    -- Create a multi-select dropdown
    MultiSelect = function(label, optionsList, options)
        options = options or {}
        return {
            type = 'multi-select',
            label = label,
            options = optionsList,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            clearable = options.clearable,
            searchable = options.searchable,
            maxSelectedValues = options.maxSelectedValues
        }
    end,
    
    -- Create a slider input
    Slider = function(label, options)
        options = options or {}
        return {
            type = 'slider',
            label = label,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            min = options.min or 0,
            max = options.max or 100,
            step = options.step or 1
        }
    end,
    
    -- Create a color picker input
    Color = function(label, options)
        options = options or {}
        return {
            type = 'color',
            label = label,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            format = options.format
        }
    end,
    
    -- Create a date picker input
    Date = function(label, options)
        options = options or {}
        return {
            type = 'date',
            label = label,
            description = options.description,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            format = options.format,
            returnString = options.returnString,
            clearable = options.clearable,
            min = options.min,
            max = options.max
        }
    end,
    
    -- Create a date range picker input
    DateRange = function(label, options)
        options = options or {}
        return {
            type = 'date-range',
            label = label,
            description = options.description,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            format = options.format,
            returnString = options.returnString,
            clearable = options.clearable
        }
    end,
    
    -- Create a time picker input
    Time = function(label, options)
        options = options or {}
        return {
            type = 'time',
            label = label,
            description = options.description,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            format = options.format,
            clearable = options.clearable
        }
    end,
    
    -- Create a textarea input
    TextArea = function(label, options)
        options = options or {}
        return {
            type = 'textarea',
            label = label,
            description = options.description,
            placeholder = options.placeholder,
            icon = options.icon,
            required = options.required,
            disabled = options.disabled,
            default = options.default,
            min = options.min,
            max = options.max,
            autosize = options.autosize
        }
    end
}

-- Convenience method to build form from multiple field types
GlitchLib.UI.BuildForm = function(title, fields, options)
    return GlitchLib.UI.InputForm(title, fields, options)
end

-- Context menu system
-- Register a context menu with full options support
GlitchLib.UI.RegisterContext = function(context)
    -- Direct passthrough to ox_lib
    return exports['ox_lib']:registerContext(context)
end

-- Show a registered context menu
GlitchLib.UI.ShowContext = function(id)
    return exports['ox_lib']:showContext(id)
end

-- Hide any visible context menu
GlitchLib.UI.HideContext = function(onExit)
    return exports['ox_lib']:hideContext(onExit)
end

-- Get the ID of the currently open context menu
GlitchLib.UI.GetOpenContext = function()
    return exports['ox_lib']:getOpenContextMenu()
end

-- Helper function to create and show a context menu in one step
GlitchLib.UI.OpenContextMenu = function(id, title, options, menu, canClose)
    -- Register the context menu first
    GlitchLib.UI.RegisterContext({
        id = id,
        title = title,
        options = options,
        menu = menu,
        canClose = canClose
    })
    
    -- Then show it
    return GlitchLib.UI.ShowContext(id)
end

-- Legacy support for existing functions
GlitchLib.UI.ContextMenu = function(id, title, options, position)
    return GlitchLib.UI.ShowContext(id)
end

GlitchLib.UI.CreateContextMenu = function(id, title, options)
    return GlitchLib.UI.RegisterContext({
        id = id,
        title = title,
        options = options
    })
end

-- Helper function to build complex nested menus
GlitchLib.UI.BuildMenuStructure = function(menuTree)
    -- Each item in menuTree should have an id, title, options and optionally a parent
    for _, menu in pairs(menuTree) do
        if menu.parent then
            -- Link this menu to its parent
            menu.menu = menu.parent
        end
        
        -- Register this menu
        GlitchLib.UI.RegisterContext({
            id = menu.id,
            title = menu.title,
            menu = menu.menu,
            options = menu.options,
            onExit = menu.onExit,
            onBack = menu.onBack,
            canClose = menu.canClose
        })
    end
    
    -- Return the id of the root menu (first in the tree)
    if #menuTree > 0 then
        return menuTree[1].id
    end
    return nil
end

-- Show a confirmation context menu
GlitchLib.UI.ConfirmContextMenu = function(id, title, message, onConfirm, onCancel, confirmText, cancelText)
    local options = {
        {
            title = confirmText or "Confirm",
            icon = 'check',
            iconColor = '#00ff00',
            onSelect = function()
                if onConfirm then onConfirm() end
            end
        },
        {
            title = cancelText or "Cancel",
            icon = 'xmark',
            iconColor = '#ff0000',
            onSelect = function()
                if onCancel then onCancel() end
            end
        }
    }
    
    if message then
        table.insert(options, 1, {
            title = message,
            readOnly = true
        })
    end
    
    GlitchLib.UI.RegisterContext({
        id = id,
        title = title,
        options = options
    })
    
    return GlitchLib.UI.ShowContext(id)
end

-- Keyboard navigation menu system
-- Register a menu with options and callback
GlitchLib.UI.RegisterMenu = function(data, cb)
    return exports['ox_lib']:registerMenu(data, cb)
end

-- Show a registered menu by ID
GlitchLib.UI.ShowMenu = function(id)
    return exports['ox_lib']:showMenu(id)
end

-- Hide the currently open menu
GlitchLib.UI.HideMenu = function(onExit)
    return exports['ox_lib']:hideMenu(onExit)
end

-- Get the ID of the currently open menu
GlitchLib.UI.GetOpenMenu = function()
    return exports['ox_lib']:getOpenMenu()
end

-- Update menu options dynamically
GlitchLib.UI.SetMenuOptions = function(id, options, index)
    return exports['ox_lib']:setMenuOptions(id, options, index)
end

-- Helper function to create a menu option
GlitchLib.UI.CreateMenuOption = function(label, options)
    options = options or {}
    
    local menuOption = {
        label = label,
        description = options.description,
        icon = options.icon,
        iconColor = options.iconColor,
        iconAnimation = options.iconAnimation,
        args = options.args or {},
        close = options.close,
        progress = options.progress,
        colorScheme = options.colorScheme
    }
    
    -- Handle special option types
    if options.values then
        menuOption.values = options.values
        menuOption.defaultIndex = options.defaultIndex
        menuOption.args.isScroll = true
    end
    
    if options.checked ~= nil then
        menuOption.checked = options.checked
        menuOption.args.isCheck = true
    end
    
    return menuOption
end

-- Create and show a menu in one step
GlitchLib.UI.OpenMenu = function(id, title, options, position, callbacks)
    callbacks = callbacks or {}
    
    -- Build the menu configuration
    local menuData = {
        id = id,
        title = title,
        position = position or 'top-left',
        options = options,
        onClose = callbacks.onClose,
        onSelected = callbacks.onSelected,
        onSideScroll = callbacks.onSideScroll,
        onCheck = callbacks.onCheck,
        canClose = callbacks.canClose,
        disableInput = callbacks.disableInput
    }
    
    -- Register and show the menu
    GlitchLib.UI.RegisterMenu(menuData, callbacks.onSelect)
    return GlitchLib.UI.ShowMenu(id)
end

-- Helper to create a confirmation menu
GlitchLib.UI.ConfirmMenu = function(id, title, message, onConfirm, onCancel)
    local options = {
        {
            label = message,
            description = 'Please select an option below',
            close = false
        },
        {
            label = 'Confirm',
            icon = 'check',
            iconColor = '#00ff00',
            close = true
        },
        {
            label = 'Cancel',
            icon = 'xmark',
            iconColor = '#ff0000',
            close = true
        }
    }
    
    local callbacks = {
        onSelect = function(selected)
            if selected == 2 then -- Confirm
                if onConfirm then onConfirm() end
            elseif selected == 3 then -- Cancel
                if onCancel then onCancel() end
            end
        end
    }
    
    return GlitchLib.UI.OpenMenu(id, title, options, 'top-left', callbacks)
end

-- Enhanced Progress Bar implementation with all parameters

-- Progress bar with complete parameter support
GlitchLib.UI.ProgressBar = function(params)
    return exports['ox_lib']:progressBar({
        duration = params.duration,
        label = params.label,
        useWhileDead = params.useWhileDead,
        allowRagdoll = params.allowRagdoll,
        allowSwimming = params.allowSwimming,
        allowCuffed = params.allowCuffed,
        allowFalling = params.allowFalling,
        canCancel = params.canCancel,
        anim = params.anim,
        prop = params.prop,
        disable = params.disable,
        position = params.position
    })
end

-- Progress Circle with complete parameter support
GlitchLib.UI.ProgressCircle = function(params)
    return exports['ox_lib']:progressCircle({
        duration = params.duration,
        label = params.label,
        position = params.position or 'middle',
        useWhileDead = params.useWhileDead,
        allowRagdoll = params.allowRagdoll,
        allowSwimming = params.allowSwimming,
        allowCuffed = params.allowCuffed,
        allowFalling = params.allowFalling,
        canCancel = params.canCancel,
        anim = params.anim,
        prop = params.prop,
        disable = params.disable
    })
end

-- Check if a progress bar/circle is currently active
GlitchLib.UI.IsProgressActive = function()
    return exports['ox_lib']:progressActive()
end

-- Cancel the current progress if it can be cancelled
GlitchLib.UI.CancelProgress = function()
    return exports['ox_lib']:cancelProgress()
end

-- Helper for creating animation parameters
GlitchLib.UI.CreateAnimation = function(dict, clip, options)
    options = options or {}
    return {
        dict = dict,
        clip = clip,
        flag = options.flag or 49,
        blendIn = options.blendIn or 3.0,
        blendOut = options.blendOut or 1.0,
        duration = options.duration or -1,
        playbackRate = options.playbackRate or 0,
        lockX = options.lockX,
        lockY = options.lockY,
        lockZ = options.lockZ
    }
end

-- Helper for creating scenario parameters
GlitchLib.UI.CreateScenario = function(scenario, options)
    options = options or {}
    return {
        scenario = scenario,
        playEnter = options.playEnter ~= false -- Default to true if not specified
    }
end

-- Helper for creating prop parameters
GlitchLib.UI.CreateProp = function(model, options)
    options = options or {}
    return {
        model = model,
        bone = options.bone or 60309,
        pos = options.pos or vec3(0.0, 0.0, 0.0),
        rot = options.rot or vec3(0.0, 0.0, 0.0),
        rotOrder = options.rotOrder
    }
end

-- Convenience function for showing progress with a drink animation
GlitchLib.UI.DrinkProgress = function(duration, label, item)
    local itemModel = item or `prop_ld_flow_bottle`
    
    return GlitchLib.UI.ProgressBar({
        duration = duration,
        label = label or 'Drinking',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,
            combat = true
        },
        anim = GlitchLib.UI.CreateAnimation('mp_player_intdrink', 'loop_bottle'),
        prop = GlitchLib.UI.CreateProp(itemModel, {
            pos = vec3(0.03, 0.03, 0.02),
            rot = vec3(0.0, 0.0, -1.5)
        })
    })
end

-- Convenience function for showing progress with an eating animation
GlitchLib.UI.EatProgress = function(duration, label, item)
    local itemModel = item or `prop_cs_burger_01`
    
    return GlitchLib.UI.ProgressBar({
        duration = duration,
        label = label or 'Eating',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,
            combat = true
        },
        anim = GlitchLib.UI.CreateAnimation('mp_player_inteat@burger', 'mp_player_int_eat_burger'),
        prop = GlitchLib.UI.CreateProp(itemModel, {
            pos = vec3(0.02, 0.02, -0.02),
            rot = vec3(0.0, 0.0, 0.0)
        })
    })
end

-- Enhanced TextUI implementation with all options and helpers

-- Show TextUI with full options support
GlitchLib.UI.ShowTextUI = function(text, options)
    -- Direct call to ox_lib
    exports['ox_lib']:showTextUI(text, options)
end

-- Hide any visible TextUI
GlitchLib.UI.HideTextUI = function()
    exports['ox_lib']:hideTextUI()
end

-- Check if TextUI is currently open
GlitchLib.UI.IsTextUIOpen = function()
    return exports['ox_lib']:isTextUIOpen()
end

-- Helper function to create styled TextUI
GlitchLib.UI.StyledTextUI = function(text, position, icon, iconColor, style)
    local options = {
        position = position,
        icon = icon,
        iconColor = iconColor,
        style = style
    }
    
    GlitchLib.UI.ShowTextUI(text, options)
end

-- Helper for creating animated icon TextUI
GlitchLib.UI.AnimatedTextUI = function(text, icon, animation, position, iconColor)
    local options = {
        position = position or 'right-center',
        icon = icon,
        iconColor = iconColor,
        iconAnimation = animation
    }
    
    GlitchLib.UI.ShowTextUI(text, options)
end

-- Common styles for TextUI
GlitchLib.UI.TextUIStyles = {
    Success = {
        backgroundColor = '#48BB78',
        color = 'white'
    },
    Error = {
        backgroundColor = '#E53E3E',
        color = 'white'
    },
    Info = {
        backgroundColor = '#3182CE',
        color = 'white'
    },
    Warning = {
        backgroundColor = '#ED8936',
        color = 'white'
    },
    Custom = function(bgColor, textColor, borderRadius)
        return {
            backgroundColor = bgColor,
            color = textColor,
            borderRadius = borderRadius or 4
        }
    end
}

-- Predefined TextUI templates
GlitchLib.UI.ShowInteractionTextUI = function(text, key)
    key = key or 'E'
    GlitchLib.UI.ShowTextUI('[' .. key .. '] - ' .. text, {
        position = 'right-center',
        icon = 'hand',
        style = GlitchLib.UI.TextUIStyles.Info
    })
end

GlitchLib.UI.ShowSuccessTextUI = function(text)
    GlitchLib.UI.ShowTextUI(text, {
        position = 'top-center',
        icon = 'circle-check',
        style = GlitchLib.UI.TextUIStyles.Success
    })
end

GlitchLib.UI.ShowErrorTextUI = function(text)
    GlitchLib.UI.ShowTextUI(text, {
        position = 'top-center',
        icon = 'circle-exclamation',
        style = GlitchLib.UI.TextUIStyles.Error
    })
end

GlitchLib.UI.ShowWarningTextUI = function(text)
    GlitchLib.UI.ShowTextUI(text, {
        position = 'top-center',
        icon = 'triangle-exclamation',
        iconAnimation = 'pulse',
        style = GlitchLib.UI.TextUIStyles.Warning
    })
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

-- Radial Menu System
-- Add item(s) to the global radial menu
GlitchLib.UI.AddRadialItem = function(items)
    return exports['ox_lib']:addRadialItem(items)
end

-- Remove an item from the global radial menu by ID
GlitchLib.UI.RemoveRadialItem = function(id)
    return exports['ox_lib']:removeRadialItem(id)
end

-- Clear all items from the radial menu
GlitchLib.UI.ClearRadialItems = function()
    return exports['ox_lib']:clearRadialItems()
end

-- Register a radial sub-menu with predefined options
GlitchLib.UI.RegisterRadial = function(radial)
    return exports['ox_lib']:registerRadial(radial)
end

-- Hide the currently open radial menu
GlitchLib.UI.HideRadial = function()
    return exports['ox_lib']:hideRadial()
end

-- Enable or disable the radial menu
GlitchLib.UI.DisableRadial = function(state)
    return exports['ox_lib']:disableRadial(state)
end

-- Get the ID of the currently open radial menu
GlitchLib.UI.GetCurrentRadialId = function()
    return exports['ox_lib']:getCurrentRadialId()
end

-- Helper function to create a radial menu item
GlitchLib.UI.CreateRadialItem = function(id, label, icon, options)
    options = options or {}
    
    local item = {
        id = id,
        label = label,
        icon = icon,
        menu = options.menu,
        onSelect = options.onSelect,
        keepOpen = options.keepOpen
    }
    
    -- Handle custom icon dimensions if provided
    if options.iconWidth then
        item.iconWidth = options.iconWidth
    end
    
    if options.iconHeight then
        item.iconHeight = options.iconHeight
    end
    
    return item
end

-- Helper function to create and register a radial menu in one step
GlitchLib.UI.CreateRadialMenu = function(id, items)
    local radial = {
        id = id,
        items = items
    }
    
    return GlitchLib.UI.RegisterRadial(radial)
end

-- Helper function to quickly add a single radial item
GlitchLib.UI.QuickRadial = function(id, label, icon, onSelect)
    return GlitchLib.UI.AddRadialItem({
        id = id,
        label = label,
        icon = icon,
        onSelect = onSelect
    })
end

-- Helper to create a radial submenu and link it to a main menu item
GlitchLib.UI.RadialSubmenu = function(parentId, parentLabel, parentIcon, submenuId, submenuItems)
    -- First register the submenu
    GlitchLib.UI.RegisterRadial({
        id = submenuId,
        items = submenuItems
    })
    
    -- Then add the parent item that links to the submenu
    return GlitchLib.UI.AddRadialItem({
        id = parentId,
        label = parentLabel,
        icon = parentIcon,
        menu = submenuId
    })
end

-- Skill Check System
-- Run a skill check with defined difficulty
GlitchLib.UI.SkillCheck = function(difficulty, inputs)
    return exports['ox_lib']:skillCheck(difficulty, inputs)
end

-- Check if a skill check is currently active
GlitchLib.UI.IsSkillCheckActive = function()
    return exports['ox_lib']:skillCheckActive()
end

-- Cancel the currently ongoing skill check
GlitchLib.UI.CancelSkillCheck = function()
    return exports['ox_lib']:cancelSkillCheck()
end

-- Helper function for creating a custom difficulty
GlitchLib.UI.CustomDifficulty = function(areaSize, speedMultiplier)
    return { areaSize = areaSize, speedMultiplier = speedMultiplier }
end

-- Helper function for creating a sequence of skill checks with the same input keys
GlitchLib.UI.SkillCheckSequence = function(difficulties, inputs, onComplete, onFail)
    -- Default to 'e' if no inputs provided
    inputs = inputs or {'e'}
    
    -- Start the first check in the sequence
    Citizen.CreateThread(function()
        local currentCheck = 1
        local success = true
        
        while currentCheck <= #difficulties and success do
            success = GlitchLib.UI.SkillCheck(difficulties[currentCheck], inputs)
            
            if success then
                currentCheck = currentCheck + 1
                -- Small delay between checks
                Citizen.Wait(300)
            else
                -- Failed the sequence
                if onFail then onFail(currentCheck) end
                return false
            end
        end
        
        -- Completed the full sequence
        if success and onComplete then onComplete() end
        return success
    end)
end

-- Convenience function for a lockpick skill check
GlitchLib.UI.Lockpick = function(difficulty, callback)
    if not difficulty then
        -- Default lockpicking sequence: medium -> medium -> hard
        difficulty = {'medium', 'medium', 'hard'}
    elseif type(difficulty) == 'string' then
        -- Single difficulty level
        difficulty = {difficulty}
    end
    
    Citizen.CreateThread(function()
        local success = GlitchLib.UI.SkillCheck(difficulty)
        if callback then callback(success) end
        return success
    end)
end

-- Convenience function for a hack skill check
GlitchLib.UI.Hack = function(difficulty, inputs, callback)
    if not difficulty then
        -- Default hacking sequence: multiple increasing difficulties
        difficulty = {
            'easy', 
            'medium', 
            GlitchLib.UI.CustomDifficulty(35, 1.5),
            'hard'
        }
    end
    
    -- Use WASD as default inputs for hacking
    inputs = inputs or {'w', 'a', 's', 'd'}
    
    Citizen.CreateThread(function()
        local success = GlitchLib.UI.SkillCheck(difficulty, inputs)
        if callback then callback(success) end
        return success
    end)
end

GlitchLib.Utils.DebugLog('ox_lib UI module loaded')
return true