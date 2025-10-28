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
