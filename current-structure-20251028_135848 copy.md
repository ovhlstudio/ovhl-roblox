# 🏗️ OVHL CORE - STRUCTURE SNAPSHOT

## 📋 SNAPSHOT INFORMATION

| Property          | Value                                            |
| ----------------- | ------------------------------------------------ |
| **Timestamp**     | `Tue, Oct 28, 2025 13:58:48`                     |
| **Snapshot File** | `./archive/current-structure-20251028_135848.md` |
| **OVHL Version**  | `1.2.0`                                          |
| **Status**        | `Client-Side WIP`                                |

## 🎯 CURRENT STATUS

### ✅ WORKING:

- Server-side auto-discovery (6 services)
- Client-side auto-discovery (6 controllers + 3 modules)
- OVHL Global Accessor APIs
- Basic State Management (Set/Get)
- Network Communication (Fire/Invoke/Listen)
- UI Component Foundation

### ❌ KNOWN ISSUES:

- HUD mounting timing issues
- State subscriptions not triggering
- UI reactivity not working
- UIController module discovery race condition

---

## 📁 COMPLETE STRUCTURE & SOURCE CODE

## 🌲 FILE TREE STRUCTURE

```
│   src/client/controllers/ClientController.lua
│   src/client/controllers/RemoteClient.lua
│   src/client/controllers/StateManager.lua
│   src/client/controllers/StyleManager.lua
│   src/client/controllers/UIController.lua
│   src/client/controllers/UIEngine.lua
│   src/client/init.client.lua
│   src/client/lib/BaseComponent.lua
│   src/client/lib/ui/Button.lua
│   src/client/lib/ui/examples/TestDashboard.example.lua
│   src/client/lib/ui/Form.lua
│   src/client/lib/ui/init.lua
│   src/client/lib/ui/Layout.lua
│   src/client/lib/ui/Panel.lua
│   src/client/lib/ui/templates/dashboard.template.lua
│   src/client/lib/ui/templates/form.template.lua
│   src/client/lib/ui/Text.lua
│   src/client/lib/ui/UIUtils.lua
│   src/client/modules/HUD.lua
│   src/client/modules/TestClientModule.lua
│   src/client/modules/TestDashboard.lua
│   src/client/test_state.lua
│   src/server/init.server.lua
│   src/server/modules/gameplay/ExampleModule.lua
│   src/server/modules/HUDTestHandler.lua
│   src/server/services/ConfigService.lua
│   src/server/services/DataService.lua
│   src/server/services/EventBus.lua
│   src/server/services/Logger.lua
│   src/server/services/ModuleLoader.lua
│   src/server/services/RemoteManager.lua
│   src/server/services/ServiceManager.lua
│   src/shared/OVHL_Global.lua
│   src/shared/utils/ClientController.lua
│   src/shared/utils/DependencyResolver.lua
│   src/shared/utils/ModuleManifest.lua
```

## 📄 `src/client/controllers/ClientController.lua`

```lua
-- ClientController v1.1.1 - UI Registration
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local ClientController = {}
ClientController.__index = ClientController

ClientController.__manifest = {
    name = "ClientController",
    version = "1.1.1",
    type = "controller",
    priority = 100,
    domain = "system",
    description = "Main client controller for OVHL framework"
}

function ClientController:Init()
    self._controllers = {}
    self._modules = {}
    print("✅ ClientController Initialized")
    return true
end

function ClientController:Start()
    print("✅ ClientController Started")
    return true
end

function ClientController:AutoDiscoverControllers(controllersFolder)
    print("🔍 Auto-discovering controllers...")

    for _, moduleScript in ipairs(controllersFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, controller = pcall(function()
                local module = require(moduleScript)

                if module and module.__manifest then
                    local manifest = module.__manifest
                    print("📦 Discovered: " .. manifest.name .. " v" .. manifest.version)

                    if module.Init then
                        local initSuccess = module:Init()
                        if initSuccess then
                            self._controllers[manifest.name] = module
                            OVHL:_registerService(manifest.name, module)
                        end
                    end

                    return module
                end
            end)

            if not success then
                warn("❌ Failed to load controller: " .. moduleScript.Name .. " - " .. tostring(controller))
            end
        end
    end

    for name, controller in pairs(self._controllers) do
        if controller.Start then
            local startSuccess, err = pcall(controller.Start, controller)
            if not startSuccess then
                warn("❌ Failed to start controller: " .. name .. " - " .. tostring(err))
            end
        end
    end

    print("✅ Auto-discovery complete: " .. tostring(#controllersFolder:GetChildren()) .. " controllers processed")
    return true
end

function ClientController:AutoDiscoverModules(modulesFolder)
    print("🔍 Auto-discovering modules...")

    for _, moduleScript in ipairs(modulesFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, module = pcall(function()
                local moduleTable = require(moduleScript)

                if moduleTable and moduleTable.__manifest then
                    local manifest = moduleTable.__manifest
                    print("📦 Discovered: " .. manifest.name .. " v" .. manifest.version)

                    OVHL:_registerModule(manifest.name, moduleTable)
                    self._modules[manifest.name] = moduleTable

                    -- NEW: Register UI modules with UIController
                    if manifest.domain == "ui" then
                        local uiController = OVHL:GetService("UIController")
                        if uiController and uiController.RegisterScreen then
                            uiController:RegisterScreen(manifest.name, moduleTable)
                            print("🎨 Registered UI screen: " .. manifest.name)
                        end
                    end

                    -- Start module if has Start method
                    if moduleTable.Start then
                        local startSuccess, err = pcall(moduleTable.Start, moduleTable)
                        if not startSuccess then
                            warn("❌ Failed to start module: " .. manifest.name .. " - " .. tostring(err))
                        end
                    end

                    return moduleTable
                end
            end)

            if not success then
                warn("❌ Failed to load module: " .. moduleScript.Name .. " - " .. tostring(module))
            end
        end
    end

    print("✅ Auto-discovery complete: " .. tostring(#modulesFolder:GetChildren()) .. " modules processed")
    return true
end

function ClientController:GetController(name)
    return self._controllers[name]
end

function ClientController:GetModule(name)
    return self._modules[name]
end

return ClientController
```

---

## 📄 `src/client/controllers/RemoteClient.lua`

```lua
-- RemoteClient v1.1.2 - OVHL Pattern (STARTUP FIXED)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteClient = {}
RemoteClient.__index = RemoteClient

-- Auto-discovery manifest
RemoteClient.__manifest = {
    name = "RemoteClient",
    version = "1.1.2",
    type = "controller",
    priority = 100,
    domain = "network",
    description = "Client-server communication"
}

function RemoteClient:Init()
    self._remoteEvents = {}
    self._remoteFunctions = {}
    self._listeners = {}

    -- SETUP REMOTES IMMEDIATELY IN INIT
    self:SetupRemotes()

    print("✅ RemoteClient Initialized with remotes setup")
    return true
end

function RemoteClient:Start()
    print("✅ RemoteClient Started")
    return true
end

function RemoteClient:SetupRemotes()
    local remotesFolder = ReplicatedStorage:FindFirstChild("OVHL_Remotes")
    if not remotesFolder then
        remotesFolder = Instance.new("Folder")
        remotesFolder.Name = "OVHL_Remotes"
        remotesFolder.Parent = ReplicatedStorage
    end

    -- Store references
    self._remoteFolder = remotesFolder
end

-- OVHL API: Fire event to server
function RemoteClient:Fire(eventName, ...)
    local args = {...}

    -- Ensure remotes are setup
    if not self._remoteFolder then
        self:SetupRemotes()
    end

    local remoteEvent = self._remoteFolder:FindFirstChild(eventName)
    if not remoteEvent then
        remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = eventName
        remoteEvent.Parent = self._remoteFolder
    end

    remoteEvent:FireServer(unpack(args))
    return true
end

-- OVHL API: Invoke server function
function RemoteClient:Invoke(eventName, ...)
    local args = {...}

    -- Ensure remotes are setup
    if not self._remoteFolder then
        self:SetupRemotes()
    end

    local remoteFunction = self._remoteFolder:FindFirstChild(eventName)
    if not remoteFunction then
        remoteFunction = Instance.new("RemoteFunction")
        remoteFunction.Name = eventName
        remoteFunction.Parent = self._remoteFolder
    end

    local success, result = pcall(function()
        return remoteFunction:InvokeServer(unpack(args))
    end)

    if not success then
        warn("RemoteClient Invoke failed: " .. tostring(result))
        return nil
    end

    return result
end

-- OVHL API: Listen to server events
function RemoteClient:Listen(eventName, callback)
    -- Ensure remotes are setup
    if not self._remoteFolder then
        self:SetupRemotes()
    end

    local remoteEvent = self._remoteFolder:FindFirstChild(eventName)
    if not remoteEvent then
        remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = eventName
        remoteEvent.Parent = self._remoteFolder
    end

    local connection = remoteEvent.OnClientEvent:Connect(callback)
    return connection
end

return RemoteClient
```

---

## 📄 `src/client/controllers/StateManager.lua`

```lua
-- StateManager v1.2.0 - Debug Version
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local StateManager = {}
StateManager.__index = StateManager

-- Auto-discovery manifest
StateManager.__manifest = {
    name = "StateManager",
    version = "1.2.0",
    type = "controller",
    priority = 90,
    domain = "state",
    description = "Client-side state management"
}

function StateManager:Init()
    self._states = {}
    self._subscribers = {}
    print("✅ StateManager Initialized")
    return true
end

function StateManager:Start()
    print("✅ StateManager Started")
    return true
end

-- OVHL API: Set state value
function StateManager:Set(key, value)
    print("🎯 StateManager:Set called - Key:", key, "Value:", value)

    local oldValue = self._states[key]
    self._states[key] = value

    print("📊 State stored -", key, "=", value)

    -- Notify subscribers
    if self._subscribers[key] then
        print("🔔 Notifying", #self._subscribers[key], "subscribers for", key)
        for i, callback in ipairs(self._subscribers[key]) do
            print("  📨 Calling subscriber", i, "for", key)
            local success, err = pcall(callback, value, oldValue)
            if not success then
                warn("❌ StateManager callback error: " .. tostring(err))
            else
                print("  ✅ Subscriber", i, "executed successfully")
            end
        end
    else
        print("ℹ️ No subscribers for", key)
    end

    return true
end

-- OVHL API: Get state value
function StateManager:Get(key, defaultValue)
    local value = self._states[key]
    if value == nil then
        return defaultValue
    end
    return value
end

-- OVHL API: Subscribe to state changes
function StateManager:Subscribe(key, callback)
    print("🎯 StateManager:Subscribe called - Key:", key)

    if not self._subscribers[key] then
        self._subscribers[key] = {}
        print("  📋 Created new subscriber list for", key)
    end

    table.insert(self._subscribers[key], callback)
    print("  ➕ Added subscriber to", key, "- Total:", #self._subscribers[key])

    -- Return unsubscribe function
    return function()
        print("🎯 Unsubscribing from", key)
        if self._subscribers[key] then
            for i, cb in ipairs(self._subscribers[key]) do
                if cb == callback then
                    table.remove(self._subscribers[key], i)
                    print("  ➖ Removed subscriber from", key, "- Remaining:", #self._subscribers[key])
                    break
                end
            end
        end
    end
end

return StateManager
```

---

## 📄 `src/client/controllers/StyleManager.lua`

```lua
-- StyleManager v5 - Simple Theming
local StyleManager = {}
StyleManager.__index = StyleManager

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
-- 🔥 MANIFEST FOR AUTO-DISCOVERY
StyleManager.__manifest = {
    name = "StyleManager",
    version = "1.0.0",
    type = "controller",
    domain = "ui",
    dependencies = {},
    autoload = true,
    priority = 60,
    description = "UI theming and styling controller",
}

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
		error = Color3.fromRGB(220, 53, 69),
		warning = Color3.fromRGB(255, 193, 7),
		textSecondary = Color3.fromRGB(200, 200, 200),
	}
	return colors[colorName] or Color3.new(1, 1, 1)
end

return StyleManager
```

---

## 📄 `src/client/controllers/UIController.lua`

```lua
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
```

---

## 📄 `src/client/controllers/UIEngine.lua`

```lua
-- UIEngine v1.1.0 - Component Support
local UIEngine = {}
UIEngine.__index = UIEngine

UIEngine.__manifest = {
    name = "UIEngine",
    version = "1.1.0",
    type = "controller",
    domain = "ui"
}

function UIEngine:Init()
    self._components = {}
    print("✅ UIEngine Initialized")
    return true
end

function UIEngine:Start()
    print("🎨 UIEngine Started")
    return true
end

function UIEngine:CreateComponent(ComponentClass, props)
    local component = setmetatable({}, ComponentClass)
    component.props = props or {}

    if component.Init then
        component:Init()
    end

    return component
end

function UIEngine:Mount(component, parent)
    if not component.Render then
        error("Component must have Render method")
    end

    local instance = component:Render()
    if not instance then
        error("Render must return an Instance")
    end

    instance.Parent = parent

    if component.DidMount then
        component:DidMount()
    end

    return instance
end

function UIEngine:Unmount(component)
    if component.WillUnmount then
        component:WillUnmount()
    end

    -- Note: Parent cleanup should be handled by the caller
    return true
end

return UIEngine
```

---

## 📄 `src/client/init.client.lua`

```lua
-- OVHL Client Bootstrap v1.2.3
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🎮 [OVHL] Client bootstrap V.1.2.3 starting (Auto-Discovery)...")

-- Load OVHL Global Accessor first
local ovhlSuccess, OVHL = pcall(function()
    return require(ReplicatedStorage.OVHL_Shared.OVHL_Global)
end)

if not ovhlSuccess then
    warn("⚠ [OVHL] OVHL Global Accessor not available: " .. tostring(OVHL))
else
    -- Expose OVHL globally for framework access
    _G.OVHL = OVHL
    print("🔑 [OVHL] Global Accessor exposed via _G.OVHL")
end

-- FIX: Use absolute path to find ClientController
local clientControllerFolder = script.Parent
if clientControllerFolder.Name ~= "OVHL_Client" then
    -- Try to find OVHL_Client folder
    clientControllerFolder = script.Parent:FindFirstChild("OVHL_Client")
    if not clientControllerFolder then
        warn("❌ [OVHL] OVHL_Client folder not found")
        return
    end
end

-- Load ClientController
local clientControllerSuccess, ClientController = pcall(function()
    local controllersFolder = clientControllerFolder:FindFirstChild("controllers")
    if not controllersFolder then
        error("controllers folder not found in OVHL_Client")
    end

    local clientControllerModule = controllersFolder:FindFirstChild("ClientController")
    if not clientControllerModule then
        error("ClientController module not found")
    end

    return require(clientControllerModule)
end)

if not clientControllerSuccess then
    warn("⚠ [OVHL] ClientController not available: " .. tostring(ClientController))
    return
end

-- Initialize ClientController
local success, err = pcall(function()
    return ClientController:Init()
end)

if not success then
    warn("❌ [OVHL] ClientController Init failed: " .. tostring(err))
    return
end

print("🔍 [OVHL] Auto-discovering controllers...")

-- Auto-discover and load controllers
success, err = pcall(function()
    local controllersFolder = clientControllerFolder:FindFirstChild("controllers")
    if not controllersFolder then
        error("controllers folder not found")
    end
    return ClientController:AutoDiscoverControllers(controllersFolder)
end)

if not success then
    warn("❌ [OVHL] Controller discovery failed: " .. tostring(err))
    return
end

print("🔍 [OVHL] Auto-discovering modules...")

-- Auto-discover and load UI modules
success, err = pcall(function()
    local modulesFolder = clientControllerFolder:FindFirstChild("modules")
    if not modulesFolder then
        error("modules folder not found")
    end
    return ClientController:AutoDiscoverModules(modulesFolder)
end)

if not success then
    warn("❌ [OVHL] Module discovery failed: " .. tostring(err))
    return
end

print("✅ [OVHL] Client bootstrap V.1.2.3 completed successfully!")
```

---

## 📄 `src/client/lib/BaseComponent.lua`

```lua
-- BaseComponent v5 - Simple Base
local BaseComponent = {}
BaseComponent.__index = BaseComponent

function BaseComponent:Init()
    self.state = self.state or {}
end

function BaseComponent:SetState(newState)
    if type(newState) == "function" then
        newState = newState(self.state)
    end

    self.state = newState

    if self._instance and self._uiEngine then
        self._uiEngine:Unmount(self)
        self._uiEngine:Mount(self, self._instance.Parent)
    end
end

return BaseComponent
```

---

## 📄 `src/client/lib/ui/Button.lua`

```lua
local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

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
```

---

## 📄 `src/client/lib/ui/examples/TestDashboard.example.lua`

```lua
-- Example: How to use UI library for TestDashboard
local UI = require(script.Parent.Parent.ui)
local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

local function CreateTestDashboard()
    local dashboard = UI.Panel:Create({
        size = UDim2.new(1, 0, 1, 0),
        backgroundColor = StyleManager:GetColor("background")
    })

    -- Header
    local header = UI.Text:Create({
        text = "🚀 OVHL TEST DASHBOARD",
        textSize = 24,
        fontStyle = "bold",
        size = UDim2.new(1, 0, 0, 40)
    })
    header.Parent = dashboard

    -- Status Section
    local statusSection = UI.Utils.CreateSection("📊 SYSTEM STATUS", 100)
    statusSection.Position = UDim2.new(0, 0, 0, 50)
    statusSection.Parent = dashboard

    -- Test Controls
    local controlsSection = UI.Utils.CreateSection("🎯 TEST CONTROLS", 120)
    controlsSection.Position = UDim2.new(0, 0, 0, 170)
    controlsSection.Parent = dashboard

    -- Add buttons to controls section
    local pingButton = UI.Button:Create({
        text = "🏓 Ping Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0, 15, 0, 30),
        onClick = function()
            print("Ping test started")
        end
    })
    pingButton.Parent = controlsSection

    local eventButton = UI.Button:Create({
        text = "📡 Event Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0.35, 0, 0, 30),
        onClick = function()
            print("Event test started")
        end
    })
    eventButton.Parent = controlsSection

    local dataButton = UI.Button:Create({
        text = "💾 Data Test",
        size = UDim2.new(0.3, 0, 0, 30),
        position = UDim2.new(0.7, 0, 0, 30),
        onClick = function()
            print("Data test started")
        end
    })
    dataButton.Parent = controlsSection

    -- Results Section
    local resultsSection = UI.Utils.CreateSection("📋 TEST RESULTS", 200)
    resultsSection.Position = UDim2.new(0, 0, 0, 310)
    resultsSection.Parent = dashboard

    return dashboard
end

return CreateTestDashboard
```

---

## 📄 `src/client/lib/ui/Form.lua`

```lua
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
```

---

## 📄 `src/client/lib/ui/init.lua`

```lua
local UI = {}

UI.Panel = require(script.Panel)
UI.Button = require(script.Button)
UI.Text = require(script.Text)
UI.Layout = require(script.Layout)
UI.Form = require(script.Form)
UI.Utils = require(script.UIUtils)

return UI
```

---

## 📄 `src/client/lib/ui/Layout.lua`

```lua
local Layout = {}
Layout.__index = Layout

function Layout:CreateVertical(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.Parent = parent
    return layout
end

function Layout:CreateHorizontal(parent, spacing)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing or 5)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = parent
    return layout
end

function Layout:CreateGrid(parent, cellPadding)
    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.new(0, cellPadding or 5, 0, cellPadding or 5)
    layout.CellSize = UDim2.new(0, 100, 0, 100)
    layout.Parent = parent
    return layout
end

return Layout
```

---

## 📄 `src/client/lib/ui/Panel.lua`

```lua
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
```

---

## 📄 `src/client/lib/ui/templates/dashboard.template.lua`

```lua
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
```

---

## 📄 `src/client/lib/ui/templates/form.template.lua`

```lua
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
```

---

## 📄 `src/client/lib/ui/Text.lua`

```lua
local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

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
```

---

## 📄 `src/client/lib/ui/UIUtils.lua`

```lua
local StyleManager = require(script.Parent.Parent.Parent.controllers.StyleManager)

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
```

---

## 📄 `src/client/modules/HUD.lua`

```lua
-- HUD v1.5.0 - Simplified Test Version
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local HUD = {}
HUD.__index = HUD

HUD.__manifest = {
    name = "HUD",
    version = "1.5.0",
    type = "module",
    domain = "ui",
    dependencies = {"StateManager", "RemoteClient"}
}

function HUD:Init()
    print("🎯 HUD INIT CALLED")
    self.connections = {}
    self._clickConnections = {}
    self._currentGui = nil
    return true
end

function HUD:DidMount()
    print("🎯 HUD DIDMOUNT CALLED")

    -- Subscribe to coins changes
    local unsubCoins = OVHL:Subscribe("coins", function(newCoins, oldCoins)
        print("🔄 COINS SUBSCRIPTION:", oldCoins, "→", newCoins)
        self:UpdateCoinsDisplay(newCoins)
    end)

    table.insert(self.connections, unsubCoins)

    -- Setup button click
    self:SetupButtonHandlers()

    print("✅ HUD Ready - Subscriptions active")
end

function HUD:SetupButtonHandlers()
    if not self._currentGui then
        print("❌ No current GUI for button setup")
        return
    end

    local testButton = self._currentGui:FindFirstChild("TestButton")
    if testButton then
        print("🎯 Setting up TestButton click handler...")

        local connection = testButton.MouseButton1Click:Connect(function()
            print("🖱️ BUTTON CLICKED!")
            self:OnTestButtonClick()
        end)

        table.insert(self._clickConnections, connection)
        print("✅ Button handler setup complete")
    else
        print("❌ TestButton not found in current GUI")
    end
end

function HUD:OnTestButtonClick()
    print("🧪 BUTTON CLICK HANDLER")

    local currentCoins = OVHL:GetState("coins", 0)
    local newCoins = currentCoins + 10

    print("💰 UPDATING COINS:", currentCoins, "→", newCoins)

    -- Update state
    OVHL:SetState("coins", newCoins)

    -- Force immediate UI update
    self:UpdateCoinsDisplay(newCoins)

    print("✅ State updated + UI refreshed")
end

function HUD:UpdateCoinsDisplay(coins)
    if not self._currentGui then
        print("❌ No current GUI to update")
        return
    end

    local coinsLabel = self._currentGui:FindFirstChild("CoinsLabel")
    if coinsLabel then
        coinsLabel.Text = "💰 Coins: " .. coins
        print("📊 UI UPDATED - Coins:", coins)
    else
        print("❌ CoinsLabel not found")
    end
end

function HUD:WillUnmount()
    print("🧹 HUD WillUnmount")

    for _, unsub in ipairs(self.connections) do
        unsub()
    end

    for _, connection in ipairs(self._clickConnections) do
        connection:Disconnect()
    end

    self._currentGui = nil
end

function HUD:Render()
    print("🎨 HUD RENDER CALLED")

    local currentCoins = OVHL:GetState("coins", 0)

    -- Create simple frame
    local frame = Instance.new("Frame")
    frame.Name = "HUDMainFrame"
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "🎮 OVHL HUD v1.5"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.Parent = frame

    -- Coins Display
    local coinsLabel = Instance.new("TextLabel")
    coinsLabel.Name = "CoinsLabel"
    coinsLabel.Size = UDim2.new(1, -20, 0, 30)
    coinsLabel.Position = UDim2.new(0, 10, 0, 40)
    coinsLabel.Text = "💰 Coins: " .. currentCoins
    coinsLabel.TextColor3 = Color3.new(1, 1, 1)
    coinsLabel.TextSize = 16
    coinsLabel.Font = Enum.Font.GothamSemibold
    coinsLabel.BackgroundTransparency = 1
    coinsLabel.TextXAlignment = Enum.TextXAlignment.Left
    coinsLabel.Parent = frame

    -- Test Button
    local testButton = Instance.new("TextButton")
    testButton.Name = "TestButton"
    testButton.Size = UDim2.new(1, -40, 0, 40)
    testButton.Position = UDim2.new(0, 20, 0, 120)
    testButton.Text = "🎯 ADD 10 COINS"
    testButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    testButton.TextColor3 = Color3.new(1, 1, 1)
    testButton.TextSize = 14
    testButton.Font = Enum.Font.GothamBold

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = testButton

    testButton.Parent = frame

    -- Store reference
    self._currentGui = frame

    print("✅ HUD Render Complete - Coins:", currentCoins)
    return frame
end

return HUD
```

---

## 📄 `src/client/modules/TestClientModule.lua`

```lua
-- TestClientModule v1.0.1 - Better Error Handling
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local TestClientModule = {}
TestClientModule.__index = TestClientModule

TestClientModule.__manifest = {
    name = "TestClientModule",
    version = "1.0.1",
    type = "module",
    domain = "test",
    dependencies = {"StateManager", "RemoteClient"}
}

function TestClientModule:Start()
    print("🧪 TestClientModule Starting...")

    -- Wait a bit for RemoteClient to be fully ready
    wait(1)

    -- Test all OVHL Client APIs with better error handling
    self:TestStateManagement()
    self:TestNetworkCommunication()

    print("✅ TestClientModule Started")
end

function TestClientModule:TestStateManagement()
    print("🧪 Testing State Management...")

    -- Test SetState
    OVHL:SetState("test_coins", 100)
    OVHL:SetState("test_health", 50)

    -- Test GetState
    local coins = OVHL:GetState("test_coins", 0)
    local health = OVHL:GetState("test_health", 100)

    print("🧪 State Test - Coins:", coins, "Health:", health)

    -- Test Subscribe
    OVHL:Subscribe("test_coins", function(newValue)
        print("🧪 State Subscription - Coins changed to:", newValue)
    end)

    -- Trigger change
    OVHL:SetState("test_coins", 200)
end

function TestClientModule:TestNetworkCommunication()
    print("🧪 Testing Network Communication...")

    -- Test Fire (async) with error handling
    local fireSuccess, fireErr = pcall(function()
        OVHL:Fire("ClientTestEvent", "Fire test from client")
    end)

    if fireSuccess then
        print("🧪 Network Test - Fire: SUCCESS")
    else
        print("🧪 Network Test - Fire failed:", fireErr)
    end

    -- Test Invoke (sync) with error handling
    local invokeSuccess, invokeResult = pcall(function()
        return OVHL:Invoke("ClientTestInvoke", "Invoke test from client")
    end)

    if invokeSuccess then
        print("🧪 Network Test - Invoke result:", invokeResult)
    else
        print("🧪 Network Test - Invoke failed:", invokeResult)
    end

    -- Test Listen with error handling
    local listenSuccess, listenErr = pcall(function()
        OVHL:Listen("ServerTestEvent", function(message)
            print("🧪 Network Test - Received from server:", message)
        end)
    end)

    if listenSuccess then
        print("🧪 Network Test - Listen: SUCCESS")
    else
        print("🧪 Network Test - Listen failed:", listenErr)
    end
end

return TestClientModule
```

---

## 📄 `src/client/modules/TestDashboard.lua`

```lua
local BaseComponent = require(script.Parent.Parent.lib.BaseComponent)
local UI = require(script.Parent.Parent.lib.ui)
local StyleManager = require(script.Parent.Parent.controllers.StyleManager)

local TestDashboard = setmetatable({}, BaseComponent)
TestDashboard.__index = TestDashboard

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
-- 🔥 MANIFEST FOR AUTO-DISCOVERY
TestDashboard.__manifest = {
    name = "TestDashboard",
    version = "1.0.0",
    type = "module",
    domain = "ui",
    dependencies = {},
    autoload = true,
    priority = 40,
    description = "System testing and monitoring dashboard",
}

function TestDashboard:Init()
	BaseComponent.Init(self)

	self.state = {
		-- Service Status
		servicesStatus = {},
		connectionStatus = "Disconnected",

		-- Test Results
		testResults = {},
		currentTest = nil,
		isTesting = false,

		-- Performance Metrics
		performanceMetrics = {
			serverPing = 0,
			serviceStartup = 0,
			eventLatency = 0,
			lastUpdate = os.time(),
		},
	}

	print("🔧 TestDashboard initialized with UI Library")
	return true
end

function TestDashboard:DidMount()
	-- Setup real-time monitoring
	self:StartServiceMonitoring()
	self:SetupEventListeners()

	print("🎯 TestDashboard mounted with UI Library")
end

function TestDashboard:StartServiceMonitoring()
	-- Monitor service health setiap 5 detik
	while self._instance and self._instance.Parent do
		self:CheckServiceHealth()
		self:UpdatePerformanceMetrics()
		wait(5)
	end
end

function TestDashboard:CheckServiceHealth()
	local RemoteClient = require(script.Parent.Parent.controllers.RemoteClient)
	local servicesStatus = {}

	-- Check RemoteClient connection
	servicesStatus.RemoteClient = RemoteClient:IsConnected() and "✅ Connected" or "❌ Disconnected"
	servicesStatus.StateManager = "✅ Active"
	servicesStatus.UIEngine = "✅ Ready"

	-- Update connection status
	self.connectionStatus = RemoteClient:IsConnected() and "Connected" or "Disconnected"

	self:SetState({
		servicesStatus = servicesStatus,
		connectionStatus = self.connectionStatus,
	})
end

function TestDashboard:UpdatePerformanceMetrics()
	-- Simulate performance metrics
	local metrics = {
		serverPing = math.random(20, 100),
		serviceStartup = math.random(50, 150),
		eventLatency = math.random(5, 30),
		lastUpdate = os.time(),
	}

	self:SetState({
		performanceMetrics = metrics,
	})
end

function TestDashboard:RunPingTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Ping Test",
	})

	local RemoteClient = require(script.Parent.Parent.controllers.RemoteClient)

	local startTime = os.clock()

	local success, result = pcall(function()
		return RemoteClient:Invoke("Test:Ping", {
			message = "Ping from TestDashboard",
			timestamp = os.time(),
		})
	end)

	local endTime = os.clock()
	local responseTime = math.floor((endTime - startTime) * 1000)

	local testResult = {
		testName = "Ping Test",
		success = success,
		responseTime = responseTime,
		result = result,
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(success and "✅ Ping test completed" or "❌ Ping test failed")
end

function TestDashboard:RunEventTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Event Test",
	})

	local EventBus = require(script.Parent.Parent.Parent.server.services.EventBus)

	local testEventName = "TestDashboard_Event_" .. tostring(math.random(1000, 9999))
	local eventReceived = false
	local testData = { message = "Test event", number = 42 }

	-- Subscribe to test event
	local unsubscribe = EventBus:Subscribe(testEventName, function(receivedData)
		eventReceived = true
		print("📨 Event received:", receivedData)
	end)

	-- Emit test event
	EventBus:Emit(testEventName, testData)

	-- Wait a bit for event to be processed
	wait(0.5)

	-- Cleanup
	unsubscribe()

	local testResult = {
		testName = "Event Test",
		success = eventReceived,
		result = eventReceived and "Event delivered successfully" or "Event not received",
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(eventReceived and "✅ Event test completed" or "❌ Event test failed")
end

function TestDashboard:RunDataTest()
	if self.state.isTesting then
		return
	end

	self:SetState({
		isTesting = true,
		currentTest = "Data Test",
	})

	local DataService = require(script.Parent.Parent.Parent.server.services.DataService)

	local success, playerData = pcall(function()
		return DataService:GetPlayerData(game.Players.LocalPlayer, "MainData")
	end)

	local testResult = {
		testName = "Data Test",
		success = success,
		result = success and "Data loaded: " .. tostring(playerData.coins) .. " coins" or "Failed to load data",
		timestamp = os.time(),
	}

	local newResults = { testResult }
	for _, existing in ipairs(self.state.testResults) do
		table.insert(newResults, existing)
	end

	self:SetState({
		testResults = newResults,
		isTesting = false,
		currentTest = nil,
	})

	print(success and "✅ Data test completed" or "❌ Data test failed")
end

function TestDashboard:ClearTestResults()
	self:SetState({
		testResults = {},
	})
end

-- ==================== UI RENDERING WITH UI LIBRARY ====================

function TestDashboard:Render()
	-- Use UI Library untuk semua rendering
	local dashboard = UI.Panel:Create({
		size = UDim2.fromScale(1, 1),
		backgroundColor = StyleManager:GetColor("background"),
		padding = { left = 20, right = 20, top = 20, bottom = 20 },
	})

	-- Header
	local header = self:RenderHeader()
	header.Parent = dashboard

	-- Status Section
	local statusSection = self:RenderStatusSection()
	statusSection.Position = UDim2.fromOffset(0, 60)
	statusSection.Parent = dashboard

	-- Controls Section
	local controlsSection = self:RenderControlsSection()
	controlsSection.Position = UDim2.fromOffset(0, 180)
	controlsSection.Parent = dashboard

	-- Results Section
	local resultsSection = self:RenderResultsSection()
	resultsSection.Position = UDim2.fromOffset(0, 320)
	resultsSection.Parent = dashboard

	return dashboard
end

function TestDashboard:RenderHeader()
	local header = UI.Panel:Create({
		size = UDim2.new(1, 0, 0, 50),
		backgroundTransparency = 1,
	})

	local title = UI.Text:Create({
		text = "🚀 OVHL TEST DASHBOARD",
		textSize = 24,
		fontStyle = "bold",
		alignX = Enum.TextXAlignment.Center,
	})
	title.Parent = header

	return header
end

function TestDashboard:RenderStatusSection()
	local section = UI.Utils.CreateSection("📊 SYSTEM STATUS", 110)

	-- Connection Status
	local connectionText = UI.Text:Create({
		text = "Connection: " .. self.state.connectionStatus,
		textColor = self.state.connectionStatus == "Connected" and StyleManager:GetColor("success")
			or StyleManager:GetColor("error"),
		textSize = 14,
		position = UDim2.fromOffset(15, 30),
	})
	connectionText.Parent = section

	-- Performance Metrics
	local metricsText = UI.Text:Create({
		text = string.format(
			"Ping: %dms | Services: %dms | Events: %dms",
			self.state.performanceMetrics.serverPing,
			self.state.performanceMetrics.serviceStartup,
			self.state.performanceMetrics.eventLatency
		),
		textSize = 12,
		textColor = StyleManager:GetColor("textSecondary"),
		position = UDim2.fromOffset(15, 55),
	})
	metricsText.Parent = section

	-- Services Status
	local servicesText = UI.Text:Create({
		text = "Services: " .. (self.state.servicesStatus.RemoteClient or "Checking..."),
		textSize = 12,
		textColor = StyleManager:GetColor("textSecondary"),
		position = UDim2.fromOffset(15, 80),
	})
	servicesText.Parent = section

	return section
end

function TestDashboard:RenderControlsSection()
	local section = UI.Utils.CreateSection("🎯 TEST CONTROLS", 120)

	-- Test Buttons menggunakan UI Library
	local pingButton = UI.Button:Create({
		text = "🏓 Ping Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.fromOffset(15, 30),
		onClick = function()
			self:RunPingTest()
		end,
	})
	pingButton.Parent = section

	local eventButton = UI.Button:Create({
		text = "📡 Event Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.new(0.35, 0, 0, 30),
		onClick = function()
			self:RunEventTest()
		end,
	})
	eventButton.Parent = section

	local dataButton = UI.Button:Create({
		text = "💾 Data Test",
		size = UDim2.new(0.3, 0, 0, 30),
		position = UDim2.new(0.7, 0, 0, 30),
		onClick = function()
			self:RunDataTest()
		end,
	})
	dataButton.Parent = section

	-- Clear Results Button
	local clearButton = UI.Button:Create({
		text = "🗑️ Clear Results",
		size = UDim2.new(0.3, 0, 0, 25),
		position = UDim2.fromOffset(15, 70),
		backgroundColor = StyleManager:GetColor("error"),
		onClick = function()
			self:ClearTestResults()
		end,
	})
	clearButton.Parent = section

	-- Current Test Indicator
	local testIndicator = UI.Text:Create({
		text = self.state.currentTest and "Running: " .. self.state.currentTest or "Ready for tests",
		textColor = self.state.isTesting and StyleManager:GetColor("warning") or StyleManager:GetColor("success"),
		textSize = 12,
		size = UDim2.new(0.6, 0, 0, 25),
		position = UDim2.new(0.35, 0, 0, 70),
	})
	testIndicator.Parent = section

	return section
end

function TestDashboard:RenderResultsSection()
	local section = UI.Utils.CreateSection("📋 TEST RESULTS", 200)

	local scrollContainer = UI.Utils.CreateScrollContainer(160)
	scrollContainer.Position = UDim2.fromOffset(0, 25)
	scrollContainer.Parent = section

	-- Populate with test results
	self:PopulateTestResults(scrollContainer)

	return section
end

function TestDashboard:PopulateTestResults(scrollContainer)
	-- Clear existing results
	for _, child in ipairs(scrollContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	-- Add test result items
	for i, result in ipairs(self.state.testResults) do
		local resultItem = UI.Panel:Create({
			size = UDim2.new(1, -10, 0, 40),
			backgroundColor = result.success and StyleManager:GetColor("success") or StyleManager:GetColor("error"),
			backgroundTransparency = 0.8,
			cornerRadius = 4,
			padding = { left = 10, right = 10, top = 5, bottom = 5 },
		})
		resultItem.Position = UDim2.fromOffset(5, (i - 1) * 45)
		resultItem.Parent = scrollContainer

		-- Test Name and Status
		local statusText = UI.Text:Create({
			text = (result.success and "✅ " or "❌ ") .. result.testName,
			textSize = 14,
			size = UDim2.fromScale(0.6, 1),
		})
		statusText.Parent = resultItem

		-- Response Time or Result
		local resultText = UI.Text:Create({
			text = result.responseTime and string.format("%dms", result.responseTime) or (result.result or ""),
			textSize = 12,
			textColor = StyleManager:GetColor("textSecondary"),
			size = UDim2.fromScale(0.4, 1),
			position = UDim2.fromScale(0.6, 0),
			alignX = Enum.TextXAlignment.Right,
		})
		resultText.Parent = resultItem

		-- Update scroll container size
		scrollContainer.CanvasSize = UDim2.fromOffset(0, i * 45)
	end
end

return TestDashboard
```

---

## 📄 `src/client/test_state.lua`

```lua
-- State Test Script
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

-- Wait for OVHL to be ready
while not OVHL:IsReady() do
    wait(0.1)
end

print("🧪 STATE MANAGEMENT TEST")
print("Initial coins:", OVHL:GetState("coins", 0))
print("Initial health:", OVHL:GetState("health", 100))

-- Test state subscription
OVHL:Subscribe("coins", function(newValue)
    print("🎯 STATE SUBSCRIPTION TRIGGERED - Coins:", newValue)
end)

-- Test setting state
print("Setting coins to 50...")
OVHL:SetState("coins", 50)

print("Setting health to 75...")
OVHL:SetState("health", 75)

print("✅ State test completed")
```

---

## 📄 `src/server/init.server.lua`

```lua
-- OVHL Server Bootstrap v1.2.0
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("🚀 [OVHL] Server bootstrap V.1.2.0 starting (Auto-Discovery)...")

-- Load OVHL Global Accessor first
local ovhlSuccess, OVHL = pcall(function()
	return require(ReplicatedStorage.OVHL_Shared.OVHL_Global)
end)

if not ovhlSuccess then
	warn("⚠ [OVHL] OVHL Global Accessor not available: " .. tostring(OVHL))
else
	-- Expose OVHL globally for backward compatibility (Selene allows this for framework core)
	_G.OVHL = OVHL
	print("🔑 [OVHL] Global Accessor exposed via _G.OVHL")
end

-- Load ServiceManager
local ServiceManager = require(ServerScriptService.OVHL_Server.services.ServiceManager)

-- Initialize ServiceManager
local success, err = pcall(function()
	ServiceManager:Init()
end)

if not success then
	error("❌ [OVHL] ServiceManager Init failed: " .. tostring(err))
end

print("🔍 [OVHL] Auto-discovering services...")

-- Auto-discover and load services
success, err = pcall(function()
	ServiceManager:AutoDiscoverServices(ServerScriptService.OVHL_Server.services)
end)

if not success then
	error("❌ [OVHL] Service discovery failed: " .. tostring(err))
end

print("✅ [OVHL] Server bootstrap V.1.2.0 completed!")
```

---

## 📄 `src/server/modules/gameplay/ExampleModule.lua`

```lua
-- ExampleModule - Demonstrating __config feature
local ExampleModule = {}
ExampleModule.__index = ExampleModule

-- MANIFEST FOR AUTO-DISCOVERY
ExampleModule.__manifest = {
    name = "ExampleModule",
    version = "1.0.0",
    type = "module",
    domain = "gameplay",
    dependencies = {"Logger"},
    autoload = true,
    priority = 50,
    description = "Example module demonstrating __config feature",
}

-- ✅ FASE 3 FEATURE: __config for default settings
ExampleModule.__config = {
    debugMode = true,
    maxPlayers = 10,
    welcomeMessage = "Welcome to OVHL Framework!",
    features = {
        events = true,
        logging = true,
        analytics = false
    }
}

function ExampleModule:Init()
    print("🔧 ExampleModule initialized with __config support")
    return true
end

function ExampleModule:Start()
    print("🎯 ExampleModule starting with FASE 3 features...")

    -- Get OVHL Global Accessor
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)

    if not success then
        warn("⚠ ExampleModule: OVHL not available - " .. tostring(OVHL))
        return true
    end

    -- Get Logger service
    local logger = OVHL:GetService("Logger")

    -- ✅ FASE 3 FEATURE: Access config via ConfigService
    local config = OVHL:GetConfig("ExampleModule")
    if config then
        if logger then
            logger:Info("ExampleModule config loaded successfully", {
                debugMode = config.debugMode,
                maxPlayers = config.maxPlayers,
                featureCount = #config.features
            })
        end

        -- Use config values
        if config.debugMode then
            print("🔧 Debug mode: ENABLED")
        end

        if config.welcomeMessage then
            print("💬 " .. config.welcomeMessage)
        end
    else
        if logger then
            logger:Warn("ExampleModule config not available")
        end
        print("⚠ ExampleModule: Using default config (fallback)")
    end

    -- Subscribe to events dengan enhanced error handling
    OVHL:Subscribe("PlayerJoined", function(player)
        -- ✅ FASE 3 FEATURE: pcall pada semua event handlers
        local success, err = pcall(function()
            self:HandlePlayerJoined(player)
        end)

        if not success and logger then
            logger:Error("PlayerJoined handler failed", {
                player = player.Name,
                error = err
            })
        end
    end)

    print("✅ ExampleModule FASE 3 features activated!")
    return true
end

function ExampleModule:HandlePlayerJoined(player)
    -- Get fresh config in case it changed
    local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    local config = OVHL:GetConfig("ExampleModule")

    if config and config.welcomeMessage then
        print("👋 " .. player.Name .. ": " .. config.welcomeMessage)
    else
        print("👋 Welcome, " .. player.Name .. "!")
    end
end

-- Method untuk demonstrate config access
function ExampleModule:GetModuleConfig()
    local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    return OVHL:GetConfig("ExampleModule") or self.__config
end

-- Method untuk demonstrate config update
function ExampleModule:UpdateConfig(newConfig)
    local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    local configService = OVHL:GetService("ConfigService")

    if configService then
        return configService:Set("ExampleModule", newConfig)
    end
    return false
end

return ExampleModule
```

---

## 📄 `src/server/modules/HUDTestHandler.lua`

```lua
-- HUDTestHandler v1.0.0 - Test Server Handler
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local HUDTestHandler = {}
HUDTestHandler.__index = HUDTestHandler

HUDTestHandler.__manifest = {
    name = "HUDTestHandler",
    version = "1.0.0",
    type = "module",
    domain = "test",
    dependencies = {"Logger", "RemoteManager"}
}

function HUDTestHandler:Start()
    self.logger = OVHL:GetService("Logger")

    -- Register handler for HUD test events
    local remoteManager = OVHL:GetService("RemoteManager")
    remoteManager:RegisterHandler("HUDTestEvent", function(player, message)
        self:HandleHUDTestEvent(player, message)
    end)

    self.logger:Info("HUDTestHandler started - Listening for HUD events")
end

function HUDTestHandler:HandleHUDTestEvent(player, message)
    self.logger:Info("HUD Test Event from " .. player.Name, {
        message = message,
        timestamp = os.time()
    })

    print("🎯 HUD Test Event Received!")
    print("   Player: " .. player.Name)
    print("   Message: " .. tostring(message))
    print("   Server Time: " .. os.date("%X"))

    -- You could send a response back to client here
    -- remoteManager:FireClient(player, "ServerResponse", "Event received!")

    return { success = true, received = true }
end

return HUDTestHandler
```

---

## 📄 `src/server/services/ConfigService.lua`

```lua
-- ConfigService v1.0.0
-- Configuration management service
local ConfigService = {}
ConfigService.__index = ConfigService

-- MANIFEST FOR AUTO-DISCOVERY
ConfigService.__manifest = {
    name = "ConfigService",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 90,
    description = "Configuration management service"
}

function ConfigService:Init()
    self.configs = {}

    -- Get Logger via OVHL pattern
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)

    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        if self.logger then
            self.logger:Info("ConfigService initialized with OVHL")
        end
    end

    print("🔧 ConfigService initialized")
    return true
end

function ConfigService:Start()
    if self.logger then
        self.logger:Info("ConfigService started")
    else
        print("✅ ConfigService started")
    end
    return true
end

function ConfigService:RegisterDefaultConfig(moduleName, configTable)
    if not self.configs[moduleName] then
        self.configs[moduleName] = configTable

        if self.logger then
            self.logger:Debug("Default config registered", {
                module = moduleName,
                configKeys = table.concat(table.keys(configTable), ", ")
            })
        end
        return true
    end
    return false
end

function ConfigService:Get(moduleName, defaultValue)
    local config = self.configs[moduleName]

    if config then
        if self.logger then
            self.logger:Debug("Config retrieved", {
                module = moduleName,
                hasConfig = true
            })
        end
        return config
    end

    if self.logger then
        self.logger:Debug("Config not found, using default", {
            module = moduleName,
            hasConfig = false
        })
    end

    return defaultValue or {}
end

function ConfigService:Set(moduleName, value)
    self.configs[moduleName] = value

    if self.logger then
        self.logger:Info("Config updated", {
            module = moduleName
        })
    end
    return true
end

function ConfigService:GetAllConfigs()
    return self.configs
end

return ConfigService
```

---

## 📄 `src/server/services/DataService.lua`

```lua
-- DataService v1 - Simple Data
local DataService = {}
DataService.__index = DataService

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
DataService.__manifest = {
    name = "DataService",
    version = "1.0.0",
    type = "service",
    domain = "data",
    dependencies = {"Logger"},
    autoload = true,
    priority = 80,
    description = "Data persistence and management service"
}

function DataService:Init()
    self.dataStores = {}
    print("🔧 DataService initialized")
    return true
end

function DataService:Start()
    print("💾 DataService started")
    return true
end

function DataService:RegisterDataStore(storeName, defaultData)
    self.dataStores[storeName] = {
        default = defaultData or {}
    }
    return true
end

function DataService:GetPlayerData(_player, storeName)
    local storeConfig = self.dataStores[storeName]
    if not storeConfig then
        return false, "DataStore not registered: " .. storeName
    end

    local mockData = {
        coins = 1000,
        gems = 100,
        level = 1,
        experience = 0,
        health = 100,
        maxHealth = 100,
        inventory = {"Starter Sword", "Health Potion"},
        lastLogin = os.time(),
        playtime = 0
    }

    return true, mockData
end

function DataService:SetPlayerData(player, storeName, _data)
    print("💾 Saved data for:", player.Name, storeName)
    return true
end

return DataService
```

---

## 📄 `src/server/services/EventBus.lua`

```lua
-- EventBus Service v1.0.0
-- Event-driven communication system for internal server events
local EventBus = {}
EventBus.__index = EventBus

-- MANIFEST FOR AUTO-DISCOVERY
EventBus.__manifest = {
    name = "EventBus",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 95,
    description = "Event-driven communication system"
}

function EventBus:Init()
    self.events = {}
    self.subscriptionId = 0

    -- ✅ USING OVHL INSTEAD OF MANUAL REQUIRE
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)

    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        if self.logger then
            self.logger:Info("EventBus initialized with OVHL integration")
        else
            print("🔧 EventBus initialized (Logger service pending)")
        end
    else
        print("🔧 EventBus initialized (OVHL not available)")
    end

    return true
end

function EventBus:Start()
    if self.logger then
        self.logger:Info("EventBus service started")
    else
        print("✅ EventBus service started")
    end
    return true
end

-- Emit an event to all subscribers
function EventBus:Emit(eventName, ...)
    if not self.events[eventName] then
        return 0
    end

    local args = {...}
    local subscriberCount = 0

    for id, callback in pairs(self.events[eventName]) do
        subscriberCount = subscriberCount + 1

        -- ✅ FASE 3: ENHANCED ERROR HANDLING
        local success, result = pcall(function()
            return callback(unpack(args))
        end)

        if not success then
            if self.logger then
                self.logger:Error("EventBus callback failed: " .. eventName, {
                    error = result,
                    subscriptionId = id
                })
            else
                warn("⚠ EventBus callback failed: " .. eventName .. " - " .. tostring(result))
            end
        end
    end

    return subscriberCount
end

-- Subscribe to an event
function EventBus:Subscribe(eventName, callback)
    if not self.events[eventName] then
        self.events[eventName] = {}
    end

    self.subscriptionId = self.subscriptionId + 1
    local subscriptionId = self.subscriptionId

    self.events[eventName][subscriptionId] = callback

    if self.logger then
        self.logger:Debug("Event subscription created", {
            event = eventName,
            subscriptionId = subscriptionId
        })
    end

    -- Return unsubscribe function
    return function()
        if self.events[eventName] then
            self.events[eventName][subscriptionId] = nil

            -- Clean up empty event tables
            if next(self.events[eventName]) == nil then
                self.events[eventName] = nil
            end

            if self.logger then
                self.logger:Debug("Event subscription removed", {
                    event = eventName,
                    subscriptionId = subscriptionId
                })
            end
        end
    end
end

-- Unsubscribe from an event
function EventBus:Unsubscribe(eventName, callback)
    if not self.events[eventName] then
        return false
    end

    for id, cb in pairs(self.events[eventName]) do
        if cb == callback then
            self.events[eventName][id] = nil

            -- Clean up empty event tables
            if next(self.events[eventName]) == nil then
                self.events[eventName] = nil
            end

            if self.logger then
                self.logger:Debug("Event subscription removed via Unsubscribe", {
                    event = eventName,
                    subscriptionId = id
                })
            end

            return true
        end
    end

    return false
end

-- Get event statistics
function EventBus:GetStats()
    local stats = {
        totalEvents = 0,
        totalSubscriptions = 0,
        events = {}
    }

    for eventName, subscriptions in pairs(self.events) do
        stats.totalEvents = stats.totalEvents + 1
        local subCount = 0
        for _ in pairs(subscriptions) do
            subCount = subCount + 1
        end
        stats.totalSubscriptions = stats.totalSubscriptions + subCount
        stats.events[eventName] = subCount
    end

    return stats
end

return EventBus
```

---

## 📄 `src/server/services/Logger.lua`

```lua
-- Logger Service v1.0.0
-- Core logging service for structured logging
local Logger = {}
Logger.__index = Logger

-- MANIFEST FOR AUTO-DISCOVERY
Logger.__manifest = {
    name = "Logger",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core logging service for structured logging"
}

function Logger:Init()
    self.levels = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4
    }

    self.currentLevel = self.levels.INFO
    print("🔧 Logger initialized with OVHL pattern")
    return true
end

function Logger:Start()
    print("✅ Logger service started")
    return true
end

function Logger:Log(level, message, data)
    if self.levels[level] < self.currentLevel then
        return false
    end

    local timestamp = DateTime.now():FormatLocalTime("LTS", "en-US")
    local logEntry = string.format("[%s] %s: %s", timestamp, level, message)

    if data then
        logEntry = logEntry .. " | " .. game:GetService("HttpService"):JSONEncode(data)
    end

    print(logEntry)
    return true
end

function Logger:Debug(message, data)
    return self:Log("DEBUG", message, data)
end

function Logger:Info(message, data)
    return self:Log("INFO", message, data)
end

function Logger:Warn(message, data)
    return self:Log("WARN", message, data)
end

function Logger:Error(message, data)
    return self:Log("ERROR", message, data)
end

function Logger:SetLogLevel(level)
    if self.levels[level] then
        self.currentLevel = self.levels[level]
        return true
    end
    return false
end

function Logger:GetLogLevel()
    for name, value in pairs(self.levels) do
        if value == self.currentLevel then
            return name
        end
    end
    return "UNKNOWN"
end

return Logger
```

---

## 📄 `src/server/services/ModuleLoader.lua`

```lua
-- ModuleLoader Service v1.0.0
-- Dynamic module loading with auto-discovery
local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

-- MANIFEST FOR AUTO-DISCOVERY
ModuleLoader.__manifest = {
    name = "ModuleLoader",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger", "EventBus", "ConfigService", "DataService", "RemoteManager"},
    autoload = true,
    priority = 50,
    description = "Dynamic module loading with auto-discovery"
}

function ModuleLoader:Init()
    self.modules = {}
    self.logger = nil
    self.configService = nil

    print("🔧 ModuleLoader v1 initialized (Auto-Discovery)")
    return true
end

function ModuleLoader:Start()
    -- Get services via OVHL pattern
    local success, OVHL = pcall(function()
        return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)
    end)

    if success and OVHL then
        self.logger = OVHL:GetService("Logger")
        self.configService = OVHL:GetService("ConfigService")
        self.eventBus = OVHL:GetService("EventBus")

        if self.logger then
            self.logger:Info("ModuleLoader started with OVHL integration")
        end
    end

    print("✅ ModuleLoader service started")
    return true
end

function ModuleLoader:AutoDiscoverModules(modulesFolder)
    if not modulesFolder then
        error("ModuleLoader: modulesFolder is required")
    end

    local discoveredCount = 0
    local loadedCount = 0

    -- Recursively find all ModuleScripts
    local function scanFolder(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("ModuleScript") then
                discoveredCount = discoveredCount + 1

                -- Safe module loading dengan pcall
                local success, result = pcall(function()
                    return self:LoadModule(child)
                end)

                if success then
                    loadedCount = loadedCount + 1
                    if self.logger then
                        self.logger:Debug("Module loaded successfully", {
                            module = child.Name,
                            path = child:GetFullName()
                        })
                    end
                else
                    if self.logger then
                        self.logger:Error("Module load failed", {
                            module = child.Name,
                            error = result,
                            path = child:GetFullName()
                        })
                    else
                        warn("❌ Module load failed: " .. child.Name .. " - " .. tostring(result))
                    end
                end
            elseif child:IsA("Folder") then
                scanFolder(child) -- Recursive scan
            end
        end
    end

    if self.logger then
        self.logger:Info("Starting module auto-discovery", {
            folder = modulesFolder:GetFullName()
        })
    end

    -- Start discovery
    scanFolder(modulesFolder)

    if self.logger then
        self.logger:Info("Module discovery completed", {
            discovered = discoveredCount,
            loaded = loadedCount,
            failed = discoveredCount - loadedCount
        })
    end

    return loadedCount > 0
end

function ModuleLoader:LoadModule(moduleScript)
    local module = require(moduleScript)

    if not module then
        error("Module returned nil: " .. moduleScript.Name)
    end

    -- Validate module has required structure
    if not module.__manifest then
        error("Module missing __manifest: " .. moduleScript.Name)
    end

    local moduleName = module.__manifest.name or moduleScript.Name

    -- ✅ FASE 3 FEATURE: Auto-register __config if present
    if module.__config and self.configService then
        local success, err = pcall(function()
            self.configService:RegisterDefaultConfig(moduleName, module.__config)
        end)

        if success then
            if self.logger then
                self.logger:Debug("Module config auto-registered", {
                    module = moduleName,
                    configKeys = table.concat(table.keys(module.__config), ", ")
                })
            end
        else
            if self.logger then
                self.logger:Warn("Module config registration failed", {
                    module = moduleName,
                    error = err
                })
            end
        end
    end

    -- Store module reference
    self.modules[moduleName] = {
        instance = module,
        script = moduleScript,
        manifest = module.__manifest,
        config = module.__config
    }

    -- Initialize module dengan pcall
    if module.Init then
        local success, err = pcall(module.Init, module)
        if not success then
            error("Module Init failed: " .. moduleName .. " - " .. tostring(err))
        end
    end

    -- Start module dengan pcall
    if module.Start then
        local success, err = pcall(module.Start, module)
        if not success then
            error("Module Start failed: " .. moduleName .. " - " .. tostring(err))
        end
    end

    -- Emit event untuk module loaded
    if self.eventBus then
        self.eventBus:Emit("ModuleLoaded", moduleName, module)
    end

    return module
end

function ModuleLoader:GetModule(moduleName)
    local moduleData = self.modules[moduleName]
    if moduleData then
        return moduleData.instance
    end
    return nil
end

function ModuleLoader:GetModuleInfo(moduleName)
    local moduleData = self.modules[moduleName]
    if moduleData then
        return {
            name = moduleName,
            manifest = moduleData.manifest,
            config = moduleData.config,
            script = moduleData.script,
            path = moduleData.script:GetFullName()
        }
    end
    return nil
end

function ModuleLoader:GetAllModules()
    local modules = {}
    for name, data in pairs(self.modules) do
        modules[name] = {
            manifest = data.manifest,
            config = data.config,
            path = data.script:GetFullName()
        }
    end
    return modules
end

return ModuleLoader
```

---

## 📄 `src/server/services/RemoteManager.lua`

```lua
-- RemoteManager v1 - Simple Communication
local RemoteManager = {}
RemoteManager.__index = RemoteManager

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
RemoteManager.__manifest = {
    name = "RemoteManager",
    version = "1.0.0",
    type = "service",
    domain = "network",
    dependencies = {"Logger", "EventBus"},
    autoload = true,
    priority = 75,
    description = "Client-server communication manager"
}

function RemoteManager:Init()
    self.handlers = {}
    print("🔧 RemoteManager initialized")
    return true
end

function RemoteManager:Start()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Create remote objects
    self.remoteFolder = Instance.new("Folder")
    self.remoteFolder.Name = "OVHL_Remotes"
    self.remoteFolder.Parent = ReplicatedStorage

    self.mainEvent = Instance.new("RemoteEvent")
    self.mainEvent.Name = "MainRemoteEvent"
    self.mainEvent.Parent = self.remoteFolder

    self.mainFunction = Instance.new("RemoteFunction")
    self.mainFunction.Name = "MainRemoteFunction"
    self.mainFunction.Parent = self.remoteFolder

    -- Set up listeners
    self.mainEvent.OnServerEvent:Connect(function(player, eventName, ...)
        local args = {...}
        self:_handleEvent(player, eventName, unpack(args))
    end)

    self.mainFunction.OnServerInvoke = function(player, eventName, ...)
        local args = {...}
        return self:_handleInvoke(player, eventName, unpack(args))
    end

    print("📡 RemoteManager started")
    return true
end

function RemoteManager:RegisterHandler(eventName, handler)
    self.handlers[eventName] = handler
    return true
end

function RemoteManager:_handleEvent(player, eventName, ...)
    local handler = self.handlers[eventName]
    if handler then
        local success, err = pcall(handler, player, ...)
        if not success then
            warn("❌ Event handler failed:", eventName, err)
        end
    end
end

function RemoteManager:_handleInvoke(player, eventName, ...)
    local handler = self.handlers[eventName]
    if handler then
        local success, result = pcall(handler, player, ...)
        if success then
            return result
        else
            return false, result
        end
    end
    return false, "No handler for: " .. eventName
end

function RemoteManager:FireClient(player, eventName, ...)
    self.mainEvent:FireClient(player, eventName, ...)
    return true
end

return RemoteManager
```

---

## 📄 `src/server/services/ServiceManager.lua`

```lua
-- ServiceManager v6 - WITH AUTO-DISCOVERY
local ServiceManager = {}
ServiceManager.__index = ServiceManager

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
ServiceManager.__manifest = {
    name = "ServiceManager",
    version = "1.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core service management with auto-discovery"
}

function ServiceManager:Init()
	self.services = {}
	self.serviceStates = {}
	print("🔧 ServiceManager v6 initialized (Auto-Discovery)")
	return true
end

function ServiceManager:Start()
	print("🚀 Starting all services...")

	for serviceName, service in pairs(self.services) do
		if service.Start then
			local success, err = pcall(service.Start, service)
			if success then
				self.serviceStates[serviceName] = "STARTED"
				print("✅ Service started:", serviceName)
			else
				self.serviceStates[serviceName] = "FAILED"
				warn("❌ Failed to start " .. serviceName .. ":", err)
			end
		else
			self.serviceStates[serviceName] = "READY"
			print("✅ Service ready:", serviceName)
		end
	end

	print("🎉 All services started!")
	return true
end

function ServiceManager:RegisterService(serviceName, serviceModule)
	self.services[serviceName] = serviceModule
	self.serviceStates[serviceName] = "REGISTERED"

	if serviceModule.Init then
		local success, err = pcall(serviceModule.Init, serviceModule)
		if success then
			print("🔧 Service initialized:", serviceName)
		else
			warn("❌ Failed to init " .. serviceName .. ":", err)
		end
	end

	print("📝 Registered service:", serviceName)
	return true
end

-- AUTO-DISCOVERY FEATURE
function ServiceManager:AutoDiscoverServices(servicesFolder)
	if not servicesFolder then
		warn("⚠️ No services folder provided for auto-discovery")
		return false
	end

	print("🔍 Auto-discovering services...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	-- Discover all services
	for _, moduleScript in ipairs(servicesFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "ServiceManager" then
			local success, serviceModule = pcall(require, moduleScript)

			if success and serviceModule then
				local manifest, err = ModuleManifest:GetFromModule(serviceModule, moduleScript.Name)

				if manifest then
					discovered[moduleScript.Name] = {
						module = serviceModule,
						manifest = manifest,
					}
					resolver:AddModule(moduleScript.Name, manifest)
					print("📦 Discovered:", moduleScript.Name, "v" .. manifest.version)
				else
					warn("⚠️ Failed to parse manifest for:", moduleScript.Name, err)
				end
			else
				warn("❌ Failed to require:", moduleScript.Name, serviceModule)
			end
		end
	end

	-- Resolve dependencies
	local loadOrder = resolver:Resolve()

	print("📋 Load order resolved (" .. #loadOrder .. " services):")
	for i, serviceName in ipairs(loadOrder) do
		print("  " .. i .. ". " .. serviceName)
	end

	-- Register in dependency order
	for _, serviceName in ipairs(loadOrder) do
		local item = discovered[serviceName]
		if item and item.manifest.autoload then
			self:RegisterService(serviceName, item.module)
		end
	end

	print("✅ Auto-discovery complete: " .. #loadOrder .. " services registered")
	return true
end

function ServiceManager:GetService(serviceName)
	local service = self.services[serviceName]
	if not service then
		error("Service not found: " .. serviceName)
	end
	return service
end

function ServiceManager:GetServiceCount()
	local count = 0
	for _ in pairs(self.services) do
		count = count + 1
	end
	return count
end

return ServiceManager
```

---

## 📄 `src/shared/OVHL_Global.lua`

```lua
-- OVHL Global Accessor v1.2.0
-- Single entry point for all OVHL framework APIs

local OVHL = {}
OVHL.__index = OVHL

-- Internal service storage
OVHL._services = {}
OVHL._modules = {}
OVHL._stateManager = nil
OVHL._remoteClient = nil

-- ===================================================
-- CORE API METHODS
-- ===================================================

-- Get a service by name (Server) or controller (Client)
function OVHL:GetService(name)
    if self._services[name] then
        return self._services[name]
    end
    return nil
end

-- Get a module by name
function OVHL:GetModule(name)
    if self._modules[name] then
        return self._modules[name]
    end
    return nil
end

-- Get module configuration
function OVHL:GetConfig(moduleName)
    local configService = self:GetService("ConfigService")
    if configService then
        return configService:Get(moduleName)
    end
    return nil
end

-- ===================================================
-- SERVER-SIDE API SHORTCUTS
-- ===================================================

-- Emit internal server event
function OVHL:Emit(eventName, ...)
    local eventBus = self:GetService("EventBus")
    if eventBus then
        return eventBus:Emit(eventName, ...)
    end
    return 0
end

-- Subscribe to internal server event
function OVHL:Subscribe(eventName, callback)
    local eventBus = self:GetService("EventBus")
    if eventBus then
        return eventBus:Subscribe(eventName, callback)
    end
    return function() end
end

-- ===================================================
-- CLIENT-SIDE API SHORTCUTS
-- ===================================================

-- Set state value
function OVHL:SetState(key, value)
    if self._stateManager then
        return self._stateManager:Set(key, value)
    end
    return false
end

-- Get state value
function OVHL:GetState(key, defaultValue)
    if self._stateManager then
        return self._stateManager:Get(key, defaultValue)
    end
    return defaultValue
end

-- Fire event to server
function OVHL:Fire(eventName, ...)
    if self._remoteClient then
        return self._remoteClient:Fire(eventName, ...)
    end
    return false
end

-- Invoke server function
function OVHL:Invoke(eventName, ...)
    if self._remoteClient then
        return self._remoteClient:Invoke(eventName, ...)
    end
    return nil
end

-- Listen to server events
function OVHL:Listen(eventName, callback)
    if self._remoteClient then
        return self._remoteClient:Listen(eventName, callback)
    end
    return nil
end

-- ===================================================
-- INTERNAL METHODS (Framework use only)
-- ===================================================

-- Register a service (used by ServiceManager)
function OVHL:_registerService(name, service)
    self._services[name] = service

    -- Special handling for client controllers
    if name == "StateManager" then
        self._stateManager = service
    elseif name == "RemoteClient" then
        self._remoteClient = service
    end
end

-- Register a module (used by ModuleLoader/ClientController)
function OVHL:_registerModule(name, module)
    self._modules[name] = module
end

-- Check if OVHL is ready
function OVHL:IsReady()
    return next(self._services) ~= nil
end

return OVHL
```

---

## 📄 `src/shared/utils/ClientController.lua`

```lua
-- ClientController.lua - Client-side Auto-Discovery
local ClientController = {}
ClientController.__index = ClientController

function ClientController:Init()
	self.controllers = {}
	self.modules = {}
	print("🔧 ClientController initialized")
	return true
end

-- Auto-discover controllers
function ClientController:AutoDiscoverControllers(controllersFolder)
	if not controllersFolder then
		warn("⚠️ No controllers folder provided")
		return false
	end

	print("🔍 Auto-discovering controllers...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage.OVHL_Shared.utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	-- Discover all controllers
	for _, moduleScript in ipairs(controllersFolder:GetChildren()) do
		if moduleScript:IsA("ModuleScript") then
			local success, controllerModule = pcall(require, moduleScript)

			if success and controllerModule then
				local manifest, err = ModuleManifest:GetFromModule(controllerModule, moduleScript.Name)

				if manifest then
					discovered[moduleScript.Name] = {
						module = controllerModule,
						manifest = manifest,
						instance = nil,
					}
					resolver:AddModule(moduleScript.Name, manifest)
					print("📦 Discovered controller:", moduleScript.Name, "v" .. manifest.version)
				else
					warn("⚠️ Failed to parse manifest for:", moduleScript.Name, err)
				end
			else
				warn("❌ Failed to require:", moduleScript.Name, controllerModule)
			end
		end
	end

	-- Resolve dependencies and get load order
	local loadOrder = resolver:Resolve()

	print("📋 Controller load order (" .. #loadOrder .. " controllers):")
	for i, controllerName in ipairs(loadOrder) do
		print("  " .. i .. ". " .. controllerName)
	end

	-- Initialize controllers in dependency order
	for _, controllerName in ipairs(loadOrder) do
		local item = discovered[controllerName]
		if item and item.manifest.autoload then
			local controllerInstance = setmetatable({}, item.module)

			-- Initialize controller
			if controllerInstance.Init then
				local success, err = pcall(controllerInstance.Init, controllerInstance)
				if success then
					print("🔧 Controller initialized:", controllerName)
				else
					warn("❌ Failed to init " .. controllerName .. ":", err)
				end
			end

			self.controllers[controllerName] = controllerInstance
			item.instance = controllerInstance
		end
	end

	-- Start controllers in order
	for _, controllerName in ipairs(loadOrder) do
		local item = discovered[controllerName]
		if item and item.instance and item.instance.Start then
			local success, err = pcall(item.instance.Start, item.instance)
			if success then
				print("✅ Controller started:", controllerName)
			else
				warn("❌ Failed to start " .. controllerName .. ":", err)
			end
		end
	end

	print("✅ Auto-discovery complete: " .. #loadOrder .. " controllers registered")
	return true
end

-- Auto-discover UI modules
function ClientController:AutoDiscoverModules(modulesFolder, uiController)
	if not modulesFolder then
		print("ℹ️ No modules folder found")
		return true
	end

	print("📦 Auto-discovering UI modules...")

	local ModuleManifest = require(game.ReplicatedStorage.OVHL_Shared.utils.ModuleManifest)
	local DependencyResolver = require(game.ReplicatedStorage.OVHL_Shared.utils.DependencyResolver)

	local resolver = DependencyResolver:New()
	local discovered = {}

	local function discoverInFolder(folder, domain)
		for _, item in ipairs(folder:GetChildren()) do
			if item:IsA("Folder") then
				discoverInFolder(item, item.Name)
			elseif item:IsA("ModuleScript") then
				local success, moduleTable = pcall(require, item)

				if success and moduleTable then
					local manifest, err = ModuleManifest:GetFromModule(moduleTable, item.Name)

					if manifest then
						if domain then
							manifest.domain = domain
						end

						discovered[item.Name] = {
							module = moduleTable,
							manifest = manifest,
						}
						resolver:AddModule(item.Name, manifest)
						print(
							"📦 Discovered module:",
							item.Name,
							"(" .. manifest.domain .. ")",
							"v" .. manifest.version
						)
					else
						warn("⚠️ Failed to parse manifest for:", item.Name, err)
					end
				else
					warn("❌ Failed to require:", item.Name, moduleTable)
				end
			end
		end
	end

	discoverInFolder(modulesFolder, nil)

	local loadOrder = resolver:Resolve()

	print("📋 Module load order (" .. #loadOrder .. " modules):")
	for i, moduleName in ipairs(loadOrder) do
		local item = discovered[moduleName]
		if item then
			print("  " .. i .. ". " .. moduleName .. " [" .. item.manifest.domain .. "]")
		end
	end

	-- Register modules with UIController
	for _, moduleName in ipairs(loadOrder) do
		local item = discovered[moduleName]
		if item and item.manifest.autoload then
			self.modules[moduleName] = item.module

			-- Auto-register dengan UIController jika ada
			if uiController and uiController.RegisterScreen then
				uiController:RegisterScreen(moduleName, item.module)
				print("🖥️ Screen registered:", moduleName)
			end
		end
	end

	print("🎉 Module discovery complete: " .. #loadOrder .. " modules processed")
	return true
end

-- Get controller by name
function ClientController:GetController(controllerName)
	return self.controllers[controllerName]
end

-- Get module by name
function ClientController:GetModule(moduleName)
	return self.modules[moduleName]
end

-- Auto-show initial screen
function ClientController:ShowInitialScreen(uiController, defaultScreen)
	if not uiController or not defaultScreen then
		return
	end

	local module = self.modules[defaultScreen]
	if module then
		uiController:ShowScreen(defaultScreen)
		print("🖥️ Initial screen shown:", defaultScreen)
		return true
	else
		warn("⚠️ Default screen not found:", defaultScreen)
		return false
	end
end

return ClientController
```

---

## 📄 `src/shared/utils/DependencyResolver.lua`

```lua
-- DependencyResolver.lua - Dependency Graph & Load Order
local DependencyResolver = {}

function DependencyResolver:New()
	local resolver = {
		modules = {},
		graph = {},
		resolved = {},
		visited = {},
		resolving = {},
	}
	setmetatable(resolver, { __index = self })
	return resolver
end

function DependencyResolver:AddModule(name, manifest)
	self.modules[name] = manifest
	self.graph[name] = manifest.dependencies or {}
end

function DependencyResolver:_detectCycle(name, path)
	if self.resolving[name] then
		local cycle = table.concat(path, " -> ") .. " -> " .. name
		return true, "Circular dependency detected: " .. cycle
	end
	return false, nil
end

function DependencyResolver:_resolve(name, path)
	path = path or {}
	table.insert(path, name)

	if self.visited[name] then
		return true
	end

	local hasCycle, cycleError = self:_detectCycle(name, path)
	if hasCycle then
		return false, cycleError
	end

	self.resolving[name] = true

	local deps = self.graph[name] or {}
	for _, depName in ipairs(deps) do
		if not self.modules[depName] then
			warn("⚠️ Missing dependency: " .. name .. " requires " .. depName)
		else
			local success, err = self:_resolve(depName, path)
			if not success then
				return false, err
			end
		end
	end

	self.visited[name] = true
	self.resolving[name] = nil
	table.insert(self.resolved, name)

	return true
end

function DependencyResolver:Resolve()
	self.resolved = {}
	self.visited = {}
	self.resolving = {}

	local sortedModules = {}
	for name, manifest in pairs(self.modules) do
		table.insert(sortedModules, { name = name, priority = manifest.priority or 50 })
	end

	table.sort(sortedModules, function(a, b)
		return a.priority > b.priority
	end)

	for _, item in ipairs(sortedModules) do
		if not self.visited[item.name] then
			local success, err = self:_resolve(item.name)
			if not success then
				error("Dependency resolution failed: " .. err)
			end
		end
	end

	return self.resolved
end

return DependencyResolver
```

---

## 📄 `src/shared/utils/ModuleManifest.lua`

```lua
-- ModuleManifest.lua - Manifest Validator & Parser
local ModuleManifest = {}
ModuleManifest.__index = ModuleManifest

function ModuleManifest:Validate(manifest, moduleName)
	if not manifest then
		return false, "No manifest found for: " .. moduleName
	end

	if not manifest.name then
		return false, moduleName .. " missing required field: name"
	end

	if not manifest.version then
		return false, moduleName .. " missing required field: version"
	end

	if not manifest.type then
		return false, moduleName .. " missing required field: type"
	end

	local validTypes = { service = true, controller = true, module = true, component = true }
	if not validTypes[manifest.type] then
		return false, moduleName .. " has invalid type: " .. manifest.type
	end

	if manifest.domain then
		local validDomains = { gameplay = true, ui = true, network = true, data = true, system = true, core = true }
		if not validDomains[manifest.domain] then
			warn(moduleName .. " has unknown domain: " .. manifest.domain)
		end
	end

	return true, "Valid manifest"
end

function ModuleManifest:Parse(manifest, moduleName)
	return {
		name = manifest.name or moduleName,
		version = manifest.version or "0.0.0",
		type = manifest.type or "module",
		domain = manifest.domain or "system",
		dependencies = manifest.dependencies or {},
		autoload = manifest.autoload ~= false,
		priority = manifest.priority or 50,
		description = manifest.description or "",
	}
end

function ModuleManifest:GetFromModule(moduleTable, moduleName)
	if type(moduleTable) ~= "table" then
		return nil, "Module is not a table"
	end

	local manifest = moduleTable.__manifest
	if not manifest then
		-- Fallback for legacy modules
		return {
			name = moduleName,
			version = "0.0.0",
			type = "module",
			domain = "system",
			dependencies = {},
			autoload = true,
			priority = 50,
			description = "Legacy module without manifest",
		},
			"Using fallback manifest"
	end

	local isValid, err = self:Validate(manifest, moduleName)
	if not isValid then
		return nil, err
	end

	return self:Parse(manifest, moduleName), nil
end

return ModuleManifest
```

---

## ⚙️ `default.project.json`

````json
{
  "name": "ovhl-core-v6",
  "tree": {
    "$className": "DataModel",

    "ServerScriptService": {
      "$className": "ServerScriptService",
      "OVHL_Server": {
        "$path": "src/server"
      }
    },

    "ReplicatedStorage": {
      "$className": "ReplicatedStorage",
      "OVHL_Shared": {
        "$path": "src/shared"
      }
    },

    "StarterPlayer": {
      "$className": "StarterPlayer",
      "StarterPlayerScripts": {
        "$className": "StarterPlayerScripts",
        "OVHL_Client": {
          "$path": "src/client"
        }
      }
    }
  }
}```

---

## ⚙️ `selene.toml`

```json
std = "roblox"

[globals.roblox]
-- Roblox built-in globals
"game" = "read",
"script" = "read",
"workspace" = "read",
"shared" = "read",

-- OVHL Framework globals (allowed for framework core)
"OVHL" = "read",

[lint]
unused_variable = true
unused_function = false
unused_label = false
unused_argument = false
redefined_variable = false
trailing_whitespace = false
line_length = { enabled = false, limit = 120 }
cyclomatic_complexity = { enabled = false, limit = 20 }
redundant_parameter = false
shadowing = false
empty_if = false
if_same_then_else = false
if_same_condition = false
prefer_and_or = false
unbalanced_assignments = false
misleading_local = false
increment_decrement = false

[lint.global_usage]
allow = ["OVHL"]  # Allow _G.OVHL for framework

[lint.unscoped_variables]
enabled = true

[lint.undefined_variable]
enabled = true

[lint.undefined_global]
enabled = true
````

---

## 🔗 DEPENDENCY ANALYSIS

### Server Services Dependencies:

#### `ConfigService`

- **File:** `src/server/services/ConfigService.lua`
- **Dependencies:** dependencies, =, {Logger}, description, =, Configuration, management, service

#### `DataService`

- **File:** `src/server/services/DataService.lua`
- **Dependencies:** dependencies, =, {Logger}, description, =, Data, persistence, and, management, service

#### `EventBus`

- **File:** `src/server/services/EventBus.lua`
- **Dependencies:** dependencies, =, {Logger}, description, =, Event-driven, communication, system

#### `Logger`

- **File:** `src/server/services/Logger.lua`
- **Dependencies:** description, =, Core, logging, service, for, structured, logging

#### `ModuleLoader`

- **File:** `src/server/services/ModuleLoader.lua`
- **Dependencies:** dependencies, =, {Logger, EventBus, ConfigService, DataService, RemoteManager}, description, =, Dynamic, module, loading, with, auto-discovery

#### `RemoteManager`

- **File:** `src/server/services/RemoteManager.lua`
- **Dependencies:** dependencies, =, {Logger, EventBus}, description, =, Client-server, communication, manager

#### `ServiceManager`

- **File:** `src/server/services/ServiceManager.lua`
- **Dependencies:** description, =, Core, service, management, with, auto-discovery, print(📋, Load, order, resolved, (, .., #loadOrder, .., services):), print(, .., i, .., ., .., serviceName)

### Client Controllers Dependencies:

#### `ClientController`

- **File:** `src/client/controllers/ClientController.lua`
- **Dependencies:** None

#### `RemoteClient`

- **File:** `src/client/controllers/RemoteClient.lua`
- **Dependencies:** None

#### `StateManager`

- **File:** `src/client/controllers/StateManager.lua`
- **Dependencies:** None

#### `StyleManager`

- **File:** `src/client/controllers/StyleManager.lua`
- **Dependencies:** description, =, UI, theming, and, styling, controller

#### `UIController`

- **File:** `src/client/controllers/UIController.lua`
- **Dependencies:** dependencies, =, {UIEngine, StateManager}

#### `UIEngine`

- **File:** `src/client/controllers/UIEngine.lua`
- **Dependencies:** None

## 🚨 CURRENT ISSUES SUMMARY

### Critical Issues:

1. **HUD Module Timing**

   - UIController tries to mount HUD before module discovery
   - `OVHL:GetModule("HUD")` returns nil during UIController:Start()

2. **State Subscriptions**

   - Subscriptions registered but not triggering callbacks
   - StateManager shows "No subscribers" despite HUD subscriptions

3. **UI Reactivity**
   - State changes don't automatically update UI
   - Manual refresh required for UI updates

### Root Causes Identified:

- **Race Condition:** UIController Start() vs Module Discovery
- **Subscription Mechanism:** StateManager callback execution failing
- **Component Lifecycle:** HUD DidMount vs State subscription timing

### Files Requiring Attention:

- `src/client/controllers/UIController.lua` - Timing issues
- `src/client/controllers/StateManager.lua` - Subscription bugs
- `src/client/modules/HUD.lua` - Reactivity implementation
- `src/client/controllers/ClientController.lua` - Load order
