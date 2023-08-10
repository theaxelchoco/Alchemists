-->Modules
local Module = {}
local Cache = {}

for _, Child in ipairs(script:GetDescendants()) do
	if Child:IsA("ModuleScript") then
		Cache[Child.Name] = require(Child)
	end
end

Module["GetObject"] = function(Name)
	assert(Cache[Name], Name .. " don't exist.")
	return Cache[Name]
end

return Module
