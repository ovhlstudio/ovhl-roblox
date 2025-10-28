-- OVHL Client Bootstrap v1.2.0
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🎮 [OVHL] Client bootstrap V.1.2.0 starting (Auto-Discovery)...")

-- Load OVHL Global Accessor
local success, OVHL = pcall(function()
    return require(ReplicatedStorage.OVHL_Shared.OVHL_Global)
end)

if not success then
    warn("⚠ [OVHL] OVHL Global Accessor not available: " .. tostring(OVHL))
else
    -- Expose OVHL globally for backward compatibility
    _G.OVHL = OVHL
    print("🔑 [OVHL] Global Accessor exposed via _G.OVHL")
end

print("✅ [OVHL] Client bootstrap V.1.2.0 completed successfully!")

-- Client modules will be auto-discovered by ClientController
-- and can now use both OVHL:GetService() and _G.OVHL:GetService()
