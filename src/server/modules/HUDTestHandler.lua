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
