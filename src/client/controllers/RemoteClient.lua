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
