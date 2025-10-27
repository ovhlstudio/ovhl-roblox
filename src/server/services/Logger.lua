-- Logger v5 - Simple & Effective
local Logger = {}
Logger.__index = Logger

function Logger:Init()
    print("🔧 Logger initialized")
    return true
end

function Logger:Start()
    print("📝 Logger started")
    return true
end

function Logger:Log(level, message, data)
    local logEntry = string.format("[%s] %s: %s", level, os.date("%H:%M:%S"), message)
    print(logEntry)
    return true
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

return Logger
