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
