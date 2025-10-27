-- ModuleLoader v5 - Simple Loading
local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader:Init()
    self.modules = {}
    print("🔧 ModuleLoader initialized")
    return true
end

function ModuleLoader:Start()
    print("📦 Loading modules...")
    
    local modulesFolder = script.Parent.Parent:FindFirstChild("modules")
    if not modulesFolder then
        print("ℹ️ No modules folder found")
        return true
    end
    
    for _, moduleScript in ipairs(modulesFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, module = pcall(require, moduleScript)
            if success and module then
                self.modules[moduleScript.Name] = module
                print("✅ Module loaded:", moduleScript.Name)
                
                if module.Start then
                    local startSuccess = pcall(module.Start, module)
                    if startSuccess then
                        print("✅ Module started:", moduleScript.Name)
                    end
                end
            else
                warn("❌ Failed to load module:", moduleScript.Name, module)
            end
        end
    end
    
    print("🎉 ModuleLoader completed")
    return true
end

return ModuleLoader
