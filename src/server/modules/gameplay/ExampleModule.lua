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
