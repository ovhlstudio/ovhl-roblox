-- Example: How to use UI library for TestDashboard
local UI = require(script.Parent.Parent.ui)
local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

local function CreateTestDashboard()
    local dashboard = UI.Panel:Create({
        size = UDim2.new(1, 0, 1, 0),
        backgroundColor = StyleManager:GetColor("background")
    })
    
    -- Header
    local header = UI.Text:Create({
        text = "🚀 OVHL TEST DASHBOARD",
        textSize = 24,
        fontStyle = "bold",
        size = UDim2.new(1, 0, 0, 40)
    })
    header.Parent = dashboard
    
    -- Status Section
    local statusSection = UI.Utils.CreateSection("📊 SYSTEM STATUS", 100)
    statusSection.Position = UDim2.new(0, 0, 0, 50)
    statusSection.Parent = dashboard
    
    -- Test Controls
    local controlsSection = UI.Utils.CreateSection("🎯 TEST CONTROLS", 120)
    controlsSection.Position = UDim2.new(0, 0, 0, 170)
    controlsSection.Parent = dashboard
    
    -- Add buttons to controls section
    local pingButton = UI.Button:Create({
        text = "🏓 Ping Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0, 15, 0, 30),
        onClick = function()
            print("Ping test started")
        end
    })
    pingButton.Parent = controlsSection
    
    local eventButton = UI.Button:Create({
        text = "📡 Event Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0.35, 0, 0, 30),
        onClick = function()
            print("Event test started")
        end
    })
    eventButton.Parent = controlsSection
    
    local dataButton = UI.Button:Create({
        text = "💾 Data Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0.7, 0, 0, 30),
        onClick = function()
            print("Data test started")
        end
    })
    dataButton.Parent = controlsSection
    
    -- Results Section
    local resultsSection = UI.Utils.CreateSection("📋 TEST RESULTS", 200)
    resultsSection.Position = UDim2.new(0, 0, 0, 310)
    resultsSection.Parent = dashboard
    
    return dashboard
end

return CreateTestDashboard
