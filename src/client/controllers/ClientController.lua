-- ClientController v1.6.0 - CRITICAL BUG FIX
local OVHL = require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global)

local ClientController = {}
ClientController.__index = ClientController

ClientController.__manifest = {
    name = "ClientController",
    version = "1.6.0",
    type = "controller",
    priority = 100,
    domain = "system",
    description = "CRITICAL bug fix for nil call"
}

function ClientController:Init()
    self._controllers = {}
    self._modules = {}
    self._eventCallbacks = {}
    print("✅ ClientController Initialized - BUG FIXED")
    return true
end

function ClientController:Start()
    print("✅ ClientController Started")
    return true
end

function ClientController:Emit(eventName, ...)
    print("📢 Emitting event:", eventName)
    if self._eventCallbacks[eventName] then
        for _, callback in ipairs(self._eventCallbacks[eventName]) do
            pcall(callback, ...)
        end
    end
end

function ClientController:On(eventName, callback)
    if not self._eventCallbacks[eventName] then
        self._eventCallbacks[eventName] = {}
    end
    table.insert(self._eventCallbacks[eventName], callback)
    print("👂 Listener registered for:", eventName)
end

function ClientController:AutoDiscoverControllers(controllersFolder)
    print("🔍 Auto-discovering controllers...")

    for _, moduleScript in ipairs(controllersFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local success, controller = pcall(function()
                local module = require(moduleScript)
                if module and module.__manifest then
                    local manifest = module.__manifest
                    print("📦 Discovered Controller: " .. manifest.name .. " v" .. manifest.version)
                    
                    if module.Init then
                        local initSuccess = pcall(module.Init, module)
                        if initSuccess then
                            self._controllers[manifest.name] = module
                            OVHL:_registerService(manifest.name, module)
                            print("✅ Controller registered: " .. manifest.name)
                        end
                    end
                    return module
                end
            end)
            if not success then
                warn("❌ Failed to load controller: " .. moduleScript.Name)
            end
        end
    end

    -- 🚨 CRITICAL BUG FIX: Safe controller starting
    print("🚀 Starting all controllers...")
    for name, controller in pairs(self._controllers) do
        if controller and type(controller) == "table" and controller.Start then
            local startSuccess, err = pcall(controller.Start, controller)
            if startSuccess then
                print("✅ Controller started: " .. name)
            else
                warn("❌ Failed to start controller " .. name .. ": " .. tostring(err))
            end
        else
            print("⚠️ Controller " .. name .. " missing or invalid")
        end
    end

    print("✅ Controller discovery complete")
    return true
end

function ClientController:AutoDiscoverModules(modulesFolder)
    print("🔍 Auto-discovering modules...")

    local discoveredCount = 0
    
    for _, moduleScript in ipairs(modulesFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            print("🔍 Checking module: " .. moduleScript.Name)
            
            local success, moduleTable = pcall(require, moduleScript)
            if success and moduleTable then
                if moduleTable.__manifest then
                    local manifest = moduleTable.__manifest
                    print("📦 DISCOVERED MODULE: " .. manifest.name .. " v" .. manifest.version)
                    
                    -- Register with OVHL
                    OVHL:_registerModule(manifest.name, moduleTable)
                    self._modules[manifest.name] = moduleTable
                    discoveredCount = discoveredCount + 1
                    
                    -- Register UI modules
                    if manifest.domain == "ui" then
                        local uiController = OVHL:GetService("UIController")
                        if uiController and uiController.RegisterScreen then
                            uiController:RegisterScreen(manifest.name, moduleTable)
                            print("🎨 UI Screen Registered: " .. manifest.name)
                        end
                    end
                    
                    -- Start module safely
                    if moduleTable.Start then
                        local startSuccess, err = pcall(moduleTable.Start, moduleTable)
                        if startSuccess then
                            print("✅ Module started: " .. manifest.name)
                        else
                            warn("❌ Failed to start module " .. manifest.name .. ": " .. tostring(err))
                        end
                    end
                else
                    print("⚠️ Module missing manifest: " .. moduleScript.Name)
                end
            else
                warn("❌ Failed to require module: " .. moduleScript.Name)
            end
        end
    end

    print("🎉 MODULE DISCOVERY COMPLETE: " .. discoveredCount .. " modules")
    
    -- Emit ModulesReady
    self:Emit("ModulesReady")
    print("📢 ModulesReady event emitted")
    
    return true
end

function ClientController:GetController(name)
    return self._controllers[name]
end

function ClientController:GetModule(name)
    return self._modules[name]
end

return ClientController
