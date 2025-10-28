-- OVHL Global Accessor v2.1.0
-- Single entry point for all core systems
local OVHL = {}
OVHL.__index = OVHL

-- Environment detection
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

-- Cache for performance
local cachedServices = {}
local cachedModules = {}

function OVHL:GetService(serviceName)
    if cachedServices[serviceName] then
        return cachedServices[serviceName]
    end

    if IS_SERVER then
        -- Server-side: Use ServiceManager directly
        local success, serviceManager = pcall(function()
            return require(game.ServerScriptService.OVHL_Server.services.ServiceManager)
        end)
        
        if success and serviceManager then
            local service = serviceManager:GetService(serviceName)
            if service then
                cachedServices[serviceName] = service
                return service
            end
        end
    else
        -- Client-side: Try multiple paths for ClientController
        local paths = {
            function() return require(ReplicatedStorage.OVHL_Shared.utils.ClientController) end,
            function() return require(script.Parent.utils.ClientController) end,
        }
        
        for _, pathFn in ipairs(paths) do
            local success, clientController = pcall(pathFn)
            if success and clientController then
                local controller = clientController:GetController(serviceName)
                if controller then
                    cachedServices[serviceName] = controller
                    return controller
                end
            end
        end
    end

    warn("⚠ OVHL: Service/Controller not found:", serviceName)
    return nil
end

function OVHL:GetModule(moduleName)
    if cachedModules[moduleName] then
        return cachedModules[moduleName]
    end

    if IS_SERVER then
        -- Server-side: Use ModuleLoader
        local moduleLoader = self:GetService("ModuleLoader")
        if moduleLoader then
            local module = moduleLoader:GetModule(moduleName)
            if module then
                cachedModules[moduleName] = module
                return module
            end
        end
    else
        -- Client-side: Try ClientController paths
        local paths = {
            function() return require(ReplicatedStorage.OVHL_Shared.utils.ClientController) end,
            function() return require(script.Parent.utils.ClientController) end,
        }
        
        for _, pathFn in ipairs(paths) do
            local success, clientController = pcall(pathFn)
            if success and clientController then
                local module = clientController:GetModule(moduleName)
                if module then
                    cachedModules[moduleName] = module
                    return module
                end
            end
        end
    end

    warn("⚠ OVHL: Module not found:", moduleName)
    return nil
end

function OVHL:GetConfig(moduleName)
    if not IS_SERVER then
        warn("⚠ OVHL: GetConfig is server-only")
        return nil
    end

    local configService = self:GetService("ConfigService")
    if configService then
        return configService:Get(moduleName)
    end
    
    return nil
end

-- ==================== SERVER-SIDE APIs ====================

function OVHL:Emit(eventName, ...)
    if not IS_SERVER then
        warn("⚠ OVHL: Emit is server-only")
        return false
    end

    local eventBus = self:GetService("EventBus")
    if eventBus then
        return eventBus:Emit(eventName, ...)
    end
    
    return false
end

function OVHL:Subscribe(eventName, callback)
    if not IS_SERVER then
        warn("⚠ OVHL: Subscribe (EventBus) is server-only")
        return
    end

    local eventBus = self:GetService("EventBus")
    if eventBus then
        return eventBus:Subscribe(eventName, callback)
    end
end

-- ==================== CLIENT-SIDE APIs ====================

function OVHL:SetState(key, value)
    if not IS_CLIENT then
        warn("⚠ OVHL: SetState is client-only")
        return false
    end

    local stateManager = self:GetService("StateManager")
    if stateManager then
        return stateManager:Set(key, value)
    end
    
    return false
end

function OVHL:GetState(key, defaultValue)
    if not IS_CLIENT then
        warn("⚠ OVHL: GetState is client-only")
        return defaultValue
    end

    local stateManager = self:GetService("StateManager")
    if stateManager then
        return stateManager:Get(key, defaultValue)
    end
    
    return defaultValue
end

function OVHL:Fire(eventName, ...)
    if not IS_CLIENT then
        warn("⚠ OVHL: Fire is client-only")
        return false
    end

    local remoteClient = self:GetService("RemoteClient")
    if remoteClient then
        return remoteClient:Fire(eventName, ...)
    end
    
    return false
end

function OVHL:Invoke(eventName, ...)
    if not IS_CLIENT then
        warn("⚠ OVHL: Invoke is client-only")
        return false
    end

    local remoteClient = self:GetService("RemoteClient")
    if remoteClient then
        return remoteClient:Invoke(eventName, ...)
    end
    
    return false
end

function OVHL:Listen(eventName, callback)
    if not IS_CLIENT then
        warn("⚠ OVHL: Listen is client-only")
        return
    end

    local remoteClient = self:GetService("RemoteClient")
    if remoteClient then
        return remoteClient:Listen(eventName, callback)
    end
end

-- ==================== INITIALIZATION ====================

-- Create global instance
local ovhlInstance = setmetatable({}, OVHL)

-- Safe initialization that won't break modules
local function safeInit()
    if IS_SERVER then
        print("🚀 OVHL Global Accessor initialized (Server)")
    else
        print("🎮 OVHL Global Accessor initialized (Client)")
    end
end

-- Run safe initialization
pcall(safeInit)

return ovhlInstance
