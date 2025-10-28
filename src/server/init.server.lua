-- OVHL Server Bootstrap v1.2.0
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🚀 [OVHL] Server bootstrap V.1.2.0 starting (Auto-Discovery)...")

-- Load OVHL Global Accessor first
local ovhlSuccess, OVHL = pcall(function()
	return require(ReplicatedStorage.OVHL_Shared.OVHL_Global)
end)

if not ovhlSuccess then
	warn("⚠ [OVHL] OVHL Global Accessor not available: " .. tostring(OVHL))
else
	-- Expose OVHL globally for backward compatibility (Selene allows this for framework core)
	_G.OVHL = OVHL
	print("🔑 [OVHL] Global Accessor exposed via _G.OVHL")
end

-- Load ServiceManager
local ServiceManager = require(ServerScriptService.OVHL_Server.services.ServiceManager)

-- Initialize ServiceManager
local success, err = pcall(function()
	ServiceManager:Init()
end)

if not success then
	error("❌ [OVHL] ServiceManager Init failed: " .. tostring(err))
end

print("🔍 [OVHL] Auto-discovering services...")

-- Auto-discover and load services
success, err = pcall(function()
	ServiceManager:AutoDiscoverServices(ServerScriptService.OVHL_Server.services)
end)

if not success then
	error("❌ [OVHL] Service discovery failed: " .. tostring(err))
end

print("✅ [OVHL] Server bootstrap V.1.2.0 completed!")
