-- Utility function for ensuring safe module initialization
function GlitchLib.Utils.SafeModuleInit(moduleName, fn)
    if not GlitchLib then
        print("[CRITICAL ERROR] GlitchLib is not initialized! Cannot load " .. moduleName)
        return false
    end
    
    local success, err = pcall(fn)
    if not success then
        GlitchLib.Utils.DebugLog("Failed to initialize " .. moduleName .. ": " .. tostring(err))
        return false
    end
    
    return true
end