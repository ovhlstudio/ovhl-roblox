-- ModuleManifest.lua - Manifest Validator & Parser
local ModuleManifest = {}
ModuleManifest.__index = ModuleManifest

function ModuleManifest:Validate(manifest, moduleName)
	if not manifest then
		return false, "No manifest found for: " .. moduleName
	end

	if not manifest.name then
		return false, moduleName .. " missing required field: name"
	end

	if not manifest.version then
		return false, moduleName .. " missing required field: version"
	end

	if not manifest.type then
		return false, moduleName .. " missing required field: type"
	end

	local validTypes = { service = true, controller = true, module = true, component = true }
	if not validTypes[manifest.type] then
		return false, moduleName .. " has invalid type: " .. manifest.type
	end

	if manifest.domain then
		local validDomains = { gameplay = true, ui = true, network = true, data = true, system = true, core = true }
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
		description = manifest.description or "",
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
			description = "Legacy module without manifest",
		},
			"Using fallback manifest"
	end

	local isValid, err = self:Validate(manifest, moduleName)
	if not isValid then
		return nil, err
	end

	return self:Parse(manifest, moduleName), nil
end

return ModuleManifest
