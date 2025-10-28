#!/bin/bash

echo "🔍 INSPECTING AND FIXING SERVICE MANAGER"
echo "========================================"

# First, let's see what's actually in ServiceManager.lua
echo ""
echo "📄 CURRENT SERVICEMANAGER.LUA CONTENT:"
echo "--------------------------------------"
head -20 src/server/services/ServiceManager.lua

echo ""
echo "🔧 FIXING SERVICE MANAGER STRUCTURE"
echo "-----------------------------------"

# Create the correct ServiceManager structure
cat > src/server/services/ServiceManager.lua << 'EOF'
-- ServiceManager v6 - WITH AUTO-DISCOVERY
local ServiceManager = {}
ServiceManager.__index = ServiceManager

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
ServiceManager.__manifest = {
    name = "ServiceManager",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core service management with auto-discovery"
}

function ServiceManager:Init()
	self.services = {}
	self.serviceStates = {}
	print("🔧 ServiceManager v6 initialized (Auto-Discovery)")
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

-- AUTO-DISCOVERY FEATURE
function ServiceManager:AutoDiscoverServices(servicesFolder)
	if not servicesFolder then
		warn("⚠️ No services folder provided for auto-discovery")
		return false
	end

	print("🔍 Auto-discovering services...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	-- Discover all services
	for _, moduleScript in ipairs(servicesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "ServiceManager" then
			local success, serviceModule = pcall(require, moduleScript)

			if success and serviceModule then
				local manifest, err = ModuleManifest:GetFromModule(serviceModule, moduleScript.Name)

				if manifest then
					discovered[moduleScript.Name] = {
						module = serviceModule,
						manifest = manifest,
					}
					resolver:AddModule(moduleScript.Name, manifest)
					print("📦 Discovered:", moduleScript.Name, "v" .. manifest.version)
				else
					warn("⚠️ Failed to parse manifest for:", moduleScript.Name, err)
				end
			else
				warn("❌ Failed to require:", moduleScript.Name, serviceModule)
			end
		end
	end

	-- Resolve dependencies
	local loadOrder = resolver:Resolve()

	print("📋 Load order resolved (" .. #loadOrder .. " services):")
	for i, serviceName in ipairs(loadOrder) do
		print("  " .. i .. ". " .. serviceName)
	end

	-- Register in dependency order
	for _, serviceName in ipairs(loadOrder) do
		local item = discovered[serviceName]
		if item and item.manifest.autoload then
			self:RegisterService(serviceName, item.module)
		end
	end

	print("✅ Auto-discovery complete: " .. #loadOrder .. " services registered")
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
	for _ in pairs(self.services) do
		count = count + 1
	end
	return count
end

return ServiceManager
EOF

echo "✅ ServiceManager fixed with proper structure!"

# Now let's check and fix other services that might have similar issues
echo ""
echo "🔧 CHECKING OTHER SERVICES FOR STRUCTURE ISSUES"
echo "-----------------------------------------------"

fix_service_structure() {
    local service_name=$1
    local file_path="src/server/services/${service_name}.lua"
    
    echo "📝 Checking: $service_name"
    
    if [ ! -f "$file_path" ]; then
        echo "❌ File not found: $file_path"
        return 1
    fi
    
    # Check if the service has proper table structure
    if ! grep -q "__index = $service_name" "$file_path" && ! grep -q "local $service_name = {}" "$file_path"; then
        echo "⚠️  Structure issue detected in $service_name"
        
        # Create backup
        cp "$file_path" "${file_path}.backup"
        
        # Rebuild the file with proper structure
        {
            echo "-- $service_name - Fixed Structure"
            echo "local $service_name = {}"
            echo "${service_name}.__index = $service_name"
            echo ""
            echo "-- 🔥 MANIFEST FOR AUTO-DISCOVERY"
            case "$service_name" in
                "ConfigService")
                    echo 'ConfigService.__manifest = {
    name = "ConfigService",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 90,
    description = "Configuration management service"
}'
                    ;;
                "DataService")
                    echo 'DataService.__manifest = {
    name = "DataService",
    version = "1.0.0",
    type = "service",
    domain = "data",
    dependencies = {"Logger"},
    autoload = true,
    priority = 80,
    description = "Data persistence and management service"
}'
                    ;;
                "EventBus")
                    echo 'EventBus.__manifest = {
    name = "EventBus",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 95,
    description = "Event-driven communication system"
}'
                    ;;
                "Logger")
                    echo 'Logger.__manifest = {
    name = "Logger",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core logging service for structured logging"
}'
                    ;;
                "ModuleLoader")
                    echo 'ModuleLoader.__manifest = {
    name = "ModuleLoader",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger", "EventBus", "ConfigService", "DataService", "RemoteManager"},
    autoload = true,
    priority = 50,
    description = "Dynamic module loading with auto-discovery"
}'
                    ;;
                "RemoteManager")
                    echo 'RemoteManager.__manifest = {
    name = "RemoteManager",
    version = "1.0.0",
    type = "service",
    domain = "network",
    dependencies = {"Logger", "EventBus"},
    autoload = true,
    priority = 75,
    description = "Client-server communication manager"
}'
                    ;;
            esac
            echo ""
            # Add the original content (skip any existing manifest or broken structure)
            grep -v "__manifest" "$file_path" | grep -v "local.*= {}" | grep -v "__index = " | tail -n +2
        } > "${file_path}.new"
        
        if [ $? -eq 0 ]; then
            mv "${file_path}.new" "$file_path"
            rm -f "${file_path}.backup"
            echo "✅ Fixed structure: $service_name"
        else
            echo "❌ Failed to fix: $service_name"
            mv "${file_path}.backup" "$file_path"
        fi
    else
        echo "✅ Structure OK: $service_name"
    fi
}

# Check and fix other services
fix_service_structure "ConfigService"
fix_service_structure "DataService"
fix_service_structure "EventBus"
fix_service_structure "Logger"
fix_service_structure "ModuleLoader"
fix_service_structure "RemoteManager"

echo ""
echo "🎯 TEST INSTRUCTIONS"
echo "========================================"
echo "1. Run: rojo serve default.project.json"
echo "2. Test in Studio Play mode"
echo "3. Should see: '🔧 ServiceManager v6 initialized (Auto-Discovery)'"
echo "4. Should see services discovered with v1.0.0"
echo "5. Should NOT see 'attempt to index nil' errors"
echo "========================================"