-- OVHL SERVER BOOTSTRAP V.1.0.1 - AUTO-DISCOVERY
print("🚀 [OVHL] Server bootstrap V.1.0.1 starting (Auto-Discovery)...")

local success, err = pcall(function()
	-- Wait for services folder
	local servicesFolder = script:WaitForChild("services")

	-- Initialize ServiceManager
	local ServiceManager = require(servicesFolder.ServiceManager)
	local serviceManager = setmetatable({}, ServiceManager)

	if not serviceManager:Init() then
		error("❌ ServiceManager failed to initialize!")
	end

	-- 🔥 AUTO-DISCOVER ALL SERVICES (Replaces manual registration)
	serviceManager:AutoDiscoverServices(servicesFolder)

	-- Manual data store registration (temporary)
	local DataService = serviceManager:GetService("DataService")
	DataService:RegisterDataStore("MainData", {
		coins = 1000,
		gems = 100,
		level = 1,
		experience = 0,
		inventory = {},
	})

	-- Start all services (ModuleLoader akan auto-start modules di sini)
	print("🚀 Starting services...")
	local servicesStarted = serviceManager:Start()

	if not servicesStarted then
		warn("⚠️ Some services failed to start, but continuing...")
	end

	-- ❌ HAPUS: JANGAN panggil ModuleLoader:Start() lagi di sini
	-- Karena sudah otomatis di-start oleh ServiceManager

	print("✅ [OVHL] Server bootstrap V.1.0.1 completed!")
	print("📊 Services: " .. serviceManager:GetServiceCount())

	return serviceManager
end)

if not success then
	warn("❌ [OVHL] Server bootstrap failed:", err)
end
