-- OVHL SERVER BOOTSTRAP v5 - FIXED STRUCTURE
print("🚀 [OVHL] Server bootstrap starting...")

local success, err = pcall(function()
    -- WAIT FOR SERVICES FOLDER
    local servicesFolder = script:WaitForChild("services")
    
    -- Initialize ServiceManager first
    local ServiceManager = require(servicesFolder.ServiceManager)
    local serviceManager = setmetatable({}, ServiceManager)
    
    if not serviceManager:Init() then
        error("❌ ServiceManager failed to initialize!")
    end
    
    -- Register all services
    print("🔧 Registering services...")
    
    serviceManager:RegisterService("Logger", require(servicesFolder.Logger))
    serviceManager:RegisterService("EventBus", require(servicesFolder.EventBus))
    serviceManager:RegisterService("ConfigService", require(servicesFolder.ConfigService))
    serviceManager:RegisterService("DataService", require(servicesFolder.DataService))
    serviceManager:RegisterService("RemoteManager", require(servicesFolder.RemoteManager))
    serviceManager:RegisterService("ModuleLoader", require(servicesFolder.ModuleLoader))
    
    -- Register data stores
    local DataService = serviceManager:GetService("DataService")
    DataService:RegisterDataStore("MainData", {
        coins = 1000,
        gems = 100,
        level = 1,
        experience = 0,
        health = 100,
        maxHealth = 100,
        inventory = {},
        lastLogin = os.time(),
        playtime = 0
    })
    
    -- Start all services
    print("🚀 Starting services...")
    local servicesStarted = serviceManager:Start()
    
    if not servicesStarted then
        warn("⚠️ Some services failed to start, but continuing...")
    end
    
    -- Load modules
    print("📦 Loading modules...")
    local ModuleLoader = serviceManager:GetService("ModuleLoader")
    local modulesStarted = ModuleLoader:Start()
    
    if not modulesStarted then
        warn("⚠️ Some modules failed to start, but continuing...")
    end
    
    print("✅ [OVHL] Server bootstrap completed successfully!")
    print("📊 Services: " .. serviceManager:GetServiceCount())
    
    return serviceManager
end)

if not success then
    warn("❌ [OVHL] Server bootstrap failed:", err)
end
