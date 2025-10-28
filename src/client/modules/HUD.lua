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
