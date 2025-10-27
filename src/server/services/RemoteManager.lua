-- RemoteManager v5 - Simple Communication
local RemoteManager = {}
RemoteManager.__index = RemoteManager

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
