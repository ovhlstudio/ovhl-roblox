-- UIController v1.2.0 - Force HUD Mount
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local UIController = {}
UIController.__index = UIController

UIController.__manifest = {
    name = "UIController",
    version = "1.2.0",
    type = "controller",
    domain = "ui",
    dependencies = {"UIEngine", "StateManager"}
}

function UIController:Init()
    self._screens = {}
    self._activeScreens = {}
    self._uiEngine = OVHL:GetService("UIEngine")
    print("✅ UIController Initialized")
    return true
end

function UIController:Start()
    print("🎨 UIController Started - Force mounting HUD...")
    
    -- Force mount HUD immediately
    self:ForceMountHUD()
    
    return true
end

function UIController:ForceMountHUD()
    print("🎯 FORCE MOUNTING HUD...")
    
    -- Get HUD module directly from OVHL
    local hudModule = OVHL:GetModule("HUD")
    if not hudModule then
        warn("❌ HUD module not found in OVHL")
        return false
    end
    
    print("📦 HUD module found, creating instance...")
    
    -- Create HUD instance
    local hudInstance = setmetatable({}, hudModule)
    
    -- Initialize HUD
    if hudInstance.Init then
        hudInstance:Init()
        print("✅ HUD Initialized")
    end
    
    -- Render HUD to PlayerGui
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = hudInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
        print("✅ HUD Rendered to PlayerGui")
    else
        warn("❌ HUD Render returned nil")
        return false
    end
    
    -- Call DidMount
    if hudInstance.DidMount then
        hudInstance:DidMount()
        print("✅ HUD DidMount called")
    end
    
    -- Store reference
    self._activeScreens["HUD"] = {
        instance = hudInstance,
        gui = screenGui
    }
    
    -- Register for future use
    self._screens["HUD"] = hudModule
    
    print("🖥️ HUD Force Mounted Successfully!")
    return true
end

function UIController:RegisterScreen(screenName, screenComponent)
    self._screens[screenName] = screenComponent
    print("📋 Registered screen: " .. screenName)
    return true
end

function UIController:ShowScreen(screenName, props)
    local screenComponent = self._screens[screenName]
    if not screenComponent then
        -- Try to get from OVHL modules
        screenComponent = OVHL:GetModule(screenName)
        if screenComponent then
            self._screens[screenName] = screenComponent
        else
            warn("❌ Screen not found: " .. screenName)
            return false
        end
    end
    
    -- Create screen instance
    local screenInstance = setmetatable({}, screenComponent)
    screenInstance:Init()
    
    -- Render to PlayerGui
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = screenName .. "Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = screenInstance:Render()
    renderedFrame.Parent = screenGui
    screenGui.Parent = playerGui
    
    -- Call DidMount
    if screenInstance.DidMount then
        screenInstance:DidMount()
    end
    
    -- Store reference
    self._activeScreens[screenName] = {
        instance = screenInstance,
        gui = screenGui
    }
    
    print("🖥️ Screen mounted: " .. screenName)
    return true
end

function UIController:HideScreen(screenName)
    local screenData = self._activeScreens[screenName]
    if screenData then
        -- Call WillUnmount
        if screenData.instance.WillUnmount then
            screenData.instance:WillUnmount()
        end
        
        -- Remove GUI
        screenData.gui:Destroy()
        self._activeScreens[screenName] = nil
        
        print("📴 Screen hidden: " .. screenName)
        return true
    end
    return false
end

return UIController
