-- StateManager v5 - Simple State
local StateManager = {}
StateManager.__index = StateManager

function StateManager:Init()
    self.state = {}
    self.listeners = {}
    print("🔧 StateManager initialized")
    return true
end

function StateManager:Start()
    print("🔄 StateManager started")
    return true
end

function StateManager:Set(key, value)
    local oldValue = self.state[key]
    self.state[key] = value
    
    if self.listeners[key] then
        for _, callback in ipairs(self.listeners[key]) do
            local success, err = pcall(callback, value, oldValue)
            if not success then
                warn("❌ State listener error:", err)
            end
        end
    end
    return true
end

function StateManager:Get(key, defaultValue)
    return self.state[key] or defaultValue
end

function StateManager:Subscribe(key, callback)
    if not self.listeners[key] then
        self.listeners[key] = {}
    end
    table.insert(self.listeners[key], callback)
    
    return function()
        self:Unsubscribe(key, callback)
    end
end

function StateManager:Unsubscribe(key, callback)
    if self.listeners[key] then
        for i, cb in ipairs(self.listeners[key]) do
            if cb == callback then
                table.remove(self.listeners[key], i)
                break
            end
        end
    end
end

return StateManager
