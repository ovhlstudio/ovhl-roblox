-- EventBus Service v1.0.0
-- Event-driven communication system for internal server events
local EventBus = {}
EventBus.__index = EventBus

-- MANIFEST FOR AUTO-DISCOVERY
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
    self.events = {}
    self.subscriptionId = 0
    
    -- ✅ USING OVHL INSTEAD OF MANUAL REQUIRE
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)
    
    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        if self.logger then
            self.logger:Info("EventBus initialized with OVHL integration")
        else
            print("🔧 EventBus initialized (Logger service pending)")
        end
    else
        print("🔧 EventBus initialized (OVHL not available)")
    end
    
    return true
end

function EventBus:Start()
    if self.logger then
        self.logger:Info("EventBus service started")
    else
        print("✅ EventBus service started")
    end
    return true
end

-- Emit an event to all subscribers
function EventBus:Emit(eventName, ...)
    if not self.events[eventName] then
        return 0
    end

    local args = {...}
    local subscriberCount = 0
    
    for id, callback in pairs(self.events[eventName]) do
        subscriberCount = subscriberCount + 1
        
        -- ✅ FASE 3: ENHANCED ERROR HANDLING
        local success, result = pcall(function()
            return callback(unpack(args))
        end)
        
        if not success then
            if self.logger then
                self.logger:Error("EventBus callback failed: " .. eventName, {
                    error = result,
                    subscriptionId = id
                })
            else
                warn("⚠ EventBus callback failed: " .. eventName .. " - " .. tostring(result))
            end
        end
    end

    return subscriberCount
end

-- Subscribe to an event
function EventBus:Subscribe(eventName, callback)
    if not self.events[eventName] then
        self.events[eventName] = {}
    end

    self.subscriptionId = self.subscriptionId + 1
    local subscriptionId = self.subscriptionId
    
    self.events[eventName][subscriptionId] = callback

    if self.logger then
        self.logger:Debug("Event subscription created", {
            event = eventName,
            subscriptionId = subscriptionId
        })
    end

    -- Return unsubscribe function
    return function()
        if self.events[eventName] then
            self.events[eventName][subscriptionId] = nil
            
            -- Clean up empty event tables
            if next(self.events[eventName]) == nil then
                self.events[eventName] = nil
            end
            
            if self.logger then
                self.logger:Debug("Event subscription removed", {
                    event = eventName,
                    subscriptionId = subscriptionId
                })
            end
        end
    end
end

-- Unsubscribe from an event
function EventBus:Unsubscribe(eventName, callback)
    if not self.events[eventName] then
        return false
    end

    for id, cb in pairs(self.events[eventName]) do
        if cb == callback then
            self.events[eventName][id] = nil
            
            -- Clean up empty event tables
            if next(self.events[eventName]) == nil then
                self.events[eventName] = nil
            end
            
            if self.logger then
                self.logger:Debug("Event subscription removed via Unsubscribe", {
                    event = eventName,
                    subscriptionId = id
                })
            end
            
            return true
        end
    end

    return false
end

-- Get event statistics
function EventBus:GetStats()
    local stats = {
        totalEvents = 0,
        totalSubscriptions = 0,
        events = {}
    }

    for eventName, subscriptions in pairs(self.events) do
        stats.totalEvents = stats.totalEvents + 1
        local subCount = 0
        for _ in pairs(subscriptions) do
            subCount = subCount + 1
        end
        stats.totalSubscriptions = stats.totalSubscriptions + subCount
        stats.events[eventName] = subCount
    end

    return stats
end

return EventBus
