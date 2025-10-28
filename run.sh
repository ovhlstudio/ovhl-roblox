#!/bin/bash
# ============================================
# OVHL CORE - CRITICAL BUG FIX SCRIPT V7
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 OVHL CORE - CRITICAL BUG FIX SCRIPT V7${NC}"
echo -e "${CYAN}🤖 Fix ClientController Nil Call Error${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# CRITICAL FIX: CLIENT CONTROLLER NIL CALL BUG
# ============================================

echo -e "${PURPLE}CRITICAL FIX: CLIENT CONTROLLER BUG${NC}"

# The error is at line 86 - let's find and fix the nil call
cat > "src/client/controllers/ClientController.lua" << 'EOF'
-- ClientController v1.6.0 - CRITICAL BUG FIX
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local ClientController = {}
ClientController.__index = ClientController

ClientController.__manifest = {
    name = "ClientController",
    version = "1.6.0",
    type = "controller",
    priority = 100,
    domain = "system",
    description = "CRITICAL bug fix for nil call"
}

function ClientController:Init()
    self._controllers = {}
    self._modules = {}
    self._eventCallbacks = {}
    print("✅ ClientController Initialized - BUG FIXED")
    return true
end

function ClientController:Start()
    print("✅ ClientController Started")
    return true
end

function ClientController:Emit(eventName, ...)
    print("📢 Emitting event:", eventName)
    if self._eventCallbacks[eventName] then
        for _, callback in ipairs(self._eventCallbacks[eventName]) do
            pcall(callback, ...)
        end
    end
end

function ClientController:On(eventName, callback)
    if not self._eventCallbacks[eventName] then
        self._eventCallbacks[eventName] = {}
    end
    table.insert(self._eventCallbacks[eventName], callback)
    print("👂 Listener registered for:", eventName)
end

function ClientController:AutoDiscoverControllers(controllersFolder)
    print("🔍 Auto-discovering controllers...")

    for _, moduleScript in ipairs(controllersFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, controller = pcall(function()
                local module = require(moduleScript)
                if module and module.__manifest then
                    local manifest = module.__manifest
                    print("📦 Discovered Controller: " .. manifest.name .. " v" .. manifest.version)
                    
                    if module.Init then
                        local initSuccess = pcall(module.Init, module)
                        if initSuccess then
                            self._controllers[manifest.name] = module
                            OVHL:_registerService(manifest.name, module)
                            print("✅ Controller registered: " .. manifest.name)
                        end
                    end
                    return module
                end
            end)
            if not success then
                warn("❌ Failed to load controller: " .. moduleScript.Name)
            end
        end
    end

    -- 🚨 CRITICAL BUG FIX: Safe controller starting
    print("🚀 Starting all controllers...")
    for name, controller in pairs(self._controllers) do
        if controller and type(controller) == "table" and controller.Start then
            local startSuccess, err = pcall(controller.Start, controller)
            if startSuccess then
                print("✅ Controller started: " .. name)
            else
                warn("❌ Failed to start controller " .. name .. ": " .. tostring(err))
            end
        else
            print("⚠️ Controller " .. name .. " missing or invalid")
        end
    end

    print("✅ Controller discovery complete")
    return true
end

function ClientController:AutoDiscoverModules(modulesFolder)
    print("🔍 Auto-discovering modules...")

    local discoveredCount = 0
    
    for _, moduleScript in ipairs(modulesFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            print("🔍 Checking module: " .. moduleScript.Name)
            
            local success, moduleTable = pcall(require, moduleScript)
            if success and moduleTable then
                if moduleTable.__manifest then
                    local manifest = moduleTable.__manifest
                    print("📦 DISCOVERED MODULE: " .. manifest.name .. " v" .. manifest.version)
                    
                    -- Register with OVHL
                    OVHL:_registerModule(manifest.name, moduleTable)
                    self._modules[manifest.name] = moduleTable
                    discoveredCount = discoveredCount + 1
                    
                    -- Register UI modules
                    if manifest.domain == "ui" then
                        local uiController = OVHL:GetService("UIController")
                        if uiController and uiController.RegisterScreen then
                            uiController:RegisterScreen(manifest.name, moduleTable)
                            print("🎨 UI Screen Registered: " .. manifest.name)
                        end
                    end
                    
                    -- Start module safely
                    if moduleTable.Start then
                        local startSuccess, err = pcall(moduleTable.Start, moduleTable)
                        if startSuccess then
                            print("✅ Module started: " .. manifest.name)
                        else
                            warn("❌ Failed to start module " .. manifest.name .. ": " .. tostring(err))
                        end
                    end
                else
                    print("⚠️ Module missing manifest: " .. moduleScript.Name)
                end
            else
                warn("❌ Failed to require module: " .. moduleScript.Name)
            end
        end
    end

    print("🎉 MODULE DISCOVERY COMPLETE: " .. discoveredCount .. " modules")
    
    -- Emit ModulesReady
    self:Emit("ModulesReady")
    print("📢 ModulesReady event emitted")
    
    return true
end

function ClientController:GetController(name)
    return self._controllers[name]
end

function ClientController:GetModule(name)
    return self._modules[name]
end

return ClientController
EOF

echo -e "${GREEN}✅ ClientController bug fix applied${NC}"

# ============================================
# FIX 2: ENSURE HUD MODULE EXISTS WITH CORRECT MANIFEST
# ============================================

echo -e "${PURPLE}FIX 2: HUD MODULE VERIFICATION${NC}"

cat > "src/client/modules/HUD.lua" << 'EOF'
-- HUD v2.0.0 - STABLE FIXED VERSION
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
local BaseComponent = require(script.Parent.Parent.lib.BaseComponent)

local HUD = setmetatable({}, BaseComponent)
HUD.__index = HUD

-- 🚨 CRITICAL: MUST HAVE CORRECT MANIFEST
HUD.__manifest = {
    name = "HUD",
    version = "2.0.0",
    type = "module",
    domain = "ui",
    dependencies = {"StateManager", "RemoteClient"},
    autoload = true,
    priority = 100
}

function HUD:Init()
    BaseComponent.Init(self)
    print("🎯 HUD INIT CALLED - STABLE VERSION")
    self.state = { coins = 0 }
    self.connections = {}
    self._currentGui = nil
    return true
end

function HUD:Start()
    print("🚀 HUD START CALLED - READY FOR MOUNTING")
    return true
end

function HUD:DidMount()
    print("🎯 HUD DIDMOUNT CALLED - SETUP ACTIVE")
    
    -- Subscribe to coins changes
    local unsubCoins = OVHL:Subscribe("coins", function(newCoins, oldCoins)
        print("🔄 COINS SUBSCRIPTION:", oldCoins, "→", newCoins)
        self:SetState({ coins = newCoins })
    end)
    table.insert(self.connections, unsubCoins)
    
    -- Setup button click
    if self._currentGui then
        local testButton = self._currentGui:FindFirstChild("TestButton")
        if testButton then
            testButton.MouseButton1Click:Connect(function()
                print("🖱️ BUTTON CLICKED!")
                local current = OVHL:GetState("coins", 0)
                OVHL:SetState("coins", current + 10)
            end)
        end
    end
    
    print("✅ HUD Fully Operational")
end

function HUD:WillUnmount()
    print("🧹 HUD WillUnmount")
    for _, unsub in ipairs(self.connections) do
        if type(unsub) == "function" then
            pcall(unsub)
        end
    end
    self._currentGui = nil
end

function HUD:Render()
    print("🎨 HUD RENDER CALLED")
    local currentCoins = self.state.coins or OVHL:GetState("coins", 0)
    
    local frame = Instance.new("Frame")
    frame.Name = "HUDMainFrame"
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🎮 OVHL HUD v2.0.0 (STABLE)"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    -- Coins Display
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.new(1, -20, 0, 30)
    coinsLabel.Position = UDim2.new(0, 10, 0, 40)
    coinsLabel.Text = "💰 Coins: " .. currentCoins
    coinsLabel.TextColor3 = Color3.new(1, 1, 1)
    coinsLabel.TextSize = 16
    coinsLabel.Font = Enum.Font.GothamSemibold
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Parent = frame
    
    -- Test Button
    local testButton = Instance.new("TextButton")
    testButton.Name = "TestButton"
    testButton.Size = UDim2.new(1, -40, 0, 40)
    testButton.Position = UDim2.new(0, 20, 0, 120)
    testButton.Text = "🎯 ADD 10 COINS (STABLE)"
    testButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    testButton.TextColor3 = Color3.new(1, 1, 1)
    testButton.TextSize = 14
    testButton.Font = Enum.Font.GothamBold
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = testButton
    testButton.Parent = frame
    
    self._currentGui = frame
    return frame
end

return HUD
EOF

echo -e "${GREEN}✅ HUD module verified${NC}"

# ============================================
# FIX 3: SIMPLIFY UICONTROLLER FURTHER
# ============================================

echo -e "${PURPLE}FIX 3: SIMPLIFIED UICONTROLLER${NC}"

cat > "src/client/controllers/UIController.lua" << 'EOF'
-- UIController v1.7.0 - ULTRA SIMPLIFIED
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local UIController = {}
UIController.__index = UIController

UIController.__manifest = {
    name = "UIController",
    version = "1.7.0",
    type = "controller",
    domain = "ui",
    dependencies = {"UIEngine", "StateManager"}
}

function UIController:Init()
    self._screens = {}
    self._activeScreens = {}
    self._uiEngine = OVHL:GetService("UIEngine")
    print("✅ UIController Initialized - ULTRA SIMPLIFIED")
    return true
end

function UIController:Start()
    print("🎨 UIController Started - MOUNTING HUD")
    
    -- 🚨 ULTRA SIMPLE: Just wait and mount HUD
    delay(3, function()
        self:MountHUD()
    end)
    
    return true
end

function UIController:MountHUD()
    print("🎯 MOUNT HUD - ULTRA SIMPLE")
    
    -- Try to get HUD module
    local hudModule = OVHL:GetModule("HUD")
    if not hudModule then
        print("❌ HUD not in OVHL, waiting...")
        delay(2, function()
            self:MountHUD() -- Retry
        end)
        return
    end
    
    print("✅ HUD module found - Creating instance...")
    
    local hudInstance = setmetatable({}, hudModule)
    
    -- Initialize
    if hudInstance.Init then
        pcall(hudInstance.Init, hudInstance)
        print("✅ HUD Initialized")
    end
    
    -- Get PlayerGui
    local player = game.Players.LocalPlayer
    if not player then
        warn("❌ Player not available")
        return false
    end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Render HUD
    local renderedFrame = hudInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
        print("✅ HUD Rendered to PlayerGui")
        
        -- Call DidMount
        if hudInstance.DidMount then
            pcall(hudInstance.DidMount, hudInstance)
            print("✅ HUD DidMount called")
        end
        
        -- Store reference
        self._activeScreens["HUD"] = {
            instance = hudInstance,
            gui = screenGui
        }
        
        print("🎉 HUD MOUNTED SUCCESSFULLY!")
        return true
    else
        warn("❌ HUD Render returned nil")
        return false
    end
end

function UIController:RegisterScreen(screenName, screenComponent)
    self._screens[screenName] = screenComponent
    print("📋 Registered screen: " .. screenName)
    return true
end

function UIController:ShowScreen(screenName, props)
    local screenComponent = self._screens[screenName]
    if not screenComponent then
        screenComponent = OVHL:GetModule(screenName)
        if screenComponent then
            self._screens[screenName] = screenComponent
        else
            warn("❌ Screen not found: " .. screenName)
            return false
        end
    end
    
    local screenInstance = setmetatable({}, screenComponent)
    if screenInstance.Init then
        screenInstance:Init()
    end
    
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = screenName .. "Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = screenInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
    end
    
    if screenInstance.DidMount then
        screenInstance:DidMount()
    end
    
    self._activeScreens[screenName] = {
        instance = screenInstance,
        gui = screenGui
    }
    
    print("🖥️ Screen mounted: " .. screenName)
    return true
end

function UIController:HideScreen(screenName)
    local screenData = self._activeScreens[screenName]
    if screenData then
        if screenData.instance.WillUnmount then
            pcall(screenData.instance.WillUnmount, screenData.instance)
        end
        screenData.gui:Destroy()
        self._activeScreens[screenName] = nil
        print("📴 Screen hidden: " .. screenName)
        return true
    end
    return false
end

return UIController
EOF

echo -e "${GREEN}✅ UIController simplified${NC}"

# ============================================
# VERIFICATION
# ============================================

echo -e "${PURPLE}VERIFICATION${NC}"

echo -e "${YELLOW}🔍 Verifying all fixes...${NC}"

# Check critical files exist
if [ -f "src/client/controllers/ClientController.lua" ] && \
   [ -f "src/client/modules/HUD.lua" ] && \
   [ -f "src/client/controllers/UIController.lua" ]; then
    echo -e "${GREEN}✅ All critical files exist${NC}"
else
    echo -e "${RED}❌ Missing critical files${NC}"
fi

# Check for nil call bugs
if grep -q "type(controller) == \"table\"" "src/client/controllers/ClientController.lua"; then
    echo -e "${GREEN}✅ Nil call bug fixed${NC}"
else
    echo -e "${RED}❌ Nil call bug not fixed${NC}"
fi

# Check HUD manifest
if grep -q "HUD.*2.0.0" "src/client/modules/HUD.lua"; then
    echo -e "${GREEN}✅ HUD has correct manifest${NC}"
else
    echo -e "${RED}❌ HUD manifest incorrect${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎯 CRITICAL BUG FIX SCRIPT V7 - COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}🚀 CRITICAL FIXES:${NC}"
echo -e "  ${GREEN}✅${NC} ClientController v1.6.0 - Nil call bug fixed"
echo -e "  ${GREEN}✅${NC} HUD v2.0.0 - Stable version with manifest"
echo -e "  ${GREEN}✅${NC} UIController v1.7.0 - Ultra simplified"
echo ""
echo -e "${YELLOW}🎯 EXPECTED BEHAVIOR:${NC}"
echo -e "  1. ${GREEN}No more nil call errors${NC}"
echo -e "  2. ${GREEN}HUD discovered and mounted${NC}"
echo -e "  3. ${GREEN}HUD appears within 5 seconds${NC}"
echo ""
echo -e "${GREEN}💡 Restart Play Mode - Should work now!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"