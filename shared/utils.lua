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
