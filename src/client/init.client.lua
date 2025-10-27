-- OVHL CLIENT BOOTSTRAP V.1.0.1 - AUTO-DISCOVERY
print("🎮 [OVHL] Client bootstrap V.1.0.1 starting (Auto-Discovery)...")

local success, err = pcall(function()
	-- Setup ClientController for auto-discovery
	local ClientController = require(game.ReplicatedStorage.OVHL_Shared.utils.ClientController)
	local clientManager = setmetatable({}, ClientController)

	if not clientManager:Init() then
		error("❌ ClientController failed to initialize!")
	end

	-- Wait for controllers folder
	local controllersFolder = script:WaitForChild("controllers")

	-- 🔥 AUTO-DISCOVER ALL CONTROLLERS
	clientManager:AutoDiscoverControllers(controllersFolder)

	-- Get essential controllers
	local uiController = clientManager:GetController("UIController")
	local stateManager = clientManager:GetController("StateManager")

	if not uiController or not stateManager then
		error("❌ Essential controllers not found!")
	end

	-- Set initial state
	stateManager:Set("coins", 1000)
	stateManager:Set("gems", 100)
	stateManager:Set("level", 1)
	stateManager:Set("health", 100)
	stateManager:Set("maxHealth", 100)

	-- 🔥 AUTO-DISCOVER ALL MODULES
	local modulesFolder = script:FindFirstChild("modules")
	clientManager:AutoDiscoverModules(modulesFolder, uiController)

	-- Auto-show initial screen
	clientManager:ShowInitialScreen(uiController, "GameHUD")

	print("✅ [OVHL] Client bootstrap V.1.0.1 completed successfully!")

	return {
		ClientController = clientManager,
		RemoteClient = clientManager:GetController("RemoteClient"),
		StateManager = stateManager,
		UIEngine = clientManager:GetController("UIEngine"),
		UIController = uiController,
		StyleManager = clientManager:GetController("StyleManager"),
	}
end)

if not success then
	warn("❌ [OVHL] Client bootstrap failed:", err)
end
