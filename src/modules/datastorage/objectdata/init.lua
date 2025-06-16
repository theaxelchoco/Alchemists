-->modules
local module = {}
local cache = {}

for _, child in ipairs(script:GetDescendants()) do
	if child:IsA("ModuleScript") then
		cache[child.Name] = require(child)
	end
end

module["get"] = function(name)
	assert(cache[name], "Module '" .. name .. "' does not exist in ingredients module.")
	return cache[name]
end

return module
