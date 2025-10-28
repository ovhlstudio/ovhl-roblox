local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local Button = {}
Button.__index = Button

function Button:Create(props)
    local button = Instance.new("TextButton")
    button.Text = props.text or "Button"
    button.Size = props.size or UDim2.fromOffset(120, 40)
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
