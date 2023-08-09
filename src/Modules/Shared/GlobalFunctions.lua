-->Services
local HTTPService = game:GetService("HttpService")

-->Modules
local Module = {
	Modules = {},
}

-->Methods
function VisualizeRay(origin, direction)
	local Model = Instance.new("Model", workspace.World.Visuals)

	local Par = Instance.new("Part")
	Par.Color = Color3.fromRGB(255, 73, 76)
	Par.Position = origin
	Par.Material = "Neon"
	Par.CanCollide = false
	Par.CanQuery = false
	Par.Anchored = true
	Par.Size = Vector3.new(1, 1, 1) * 0.1
	Par.Parent = Model

	Par = Instance.new("Part")
	Par.Color = Color3.fromRGB(85, 255, 127)
	Par.Material = "Neon"
	Par.Position = direction
	Par.CanCollide = false
	Par.Size = Vector3.new(1, 1, 1) * 0.1
	Par.CanQuery = false
	Par.Anchored = true
	Par.Parent = Model

	local Distance = (origin - direction).Magnitude

	local Visual = Instance.new("Part")
	Visual.CFrame = CFrame.new(origin, direction) * CFrame.new(0, 0, -Distance / 2)
	Visual.Material = "Neon"
	Visual.Color = Color3.fromRGB(255, 255, 127)
	Visual.Anchored = true
	Visual.CanCollide = false
	Visual.CanQuery = false
	Visual.Size = Vector3.new(0.1, 0.1, Distance)
	Visual.Parent = Model
end

function _Visualize(StartPosition, EndPosition, Color)
	local Distance = (EndPosition - StartPosition).Magnitude

	local Beam = Instance.new("Part")
	Beam.Anchored = true
	Beam.Color = Color or Color3.fromRGB(255, 255, 255)
	Beam.Locked = true
	Beam.CanCollide = false
	Beam.Size = Vector3.new(0.1, 0.1, Distance)
	Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, -Distance / 2)
	Beam.Parent = workspace.World.Visuals
end

Module["CheckState"] = function(Character, Name)
	local States = game.ReplicatedStorage.PlayerValues:FindFirstChild(Character.Name).States
	if States and States:FindFirstChild(Name) then
		return States[Name].Value
	end

	return
end

Module["CheckCooldown"] = function(Character, Name)
	local Cooldowns = game.ReplicatedStorage.PlayerValues:FindFirstChild(Character.Name).Cooldowns
	if Cooldowns then
		return Cooldowns:FindFirstChild(Name)
	end

	return
end

Module["MakeRemote"] = function(Name, Parent)
	local Remote = Instance.new("RemoteEvent")
	Remote.Name = Name
	Remote.Parent = Parent
	return Remote
end

Module["GetRemote"] = function(Name)
	return game.ReplicatedStorage.Remotes:FindFirstChild(Name, true)
end

Module["GetModule"] = function(Name)
	return Module.Modules[Name]
end

Module["Raycast"] = function(Origin, Direction, Blacklist, Visualize)
	table.insert(Blacklist, workspace.World.Visuals)
	table.insert(Blacklist, workspace.World.Interactable)

	local RayCastParameters = RaycastParams.new()
	RayCastParameters.FilterType = Enum.RaycastFilterType.Exclude
	RayCastParameters.FilterDescendantsInstances = Blacklist

	local Check = workspace:Raycast(Origin, Direction, RayCastParameters)
	if Visualize then
		VisualizeRay(Origin, Direction)
	end

	return Check
end

Module["RoundNumber"] = function(Number, Places)
	Places = Places or 1
	return math.floor(Number * (10 ^ Places)) / (10 ^ Places)
end

Module["PercentOf"] = function(Number, Percent)
	if Percent > 100 then
		return
	end
	return Number * (Percent / 100)
end

Module["TableSearch"] = function(Table, Target)
	for Index, Value in pairs(Table) do
		print(Index, Value)
		if Value == Target then
			return Index, Value
		elseif typeof(Value) == "table" then
			return Module.TableSearch(Value, Target)
		end
	end
	return nil
end

Module["Alive"] = function(Character)
	return Character:FindFirstChild("Humanoid")
		and Character.Humanoid.Health > 0
		and Character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead
end

Module["JSONParse"] = function(Input)
	if typeof(Input) == "string" then
		return HTTPService:JSONDecode(Input)
	else
		return HTTPService:JSONEncode(Input)
	end
end

return Module
