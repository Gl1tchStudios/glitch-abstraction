-- Safety check for GlitchAbst
if not GlitchAbst or not GlitchAbst.Utils then
    print("^1[ERROR] GlitchAbst not initialized before loading cutscene module^7")
    return false
end

-- Initialize cutscene namespace
GlitchAbst.Cutscene = GlitchAbst.Cutscene or {}

GlitchAbst.Utils.DebugLog('Cutscene module loaded')

local playerAppearance = {}

-- Save player appearance
GlitchAbst.Cutscene.SavePlayerAppearance = function()
    local ped = PlayerPedId()
    
    playerAppearance = {
        mask = {GetPedDrawableVariation(ped, 1), GetPedTextureVariation(ped, 1), GetPedPaletteVariation(ped, 1)},
        hair = {GetPedDrawableVariation(ped, 2), GetPedTextureVariation(ped, 2), GetPedPaletteVariation(ped, 2)},
        arms = {GetPedDrawableVariation(ped, 3), GetPedTextureVariation(ped, 3), GetPedPaletteVariation(ped, 3)},
        
        pants = {GetPedDrawableVariation(ped, 4), GetPedTextureVariation(ped, 4), GetPedPaletteVariation(ped, 4)},
        bag = {GetPedDrawableVariation(ped, 5), GetPedTextureVariation(ped, 5), GetPedPaletteVariation(ped, 5)},
        feet = {GetPedDrawableVariation(ped, 6), GetPedTextureVariation(ped, 6), GetPedPaletteVariation(ped, 6)},
        shirt = {GetPedDrawableVariation(ped, 8), GetPedTextureVariation(ped, 8), GetPedPaletteVariation(ped, 8)},
        vest = {GetPedDrawableVariation(ped, 9), GetPedTextureVariation(ped, 9), GetPedPaletteVariation(ped, 9)},
        decals = {GetPedDrawableVariation(ped, 10), GetPedTextureVariation(ped, 10), GetPedPaletteVariation(ped, 10)},
        jacket = {GetPedDrawableVariation(ped, 11), GetPedTextureVariation(ped, 11), GetPedPaletteVariation(ped, 11)},
        
        hat = {GetPedPropIndex(ped, 0), GetPedPropTextureIndex(ped, 0)},
        glasses = {GetPedPropIndex(ped, 1), GetPedPropTextureIndex(ped, 1)},
        ear = {GetPedPropIndex(ped, 2), GetPedPropTextureIndex(ped, 2)},
        watch = {GetPedPropIndex(ped, 6), GetPedPropTextureIndex(ped, 6)},
        bracelet = {GetPedPropIndex(ped, 7), GetPedPropTextureIndex(ped, 7)}
    }
    
    return playerAppearance
end

-- Restore player appearance
GlitchAbst.Cutscene.RestorePlayerAppearance = function()
    if not playerAppearance or next(playerAppearance) == nil then
        GlitchAbst.Utils.DebugLog('No saved appearance to restore')
        return false
    end
    
    local ped = PlayerPedId()
    
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
    
    SetPedPropIndex(ped, 0, playerAppearance.hat[1], playerAppearance.hat[2], true)
    SetPedPropIndex(ped, 1, playerAppearance.glasses[1], playerAppearance.glasses[2], true)
    SetPedPropIndex(ped, 2, playerAppearance.ear[1], playerAppearance.ear[2], true)
    SetPedPropIndex(ped, 6, playerAppearance.watch[1], playerAppearance.watch[2], true)
    SetPedPropIndex(ped, 7, playerAppearance.bracelet[1], playerAppearance.bracelet[2], true)
    
    return true
end

-- Play a cutscene with customization options
-- Online cutscenes (name starts with "mp_") are auto-detected: flags are
-- forced to 8 (multiplayer context) and the streaming sphere is pre-loaded
-- so GTA can resolve all the online content assets before RequestCutscene.
GlitchAbst.Cutscene.Play = function(cutsceneName, options)
    options = options or {}
    
    -- Determine whether this is an online cutscene (mp_ prefix)
    local isOnline = cutsceneName:sub(1, 3) == "mp_"

    -- Default options
    local config = {
        saveAppearance = options.saveAppearance ~= false, -- Default true
        restoreAppearance = options.restoreAppearance ~= false, -- Default true
        hidePlayer = options.hidePlayer or false,
        -- hideSlots: list of slot names (e.g. {"MP_2","MP_3","MP_4"}) to suppress by
        -- registering invisible dummy peds so GTA doesn't spawn default bald characters.
        hideSlots = options.hideSlots or {},
        -- Online cutscenes must use flags = 8 (multiplayer context); override if caller forces a value
        flags = options.flags or (isOnline and 8 or 0),
        customEntities = options.customEntities or {},
        onStart = options.onStart,
        onEnd = options.onEnd,
        -- Give online cutscenes extra time to stream in
        timeoutMs = options.timeoutMs or (isOnline and 20000 or 10000)
    }
    
    GlitchAbst.Utils.DebugLog('Playing cutscene: ' .. cutsceneName .. (isOnline and ' [online, flags=8]' or ''))
    
    if IsCutsceneActive() then
        StopCutsceneImmediately()
    end
    
    -- Save player appearance if needed
    if config.saveAppearance then
        GlitchAbst.Cutscene.SavePlayerAppearance()
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
        GlitchAbst.Utils.DebugLog('Cutscene failed to load (timeout): ' .. cutsceneName)
        if config.onEnd then config.onEnd(false) end
        return false
    end

    GlitchAbst.Utils.DebugLog('Cutscene loaded OK, registering entities and starting...')
    local playerPed = PlayerPedId()

    -- For each slot in hideSlots: create an invisible dummy ped and register it
    -- so GTA uses our invisible ped instead of spawning a default bald character.
    local dummyPeds = {}
    if #config.hideSlots > 0 then
        local dummyModel = GetHashKey('mp_m_freemode_01')
        RequestModel(dummyModel)
        local mwait = 0
        while not HasModelLoaded(dummyModel) and mwait < 3000 do
            Citizen.Wait(100)
            mwait = mwait + 100
        end
        local coords = GetEntityCoords(playerPed)
        for _, slotName in ipairs(config.hideSlots) do
            local dummy = CreatePed(4, dummyModel, coords.x, coords.y, coords.z - 200, 0, false, true)
            SetEntityVisible(dummy, false, false)
            SetEntityCollision(dummy, false, false)
            FreezeEntityPosition(dummy, true)
            RegisterEntityForCutscene(dummy, slotName, 0, dummyModel, 64)
            table.insert(dummyPeds, dummy)
            GlitchAbst.Utils.DebugLog('Registered invisible dummy for slot: ' .. slotName)
        end
        SetModelAsNoLongerNeeded(dummyModel)
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
    
    if config.hidePlayer then
        NetworkSetEntityInvisibleToNetwork(playerPed, true)
    end
    
    StartCutscene(0)
    GlitchAbst.Utils.DebugLog('StartCutscene called, waiting for MP_1 entity...')
    
    local entityTimeout = GetGameTimer() + 5000
    while not (DoesCutsceneEntityExist('MP_1', 0)) and GetGameTimer() < entityTimeout do
        Citizen.Wait(0)
    end

    if not DoesCutsceneEntityExist('MP_1', 0) then
        GlitchAbst.Utils.DebugLog('WARNING: MP_1 entity never appeared — cutscene may still be playing')
    else
        GlitchAbst.Utils.DebugLog('MP_1 entity found, cutscene is running')
    end
    
    if config.onStart then
        config.onStart()
    end
    
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
        while not IsCutscenePlaying() do
            Citizen.Wait(0)
            if not IsCutsceneActive() then return end
        end
        
        while IsCutscenePlaying() do
            Citizen.Wait(0)
            
            if config.restoreAppearance then
                SetCutscenePedComponentVariationFromPed(PlayerPedId(), PlayerPedId(), 1885233650)
                
                if playerAppearance.mask then SetPedComponentVariation(playerPed, 1, playerAppearance.mask[1], playerAppearance.mask[2], playerAppearance.mask[3]) end
                if playerAppearance.hair then SetPedComponentVariation(playerPed, 2, playerAppearance.hair[1], playerAppearance.hair[2], playerAppearance.hair[3]) end
                if playerAppearance.arms then SetPedComponentVariation(playerPed, 3, playerAppearance.arms[1], playerAppearance.arms[2], playerAppearance.arms[3]) end
                if playerAppearance.pants then SetPedComponentVariation(playerPed, 4, playerAppearance.pants[1], playerAppearance.pants[2], playerAppearance.pants[3]) end
                if playerAppearance.feet then SetPedComponentVariation(playerPed, 6, playerAppearance.feet[1], playerAppearance.feet[2], playerAppearance.feet[3]) end
                if playerAppearance.shirt then SetPedComponentVariation(playerPed, 8, playerAppearance.shirt[1], playerAppearance.shirt[2], playerAppearance.shirt[3]) end
                if playerAppearance.vest then SetPedComponentVariation(playerPed, 9, playerAppearance.vest[1], playerAppearance.vest[2], playerAppearance.vest[3]) end
                if playerAppearance.jacket then SetPedComponentVariation(playerPed, 11, playerAppearance.jacket[1], playerAppearance.jacket[2], playerAppearance.jacket[3]) end
                
                if playerAppearance.hat then SetPedPropIndex(playerPed, 0, playerAppearance.hat[1], playerAppearance.hat[2], true) end
                if playerAppearance.glasses then SetPedPropIndex(playerPed, 1, playerAppearance.glasses[1], playerAppearance.glasses[2], true) end
            end
        end
        
        -- Cleanup after cutscene finishes
        if config.hidePlayer then
            NetworkSetEntityInvisibleToNetwork(playerPed, false)
        end

        -- Delete dummy peds that were registered to suppress unused slots
        for _, dummy in ipairs(dummyPeds) do
            if DoesEntityExist(dummy) then
                DeleteEntity(dummy)
            end
        end

        -- Call onEnd callback if provided
        if config.onEnd then
            config.onEnd(true)
        end
    end)
    
    return true
end

-- Checks if a cutscene is currently active
GlitchAbst.Cutscene.IsActive = function()
    return IsCutsceneActive()
end

-- Checks if a cutscene is currently playing
GlitchAbst.Cutscene.IsPlaying = function()
    return IsCutscenePlaying()
end

-- Stop the current cutscene
GlitchAbst.Cutscene.Stop = function(immediate)
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
GlitchAbst.Cutscene.GetTime = function()
    return GetCutsceneTime()
end

-- Skip to a specific time in the cutscene (in ms)
GlitchAbst.Cutscene.SkipToTime = function(time)
    if IsCutsceneActive() then
        SkipCutsceneToTime(time)
        return true
    end
    return false
end