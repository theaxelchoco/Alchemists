-->Variables
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

--Shared Modules
for _, Module in ipairs(game.ReplicatedStorage.Modules.Shared:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" then
		GlobalFunctions.Modules[Module.Name] = require(Module)
	end
end

--Package Modules
for _, Module in ipairs(game.ReplicatedStorage.Packages:GetChildren()) do
	if Module:IsA("ModuleScript") then
		GlobalFunctions.Modules[Module.Name] = require(Module)
	end
end

--Server Modules
for _, Module in ipairs(script:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" then
		local Usage = require(Module)
		if Usage.Init then
			GlobalFunctions.Modules[Module.Name] = Usage
		end
	end
end

-->Instantiating the modules
for _, Module in pairs(GlobalFunctions.Modules) do
	if Module.Init then
		if typeof(Module.Init) == "function" then
			Module.Init(GlobalFunctions.Modules)
		end
	end
end

print(GlobalFunctions.Modules)
warn("Server Modules done loading")
