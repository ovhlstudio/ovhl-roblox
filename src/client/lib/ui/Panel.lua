local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

local Panel = {}
Panel.__index = Panel

function Panel:Create(props)
    local panel = Instance.new("Frame")
    panel.Size = props.size or UDim2.fromScale(1, 1)
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
