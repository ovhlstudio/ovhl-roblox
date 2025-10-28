-- StateManager v1.2.0 - Debug Version
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local StateManager = {}
StateManager.__index = StateManager

-- Auto-discovery manifest
StateManager.__manifest = {
    name = "StateManager",
    version = "1.2.0",
    type = "controller",
    priority = 90,
    domain = "state",
    description = "Client-side state management"
}

function StateManager:Init()
    self._states = {}
    self._subscribers = {}
    print("✅ StateManager Initialized")
    return true
end

function StateManager:Start()
    print("✅ StateManager Started")
    return true
end

-- OVHL API: Set state value
function StateManager:Set(key, value)
    print("🎯 StateManager:Set called - Key:", key, "Value:", value)
    
    local oldValue = self._states[key]
    self._states[key] = value
    
    print("📊 State stored -", key, "=", value)
    
    -- Notify subscribers
    if self._subscribers[key] then
        print("🔔 Notifying", #self._subscribers[key], "subscribers for", key)
        for i, callback in ipairs(self._subscribers[key]) do
            print("  📨 Calling subscriber", i, "for", key)
            local success, err = pcall(callback, value, oldValue)
            if not success then
                warn("❌ StateManager callback error: " .. tostring(err))
            else
                print("  ✅ Subscriber", i, "executed successfully")
            end
        end
    else
        print("ℹ️ No subscribers for", key)
    end
    
    return true
end

-- OVHL API: Get state value
function StateManager:Get(key, defaultValue)
    local value = self._states[key]
    if value == nil then
        return defaultValue
    end
    return value
end

-- OVHL API: Subscribe to state changes
function StateManager:Subscribe(key, callback)
    print("🎯 StateManager:Subscribe called - Key:", key)
    
    if not self._subscribers[key] then
        self._subscribers[key] = {}
        print("  📋 Created new subscriber list for", key)
    end
    
    table.insert(self._subscribers[key], callback)
    print("  ➕ Added subscriber to", key, "- Total:", #self._subscribers[key])
    
    -- Return unsubscribe function
    return function()
        print("🎯 Unsubscribing from", key)
        if self._subscribers[key] then
            for i, cb in ipairs(self._subscribers[key]) do
                if cb == callback then
                    table.remove(self._subscribers[key], i)
                    print("  ➖ Removed subscriber from", key, "- Remaining:", #self._subscribers[key])
                    break
                end
            end
        end
    end
end

return StateManager
