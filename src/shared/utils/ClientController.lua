-- ClientController.lua - Client-side Auto-Discovery
local ClientController = {}
ClientController.__index = ClientController

function ClientController:Init()
	self.controllers = {}
	self.modules = {}
	print("🔧 ClientController initialized")
	return true
end

-- Auto-discover controllers
function ClientController:AutoDiscoverControllers(controllersFolder)
	if not controllersFolder then
		warn("⚠️ No controllers folder provided")
		return false
	end

	print("🔍 Auto-discovering controllers...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage.OVHL_Shared.utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	-- Discover all controllers
	for _, moduleScript in ipairs(controllersFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local success, controllerModule = pcall(require, moduleScript)

			if success and controllerModule then
				local manifest, err = ModuleManifest:GetFromModule(controllerModule, moduleScript.Name)

				if manifest then
					discovered[moduleScript.Name] = {
						module = controllerModule,
						manifest = manifest,
						instance = nil,
					}
					resolver:AddModule(moduleScript.Name, manifest)
					print("📦 Discovered controller:", moduleScript.Name, "v" .. manifest.version)
				else
					warn("⚠️ Failed to parse manifest for:", moduleScript.Name, err)
				end
			else
				warn("❌ Failed to require:", moduleScript.Name, controllerModule)
			end
		end
	end

	-- Resolve dependencies and get load order
	local loadOrder = resolver:Resolve()

	print("📋 Controller load order (" .. #loadOrder .. " controllers):")
	for i, controllerName in ipairs(loadOrder) do
		print("  " .. i .. ". " .. controllerName)
	end

	-- Initialize controllers in dependency order
	for _, controllerName in ipairs(loadOrder) do
		local item = discovered[controllerName]
		if item and item.manifest.autoload then
			local controllerInstance = setmetatable({}, item.module)

			-- Initialize controller
			if controllerInstance.Init then
				local success, err = pcall(controllerInstance.Init, controllerInstance)
				if success then
					print("🔧 Controller initialized:", controllerName)
				else
					warn("❌ Failed to init " .. controllerName .. ":", err)
				end
			end

			self.controllers[controllerName] = controllerInstance
			item.instance = controllerInstance
		end
	end

	-- Start controllers in order
	for _, controllerName in ipairs(loadOrder) do
		local item = discovered[controllerName]
		if item and item.instance and item.instance.Start then
			local success, err = pcall(item.instance.Start, item.instance)
			if success then
				print("✅ Controller started:", controllerName)
			else
				warn("❌ Failed to start " .. controllerName .. ":", err)
			end
		end
	end

	print("✅ Auto-discovery complete: " .. #loadOrder .. " controllers registered")
	return true
end

-- Auto-discover UI modules
function ClientController:AutoDiscoverModules(modulesFolder, uiController)
	if not modulesFolder then
		print("ℹ️ No modules folder found")
		return true
	end

	print("📦 Auto-discovering UI modules...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage.OVHL_Shared.utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	local function discoverInFolder(folder, domain)
		for _, item in ipairs(folder:GetChildren()) do
			if item:IsA("Folder") then
				discoverInFolder(item, item.Name)
			elseif item:IsA("ModuleScript") then
				local success, moduleTable = pcall(require, item)

				if success and moduleTable then
					local manifest, err = ModuleManifest:GetFromModule(moduleTable, item.Name)

					if manifest then
						if domain then
							manifest.domain = domain
						end

						discovered[item.Name] = {
							module = moduleTable,
							manifest = manifest,
						}
						resolver:AddModule(item.Name, manifest)
						print(
							"📦 Discovered module:",
							item.Name,
							"(" .. manifest.domain .. ")",
							"v" .. manifest.version
						)
					else
						warn("⚠️ Failed to parse manifest for:", item.Name, err)
					end
				else
					warn("❌ Failed to require:", item.Name, moduleTable)
				end
			end
		end
	end

	discoverInFolder(modulesFolder, nil)

	local loadOrder = resolver:Resolve()

	print("📋 Module load order (" .. #loadOrder .. " modules):")
	for i, moduleName in ipairs(loadOrder) do
		local item = discovered[moduleName]
		if item then
			print("  " .. i .. ". " .. moduleName .. " [" .. item.manifest.domain .. "]")
		end
	end

	-- Register modules with UIController
	for _, moduleName in ipairs(loadOrder) do
		local item = discovered[moduleName]
		if item and item.manifest.autoload then
			self.modules[moduleName] = item.module

			-- Auto-register dengan UIController jika ada
			if uiController and uiController.RegisterScreen then
				uiController:RegisterScreen(moduleName, item.module)
				print("🖥️ Screen registered:", moduleName)
			end
		end
	end

	print("🎉 Module discovery complete: " .. #loadOrder .. " modules processed")
	return true
end

-- Get controller by name
function ClientController:GetController(controllerName)
	return self.controllers[controllerName]
end

-- Get module by name
function ClientController:GetModule(moduleName)
	return self.modules[moduleName]
end

-- Auto-show initial screen
function ClientController:ShowInitialScreen(uiController, defaultScreen)
	if not uiController or not defaultScreen then
		return
	end

	local module = self.modules[defaultScreen]
	if module then
		uiController:ShowScreen(defaultScreen)
		print("🖥️ Initial screen shown:", defaultScreen)
		return true
	else
		warn("⚠️ Default screen not found:", defaultScreen)
		return false
	end
end

return ClientController
