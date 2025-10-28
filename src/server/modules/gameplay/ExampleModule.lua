-- ExampleModule - Example dengan OVHL Global Accessor
local ExampleModule = {}
ExampleModule.__index = ExampleModule

-- 🔥 MANIFEST FOR AUTO-DISCOVERY
ExampleModule.__manifest = {
	name = "ExampleModule",
	version = "1.0.0",
	type = "module",
	domain = "gameplay",
	dependencies = {},
	autoload = true,
	priority = 50,
	description = "Example gameplay module with OVHL integration",
}

-- Cache OVHL instance
local ovhlInstance = nil

-- Helper function untuk get OVHL safely
local function getOVHL()
	if ovhlInstance then
		return ovhlInstance
	end
	
	-- Try multiple paths
	local paths = {
		function() return require(game.ReplicatedStorage.OVHL_Shared.OVHL_Global) end,
		function() return require(game.ServerScriptService.OVHL_Server.shared.OVHL_Global) end,
	}
	
	for _, pathFn in ipairs(paths) do
		local success, result = pcall(pathFn)
		if success and result then
			ovhlInstance = result
			return ovhlInstance
		end
	end
	
	return nil
end

function ExampleModule:Init()
	print("🔧 ExampleModule initialized")
	return true
end

function ExampleModule:Start()
	print("✅ ExampleModule started - Auto-discovery working! 🎉")

	-- Get OVHL with proper error handling
	local ovhl = getOVHL()

	if ovhl then
		-- Try to get Logger service (might not be ready yet)
		local success, logger = pcall(function()
			return ovhl:GetService("Logger")
		end)
		
		if success and logger then
			-- Use Logger safely
			local logSuccess = pcall(function()
				logger:Info("ExampleModule integrated successfully via OVHL")
			end)
			
			if not logSuccess then
				print("✅ ExampleModule integrated via OVHL (Logger not ready)")
			end
		else
			print("✅ ExampleModule integrated via OVHL (Logger service pending)")
		end
	else
		print("⚠️ OVHL not available - Module running in standalone mode")
	end

	return true
end

-- Example method untuk demonstrate functionality
function ExampleModule:GetModuleInfo()
	return {
		name = self.__manifest.name,
		version = self.__manifest.version,
		domain = self.__manifest.domain,
		description = self.__manifest.description,
	}
end

-- Example method that safely uses OVHL
function ExampleModule:LogMessage(message)
	local ovhl = getOVHL()
	if ovhl then
		local logger = ovhl:GetService("Logger")
		if logger then
			logger:Info(message)
			return true
		end
	end
	
	-- Fallback to print
	print("[ExampleModule]", message)
	return false
end

return ExampleModule
