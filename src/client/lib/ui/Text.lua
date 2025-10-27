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
        text.Font = Enum.Font.GothamMedium
    end
    
    return text
end

return Text
