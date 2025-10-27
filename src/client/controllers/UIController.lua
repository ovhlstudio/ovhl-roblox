-- UIController v5 - Simple UI Management
local UIController = {}
UIController.__index = UIController

function UIController:Init()
    self.screens = {}
    print("🔧 UIController initialized")
    return true
end

function UIController:Start()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create UI
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "OVHL_UI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = playerGui
    
    self.container = Instance.new("Frame")
    self.container.Size = UDim2.new(1, 0, 1, 0)
    self.container.BackgroundTransparency = 1
    self.container.Parent = self.screenGui
    
    print("🖥️ UIController started")
    return true
end

function UIController:RegisterScreen(screenName, screenComponent)
    self.screens[screenName] = screenComponent
    return true
end

function UIController:ShowScreen(screenName, props)
    local screenComponent = self.screens[screenName]
    if not screenComponent then
        warn("❌ Screen not found:", screenName)
        return false
    end
    
    local UIEngine = require(script.Parent.UIEngine)
    local screenInstance = UIEngine:CreateComponent(screenComponent, props)
    UIEngine:Mount(screenInstance, self.container)
    
    print("🖥️ Screen shown:", screenName)
    return true
end

return UIController
