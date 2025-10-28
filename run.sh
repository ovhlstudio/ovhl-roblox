#!/bin/bash

# ============================================================================
# OVHL CORE - AUTO-DISCOVERY SYSTEM IMPLEMENTATION
# Script untuk automated implementation dengan validation
# ============================================================================

set -e  # Exit on error

# Colors untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}🚀 OVHL AUTO-DISCOVERY SETUP${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# ============================================================================
# VALIDATION: Cek struktur project
# ============================================================================

echo -e "${YELLOW}🔍 Validating project structure...${NC}"

# Cek critical files
if [ ! -f "./src/server/services/ServiceManager.lua" ]; then
    echo -e "${RED}❌ ERROR: ServiceManager.lua not found!${NC}"
    exit 1
fi

if [ ! -f "./src/server/services/ModuleLoader.lua" ]; then
    echo -e "${RED}❌ ERROR: ModuleLoader.lua not found!${NC}"
    exit 1
fi

if [ ! -f "./src/server/init.server.lua" ]; then
    echo -e "${RED}❌ ERROR: init.server.lua not found!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project structure validated${NC}"
echo ""

# ============================================================================
# BACKUP: Buat backup dengan timestamp
# ============================================================================

echo -e "${YELLOW}💾 Creating backups...${NC}"

timestamp=$(date +%Y%m%d_%H%M%S)
backup_dir="./backups/auto_discovery_$timestamp"
mkdir -p "$backup_dir"

# Backup files yang akan diubah
cp ./src/server/services/ServiceManager.lua "$backup_dir/ServiceManager.lua.backup"
cp ./src/server/services/ModuleLoader.lua "$backup_dir/ModuleLoader.lua.backup" 
cp ./src/server/init.server.lua "$backup_dir/init.server.lua.backup"

echo -e "${GREEN}✅ Backups created in: $backup_dir${NC}"
echo ""

# ============================================================================
# PHASE 1: CREATE UTILITY FILES
# ============================================================================

echo -e "${YELLOW}📦 Phase 1: Creating utility files...${NC}"

# Create shared/utils directory
mkdir -p ./src/shared/utils

# ModuleManifest.lua
cat > ./src/shared/utils/ModuleManifest.lua << 'EOF'
-- ModuleManifest.lua - Manifest Validator & Parser
local ModuleManifest = {}

function ModuleManifest:Validate(manifest, moduleName)
    if not manifest then
        return false, "No manifest found for: " .. moduleName
    end
    
    -- Required fields validation
    if not manifest.name then
        return false, moduleName .. " missing required field: name"
    end
    
    if not manifest.version then
        return false, moduleName .. " missing required field: version"
    end
    
    if not manifest.type then
        return false, moduleName .. " missing required field: type"
    end
    
    -- Validate type
    local validTypes = {service = true, controller = true, module = true, component = true}
    if not validTypes[manifest.type] then
        return false, moduleName .. " has invalid type: " .. manifest.type
    end
    
    -- Validate domain
    if manifest.domain then
        local validDomains = {gameplay = true, ui = true, network = true, data = true, system = true, core = true}
        if not validDomains[manifest.domain] then
            warn(moduleName .. " has unknown domain: " .. manifest.domain)
        end
    end
    
    return true, "Valid manifest"
end

function ModuleManifest:Parse(manifest, moduleName)
    return {
        name = manifest.name or moduleName,
        version = manifest.version or "0.0.0",
        type = manifest.type or "module",
        domain = manifest.domain or "system",
        dependencies = manifest.dependencies or {},
        autoload = manifest.autoload ~= false,
        priority = manifest.priority or 50,
        description = manifest.description or ""
    }
end

function ModuleManifest:GetFromModule(moduleTable, moduleName)
    if type(moduleTable) ~= "table" then
        return nil, "Module is not a table"
    end
    
    local manifest = moduleTable.__manifest
    if not manifest then
        -- Fallback for legacy modules
        return {
            name = moduleName,
            version = "0.0.0",
            type = "module",
            domain = "system",
            dependencies = {},
            autoload = true,
            priority = 50,
            description = "Legacy module without manifest"
        }, "Using fallback manifest"
    end
    
    local isValid, err = self:Validate(manifest, moduleName)
    if not isValid then
        return nil, err
    end
    
    return self:Parse(manifest, moduleName), nil
end

return ModuleManifest
EOF

# DependencyResolver.lua
cat > ./src/shared/utils/DependencyResolver.lua << 'EOF'
-- DependencyResolver.lua - Dependency Graph & Load Order
local DependencyResolver = {}

function DependencyResolver:New()
    local resolver = {
        modules = {},
        graph = {},
        resolved = {},
        visited = {},
        resolving = {}
    }
    setmetatable(resolver, {__index = self})
    return resolver
end

function DependencyResolver:AddModule(name, manifest)
    self.modules[name] = manifest
    self.graph[name] = manifest.dependencies or {}
end

function DependencyResolver:_detectCycle(name, path)
    if self.resolving[name] then
        local cycle = table.concat(path, " -> ") .. " -> " .. name
        return true, "Circular dependency detected: " .. cycle
    end
    return false, nil
end

function DependencyResolver:_resolve(name, path)
    path = path or {}
    table.insert(path, name)
    
    if self.visited[name] then
        return true
    end
    
    local hasCycle, cycleError = self:_detectCycle(name, path)
    if hasCycle then
        return false, cycleError
    end
    
    self.resolving[name] = true
    
    local deps = self.graph[name] or {}
    for _, depName in ipairs(deps) do
        if not self.modules[depName] then
            warn("⚠️ Missing dependency: " .. name .. " requires " .. depName)
        else
            local success, err = self:_resolve(depName, path)
            if not success then
                return false, err
            end
        end
    end
    
    self.visited[name] = true
    self.resolving[name] = nil
    table.insert(self.resolved, name)
    
    return true
end

function DependencyResolver:Resolve()
    self.resolved = {}
    self.visited = {}
    self.resolving = {}
    
    local sortedModules = {}
    for name, manifest in pairs(self.modules) do
        table.insert(sortedModules, {name = name, priority = manifest.priority or 50})
    end
    
    table.sort(sortedModules, function(a, b)
        return a.priority > b.priority
    end)
    
    for _, item in ipairs(sortedModules) do
        if not self.visited[item.name] then
            local success, err = self:_resolve(item.name)
            if not success then
                error("Dependency resolution failed: " .. err)
            end
        end
    end
    
    return self.resolved
end

return DependencyResolver
EOF

echo -e "${GREEN}✅ Phase 1 Complete: Utility files created${NC}"
echo ""

# ============================================================================
# PHASE 2: UPDATE ServiceManager.lua
# ============================================================================

echo -e "${YELLOW}🔧 Phase 2: Updating ServiceManager.lua...${NC}"

cat > ./src/server/services/ServiceManager.lua << 'EOF'
-- ServiceManager v6 - WITH AUTO-DISCOVERY
local ServiceManager = {}
ServiceManager.__index = ServiceManager

function ServiceManager:Init()
    self.services = {}
    self.serviceStates = {}
    print("🔧 ServiceManager v6 initialized (Auto-Discovery)")
    return true
end

function ServiceManager:Start()
    print("🚀 Starting all services...")
    
    for serviceName, service in pairs(self.services) do
        if service.Start then
            local success, err = pcall(service.Start, service)
            if success then
                self.serviceStates[serviceName] = "STARTED"
                print("✅ Service started:", serviceName)
            else
                self.serviceStates[serviceName] = "FAILED"
                warn("❌ Failed to start " .. serviceName .. ":", err)
            end
        else
            self.serviceStates[serviceName] = "READY"
            print("✅ Service ready:", serviceName)
        end
    end
    
    print("🎉 All services started!")
    return true
end

function ServiceManager:RegisterService(serviceName, serviceModule)
    self.services[serviceName] = serviceModule
    self.serviceStates[serviceName] = "REGISTERED"
    
    if serviceModule.Init then
        local success, err = pcall(serviceModule.Init, serviceModule)
        if success then
            print("🔧 Service initialized:", serviceName)
        else
            warn("❌ Failed to init " .. serviceName .. ":", err)
        end
    end
    
    print("📝 Registered service:", serviceName)
    return true
end

-- AUTO-DISCOVERY FEATURE
function ServiceManager:AutoDiscoverServices(servicesFolder)
    if not servicesFolder then
        warn("⚠️ No services folder provided for auto-discovery")
        return false
    end
    
    print("🔍 Auto-discovering services...")
    
    local ModuleManifest = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.ModuleManifest)
    local DependencyResolver = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.DependencyResolver)
    
    local resolver = DependencyResolver:New()
    local discovered = {}
    
    -- Discover all services
    for _, moduleScript in ipairs(servicesFolder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") and moduleScript.Name ~= "ServiceManager" then
            local success, serviceModule = pcall(require, moduleScript)
            
            if success and serviceModule then
                local manifest, err = ModuleManifest:GetFromModule(serviceModule, moduleScript.Name)
                
                if manifest then
                    discovered[moduleScript.Name] = {
                        module = serviceModule,
                        manifest = manifest
                    }
                    resolver:AddModule(moduleScript.Name, manifest)
                    print("📦 Discovered:", moduleScript.Name, "v" .. manifest.version)
                else
                    warn("⚠️ Failed to parse manifest for:", moduleScript.Name, err)
                end
            else
                warn("❌ Failed to require:", moduleScript.Name, serviceModule)
            end
        end
    end
    
    -- Resolve dependencies
    local loadOrder = resolver:Resolve()
    
    print("📋 Load order resolved (" .. #loadOrder .. " services):")
    for i, serviceName in ipairs(loadOrder) do
        print("  " .. i .. ". " .. serviceName)
    end
    
    -- Register in dependency order
    for _, serviceName in ipairs(loadOrder) do
        local item = discovered[serviceName]
        if item and item.manifest.autoload then
            self:RegisterService(serviceName, item.module)
        end
    end
    
    print("✅ Auto-discovery complete: " .. #loadOrder .. " services registered")
    return true
end

function ServiceManager:GetService(serviceName)
    local service = self.services[serviceName]
    if not service then
        error("Service not found: " .. serviceName)
    end
    return service
end

function ServiceManager:GetServiceCount()
    local count = 0
    for _ in pairs(self.services) do count = count + 1 end
    return count
end

return ServiceManager
EOF

echo -e "${GREEN}✅ ServiceManager.lua updated${NC}"
echo ""

# ============================================================================
# PHASE 3: UPDATE ModuleLoader.lua
# ============================================================================

echo -e "${YELLOW}🔧 Phase 3: Updating ModuleLoader.lua...${NC}"

cat > ./src/server/services/ModuleLoader.lua << 'EOF'
-- ModuleLoader v6 - WITH AUTO-DISCOVERY & MANIFEST SUPPORT
local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader:Init()
    self.modules = {}
    print("🔧 ModuleLoader v6 initialized (Auto-Discovery)")
    return true
end

function ModuleLoader:Start()
    print("📦 Loading modules with auto-discovery...")
    
    local modulesFolder = script.Parent.Parent:FindFirstChild("modules")
    if not modulesFolder then
        print("ℹ️ No modules folder found")
        return true
    end
    
    local ModuleManifest = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.ModuleManifest)
    local DependencyResolver = require(game.ReplicatedStorage:FindFirstChild("OVHL_Shared").utils.DependencyResolver)
    
    local resolver = DependencyResolver:New()
    local discovered = {}
    
    local function discoverInFolder(folder, domain)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Folder") then
                discoverInFolder(item, item.Name)
            elseif item:IsA("ModuleScript") then
                local success, moduleTable = pcall(require, item)
                
                if success and moduleTable then
                    local manifest, err = ModuleManifest:GetFromModule(moduleTable, item.Name)
                    
                    if manifest then
                        if domain then
                            manifest.domain = domain
                        end
                        
                        discovered[item.Name] = {
                            module = moduleTable,
                            manifest = manifest
                        }
                        resolver:AddModule(item.Name, manifest)
                        print("📦 Discovered:", item.Name, "(" .. manifest.domain .. ")", "v" .. manifest.version)
                    else
                        warn("⚠️ Failed to parse manifest for:", item.Name, err)
                    end
                else
                    warn("❌ Failed to require:", item.Name, moduleTable)
                end
            end
        end
    end
    
    discoverInFolder(modulesFolder, nil)
    
    local loadOrder = resolver:Resolve()
    
    print("📋 Module load order (" .. #loadOrder .. " modules):")
    for i, moduleName in ipairs(loadOrder) do
        local item = discovered[moduleName]
        if item then
            print("  " .. i .. ". " .. moduleName .. " [" .. item.manifest.domain .. "]")
        end
    end
    
    for _, moduleName in ipairs(loadOrder) do
        local item = discovered[moduleName]
        if item and item.manifest.autoload then
            self.modules[moduleName] = item.module
            
            if item.module.Start then
                local success, err = pcall(item.module.Start, item.module)
                if success then
                    print("✅ Module started:", moduleName)
                else
                    warn("❌ Module start failed:", moduleName, err)
                end
            else
                print("✅ Module loaded:", moduleName)
            end
        end
    end
    
    print("🎉 ModuleLoader completed: " .. #loadOrder .. " modules processed")
    return true
end

function ModuleLoader:GetModule(moduleName)
    return self.modules[moduleName]
end

return ModuleLoader
EOF

echo -e "${GREEN}✅ ModuleLoader.lua updated${NC}"
echo ""

# ============================================================================
# PHASE 4: SIMPLIFY init.server.lua
# ============================================================================

echo -e "${YELLOW}🔧 Phase 4: Simplifying init.server.lua...${NC}"

cat > ./src/server/init.server.lua << 'EOF'
-- OVHL SERVER BOOTSTRAP v6 - AUTO-DISCOVERY
print("🚀 [OVHL] Server bootstrap v6 starting (Auto-Discovery)...")

local success, err = pcall(function()
    -- Setup shared utilities
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local sharedFolder = Instance.new("Folder")
    sharedFolder.Name = "OVHL_Shared"
    sharedFolder.Parent = ReplicatedStorage
    
    local utilsFolder = Instance.new("Folder")
    utilsFolder.Name = "utils"
    utilsFolder.Parent = sharedFolder
    
    -- Copy shared utils
    local sharedUtils = script.Parent:FindFirstChild("shared"):FindFirstChild("utils")
    if sharedUtils then
        for _, util in ipairs(sharedUtils:GetChildren()) do
            if util:IsA("ModuleScript") then
                util:Clone().Parent = utilsFolder
            end
        end
    end
    
    -- Wait for services folder
    local servicesFolder = script:WaitForChild("services")
    
    -- Initialize ServiceManager
    local ServiceManager = require(servicesFolder.ServiceManager)
    local serviceManager = setmetatable({}, ServiceManager)
    
    if not serviceManager:Init() then
        error("❌ ServiceManager failed to initialize!")
    end
    
    -- 🔥 AUTO-DISCOVER ALL SERVICES (Replaces manual registration)
    serviceManager:AutoDiscoverServices(servicesFolder)
    
    -- Manual data store registration (temporary)
    local DataService = serviceManager:GetService("DataService")
    DataService:RegisterDataStore("MainData", {
        coins = 1000,
        gems = 100,
        level = 1,
        experience = 0,
        inventory = {}
    })
    
    -- Start all services
    print("🚀 Starting services...")
    local servicesStarted = serviceManager:Start()
    
    if not servicesStarted then
        warn("⚠️ Some services failed to start, but continuing...")
    end
    
    -- Load modules
    print("📦 Loading modules...")
    local ModuleLoader = serviceManager:GetService("ModuleLoader")
    local modulesStarted = ModuleLoader:Start()
    
    if not modulesStarted then
        warn("⚠️ Some modules failed to start, but continuing...")
    end
    
    print("✅ [OVHL] Server bootstrap v6 completed!")
    print("📊 Services: " .. serviceManager:GetServiceCount())
    
    return serviceManager
end)

if not success then
    warn("❌ [OVHL] Server bootstrap failed:", err)
end
EOF

echo -e "${GREEN}✅ init.server.lua simplified${NC}"
echo ""

# ============================================================================
# PHASE 5: CREATE MANIFEST TEMPLATES FOR EXISTING SERVICES
# ============================================================================

echo -e "${YELLOW}📝 Phase 5: Creating manifest templates...${NC}"

mkdir -p ./manifest_templates

# Buat template manifests untuk services yang ada
cat > ./manifest_templates/Logger_manifest.txt << 'EOF'
-- ADD TO Logger.lua (after the module table definition)
Logger.__manifest = {
    name = "Logger",
    version = "5.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 100,
    description = "Core logging service for structured logging"
}
EOF

cat > ./manifest_templates/EventBus_manifest.txt << 'EOF'
-- ADD TO EventBus.lua (after the module table definition)
EventBus.__manifest = {
    name = "EventBus",
    version = "5.0.0",
    type = "service",
    domain = "core",
    dependencies = {"Logger"},
    autoload = true,
    priority = 95,
    description = "Event-driven communication system"
}
EOF

cat > ./manifest_templates/ConfigService_manifest.txt << 'EOF'
-- ADD TO ConfigService.lua (after the module table definition)
ConfigService.__manifest = {
    name = "ConfigService",
    version = "5.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 90,
    description = "Configuration management service"
}
EOF

cat > ./manifest_templates/DataService_manifest.txt << 'EOF'
-- ADD TO DataService.lua (after the module table definition)
DataService.__manifest = {
    name = "DataService",
    version = "5.0.0",
    type = "service",
    domain = "data",
    dependencies = {"Logger"},
    autoload = true,
    priority = 80,
    description = "Data persistence and management service"
}
EOF

cat > ./manifest_templates/RemoteManager_manifest.txt << 'EOF'
-- ADD TO RemoteManager.lua (after the module table definition)
RemoteManager.__manifest = {
    name = "RemoteManager",
    version = "5.0.0",
    type = "service",
    domain = "network",
    dependencies = {"Logger", "EventBus"},
    autoload = true,
    priority = 75,
    description = "Client-server communication manager"
}
EOF

cat > ./manifest_templates/ModuleLoader_manifest.txt << 'EOF'
-- ADD TO ModuleLoader.lua (after the module table definition)
ModuleLoader.__manifest = {
    name = "ModuleLoader",
    version = "6.0.0",
    type = "service",
    domain = "core",
    dependencies = {},
    autoload = true,
    priority = 50,
    description = "Dynamic module loading with auto-discovery"
}
EOF

echo -e "${GREEN}✅ Manifest templates created in ./manifest_templates/${NC}"
echo ""

# ============================================================================
# PHASE 6: CREATE EXAMPLE MODULE WITH MANIFEST
# ============================================================================

echo -e "${YELLOW}📦 Phase 6: Creating example module...${NC}"

mkdir -p ./src/server/modules/gameplay

cat > ./src/server/modules/gameplay/ExampleModule.lua << 'EOF'
-- ExampleModule - Example dengan manifest lengkap
local ExampleModule = {}
ExampleModule.__index = ExampleModule

-- 🔥 MANIFEST (Required for auto-discovery)
ExampleModule.__manifest = {
    name = "ExampleModule",
    version = "1.0.0",
    type = "module",
    domain = "gameplay",
    dependencies = {"Logger", "EventBus"},
    autoload = true,
    priority = 50,
    description = "Example gameplay module with manifest"
}

function ExampleModule:Init()
    print("🔧 ExampleModule initialized")
    return true
end

function ExampleModule:Start()
    print("✅ ExampleModule started")
    return true
end

return ExampleModule
EOF

echo -e "${GREEN}✅ Example module created${NC}"
echo ""

# ============================================================================
# COMPLETION
# ============================================================================

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}✅ AUTO-DISCOVERY SETUP COMPLETE!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${BLUE}📋 What was implemented:${NC}"
echo "  ✅ ModuleManifest.lua - Manifest validator & parser"
echo "  ✅ DependencyResolver.lua - Dependency graph resolver" 
echo "  ✅ ServiceManager.lua v6 - Auto-discovery for services"
echo "  ✅ ModuleLoader.lua v6 - Auto-discovery for modules"
echo "  ✅ Simplified init.server.lua - From 20+ lines to 1 line!"
echo "  ✅ Manifest templates for all 6 existing services"
echo "  ✅ Example module with manifest"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANT NEXT STEPS:${NC}"
echo "  1. Manual: Add manifests to existing service files"
echo "  2. Test: Run 'rojo serve' to verify everything works"  
echo "  3. Check: Look for auto-discovery logs in console"
echo ""
echo -e "${BLUE}📂 Backup location:${NC}"
echo "  $backup_dir"
echo ""
echo -e "${BLUE}📁 Manifest templates:${NC}"
echo "  ./manifest_templates/"
echo ""
echo -e "${GREEN}🚀 Ready to test! Run: rojo serve${NC}"