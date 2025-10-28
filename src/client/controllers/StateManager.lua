-- StateManager v1.3.0 - Complete Enhanced Debugging
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local StateManager = {}
StateManager.__index = StateManager

StateManager.__manifest = {
    name = "StateManager",
    version = "1.3.0",
    type = "controller",
    priority = 90,
    domain = "state",
    description = "State management with complete enhanced debugging"
}

function StateManager:Init()
    self._states = {}
    self._subscribers = {}
    print("✅ StateManager Initialized with Enhanced Debugging")
    return true
end

function StateManager:Start()
    print("✅ StateManager Started")
    return true
end

function StateManager:Set(key, value)
    print("🎯 StateManager:Set ENHANCED DEBUG")
    print("  📌 Key:", key)
    print("  📌 Value:", value)
    print("  📌 Old Value:", self._states[key])
    local oldValue = self._states[key]
    self._states[key] = value
    print("  💾 State stored:", key, "=", value)
    print("  🔍 Subscription Check for:", key)
    if self._subscribers[key] then
        local count = #self._subscribers[key]
        print("  🔔 Found", count, "subscribers for", key)
        for i, callback in ipairs(self._subscribers[key]) do
            print("  📨 Executing subscriber", i, "/", count)
            local success, err = pcall(callback, value, oldValue)
            if not success then
                warn("  ❌ Subscriber error:", err)
            else
                print("  ✅ Subscriber", i, "executed successfully")
            end
        end
    else
        print("  ℹ️ No subscribers for", key)
    end
    return true
end

function StateManager:Get(key, defaultValue)
    local value = self._states[key]
    if value == nil then
        return defaultValue
    end
    return value
end

function StateManager:Subscribe(key, callback)
    print("🎯 StateManager:Subscribe ENHANCED DEBUG")
    print("  📌 Key:", key)
    print("  📌 Callback type:", type(callback))
    if not self._subscribers[key] then
        self._subscribers[key] = {}
        print("  📋 Created new subscriber list for", key)
    end
    table.insert(self._subscribers[key], callback)
    local count = #self._subscribers[key]
    print("  ➕ Added subscriber to", key)
    print("  📊 Total subscribers for", key .. ":", count)
    return function()
        print("🎯 Unsubscribing from", key)
        if self._subscribers[key] then
            for i, cb in ipairs(self._subscribers[key]) do
                if cb == callback then
                    table.remove(self._subscribers[key], i)
                    print("  ➖ Removed subscriber from", key)
                    print("  📊 Remaining:", #self._subscribers[key])
                    break
                end
            end
        end
    end
end

return StateManager
