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
