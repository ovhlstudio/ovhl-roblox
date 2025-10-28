-- OVHL Client Bootstrap v1.2.3
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🎮 [OVHL] Client bootstrap V.1.2.3 starting (Auto-Discovery)...")

-- Load OVHL Global Accessor first
local ovhlSuccess, OVHL = pcall(function()
    return require(ReplicatedStorage.OVHL_Shared.OVHL_Global)
end)

if not ovhlSuccess then
    warn("⚠ [OVHL] OVHL Global Accessor not available: " .. tostring(OVHL))
else
    -- Expose OVHL globally for framework access
    _G.OVHL = OVHL
    print("🔑 [OVHL] Global Accessor exposed via _G.OVHL")
end

-- FIX: Use absolute path to find ClientController
local clientControllerFolder = script.Parent
if clientControllerFolder.Name ~= "OVHL_Client" then
    -- Try to find OVHL_Client folder
    clientControllerFolder = script.Parent:FindFirstChild("OVHL_Client")
    if not clientControllerFolder then
        warn("❌ [OVHL] OVHL_Client folder not found")
        return
    end
end

-- Load ClientController
local clientControllerSuccess, ClientController = pcall(function()
    local controllersFolder = clientControllerFolder:FindFirstChild("controllers")
    if not controllersFolder then
        error("controllers folder not found in OVHL_Client")
    end
    
    local clientControllerModule = controllersFolder:FindFirstChild("ClientController")
    if not clientControllerModule then
        error("ClientController module not found")
    end
    
    return require(clientControllerModule)
end)

if not clientControllerSuccess then
    warn("⚠ [OVHL] ClientController not available: " .. tostring(ClientController))
    return
end

-- Initialize ClientController
local success, err = pcall(function()
    return ClientController:Init()
end)

if not success then
    warn("❌ [OVHL] ClientController Init failed: " .. tostring(err))
    return
end

print("🔍 [OVHL] Auto-discovering controllers...")

-- Auto-discover and load controllers
success, err = pcall(function()
    local controllersFolder = clientControllerFolder:FindFirstChild("controllers")
    if not controllersFolder then
        error("controllers folder not found")
    end
    return ClientController:AutoDiscoverControllers(controllersFolder)
end)

if not success then
    warn("❌ [OVHL] Controller discovery failed: " .. tostring(err))
    return
end

print("🔍 [OVHL] Auto-discovering modules...")

-- Auto-discover and load UI modules
success, err = pcall(function()
    local modulesFolder = clientControllerFolder:FindFirstChild("modules")
    if not modulesFolder then
        error("modules folder not found")
    end
    return ClientController:AutoDiscoverModules(modulesFolder)
end)

if not success then
    warn("❌ [OVHL] Module discovery failed: " .. tostring(err))
    return
end

print("✅ [OVHL] Client bootstrap V.1.2.3 completed successfully!")
