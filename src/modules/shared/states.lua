-->services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->modules
local module = {}
local statetemplate = require(ReplicatedStorage.modules.templates.statetemplate)
local tableutil = require(ReplicatedStorage.packages.tableutil)

-->variables
local mapping = {
	number = "NumberValue",
	string = "StringValue",
	boolean = "BoolValue",
	table = "StringValue",
	Instance = "ObjectValue",
	CFrame = "CFrameValue",
}

-->methods
module["get"] = function(player, name)
	local folder = player:FindFirstChild("states")
	if not folder then
		return
	end

	local object = folder:FindFirstChild(name)
	if not object then
		return
	end

	if object:IsA("StringValue") then
		return tableutil.DecodeJSON(object.Value)
	else
		return object.Value
	end
end

module["set"] = function(player, name, value)
	local folder = player:FindFirstChild("states")
	if not folder then
		return
	end

	local object = folder:FindFirstChild(name)
	if not object then
		return
	end

	if object:IsA("StringValue") then
		object.Value = tableutil.EncodeJSON(value)
	else
		object.Value = value
	end
end

module["refresh"] = function(player)
	local folder = player:FindFirstChild("states")
	if not folder then
		return
	end

	for name, value in pairs(statetemplate) do
		local object = folder:FindFirstChild(name)
		if not object then
			continue
		end

		local valtype = mapping[typeof(value)]
		if valtype == nil then
			continue
		end

		object.Value = typeof(value) == "table" and tableutil.EncodeJSON(value) or value
	end
end

module["load"] = function(player)
	local folder = Instance.new("Folder")
	folder.Name = "states"
	folder.Parent = player

	for name, value in pairs(statetemplate) do
		local valtype = mapping[typeof(value)]
		if valtype == nil then
			continue
		end

		local object = Instance.new(valtype)
		object.Name = name

		if valtype == "BoolValue" then
			object.Value = value
		else
			object.Value = typeof(value) == "table" and tableutil.EncodeJSON(value) or value
		end

		object.Parent = folder
	end
end

module["clear"] = function(player)
	local folder = player:FindFirstChild("states")
	if folder then
		folder:Destroy()
	end
end

return module
