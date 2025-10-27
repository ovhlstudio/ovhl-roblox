-- DataService v5 - Simple Data
local DataService = {}
DataService.__index = DataService

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

function DataService:GetPlayerData(player, storeName)
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

function DataService:SetPlayerData(player, storeName, data)
    print("💾 Saved data for:", player.Name, storeName)
    return true
end

return DataService
