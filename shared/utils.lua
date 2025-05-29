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