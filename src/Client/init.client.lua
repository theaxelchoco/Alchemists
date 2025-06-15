-->Modules
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)
local ModuleObjects = {}

--RepStorage Modules
for _, Module in ipairs(game.ReplicatedStorage.Modules:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" and not Module:GetAttribute("Ignore") then
		GlobalFunctions.Modules[Module.Name] = require(Module)
		ModuleObjects[Module.Name] = Module
	end
end

--Package Modules
for _, Module in ipairs(game.ReplicatedStorage.Packages:GetChildren()) do
	if Module:IsA("ModuleScript") then
		GlobalFunctions.Modules[Module.Name] = require(Module)
		ModuleObjects[Module.Name] = Module
	end
end

--Client Modules
for _, Module in ipairs(script:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" and not Module:GetAttribute("Ignore") then
		local Usage = require(Module)
		if Usage.Init then
			GlobalFunctions.Modules[Module.Name] = Usage
			ModuleObjects[Module.Name] = Module
		end
	end
end

-->Instantiating the modules
for Name, Module in pairs(GlobalFunctions.Modules) do
	if ModuleObjects[Name].Parent.Name == "Packages" then
		continue
	end

	if Module.Init then
		if typeof(Module.Init) == "function" then
			Module.Init()
		end
	end
end

print(GlobalFunctions.GetModule("Roact"))
--WRITE CODE FOR CHARACTER ADDED AND WHATNOT SO WE CAN REFRESH THE INIT OF EVERY MODULE FOR THE PLAYER (CHILDREN OF THIS SCRIPT)

print(GlobalFunctions.Modules)
warn("Client Modules done loading.")
