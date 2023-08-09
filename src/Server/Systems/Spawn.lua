-->Modules
local Module = {}
--local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

--/Variables

--/Methods

Module["Init"] = function()
	--[[
		Datastore = GlobalFunctions.Modules["Datastore"]
	States = GlobalFunctions.Modules["States"]
	]]
end

Module["Load"] = function(Character)
	Character.PrimaryPart = Character:FindFirstChild("HumanoidRootPart")

	local Folder = Instance.new("Folder")
	Folder.Name = "ItemHeld"
	Folder.Parent = Character
end

return Module
