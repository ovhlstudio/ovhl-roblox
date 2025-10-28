-- UIController v1.7.0 - ULTRA SIMPLIFIED
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local UIController = {}
UIController.__index = UIController

UIController.__manifest = {
    name = "UIController",
    version = "1.7.0",
    type = "controller",
    domain = "ui",
    dependencies = {"UIEngine", "StateManager"}
}

function UIController:Init()
    self._screens = {}
    self._activeScreens = {}
    self._uiEngine = OVHL:GetService("UIEngine")
    print("✅ UIController Initialized - ULTRA SIMPLIFIED")
    return true
end

function UIController:Start()
    print("🎨 UIController Started - MOUNTING HUD")
    
    -- 🚨 ULTRA SIMPLE: Just wait and mount HUD
    delay(3, function()
        self:MountHUD()
    end)
    
    return true
end

function UIController:MountHUD()
    print("🎯 MOUNT HUD - ULTRA SIMPLE")
    
    -- Try to get HUD module
    local hudModule = OVHL:GetModule("HUD")
    if not hudModule then
        print("❌ HUD not in OVHL, waiting...")
        delay(2, function()
            self:MountHUD() -- Retry
        end)
        return
    end
    
    print("✅ HUD module found - Creating instance...")
    
    local hudInstance = setmetatable({}, hudModule)
    
    -- Initialize
    if hudInstance.Init then
        pcall(hudInstance.Init, hudInstance)
        print("✅ HUD Initialized")
    end
    
    -- Get PlayerGui
    local player = game.Players.LocalPlayer
    if not player then
        warn("❌ Player not available")
        return false
    end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HUDGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Render HUD
    local renderedFrame = hudInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
        print("✅ HUD Rendered to PlayerGui")
        
        -- Call DidMount
        if hudInstance.DidMount then
            pcall(hudInstance.DidMount, hudInstance)
            print("✅ HUD DidMount called")
        end
        
        -- Store reference
        self._activeScreens["HUD"] = {
            instance = hudInstance,
            gui = screenGui
        }
        
        print("🎉 HUD MOUNTED SUCCESSFULLY!")
        return true
    else
        warn("❌ HUD Render returned nil")
        return false
    end
end

function UIController:RegisterScreen(screenName, screenComponent)
    self._screens[screenName] = screenComponent
    print("📋 Registered screen: " .. screenName)
    return true
end

function UIController:ShowScreen(screenName, props)
    local screenComponent = self._screens[screenName]
    if not screenComponent then
        screenComponent = OVHL:GetModule(screenName)
        if screenComponent then
            self._screens[screenName] = screenComponent
        else
            warn("❌ Screen not found: " .. screenName)
            return false
        end
    end
    
    local screenInstance = setmetatable({}, screenComponent)
    if screenInstance.Init then
        screenInstance:Init()
    end
    
    local player = game.Players.LocalPlayer
    if not player then return false end
    
    local playerGui = player:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = screenName .. "Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local renderedFrame = screenInstance:Render()
    if renderedFrame then
        renderedFrame.Parent = screenGui
        screenGui.Parent = playerGui
    end
    
    if screenInstance.DidMount then
        screenInstance:DidMount()
    end
    
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
        if screenData.instance.WillUnmount then
            pcall(screenData.instance.WillUnmount, screenData.instance)
        end
        screenData.gui:Destroy()
        self._activeScreens[screenName] = nil
        print("📴 Screen hidden: " .. screenName)
        return true
    end
    return false
end

return UIController
