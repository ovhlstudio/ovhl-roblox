#!/bin/bash

echo "🚀 OVHL UI CORE GENERATOR - ONE TIME SETUP"
echo "=========================================="
echo "📍 Current Directory: $(pwd)"
echo "📍 Branch: core/ui-manager"

# Define paths - FIXED FOR YOUR STRUCTURE
UI_LIB_PATH="src/client/lib/ui"
TEMPLATES_PATH="src/client/lib/ui/templates"
EXAMPLES_PATH="src/client/lib/ui/examples"

echo "📁 Creating UI core structure..."
mkdir -p $UI_LIB_PATH
mkdir -p $TEMPLATES_PATH
mkdir -p $EXAMPLES_PATH

# ==================== CORE UI COMPONENTS ====================

echo "🔧 Generating Panel component..."
cat > $UI_LIB_PATH/Panel.lua << 'EOF'
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local Panel = {}
Panel.__index = Panel

function Panel:Create(props)
    local panel = Instance.new("Frame")
    panel.Size = props.size or UDim2.new(1, 0, 1, 0)
    panel.BackgroundColor3 = props.backgroundColor or StyleManager:GetColor("surface")
    panel.BackgroundTransparency = props.backgroundTransparency or 0.1
    panel.BorderSizePixel = 0
    
    if props.cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.cornerRadius)
        corner.Parent = panel
    end
    
    if props.padding then
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, props.padding.left or 10)
        padding.PaddingRight = UDim.new(0, props.padding.right or 10)
        padding.PaddingTop = UDim.new(0, props.padding.top or 10)
        padding.PaddingBottom = UDim.new(0, props.padding.bottom or 10)
        padding.Parent = panel
    end
    
    return panel
end

return Panel
EOF

echo "🔧 Generating Button component..."
cat > $UI_LIB_PATH/Button.lua << 'EOF'
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local Button = {}
Button.__index = Button

function Button:Create(props)
    local button = Instance.new("TextButton")
    button.Text = props.text or "Button"
    button.Size = props.size or UDim2.new(0, 120, 0, 40)
    button.BackgroundColor3 = props.backgroundColor or StyleManager:GetColor("primary")
    button.TextColor3 = props.textColor or Color3.new(1, 1, 1)
    button.TextSize = props.textSize or 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = props.autoButtonColor ~= false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.cornerRadius or 6)
    corner.Parent = button
    
    if props.onClick then
        button.MouseButton1Click:Connect(props.onClick)
    end
    
    return button
end

return Button
EOF

echo "🔧 Generating Text component..."
cat > $UI_LIB_PATH/Text.lua << 'EOF'
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local Text = {}
Text.__index = Text

function Text:Create(props)
    local text = Instance.new("TextLabel")
    text.Text = props.text or ""
    text.Size = props.size or UDim2.new(1, 0, 0, 20)
    text.TextColor3 = props.textColor or StyleManager:GetColor("text")
    text.TextSize = props.textSize or 14
    text.Font = props.font or Enum.Font.Gotham
    text.BackgroundTransparency = 1
    text.TextXAlignment = props.alignX or Enum.TextXAlignment.Left
    text.TextYAlignment = props.alignY or Enum.TextYAlignment.Center
    text.TextWrapped = props.wrapped or true
    
    if props.fontStyle == "bold" then
        text.Font = Enum.Font.GothamBold
    elseif props.fontStyle == "semibold" then
        text.Font = Enum.Font.GothamSemibold
    end
    
    return text
end

return Text
EOF

echo "🔧 Generating Layout component..."
cat > $UI_LIB_PATH/Layout.lua << 'EOF'
local Layout = {}
Layout.__index = Layout

function Layout:CreateVertical(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.Parent = parent
    return layout
end

function Layout:CreateHorizontal(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = parent
    return layout
end

function Layout:CreateGrid(parent, cellPadding)
    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.new(0, cellPadding or 5, 0, cellPadding or 5)
    layout.CellSize = UDim2.new(0, 100, 0, 100)
    layout.Parent = parent
    return layout
end

return Layout
EOF

echo "🔧 Generating Form components..."
cat > $UI_LIB_PATH/Form.lua << 'EOF'
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local Form = {}
Form.__index = Form

function Form:CreateInput(props)
    local container = Instance.new("Frame")
    container.Size = props.size or UDim2.new(1, 0, 0, 60)
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Text = props.label or "Input"
    label.Size = UDim2.new(1, 0, 0, 20)
    label.TextColor3 = StyleManager:GetColor("text")
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, 0, 0, 35)
    input.Position = UDim2.new(0, 0, 0, 25)
    input.PlaceholderText = props.placeholder or ""
    input.Text = props.text or ""
    input.BackgroundColor3 = StyleManager:GetColor("surface")
    input.TextColor3 = StyleManager:GetColor("text")
    input.TextSize = 14
    input.Parent = container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = input
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.Parent = input
    
    return container, input
end

return Form
EOF

# ==================== UI UTILITIES ====================

echo "🔧 Generating UI utilities..."
cat > $UI_LIB_PATH/UIUtils.lua << 'EOF'
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local UIUtils = {}

function UIUtils.CreateSection(title, height)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, height or 100)
    section.BackgroundColor3 = StyleManager:GetColor("surface")
    section.BackgroundTransparency = 0.1
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = section
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 15)
    padding.PaddingRight = UDim.new(0, 15)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = section
    
    if title then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = title
        titleLabel.TextColor3 = StyleManager:GetColor("text")
        titleLabel.TextSize = 16
        titleLabel.Size = UDim2.new(1, 0, 0, 20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.Parent = section
    end
    
    return section
end

function UIUtils.CreateScrollContainer(height)
    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 0, height or 200)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 6
    container.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    return container
end

function UIUtils.AddToScrollContainer(scrollFrame, item, itemHeight)
    item.Parent = scrollFrame
    item.LayoutOrder = #scrollFrame:GetChildren()
    
    local currentSize = scrollFrame.CanvasSize
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, currentSize.Y.Offset + itemHeight)
end

return UIUtils
EOF

# ==================== MAIN UI LIBRARY INDEX ====================

echo "🔧 Generating main UI library index..."
cat > $UI_LIB_PATH/init.lua << 'EOF'
local UI = {}

UI.Panel = require(script.Panel)
UI.Button = require(script.Button)
UI.Text = require(script.Text)
UI.Layout = require(script.Layout)
UI.Form = require(script.Form)
UI.Utils = require(script.UIUtils)

return UI
EOF

# ==================== TEMPLATES ====================

echo "🔧 Generating UI templates..."
cat > $TEMPLATES_PATH/dashboard.template.lua << 'EOF'
-- Dashboard Template
return function(props)
    local UI = require(script.Parent.Parent.Parent.ui)
    
    local dashboard = UI.Panel:Create({
        size = UDim2.new(1, 0, 1, 0),
        backgroundColor = props.backgroundColor,
        padding = {left = 20, right = 20, top = 20, bottom = 20}
    })
    
    -- Header Section
    local header = UI.Utils.CreateSection("🚀 " .. (props.title or "Dashboard"), 60)
    header.Parent = dashboard
    
    -- Content Section
    local content = UI.Panel:Create({
        size = UDim2.new(1, 0, 1, -140),
        position = UDim2.new(0, 0, 0, 80),
        backgroundTransparency = 1
    })
    content.Parent = dashboard
    
    return dashboard
end
EOF

cat > $TEMPLATES_PATH/form.template.lua << 'EOF'
-- Form Template
return function(props)
    local UI = require(script.Parent.Parent.Parent.ui)
    
    local form = UI.Panel:Create({
        size = props.size or UDim2.new(1, 0, 0, 300),
        backgroundColor = props.backgroundColor,
        padding = {left = 20, right = 20, top = 20, bottom = 20},
        cornerRadius = 8
    })
    
    local layout = UI.Layout:CreateVertical(form, 15)
    
    return form
end
EOF

# ==================== USAGE EXAMPLES ====================

echo "🔧 Generating usage examples..."
cat > $EXAMPLES_PATH/TestDashboard.example.lua << 'EOF'
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
EOF

echo "✅ UI CORE GENERATION COMPLETED!"
echo ""
echo "📁 GENERATED STRUCTURE:"
echo "src/client/lib/ui/"
echo "├── Panel.lua           - Container component"
echo "├── Button.lua          - Interactive buttons"
echo "├── Text.lua            - Text labels"
echo "├── Layout.lua          - Layout management"
echo "├── Form.lua            - Form inputs"
echo "├── UIUtils.lua         - Utility functions"
echo "├── init.lua            - Main library index"
echo "├── templates/"
echo "│   ├── dashboard.template.lua"
echo "│   └── form.template.lua"
echo "└── examples/"
echo "    └── TestDashboard.example.lua"
echo ""
echo "🚀 USAGE:"
echo "local UI = require(script.Parent.Parent.lib.ui)"
echo "local panel = UI.Panel:Create({size = UDim2.new(1, 0, 1, 0)})"
echo ""
echo "🎯 NEXT: Update TestDashboard to use this UI library!"