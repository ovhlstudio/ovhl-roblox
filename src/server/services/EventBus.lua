-- EventBus v1 - Simple Event System
local EventBus = {}
EventBus.__index = EventBus

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
EventBus.__manifest = {
    name = "EventBus",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 95,
    description = "Event-driven communication system"
}

function EventBus:Init()
    self.listeners = {}
    print("🔧 EventBus initialized")
    return true
end

function EventBus:Start()
    print("📡 EventBus started")
    return true
end

function EventBus:Subscribe(eventName, callback)
    if not self.listeners[eventName] then
        self.listeners[eventName] = {}
    end
    
    table.insert(self.listeners[eventName], callback)
    
    return function()
        self:Unsubscribe(eventName, callback)
    end
end

function EventBus:Emit(eventName, ...)
    local args = {...}
    if self.listeners[eventName] then
        for _, callback in ipairs(self.listeners[eventName]) do
            local success, err = pcall(function()
                callback(unpack(args))
            end)
            if not success then
                warn("❌ Event callback failed:", eventName, err)
            end
        end
    end
    return true
end

function EventBus:Unsubscribe(eventName, callback)
    if self.listeners[eventName] then
        for i, cb in ipairs(self.listeners[eventName]) do
            if cb == callback then
                table.remove(self.listeners[eventName], i)
                break
            end
        end
    end
end

return EventBus
