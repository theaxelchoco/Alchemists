--/Services
local HTTPService = game:GetService("HttpService")

--/Modules
local Module = {}
local Template = require(script.Template)

--/Variables
local PlayerValues = game.ReplicatedStorage.PlayerValues

--/Methods
Module.Init = true
Module["LoadStates"] = function(Folder)
	for Name, Value in pairs(Template) do
		local Type = typeof(Value) == "number" and "NumberValue"
			or typeof(Value) == "string" and "StringValue"
			or typeof(Value) == "boolean" and "BoolValue"
			or nil

		local Obj = Instance.new(Type or "StringValue")
		Obj.Name = Name
		Obj.Value = if Type then Value else HTTPService:JSONEncode(Value)
		Obj.Parent = Folder
	end
end

Module["Refresh"] = function(Folder)
	for _, Obj in ipairs(Folder:GetChildren()) do
		local Value = Template[Obj.Name]
		if not Value then
			continue
		end

		local Type = typeof(Value) == "number" and "NumberValue"
			or typeof(Value) == "string" and "StringValue"
			or typeof(Value) == "boolean" and "BoolValue"
			or nil
		Obj.Value = if Type then Value else HTTPService:JSONEncode(Value)
	end
end

Module["Get"] = function(Player, Name)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	if not Values then
		return
	end

	local States = Values.States
	if States and States:FindFirstChild(Name) then
		return States:FindFirstChild(Name).Value
	end

	return
end

Module["GetObject"] = function(Player, Name)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local States = Values.States
	if States and States:FindFirstChild(Name) then
		return States:FindFirstChild(Name)
	end

	return
end

Module["Set"] = function(Player, Name, Value)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local States = Values.States
	if States and States:FindFirstChild(Name) then
		States:FindFirstChild(Name).Value = Value
	end
end

Module["Add"] = function(Player, Name, Value)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local Type = typeof(Value) == "number" and "NumberValue"
		or typeof(Value) == "string" and "StringValue"
		or typeof(Value) == "boolean" and "BoolValue"
		or typeof(Value) == "CFrame" and "CFrameValue"
		or nil

	local Obj = Instance.new(Type or "StringValue")
	Obj.Name = Name
	Obj.Value = if Type then Value else HTTPService:JSONEncode(Value)
	Obj.Parent = Values.States
end

Module["Increment"] = function(Player, Name, Amount)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local States = Values.States
	if States and States:FindFirstChild(Name) then
		States:FindFirstChild(Name).Value += Amount or 1
	end
end

Module["Print"] = function(Player)
	local Values = PlayerValues:FindFirstChild(Player.Name)
	if not Values then
		Values = Player:FindFirstChild("Values")
	end

	local States = Values.States
	local Table = {}

	if States then
		for _, State in ipairs(States:GetChildren()) do
			Table[State.Name] = State.Value
		end
		print(Table)
	end
end

return Module
