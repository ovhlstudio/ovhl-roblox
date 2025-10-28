-- ModuleLoader Service v1.0.0
-- Dynamic module loading with auto-discovery
local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

-- MANIFEST FOR AUTO-DISCOVERY
ModuleLoader.__manifest = {
    name = "ModuleLoader",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger", "EventBus", "ConfigService", "DataService", "RemoteManager"},
    autoload = true,
    priority = 50,
    description = "Dynamic module loading with auto-discovery"
}

function ModuleLoader:Init()
    self.modules = {}
    self.logger = nil
    self.configService = nil
    
    print("🔧 ModuleLoader v1 initialized (Auto-Discovery)")
    return true
end

function ModuleLoader:Start()
    -- Get services via OVHL pattern
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)
    
    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        self.configService = OVHL:GetService("ConfigService")
        self.eventBus = OVHL:GetService("EventBus")
        
        if self.logger then
            self.logger:Info("ModuleLoader started with OVHL integration")
        end
    end
    
    print("✅ ModuleLoader service started")
    return true
end

function ModuleLoader:AutoDiscoverModules(modulesFolder)
    if not modulesFolder then
        error("ModuleLoader: modulesFolder is required")
    end

    local discoveredCount = 0
    local loadedCount = 0

    -- Recursively find all ModuleScripts
    local function scanFolder(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("ModuleScript") then
                discoveredCount = discoveredCount + 1
                
                -- Safe module loading dengan pcall
                local success, result = pcall(function()
                    return self:LoadModule(child)
                end)
                
                if success then
                    loadedCount = loadedCount + 1
                    if self.logger then
                        self.logger:Debug("Module loaded successfully", {
                            module = child.Name,
                            path = child:GetFullName()
                        })
                    end
                else
                    if self.logger then
                        self.logger:Error("Module load failed", {
                            module = child.Name,
                            error = result,
                            path = child:GetFullName()
                        })
                    else
                        warn("❌ Module load failed: " .. child.Name .. " - " .. tostring(result))
                    end
                end
            elseif child:IsA("Folder") then
                scanFolder(child) -- Recursive scan
            end
        end
    end

    if self.logger then
        self.logger:Info("Starting module auto-discovery", {
            folder = modulesFolder:GetFullName()
        })
    end

    -- Start discovery
    scanFolder(modulesFolder)

    if self.logger then
        self.logger:Info("Module discovery completed", {
            discovered = discoveredCount,
            loaded = loadedCount,
            failed = discoveredCount - loadedCount
        })
    end

    return loadedCount > 0
end

function ModuleLoader:LoadModule(moduleScript)
    local module = require(moduleScript)
    
    if not module then
        error("Module returned nil: " .. moduleScript.Name)
    end

    -- Validate module has required structure
    if not module.__manifest then
        error("Module missing __manifest: " .. moduleScript.Name)
    end

    local moduleName = module.__manifest.name or moduleScript.Name

    -- ✅ FASE 3 FEATURE: Auto-register __config if present
    if module.__config and self.configService then
        local success, err = pcall(function()
            self.configService:RegisterDefaultConfig(moduleName, module.__config)
        end)
        
        if success then
            if self.logger then
                self.logger:Debug("Module config auto-registered", {
                    module = moduleName,
                    configKeys = table.concat(table.keys(module.__config), ", ")
                })
            end
        else
            if self.logger then
                self.logger:Warn("Module config registration failed", {
                    module = moduleName,
                    error = err
                })
            end
        end
    end

    -- Store module reference
    self.modules[moduleName] = {
        instance = module,
        script = moduleScript,
        manifest = module.__manifest,
        config = module.__config
    }

    -- Initialize module dengan pcall
    if module.Init then
        local success, err = pcall(module.Init, module)
        if not success then
            error("Module Init failed: " .. moduleName .. " - " .. tostring(err))
        end
    end

    -- Start module dengan pcall
    if module.Start then
        local success, err = pcall(module.Start, module)
        if not success then
            error("Module Start failed: " .. moduleName .. " - " .. tostring(err))
        end
    end

    -- Emit event untuk module loaded
    if self.eventBus then
        self.eventBus:Emit("ModuleLoaded", moduleName, module)
    end

    return module
end

function ModuleLoader:GetModule(moduleName)
    local moduleData = self.modules[moduleName]
    if moduleData then
        return moduleData.instance
    end
    return nil
end

function ModuleLoader:GetModuleInfo(moduleName)
    local moduleData = self.modules[moduleName]
    if moduleData then
        return {
            name = moduleName,
            manifest = moduleData.manifest,
            config = moduleData.config,
            script = moduleData.script,
            path = moduleData.script:GetFullName()
        }
    end
    return nil
end

function ModuleLoader:GetAllModules()
    local modules = {}
    for name, data in pairs(self.modules) do
        modules[name] = {
            manifest = data.manifest,
            config = data.config,
            path = data.script:GetFullName()
        }
    end
    return modules
end

return ModuleLoader
