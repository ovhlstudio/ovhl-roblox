-- StyleManager v5 - Simple Theming
local StyleManager = {}
StyleManager.__index = StyleManager

function StyleManager:Init()
    self.theme = "Dark"
    print("🔧 StyleManager initialized")
    return true
end

function StyleManager:Start()
    print("🎨 StyleManager started")
    return true
end

function StyleManager:GetColor(colorName)
    local colors = {
        primary = Color3.fromRGB(66, 135, 245),
        background = Color3.fromRGB(30, 30, 40),
        surface = Color3.fromRGB(40, 40, 50),
        text = Color3.fromRGB(255, 255, 255),
        success = Color3.fromRGB(40, 167, 69),
        error = Color3.fromRGB(220, 53, 69)
    }
    return colors[colorName] or Color3.new(1, 1, 1)
end

return StyleManager
