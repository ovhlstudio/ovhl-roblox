#!/bin/bash
# ============================================
# OVHL - FORCE HUD MOUNT FIX
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🚀 OVHL - FORCE HUD MOUNT FIX${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ============================================
# FIX 1: UPDATE UICONTROLLER TO FORCE MOUNT HUD
# ============================================

echo -e "${YELLOW}🔧 Fixing UIController to force mount HUD...${NC}"

cat > "src/client/controllers/UIController.lua" << 'EOF'
-- UIController v1.2.0 - Force HUD Mount
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local UIController = {}
UIController.__index = UIController

UIController.__manifest = {
    name = "UIController",
    version = "1.2.0",
    type = "controller",
    domain = "ui",
    dependencies = {"UIEngine", "StateManager"}
}

function UIController:Init()
    self._screens = {}
    self._activeScreens = {}
    self._uiEngine = OVHL:GetService("UIEngine")
    print("✅ UIController Initialized")
    return true
end

function UIController:Start()
    print("🎨 UIController Started - Force mounting HUD...")
    
    -- Force mount HUD immediately
    self:ForceMountHUD()
    
    return true
end

function UIController:ForceMountHUD()
    print("🎯 FORCE MOUNTING HUD...")
    
    -- Get HUD module directly from OVHL
    local hudModule = OVHL:GetModule("HUD")
    if not hudModule then
        warn("❌ HUD module not found in OVHL")
        return false
    end
    
    print("📦 HUD module found, creating instance...")
    
    -- Create HUD instance
    local hudInstance = setmetatable({}, hudModule)
    
    -- Initialize HUD
    if hudInstance.Init then
        hudInstance:Init()
        print("✅ HUD Initialized")
    end
    
    -- Render HUD to PlayerGui
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = hudInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
        print("✅ HUD Rendered to PlayerGui")
    else
        warn("❌ HUD Render returned nil")
        return false
    end
    
    -- Call DidMount
    if hudInstance.DidMount then
        hudInstance:DidMount()
        print("✅ HUD DidMount called")
    end
    
    -- Store reference
    self._activeScreens["HUD"] = {
        instance = hudInstance,
        gui = screenGui
    }
    
    -- Register for future use
    self._screens["HUD"] = hudModule
    
    print("🖥️ HUD Force Mounted Successfully!")
    return true
end

function UIController:RegisterScreen(screenName, screenComponent)
    self._screens[screenName] = screenComponent
    print("📋 Registered screen: " .. screenName)
    return true
end

function UIController:ShowScreen(screenName, props)
    local screenComponent = self._screens[screenName]
    if not screenComponent then
        -- Try to get from OVHL modules
        screenComponent = OVHL:GetModule(screenName)
        if screenComponent then
            self._screens[screenName] = screenComponent
        else
            warn("❌ Screen not found: " .. screenName)
            return false
        end
    end
    
    -- Create screen instance
    local screenInstance = setmetatable({}, screenComponent)
    screenInstance:Init()
    
    -- Render to PlayerGui
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = screenName .. "Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = screenInstance:Render()
    renderedFrame.Parent = screenGui
    screenGui.Parent = playerGui
    
    -- Call DidMount
    if screenInstance.DidMount then
        screenInstance:DidMount()
    end
    
    -- Store reference
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
        -- Call WillUnmount
        if screenData.instance.WillUnmount then
            screenData.instance:WillUnmount()
        end
        
        -- Remove GUI
        screenData.gui:Destroy()
        self._activeScreens[screenName] = nil
        
        print("📴 Screen hidden: " .. screenName)
        return true
    end
    return false
end

return UIController
EOF

echo -e "${GREEN}✅ UIController force mount fix applied${NC}"

# ============================================
# FIX 2: SIMPLIFY HUD FOR TESTING
# ============================================

echo -e "${YELLOW}🔧 Simplifying HUD for testing...${NC}"

cat > "src/client/modules/HUD.lua" << 'EOF'
-- HUD v1.5.0 - Simplified Test Version
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local HUD = {}
HUD.__index = HUD

HUD.__manifest = {
    name = "HUD",
    version = "1.5.0",
    type = "module", 
    domain = "ui",
    dependencies = {"StateManager", "RemoteClient"}
}

function HUD:Init()
    print("🎯 HUD INIT CALLED")
    self.connections = {}
    self._clickConnections = {}
    self._currentGui = nil
    return true
end

function HUD:DidMount()
    print("🎯 HUD DIDMOUNT CALLED")
    
    -- Subscribe to coins changes
    local unsubCoins = OVHL:Subscribe("coins", function(newCoins, oldCoins)
        print("🔄 COINS SUBSCRIPTION:", oldCoins, "→", newCoins)
        self:UpdateCoinsDisplay(newCoins)
    end)
    
    table.insert(self.connections, unsubCoins)
    
    -- Setup button click
    self:SetupButtonHandlers()
    
    print("✅ HUD Ready - Subscriptions active")
end

function HUD:SetupButtonHandlers()
    if not self._currentGui then 
        print("❌ No current GUI for button setup")
        return 
    end
    
    local testButton = self._currentGui:FindFirstChild("TestButton")
    if testButton then
        print("🎯 Setting up TestButton click handler...")
        
        local connection = testButton.MouseButton1Click:Connect(function()
            print("🖱️ BUTTON CLICKED!")
            self:OnTestButtonClick()
        end)
        
        table.insert(self._clickConnections, connection)
        print("✅ Button handler setup complete")
    else
        print("❌ TestButton not found in current GUI")
    end
end

function HUD:OnTestButtonClick()
    print("🧪 BUTTON CLICK HANDLER")
    
    local currentCoins = OVHL:GetState("coins", 0)
    local newCoins = currentCoins + 10
    
    print("💰 UPDATING COINS:", currentCoins, "→", newCoins)
    
    -- Update state
    OVHL:SetState("coins", newCoins)
    
    -- Force immediate UI update
    self:UpdateCoinsDisplay(newCoins)
    
    print("✅ State updated + UI refreshed")
end

function HUD:UpdateCoinsDisplay(coins)
    if not self._currentGui then
        print("❌ No current GUI to update")
        return
    end
    
    local coinsLabel = self._currentGui:FindFirstChild("CoinsLabel")
    if coinsLabel then
        coinsLabel.Text = "💰 Coins: " .. coins
        print("📊 UI UPDATED - Coins:", coins)
    else
        print("❌ CoinsLabel not found")
    end
end

function HUD:WillUnmount()
    print("🧹 HUD WillUnmount")
    
    for _, unsub in ipairs(self.connections) do
        unsub()
    end
    
    for _, connection in ipairs(self._clickConnections) do
        connection:Disconnect()
    end
    
    self._currentGui = nil
end

function HUD:Render()
    print("🎨 HUD RENDER CALLED")
    
    local currentCoins = OVHL:GetState("coins", 0)
    
    -- Create simple frame
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
    title.Text = "🎮 OVHL HUD v1.5"
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
    testButton.Text = "🎯 ADD 10 COINS"
    testButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    testButton.TextColor3 = Color3.new(1, 1, 1)
    testButton.TextSize = 14
    testButton.Font = Enum.Font.GothamBold
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = testButton
    
    testButton.Parent = frame
    
    -- Store reference
    self._currentGui = frame
    
    print("✅ HUD Render Complete - Coins:", currentCoins)
    return frame
end

return HUD
EOF

echo -e "${GREEN}✅ HUD simplified for testing${NC}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎯 FORCE MOUNT FIX COMPLETE!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📋 KEY FIXES:${NC}"
echo -e "  ${GREEN}✅${NC} UIController v1.2.0 - Force mounts HUD on start"
echo -e "  ${GREEN}✅${NC} HUD v1.5.0 - Simplified with direct OVHL access"
echo -e "  ${GREEN}✅${NC} Manual UI updates bypassing subscriptions"
echo -e "  ${GREEN}✅${NC} Better debug logging"
echo ""
echo -e "${YELLOW}🎯 EXPECTED BEHAVIOR:${NC}"
echo -e "  ${GREEN}✓${NC} HUD appears immediately on startup"
echo -e "  ${GREEN}✓${NC} Button clicks work and show debug logs"
echo -e "  ${GREEN}✓${NC} Coins increase and UI updates"
echo -e "  ${GREEN}✓${NC} All steps visible in output"
echo ""
echo -e "${GREEN}🚀 RESTART PLAY MODE - HUD HARUS MUNCUL!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"