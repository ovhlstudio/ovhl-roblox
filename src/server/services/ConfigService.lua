-- ConfigService v5 - Simple Config
local ConfigService = {}
ConfigService.__index = ConfigService

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
