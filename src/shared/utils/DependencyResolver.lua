-- DependencyResolver.lua - Dependency Graph & Load Order
local DependencyResolver = {}

function DependencyResolver:New()
	local resolver = {
		modules = {},
		graph = {},
		resolved = {},
		visited = {},
		resolving = {},
	}
	setmetatable(resolver, { __index = self })
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
		table.insert(sortedModules, { name = name, priority = manifest.priority or 50 })
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
