-- ServiceManager v5 - Simple & Robust
local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager:Init()
    self.services = {}
    self.serviceStates = {}
    print("🔧 ServiceManager initialized")
    return true
end

function ServiceManager:Start()
    print("🚀 Starting all services...")
    
    for serviceName, service in pairs(self.services) do
        if service.Start then
            local success, err = pcall(service.Start, service)
            if success then
                self.serviceStates[serviceName] = "STARTED"
                print("✅ Service started:", serviceName)
            else
                self.serviceStates[serviceName] = "FAILED"
                warn("❌ Failed to start " .. serviceName .. ":", err)
            end
        else
            self.serviceStates[serviceName] = "READY"
            print("✅ Service ready:", serviceName)
        end
    end
    
    print("🎉 All services started!")
    return true
end

function ServiceManager:RegisterService(serviceName, serviceModule)
    self.services[serviceName] = serviceModule
    self.serviceStates[serviceName] = "REGISTERED"
    
    if serviceModule.Init then
        local success, err = pcall(serviceModule.Init, serviceModule)
        if success then
            print("🔧 Service initialized:", serviceName)
        else
            warn("❌ Failed to init " .. serviceName .. ":", err)
        end
    end
    
    print("📝 Registered service:", serviceName)
    return true
end

function ServiceManager:GetService(serviceName)
    local service = self.services[serviceName]
    if not service then
        error("Service not found: " .. serviceName)
    end
    return service
end

function ServiceManager:GetServiceCount()
    local count = 0
    for _ in pairs(self.services) do count = count + 1 end
    return count
end

return ServiceManager
