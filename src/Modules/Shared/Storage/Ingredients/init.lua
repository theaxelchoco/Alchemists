-->Modules
local Module = {}
local Cache = {}

for _, Child in ipairs(script:GetChildren()) do
	if Child:IsA("ModuleScript") then
		Cache[Child.Name] = require(Child)
	end
end

Module["GetIngredient"] = function(Name)
	assert(Cache[Name], Name .. " don't exist.")
	return Cache[Name]
end

return Module
