-- TestClientModule v1.0.1 - Better Error Handling
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local TestClientModule = {}
TestClientModule.__index = TestClientModule

TestClientModule.__manifest = {
    name = "TestClientModule",
    version = "1.0.1",
    type = "module",
    domain = "test",
    dependencies = {"StateManager", "RemoteClient"}
}

function TestClientModule:Start()
    print("🧪 TestClientModule Starting...")
    
    -- Wait a bit for RemoteClient to be fully ready
    wait(1)
    
    -- Test all OVHL Client APIs with better error handling
    self:TestStateManagement()
    self:TestNetworkCommunication()
    
    print("✅ TestClientModule Started")
end

function TestClientModule:TestStateManagement()
    print("🧪 Testing State Management...")
    
    -- Test SetState
    OVHL:SetState("test_coins", 100)
    OVHL:SetState("test_health", 50)
    
    -- Test GetState
    local coins = OVHL:GetState("test_coins", 0)
    local health = OVHL:GetState("test_health", 100)
    
    print("🧪 State Test - Coins:", coins, "Health:", health)
    
    -- Test Subscribe
    OVHL:Subscribe("test_coins", function(newValue)
        print("🧪 State Subscription - Coins changed to:", newValue)
    end)
    
    -- Trigger change
    OVHL:SetState("test_coins", 200)
end

function TestClientModule:TestNetworkCommunication()
    print("🧪 Testing Network Communication...")
    
    -- Test Fire (async) with error handling
    local fireSuccess, fireErr = pcall(function()
        OVHL:Fire("ClientTestEvent", "Fire test from client")
    end)
    
    if fireSuccess then
        print("🧪 Network Test - Fire: SUCCESS")
    else
        print("🧪 Network Test - Fire failed:", fireErr)
    end
    
    -- Test Invoke (sync) with error handling
    local invokeSuccess, invokeResult = pcall(function()
        return OVHL:Invoke("ClientTestInvoke", "Invoke test from client")
    end)
    
    if invokeSuccess then
        print("🧪 Network Test - Invoke result:", invokeResult)
    else
        print("🧪 Network Test - Invoke failed:", invokeResult)
    end
    
    -- Test Listen with error handling
    local listenSuccess, listenErr = pcall(function()
        OVHL:Listen("ServerTestEvent", function(message)
            print("🧪 Network Test - Received from server:", message)
        end)
    end)
    
    if listenSuccess then
        print("🧪 Network Test - Listen: SUCCESS")
    else
        print("🧪 Network Test - Listen failed:", listenErr)
    end
end

return TestClientModule
