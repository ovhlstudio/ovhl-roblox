-- ServiceManager v6 - WITH AUTO-DISCOVERY
local ServiceManager = {}
ServiceManager.__index = ServiceManager

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
