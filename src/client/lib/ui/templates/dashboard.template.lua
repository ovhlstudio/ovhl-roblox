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
