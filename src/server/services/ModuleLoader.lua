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
