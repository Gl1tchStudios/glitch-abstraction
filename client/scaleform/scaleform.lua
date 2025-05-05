-- Safety check for GlitchLib
if not GlitchLib or not GlitchLib.Utils then
    print("^1[ERROR] GlitchLib not initialized before loading scaleform module^7")
    return false
end

-- Initialize scaleform namespace
GlitchLib.Scaleform = GlitchLib.Scaleform or {}

-- Scaleform
GlitchLib.Utils.DebugLog('Scaleform module loaded')

-- Active scaleforms cache
GlitchLib.Scaleform.Active = {}

-- Load a scaleform
GlitchLib.Scaleform.Load = function(name)
    if not name then return nil end
    
    local handle = RequestScaleformMovie(name)
    local timeout = GetGameTimer() + 5000
    
    while not HasScaleformMovieLoaded(handle) and GetGameTimer() < timeout do
        Wait(0)
    end
    
    if HasScaleformMovieLoaded(handle) then
        GlitchLib.Scaleform.Active[name] = handle
        return handle
    end
    
    GlitchLib.Utils.DebugLog('Failed to load scaleform: ' .. name)
    return nil
end

-- Unload a scaleform
GlitchLib.Scaleform.Unload = function(nameOrHandle)
    if not nameOrHandle then return false end
    
    if type(nameOrHandle) == 'string' then
        -- If provided a name, lookup the handle
        if GlitchLib.Scaleform.Active[nameOrHandle] then
            SetScaleformMovieAsNoLongerNeeded(GlitchLib.Scaleform.Active[nameOrHandle])
            GlitchLib.Scaleform.Active[nameOrHandle] = nil
            return true
        end
        return false
    end
    
    -- Otherwise assume it's a handle
    SetScaleformMovieAsNoLongerNeeded(nameOrHandle)
    
    -- Also remove from active cache if found
    for name, handle in pairs(GlitchLib.Scaleform.Active) do
        if handle == nameOrHandle then
            GlitchLib.Scaleform.Active[name] = nil
            break
        end
    end
    
    return true
end

-- Call a function on a scaleform
GlitchLib.Scaleform.CallFunction = function(handleOrName, retval, funcName, ...)
    local handle = handleOrName
    
    if type(handleOrName) == 'string' then
        handle = GlitchLib.Scaleform.Active[handleOrName]
        if not handle then
            handle = GlitchLib.Scaleform.Load(handleOrName)
            if not handle then return false end
        end
    end
    
    BeginScaleformMovieMethod(handle, funcName)
    
    local args = {...}
    for _, arg in ipairs(args) do
        local argType = type(arg)
        
        if argType == 'number' then
            if math.type(arg) == 'integer' then
                ScaleformMovieMethodAddParamInt(arg)
            else
                ScaleformMovieMethodAddParamFloat(arg)
            end
        elseif argType == 'string' then
            ScaleformMovieMethodAddParamTextureNameString(arg)
        elseif argType == 'boolean' then
            ScaleformMovieMethodAddParamBool(arg)
        end
    end
    
    if retval then
        return EndScaleformMovieMethodReturnValue()
    else
        EndScaleformMovieMethod()
        return true
    end
end

-- Render a scaleform
GlitchLib.Scaleform.Render = function(handleOrName, x, y, width, height, r, g, b, a, scale)
    local handle = handleOrName
    
    if type(handleOrName) == 'string' then
        handle = GlitchLib.Scaleform.Active[handleOrName]
        if not handle then
            handle = GlitchLib.Scaleform.Load(handleOrName)
            if not handle then return false end
        end
    end
    
    if x and y and width and height then
        -- Draw on screen position
        DrawScaleformMovie(handle, x, y, width, height, r or 255, g or 255, b or 255, a or 255, 0)
    elseif scale then
        -- Draw fullscreen with scale
        DrawScaleformMovieFullscreenMasked(handle, handle, r or 255, g or 255, b or 255, a or 255)
    else
        -- Draw fullscreen
        DrawScaleformMovieFullscreen(handle, r or 255, g or 255, b or 255, a or 255, 0)
    end
    
    return true
end

-- Render a scaleform in 3D space
GlitchLib.Scaleform.Render3D = function(handleOrName, x, y, z, rx, ry, rz, scale)
    local handle = handleOrName
    
    if type(handleOrName) == 'string' then
        handle = GlitchLib.Scaleform.Active[handleOrName]
        if not handle then
            handle = GlitchLib.Scaleform.Load(handleOrName)
            if not handle then return false end
        end
    end
    
    DrawScaleformMovie_3d(handle, x, y, z, rx, ry, rz, 2.0, 2.0, 1.0, scale or 1.0, 1.0, 1.0, 2)
    return true
end

---------------------------
-- Common Scaleform UIs --
---------------------------

-- Setup instructional buttons scaleform
GlitchLib.Scaleform.SetupInstructionalButtons = function(buttons)
    if not buttons or #buttons == 0 then return nil end
    
    local handle = GlitchLib.Scaleform.Load("INSTRUCTIONAL_BUTTONS")
    if not handle then return nil end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "CLEAR_ALL")
    GlitchLib.Scaleform.CallFunction(handle, false, "SET_CLEAR_SPACE", 200)
    
    for i, button in ipairs(buttons) do
        GlitchLib.Scaleform.CallFunction(handle, false, "SET_DATA_SLOT", i - 1, button.control, button.label)
    end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "DRAW_INSTRUCTIONAL_BUTTONS")
    
    return handle
end

-- Show message box (BIG_MESSAGE)
GlitchLib.Scaleform.ShowMessageBox = function(title, subtitle, footer)
    local handle = GlitchLib.Scaleform.Load("MP_BIG_MESSAGE_FREEMODE")
    if not handle then return nil end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "SHOW_SHARD_CENTERED_MP_MESSAGE", title, subtitle, 5, footer or "")
    
    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 5000 do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        GlitchLib.Scaleform.Unload(handle)
    end)
    
    return handle
end

-- Show midsize banner (same functionality as CSform.MidsizeBanner)
GlitchLib.Scaleform.ShowMidsizeBanner = function(title, subtitle, bannerColor, waitTime, playSound)
    -- Load the correct scaleform
    local handle = GlitchLib.Scaleform.Load("MIDSIZED_MESSAGE")
    if not handle then return nil end
    
    -- Play sound if requested
    if playSound then
        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true)
    end
    
    -- Set default wait time if not provided
    waitTime = waitTime or 5
    
    -- Call the correct function with parameters matching the original
    GlitchLib.Scaleform.CallFunction(handle, false, "SHOW_COND_SHARD_MESSAGE", title, subtitle, bannerColor, true)
    
    -- Create thread to display and handle timing
    CreateThread(function()
        local startTime = GetGameTimer()
        local duration = (waitTime * 1000) - 1000
        
        -- Display the scaleform
        while GetGameTimer() - startTime < duration do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        
        -- Fade out animation
        GlitchLib.Scaleform.CallFunction(handle, false, "SHARD_ANIM_OUT", 2, 0.3, true)
        
        -- Continue rendering during fade out
        local fadeOutTime = GetGameTimer()
        while GetGameTimer() - fadeOutTime < 1000 do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        
        -- Unload the scaleform
        GlitchLib.Scaleform.Unload(handle)
    end)
    
    return handle
end

-- Show mission passed scaleform
GlitchLib.Scaleform.ShowMissionPassed = function(title, subtitle, rp, money)
    local handle = GlitchLib.Scaleform.Load("MP_MISSION_NAME_FREEMODE")
    if not handle then return nil end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "SET_MISSION_INFO", title, subtitle, "", (rp and rp > 0), rp or 0, (money and money > 0), "$" .. (money or 0))
    
    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 5000 do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        GlitchLib.Scaleform.Unload(handle)
    end)
    
    return handle
end

-- Show countdown scaleform
GlitchLib.Scaleform.ShowCountdown = function(number, message)
    local handle = GlitchLib.Scaleform.Load("COUNTDOWN")
    if not handle then return nil end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "SET_MESSAGE", message or "")
    GlitchLib.Scaleform.CallFunction(handle, false, "SET_COUNTDOWN", number, 0)
    
    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 5000 do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        GlitchLib.Scaleform.Unload(handle)
    end)
    
    return handle
end

-- Show credits scaleform
GlitchLib.Scaleform.ShowCredits = function(items)
    local handle = GlitchLib.Scaleform.Load("CREDITS_SCROLL")
    if not handle then return nil end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "SCROLL_CREDITS", 0.5)
    
    for _, item in ipairs(items) do
        if item.type == "header" then
            GlitchLib.Scaleform.CallFunction(handle, false, "ADD_CREDITS_HEADER", item.text)
        elseif item.type == "credit" then
            GlitchLib.Scaleform.CallFunction(handle, false, "ADD_CREDITS_PERSON", item.role, item.name)
        elseif item.type == "space" then
            GlitchLib.Scaleform.CallFunction(handle, false, "ADD_CREDITS_SPACE")
        end
    end
    
    GlitchLib.Scaleform.CallFunction(handle, false, "FINALIZE_CREDITS")
    
    CreateThread(function()
        local startTime = GetGameTimer()
        while GetGameTimer() - startTime < 10000 do
            Wait(0)
            GlitchLib.Scaleform.Render(handle)
        end
        GlitchLib.Scaleform.Unload(handle)
    end)
    
    return handle
end