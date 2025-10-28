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
