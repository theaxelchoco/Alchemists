-->Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

-->Variables
local Remote = GlobalFunctions.GetRemote("Effects")

-->Methods
Module["Init"] = function()
	Datastore = GlobalFunctions.Modules["Datastore"]
end

local function LevelUp(Player)
	--local Datastore = _G.GetModule("Datastore")

	local ExperienceProgression = 50

	--/Experience Given
	local Max = Datastore.Get(Player, "MaxExperience")
	local Exp = Datastore.Get(Player, "Experience")
	local Level = Datastore.Get(Player, "Level")
	local Spins = Datastore.Get(Player, "Spins")

	while Exp >= Max do
		local Diff = Exp - Max

		Level += 1
		Spins += 2

		Exp = Diff
		Max += ExperienceProgression
	end

	--print(Exp,Max,Level,StatPoints)

	Datastore.Set(Player, "MaxExperience", Max)
	Datastore.Set(Player, "Level", Level)
	Datastore.Set(Player, "Spins", Spins)
	--task.wait()
	Datastore.Set(Player, "Experience", Exp)
end

Module["LevelCheck"] = function(Player)
	if Datastore.Get(Player, "Experience") >= Datastore.Get(Player, "MaxExperience") then
		Remote:FireAllClients("LevelUp", Player.Character)
		LevelUp(Player)
	end
end

Module["GiveExp"] = function(Player, Amount)
	-->TODO: Gamepass check for double exp
	Datastore.Increment(Player, "Experience", Amount)
end

return Module
