-- Utility function for ensuring safe module initialization
function GlitchAbst.Utils.SafeModuleInit(moduleName, fn)
    if not GlitchAbst then
        print("[CRITICAL ERROR] GlitchAbst is not initialized! Cannot load " .. moduleName)
        return false
    end

    local success, err = pcall(fn)
    if not success then
        GlitchAbst.Utils.DebugLog("Failed to initialize " .. moduleName .. ": " .. tostring(err))
        return false
    end

    return true
end

-- True when a resource is running. 'starting' counts: a resource that is part way
-- through its own start (or one that depends on us) already has its exports.
function GlitchAbst.Utils.IsStarted(resourceName)
    if not resourceName then return false end
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

-- Load and run one module file from this resource exactly as a script would run.
-- Returns loaded (bool), result-or-error.
-- A module that returns false means "not for this server" (wrong framework, missing
-- resource); that counts as not loaded. Any other return value counts as loaded.
function GlitchAbst.Utils.LoadModule(path)
    local src = LoadResourceFile(GetCurrentResourceName(), path)
    if not src then
        return false, 'module file not found: ' .. path
    end

    local fn, loadErr = load(src, '@' .. GetCurrentResourceName() .. '/' .. path)
    if not fn then
        return false, 'syntax error in ' .. path .. ': ' .. tostring(loadErr)
    end

    local ok, result = pcall(fn)
    if not ok then
        return false, 'error running ' .. path .. ': ' .. tostring(result)
    end

    if result == false then
        return false, path .. ' skipped itself (not for this server)'
    end

    return true, result
end

-- Money arguments: modules accept both (source, amount) and (source, account, amount)
-- so the same call works on every framework. Returns account (or nil), amount.
function GlitchAbst.Utils.MoneyArgs(a, b)
    if type(a) == 'string' and tonumber(a) == nil then
        return a, tonumber(b)
    end
    return nil, tonumber(a)
end

-- True when the cutscene tools (stream and admin modules) should load: Config.Cutscenes.Enabled
-- is true, or 'auto' with glitch-mapHandler installed.
function GlitchAbst.Utils.CutscenesEnabled()
    local c = Config.Cutscenes and Config.Cutscenes.Enabled
    if c == nil or c == 'auto' then
        return GetResourceState('glitch-mapHandler') ~= 'missing'
    end
    return c == true
end

-- Money arguments must be finite numbers; fractions are floored.
local rawMoneyArgs = GlitchAbst.Utils.MoneyArgs
function GlitchAbst.Utils.MoneyArgs(a, b)
    local account, amount = rawMoneyArgs(a, b)
    if amount and (amount ~= amount or amount == math.huge or amount == -math.huge) then amount = nil end
    if amount then amount = math.floor(amount) end
    return account, amount
end

-- Framework detection. Qbox (qbx_core) provides 'qb-core' and ships a QBCore
-- compatible object, so it uses the QBCore modules; GlitchAbst.IsQbox tells them apart.
local function Running(resourceName)
    local state = GetResourceState(resourceName)
    return state == 'started' or state == 'starting'
end

function GlitchAbst.Utils.DetectFramework()
    local configFramework = Config.UseFramework
    GlitchAbst.IsQbox = Running('qbx_core')

    if configFramework and configFramework ~= 'auto' then
        if configFramework == 'QBox' or configFramework == 'Qbox' then configFramework = 'QBCore' end
        GlitchAbst.Utils.DebugLog('Using configured framework: ' .. configFramework)
        return configFramework
    end

    local detected
    if Running('es_extended') then
        detected = 'ESX'
    elseif Running('qbx_core') or Running('qb-core') then
        detected = 'QBCore'
    end

    if detected then
        GlitchAbst.Utils.DebugLog('Auto-detected framework: ' .. detected .. (GlitchAbst.IsQbox and ' (Qbox)' or ''))
    else
        GlitchAbst.Utils.DebugLog('WARNING: No supported framework detected yet')
        detected = 'unknown'
    end

    return detected
end

function GlitchAbst.Utils.DetectUISystem()
    local configUI = Config.UISystem or 'auto'
    local detected

    if configUI ~= 'auto' then
        GlitchAbst.Utils.DebugLog('Using configured UI system: ' .. configUI)
        return configUI
    end

    for _, ui in ipairs(Config.UI or {}) do
        if Running(ui.resourceName) then
            detected = ui.name
            break
        end
    end

    -- Fall back to the detected framework if no UI system is found
    if not detected and GlitchAbst.FrameworkName and GlitchAbst.FrameworkName ~= 'unknown' then
        detected = GlitchAbst.FrameworkName == 'QBCore' and 'qb' or string.lower(GlitchAbst.FrameworkName)
    end

    if not detected then
        GlitchAbst.Utils.DebugLog('WARNING: No UI system detected, using default')
        detected = 'ox'
    end
    return detected
end

-- Detected once at load (the cores detect again if the framework was not running yet)
GlitchAbst.FrameworkName = GlitchAbst.Utils.DetectFramework()
GlitchAbst.UISystem = GlitchAbst.Utils.DetectUISystem()
