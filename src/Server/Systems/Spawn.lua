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
end

return Module
