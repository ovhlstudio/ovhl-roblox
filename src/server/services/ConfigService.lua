-- ConfigService v1.0.0
-- Configuration management service
local ConfigService = {}
ConfigService.__index = ConfigService

-- MANIFEST FOR AUTO-DISCOVERY
ConfigService.__manifest = {
    name = "ConfigService",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 90,
    description = "Configuration management service"
}

function ConfigService:Init()
    self.configs = {}
    
    -- Get Logger via OVHL pattern
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)
    
    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        if self.logger then
            self.logger:Info("ConfigService initialized with OVHL")
        end
    end
    
    print("🔧 ConfigService initialized")
    return true
end

function ConfigService:Start()
    if self.logger then
        self.logger:Info("ConfigService started")
    else
        print("✅ ConfigService started")
    end
    return true
end

function ConfigService:RegisterDefaultConfig(moduleName, configTable)
    if not self.configs[moduleName] then
        self.configs[moduleName] = configTable
        
        if self.logger then
            self.logger:Debug("Default config registered", {
                module = moduleName,
                configKeys = table.concat(table.keys(configTable), ", ")
            })
        end
        return true
    end
    return false
end

function ConfigService:Get(moduleName, defaultValue)
    local config = self.configs[moduleName]
    
    if config then
        if self.logger then
            self.logger:Debug("Config retrieved", {
                module = moduleName,
                hasConfig = true
            })
        end
        return config
    end
    
    if self.logger then
        self.logger:Debug("Config not found, using default", {
            module = moduleName,
            hasConfig = false
        })
    end
    
    return defaultValue or {}
end

function ConfigService:Set(moduleName, value)
    self.configs[moduleName] = value
    
    if self.logger then
        self.logger:Info("Config updated", {
            module = moduleName
        })
    end
    return true
end

function ConfigService:GetAllConfigs()
    return self.configs
end

return ConfigService
