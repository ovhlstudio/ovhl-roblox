-- Logger Service v1.0.0
-- Core logging service for structured logging
local Logger = {}
Logger.__index = Logger

-- MANIFEST FOR AUTO-DISCOVERY
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
    self.levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4
    }
    
    self.currentLevel = self.levels.INFO
    print("🔧 Logger initialized with OVHL pattern")
    return true
end

function Logger:Start()
    print("✅ Logger service started")
    return true
end

function Logger:Log(level, message, data)
    if self.levels[level] < self.currentLevel then
        return false
    end

    local timestamp = DateTime.now():FormatLocalTime("LTS", "en-US")
    local logEntry = string.format("[%s] %s: %s", timestamp, level, message)
    
    if data then
        logEntry = logEntry .. " | " .. game:GetService("HttpService"):JSONEncode(data)
    end
    
    print(logEntry)
    return true
end

function Logger:Debug(message, data)
    return self:Log("DEBUG", message, data)
end

function Logger:Info(message, data)
    return self:Log("INFO", message, data)
end

function Logger:Warn(message, data)
    return self:Log("WARN", message, data)
end

function Logger:Error(message, data)
    return self:Log("ERROR", message, data)
end

function Logger:SetLogLevel(level)
    if self.levels[level] then
        self.currentLevel = self.levels[level]
        return true
    end
    return false
end

function Logger:GetLogLevel()
    for name, value in pairs(self.levels) do
        if value == self.currentLevel then
            return name
        end
    end
    return "UNKNOWN"
end

return Logger
