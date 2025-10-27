-- Form Template
return function(props)
    local UI = require(script.Parent.Parent.Parent.ui)
    
    local form = UI.Panel:Create({
        size = props.size or UDim2.new(1, 0, 0, 300),
        backgroundColor = props.backgroundColor,
        padding = {left = 20, right = 20, top = 20, bottom = 20},
        cornerRadius = 8
    })
    
    
    return form
end
