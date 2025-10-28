local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

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
