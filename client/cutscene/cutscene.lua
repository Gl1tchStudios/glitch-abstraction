GlitchLib.Utils.DebugLog('Cutscene module loaded')

-- Player appearance storage
local playerAppearance = {}

-- Save player appearance
GlitchLib.Cutscene.SavePlayerAppearance = function()
    local ped = PlayerPedId()
    
    playerAppearance = {
        -- Face/Head
        mask = {GetPedDrawableVariation(ped, 1), GetPedTextureVariation(ped, 1), GetPedPaletteVariation(ped, 1)},
        hair = {GetPedDrawableVariation(ped, 2), GetPedTextureVariation(ped, 2), GetPedPaletteVariation(ped, 2)},
        arms = {GetPedDrawableVariation(ped, 3), GetPedTextureVariation(ped, 3), GetPedPaletteVariation(ped, 3)},
        
        -- Clothing
        pants = {GetPedDrawableVariation(ped, 4), GetPedTextureVariation(ped, 4), GetPedPaletteVariation(ped, 4)},
        bag = {GetPedDrawableVariation(ped, 5), GetPedTextureVariation(ped, 5), GetPedPaletteVariation(ped, 5)},
        feet = {GetPedDrawableVariation(ped, 6), GetPedTextureVariation(ped, 6), GetPedPaletteVariation(ped, 6)},
        shirt = {GetPedDrawableVariation(ped, 8), GetPedTextureVariation(ped, 8), GetPedPaletteVariation(ped, 8)},
        vest = {GetPedDrawableVariation(ped, 9), GetPedTextureVariation(ped, 9), GetPedPaletteVariation(ped, 9)},
        decals = {GetPedDrawableVariation(ped, 10), GetPedTextureVariation(ped, 10), GetPedPaletteVariation(ped, 10)},
        jacket = {GetPedDrawableVariation(ped, 11), GetPedTextureVariation(ped, 11), GetPedPaletteVariation(ped, 11)},
        
        -- Props
        hat = {GetPedPropIndex(ped, 0), GetPedPropTextureIndex(ped, 0)},
        glasses = {GetPedPropIndex(ped, 1), GetPedPropTextureIndex(ped, 1)},
        ear = {GetPedPropIndex(ped, 2), GetPedPropTextureIndex(ped, 2)},
        watch = {GetPedPropIndex(ped, 6), GetPedPropTextureIndex(ped, 6)},
        bracelet = {GetPedPropIndex(ped, 7), GetPedPropTextureIndex(ped, 7)}
    }
    
    return playerAppearance
end

-- Restore player appearance
GlitchLib.Cutscene.RestorePlayerAppearance = function()
    if not playerAppearance or next(playerAppearance) == nil then
        GlitchLib.Utils.DebugLog('No saved appearance to restore')
        return false
    end
    
    local ped = PlayerPedId()
    
    -- Restore components
    SetPedComponentVariation(ped, 1, playerAppearance.mask[1], playerAppearance.mask[2], playerAppearance.mask[3])
    SetPedComponentVariation(ped, 2, playerAppearance.hair[1], playerAppearance.hair[2], playerAppearance.hair[3])
    SetPedComponentVariation(ped, 3, playerAppearance.arms[1], playerAppearance.arms[2], playerAppearance.arms[3])
    SetPedComponentVariation(ped, 4, playerAppearance.pants[1], playerAppearance.pants[2], playerAppearance.pants[3])
    SetPedComponentVariation(ped, 5, playerAppearance.bag[1], playerAppearance.bag[2], playerAppearance.bag[3])
    SetPedComponentVariation(ped, 6, playerAppearance.feet[1], playerAppearance.feet[2], playerAppearance.feet[3])
    SetPedComponentVariation(ped, 8, playerAppearance.shirt[1], playerAppearance.shirt[2], playerAppearance.shirt[3])
    SetPedComponentVariation(ped, 9, playerAppearance.vest[1], playerAppearance.vest[2], playerAppearance.vest[3])
    SetPedComponentVariation(ped, 10, playerAppearance.decals[1], playerAppearance.decals[2], playerAppearance.decals[3])
    SetPedComponentVariation(ped, 11, playerAppearance.jacket[1], playerAppearance.jacket[2], playerAppearance.jacket[3])
    
    -- Restore props
    SetPedPropIndex(ped, 0, playerAppearance.hat[1], playerAppearance.hat[2], true)
    SetPedPropIndex(ped, 1, playerAppearance.glasses[1], playerAppearance.glasses[2], true)
    SetPedPropIndex(ped, 2, playerAppearance.ear[1], playerAppearance.ear[2], true)
    SetPedPropIndex(ped, 6, playerAppearance.watch[1], playerAppearance.watch[2], true)
    SetPedPropIndex(ped, 7, playerAppearance.bracelet[1], playerAppearance.bracelet[2], true)
    
    return true
end

-- Play a cutscene with customization options
GlitchLib.Cutscene.Play = function(cutsceneName, options)
    options = options or {}
    
    -- Default options
    local config = {
        saveAppearance = options.saveAppearance ~= false, -- Default true
        restoreAppearance = options.restoreAppearance ~= false, -- Default true
        hidePlayer = options.hidePlayer or false,
        hideEntities = options.hideEntities or {},
        flags = options.flags or 0,
        customEntities = options.customEntities or {},
        onStart = options.onStart,
        onEnd = options.onEnd,
        timeoutMs = options.timeoutMs or 10000
    }
    
    -- Debug output
    GlitchLib.Utils.DebugLog('Playing cutscene: ' .. cutsceneName)
    
    -- Stop any active cutscene
    if IsCutsceneActive() then
        StopCutsceneImmediately()
    end
    
    -- Save player appearance if needed
    if config.saveAppearance then
        GlitchLib.Cutscene.SavePlayerAppearance()
    end
    
    -- Request the cutscene
    RequestCutscene(cutsceneName, config.flags)
    
    -- Wait for the cutscene to load with timeout
    local timeout = GetGameTimer() + config.timeoutMs
    while not HasCutsceneLoaded() and GetGameTimer() < timeout do
        Citizen.Wait(0)
    end
    
    -- Check if cutscene loaded successfully
    if not HasCutsceneLoaded() then
        GlitchLib.Utils.DebugLog('Cutscene failed to load: ' .. cutsceneName)
        if config.onEnd then config.onEnd(false) end
        return false
    end
    
    local playerPed = PlayerPedId()
    
    -- Set up cutscene entity streaming flags
    for entity, flag in pairs(config.hideEntities) do
        SetCutsceneEntityStreamingFlags(entity, 0, flag)
    end
    
    -- Register default player entity
    RegisterEntityForCutscene(playerPed, "MP_1", 0, 0, 64)
    
    -- Register custom entities
    for name, data in pairs(config.customEntities) do
        if data.entity then
            RegisterEntityForCutscene(data.entity, name, data.type or 0, data.hash or 0, data.flags or 64)
        else
            RegisterEntityForCutscene(0, name, data.type or 3, data.hash or GetHashKey("mp_m_freemode_01"), data.flags or 64)
        end
    end
    
    -- Hide player if needed
    if config.hidePlayer then
        NetworkSetEntityInvisibleToNetwork(playerPed, true)
    end
    
    -- Start the cutscene
    StartCutscene(0)
    
    -- Wait for MP_1 to exist
    while not (DoesCutsceneEntityExist('MP_1', 0)) do
        Citizen.Wait(0)
    end
    
    -- Call onStart callback if provided
    if config.onStart then
        config.onStart()
    end
    
    -- Scene loading optimization
    Citizen.CreateThread(function()
        Citizen.SetTimeout(100, function()
            if IsCutsceneActive() then
                local coords = GetWorldCoordFromScreenCoord(0.5, 0.5)
                NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 1000, 0)
            end
        end)
    end)
    
    -- Handle cutscene appearance updates
    Citizen.CreateThread(function()
        -- Wait for cutscene to actually start playing
        while not IsCutscenePlaying() do
            Citizen.Wait(0)
            if not IsCutsceneActive() then return end -- Cutscene was stopped
        end
        
        -- While the cutscene is playing
        while IsCutscenePlaying() do
            Citizen.Wait(0)
            
            -- Apply appearance during cutscene if needed
            if config.restoreAppearance then
                SetCutscenePedComponentVariationFromPed(PlayerPedId(), PlayerPedId(), 1885233650)
                
                -- Apply saved appearance
                if playerAppearance.mask then SetPedComponentVariation(playerPed, 1, playerAppearance.mask[1], playerAppearance.mask[2], playerAppearance.mask[3]) end
                if playerAppearance.hair then SetPedComponentVariation(playerPed, 2, playerAppearance.hair[1], playerAppearance.hair[2], playerAppearance.hair[3]) end
                if playerAppearance.arms then SetPedComponentVariation(playerPed, 3, playerAppearance.arms[1], playerAppearance.arms[2], playerAppearance.arms[3]) end
                if playerAppearance.pants then SetPedComponentVariation(playerPed, 4, playerAppearance.pants[1], playerAppearance.pants[2], playerAppearance.pants[3]) end
                if playerAppearance.feet then SetPedComponentVariation(playerPed, 6, playerAppearance.feet[1], playerAppearance.feet[2], playerAppearance.feet[3]) end
                if playerAppearance.shirt then SetPedComponentVariation(playerPed, 8, playerAppearance.shirt[1], playerAppearance.shirt[2], playerAppearance.shirt[3]) end
                if playerAppearance.vest then SetPedComponentVariation(playerPed, 9, playerAppearance.vest[1], playerAppearance.vest[2], playerAppearance.vest[3]) end
                if playerAppearance.jacket then SetPedComponentVariation(playerPed, 11, playerAppearance.jacket[1], playerAppearance.jacket[2], playerAppearance.jacket[3]) end
                
                -- Apply props
                if playerAppearance.hat then SetPedPropIndex(playerPed, 0, playerAppearance.hat[1], playerAppearance.hat[2], true) end
                if playerAppearance.glasses then SetPedPropIndex(playerPed, 1, playerAppearance.glasses[1], playerAppearance.glasses[2], true) end
            end
        end
        
        -- Cleanup after cutscene finishes
        if config.hidePlayer then
            NetworkSetEntityInvisibleToNetwork(playerPed, false)
        end
        
        -- Call onEnd callback if provided
        if config.onEnd then
            config.onEnd(true)
        end
    end)
    
    return true
end

-- Check if a cutscene is currently active
GlitchLib.Cutscene.IsActive = function()
    return IsCutsceneActive()
end

-- Check if a cutscene is currently playing
GlitchLib.Cutscene.IsPlaying = function()
    return IsCutscenePlaying()
end

-- Stop the current cutscene
GlitchLib.Cutscene.Stop = function(immediate)
    if IsCutsceneActive() then
        if immediate then
            StopCutsceneImmediately()
        else
            StopCutscene(true)
        end
        return true
    end
    return false
end

-- Get current cutscene time (in ms)
GlitchLib.Cutscene.GetTime = function()
    return GetCutsceneTime()
end

-- Skip to a specific time in the cutscene (in ms)
GlitchLib.Cutscene.SkipToTime = function(time)
    if IsCutsceneActive() then
        SkipCutsceneToTime(time)
        return true
    end
    return false
end