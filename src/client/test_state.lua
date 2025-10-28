-- State Test Script
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

-- Wait for OVHL to be ready
while not OVHL:IsReady() do
    wait(0.1)
end

print("🧪 STATE MANAGEMENT TEST")
print("Initial coins:", OVHL:GetState("coins", 0))
print("Initial health:", OVHL:GetState("health", 100))

-- Test state subscription
OVHL:Subscribe("coins", function(newValue)
    print("🎯 STATE SUBSCRIPTION TRIGGERED - Coins:", newValue)
end)

-- Test setting state
print("Setting coins to 50...")
OVHL:SetState("coins", 50)

print("Setting health to 75...") 
OVHL:SetState("health", 75)

print("✅ State test completed")
