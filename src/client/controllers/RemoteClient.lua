-- RemoteClient v5 - Simple Communication
local RemoteClient = {}
RemoteClient.__index = RemoteClient

function RemoteClient:Init()
    self.connected = false
    print("🔧 RemoteClient initialized")
    return true
end

function RemoteClient:Start()
    print("📡 RemoteClient connecting...")
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local startTime = tick()
    
    while tick() - startTime < 10 do
        local success = pcall(function()
            self.remoteFolder = ReplicatedStorage:WaitForChild("OVHL_Remotes", 1)
            if self.remoteFolder then
                self.mainEvent = self.remoteFolder:WaitForChild("MainRemoteEvent", 1)
                self.mainFunction = self.remoteFolder:WaitForChild("MainRemoteFunction", 1)
            end
        end)
        
        if success and self.mainEvent and self.mainFunction then
            self.connected = true
            print("✅ RemoteClient connected!")
            return true
        end
        wait(0.5)
    end
    
    warn("❌ RemoteClient failed to connect")
    return false
end

function RemoteClient:Invoke(eventName, ...)
    if not self.connected then return false, "Not connected" end
    
    local args = {...}
    local success, result = pcall(function()
        return self.mainFunction:InvokeServer(eventName, unpack(args))
    end)
    
    if success then
        return result
    else
        return false, result
    end
end

function RemoteClient:Listen(eventName, callback)
    if not self.connected then return function() end end
    
    return self.mainEvent.OnClientEvent:Connect(function(receivedEventName, ...)
        if receivedEventName == eventName then
            local args = {...}
            callback(unpack(args))
        end
    end)
end

function RemoteClient:Fire(eventName, ...)
    if not self.connected then return false end
    self.mainEvent:FireServer(eventName, ...)
    return true
end

return RemoteClient
