-- ConfigService v1 - Simple Config
local ConfigService = {}
ConfigService.__index = ConfigService

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
ConfigService.__manifest = {
    name = "ConfigService",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 90,
    description = "Configuration management service"
}

function ConfigService:Init()
    self.configs = {}
    print("🔧 ConfigService initialized")
    return true
end

function ConfigService:Start()
    print("⚙️ ConfigService started")
    return true
end

function ConfigService:Set(configPath, value)
    self.configs[configPath] = value
    return true
end

function ConfigService:Get(configPath, defaultValue)
    return self.configs[configPath] or defaultValue
end

return ConfigService
