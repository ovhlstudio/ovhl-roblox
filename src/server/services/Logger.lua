-- Logger v1 - Simple & Effective
local Logger = {}
Logger.__index = Logger

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
Logger.__manifest = {
    name = "Logger",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core logging service for structured logging"
}

function Logger:Init()
    print("🔧 Logger initialized")
    return true
end

function Logger:Start()
    print("📝 Logger started")
    return true
end

function Logger:Log(level, message, _data)
    local logEntry = string.format("[%s] %s: %s", level, os.date("%H:%M:%S"), message)
    print(logEntry)
    return true
end

function Logger:Info(message, _data)
    return self:Log("INFO", message, _data)
end

function Logger:Warn(message, _data)
    return self:Log("WARN", message, _data)
end

function Logger:Error(message, _data)
    return self:Log("ERROR", message, _data)
end

return Logger
