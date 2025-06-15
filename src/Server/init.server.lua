-->Variables
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)
local ModuleObjects = {}

--Shared Modules
for _, Module in ipairs(game.ReplicatedStorage.Modules.Shared:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" then
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

--Server Modules
for _, Module in ipairs(script:GetDescendants()) do
	if Module:IsA("ModuleScript") and typeof(require(Module)) == "table" then
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

-->Hot reloading
local Reloader = GlobalFunctions.GetModule("Rewire").HotReloader.new()

for Name, Module in pairs(ModuleObjects) do
	Reloader:listen(Module, function(module)
		GlobalFunctions.Modules[Name] = require(module)
	end, function(module) end)
end

print(Reloader)

print(GlobalFunctions.Modules)
warn("Server Modules done loading")
