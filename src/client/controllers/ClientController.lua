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
