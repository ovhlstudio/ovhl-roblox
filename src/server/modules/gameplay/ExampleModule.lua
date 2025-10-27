-- ExampleModule - Example dengan manifest lengkap (FIXED)
local ExampleModule = {}
ExampleModule.__index = ExampleModule

-- 🔥 MANIFEST (Required for auto-discovery) - FIXED DEPENDENCIES
ExampleModule.__manifest = {
	name = "ExampleModule",
	version = "1.0.0",
	type = "module",
	domain = "gameplay",
	dependencies = {}, -- ✅ FIXED: Modules tidak bisa depend ke services
	autoload = true,
	priority = 50,
	description = "Example gameplay module with manifest",
}

function ExampleModule:Init()
	print("🔧 ExampleModule initialized")
	return true
end

function ExampleModule:Start()
	print("✅ ExampleModule started - Auto-discovery working! 🎉")

	-- Test integration dengan services (tapi tidak sebagai dependency)
	local success, serviceManager = pcall(function()
		return require(script.Parent.Parent.Parent.services.ServiceManager)
	end)

	if success and serviceManager then
		local smInstance = getmetatable(serviceManager).__index
		local logger = smInstance:GetService("Logger")
		if logger then
			logger:Info("ExampleModule integrated successfully")
		end
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

return ExampleModule
