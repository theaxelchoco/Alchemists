--/Services
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local HTTPService = game:GetService("HttpService")

--/Modules
local Module = {}
local ProfileService = require(script.ProfileService)
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

local Template = require(script.Template)
local Experience = require(script.Experience)

--/Variables
local DataKey = Template.Version
local GameProfile = ProfileService.GetProfileStore(DataKey, Template)

--[[
if game:GetService("RunService"):IsStudio() then
	GameProfile = GameProfile.Mock
end
]]

local PlayerValues = game.ReplicatedStorage.PlayerValues
Module.Profiles = {}

local Whitelist = {
	"SableEyed",
	--"DPainless"
}

--/Methods
Module["Get"] = function(Player, Name)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	if not Values then
		return
	end

	local Data = Values.Data
	if Data then
		return Data:FindFirstChild(Name).Value
	end

	return
end

Module["GetObject"] = function(Player, Name)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	if not Values then
		return
	end

	local Data = Values.Data
	if Data then
		return Data:FindFirstChild(Name)
	end

	return
end

Module["Set"] = function(Player, Name, Value)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local Data = Values.Data
	if Data then
		Data:FindFirstChild(Name).Value = Value
	end
end

Module["Increment"] = function(Player, Name, Value)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local Data = Values.Data
	if Data and typeof(Data:FindFirstChild(Name).Value) == "number" then
		Data:FindFirstChild(Name).Value += Value or 1
	end
end

Module["RefreshStates"] = function(Player)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	if not Values then
		return
	end

	local States = Values.States
	if States then
		GlobalFunctions.Modules["States"].Refresh(States)
	end
end

Module["DestroyValues"] = function(Player)
	local Values = game.ReplicatedStorage.PlayerValues:FindFirstChild(Player.Name)
	if Values then
		Values:Destroy()
	end
end

Module["CreateValues"] = function(Player, Data, Parent)
	-->Leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Bounty = Instance.new("IntValue")
	Bounty.Name = "Bounty"
	Bounty.Parent = leaderstats

	local Streak = Instance.new("IntValue")
	Streak.Name = "Streak"
	Streak.Parent = leaderstats

	--> Made folders
	local Config = Instance.new("Configuration", Parent or game.ReplicatedStorage.PlayerValues)
	Config.Name = if Parent then "Values" else Player.Name

	local DataFolder = Instance.new("Folder", Config)
	DataFolder.Name = "Data"

	local States = Instance.new("Folder", Config)
	States.Name = "States"

	local Cooldowns = Instance.new("Folder", Config)
	Cooldowns.Name = "Cooldowns"

	--> Load Values
	for Name, Value in pairs(Data) do
		local Type = typeof(Value) == "number" and "NumberValue"
			or typeof(Value) == "string" and "StringValue"
			or typeof(Value) == "boolean" and "BoolValue"
			or nil

		local Obj = Instance.new(Type or "StringValue")
		Obj.Name = Name
		Obj.Value = Type and Value or HTTPService:JSONEncode(Value)
		Obj.Parent = DataFolder

		Obj.Changed:Connect(function(NewValue)
			Data[Name] = NewValue
			if Name == "Experience" then
				Experience.LevelCheck(Player)
			elseif Name == "Bounty" or Name == "Streak" then
				leaderstats:FindFirstChild(Name).Value = NewValue
			end
		end)
	end

	GlobalFunctions.Modules["States"].LoadStates(Player)
end

Module["Init"] = function()
	--> Player Joined
	Players.PlayerAdded:Connect(function(Player)
		if not game:GetService("RunService"):IsStudio() and not table.find(Whitelist, Player.Name) then
			Player:Kick("NO ACCESS")
		end

		local Profile = GameProfile:LoadProfileAsync(Player.Name .. "_" .. Player.UserId)
		if Profile then
			Profile:Reconcile()

			Profile:ListenToRelease(function()
				Module.Profiles[Player] = nil
				Player:Kick()
			end)

			if Player:IsDescendantOf(Players) then
				Module.Profiles[Player] = Profile
				Module.CreateValues(Player, Profile.Data)
			else
				Profile:Release()
			end
		else
			Player:Kick()
		end

		if Player.Character then
			Player.Character.Parent = workspace.World.Live.Players
			GlobalFunctions.Modules["Spawn"].Load(Player.Character)

			for _, Part in pairs(Player.Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.CollisionGroupId = 1
				end
			end
		end

		Player.CharacterAdded:Connect(function(Character)
			task.wait()
			Character.Parent = workspace.World.Live.Players

			CollectionService:AddTag(Character, "Tilt")
			Module.RefreshStates(Character)

			GlobalFunctions.Modules["Spawn"].Load(Player.Character)

			for _, Part in pairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.CollisionGroupId = 1
				end
			end
		end)
	end)

	--> Player Left
	Players.PlayerRemoving:Connect(function(Player)
		Module.DestroyValues(Player)
		local Profile = Module.Profiles[Player]
		if Profile then
			local Values = game.ReplicatedStorage.PlayerValues:FindFirstChild(Player.Name)
			if Values then
				--> Combat Tag
				local Tag = Values.Cooldowns:FindFirstChild("CombatTag")
				if Tag and Players:FindFirstChild(Tag.Value) then
					-->Penalize them
					local Deduction = GlobalFunctions.PercentOf(Profile.Data.Cash, 5)
					Profile.Data.Cash -= Deduction
					Module.Increment(Players:FindFirstChild(Tag.Value), "Cash", Deduction)
				end
			end

			Profile:Release()
		end
	end)
end

return Module
