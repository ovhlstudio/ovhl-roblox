-- OVHL CLIENT BOOTSTRAP v5 - FIXED STRUCTURE
print("🎮 [OVHL] Client bootstrap starting...")

local success, err = pcall(function()
    -- WAIT FOR CONTROLLERS FOLDER
    local controllersFolder = script:WaitForChild("controllers")
    
    -- Initialize controllers
    local RemoteClient = require(controllersFolder.RemoteClient)
    local StateManager = require(controllersFolder.StateManager)
    local UIEngine = require(controllersFolder.UIEngine)
    local UIController = require(controllersFolder.UIController)
    local StyleManager = require(controllersFolder.StyleManager)
    
    local remoteClient = setmetatable({}, RemoteClient)
    local stateManager = setmetatable({}, StateManager)
    local uiEngine = setmetatable({}, UIEngine)
    local uiController = setmetatable({}, UIController)
    local styleManager = setmetatable({}, StyleManager)
    
    -- Initialize in order
    remoteClient:Init()
    stateManager:Init()
    uiEngine:Init()
    uiController:Init()
    styleManager:Init()
    
    -- Start all controllers
    remoteClient:Start()
    stateManager:Start()
    uiController:Start()
    styleManager:Start()
    
    -- Set initial state
    stateManager:Set("coins", 1000)
    stateManager:Set("gems", 100)
    stateManager:Set("level", 1)
    stateManager:Set("health", 100)
    stateManager:Set("maxHealth", 100)
    
    -- Try to load HUD
    local modulesFolder = script:FindFirstChild("modules")
    if modulesFolder then
        local HUD = modulesFolder:FindFirstChild("HUD")
        if HUD then
            local hudModule = require(HUD)
            uiController:RegisterScreen("GameHUD", hudModule)
            uiController:ShowScreen("GameHUD")
            print("✅ HUD loaded and shown!")
        end
    end
    
    print("✅ [OVHL] Client bootstrap completed successfully!")
    
    return {
        RemoteClient = remoteClient,
        StateManager = stateManager,
        UIEngine = uiEngine,
        UIController = uiController,
        StyleManager = styleManager
    }
end)

if not success then
    warn("❌ [OVHL] Client bootstrap failed:", err)
end
