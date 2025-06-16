-->services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->modules
local module = {}
local profileservice = require(script.profileservice)
local datatemplate = require(ReplicatedStorage.modules.templates.datatemplate)
local tableutil = require(ReplicatedStorage.packages.tableutil)

-->variables
local profiles = {}
local datakey = datatemplate.version
local gameprofile = profileservice.GetProfileStore(datakey, datatemplate)

local errormessage = "Experienced an error while loading your profile. Please rejoin."
local mapping = {
	number = "NumberValue",
	string = "StringValue",
	boolean = "BoolValue",
	table = "StringValue",
	Instance = "ObjectValue",
	Vector3 = "Vector3Value",
}

-->methods
module["createfolder"] = function(player, data)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = data.level or 1
	level.Parent = leaderstats

	local folder = Instance.new("Folder")
	folder.Name = "data"
	folder.Parent = player

	for name, value in pairs(data) do
		local valtype = typeof(value)

		local object = Instance.new(mapping[valtype] or "StringValue")
		object.Name = name

		if valtype == "boolValue" then
			object.Value = value
		elseif valtype == "table" then
			object.Value = tableutil.EncodeJSON(value)
		else
			object.Value = value
		end

		object.Parent = folder

		object.Changed:Connect(function(NewValue)
			data[name] = NewValue
			if name == "level" then
				leaderstats:FindFirstChild("Level").Value = NewValue
			end
		end)
	end
end

module["load"] = function(player)
	local profile = gameprofile:LoadProfileAsync(tostring(player.UserId))
	if not profile then
		player:Kick(errormessage)
		return
	end

	profile:AddUserId(player.UserId)
	profile:Reconcile() -- Reconcile the profile to ensure it matches the template

	profile:ListenToRelease(function()
		if player and player:IsDescendantOf(game) then
			profiles[player] = nil
			player:Kick(errormessage)
		end
	end)

	if player:IsDescendantOf(game) then
		profiles[player] = profile
		module.createfolder(player, profile.Data)
	else
		profile:Release(errormessage)
	end
end

module["get"] = function(player, name)
	local data = player:FindFirstChild("data")
	if not data then
		return
	end

	local object = data:FindFirstChild(name)
	return object and object.Value
end

module["getobject"] = function(player, name)
	local data = player:FindFirstChild("data")
	if not data then
		return
	end

	return data:FindFirstChild(name)
end

module["set"] = function(player, name, value)
	local data = player:FindFirstChild("data")
	if not data then
		return
	end

	local object = data:FindFirstChild(name)
	if object then
		object.Value = value
	end
end

module["increment"] = function(player, name, amount)
	local currval = module.get(player, name)
	if not currval then
		return
	end

	module.set(player, name, currval + (amount or 1))
end

module["append"] = function(player, name, value)
	local currval = module.get(player, name)
	if not currval then
		return
	end

	currval = tableutil.DecodeJSON(currval)

	table.insert(currval, value)
	module.set(player, name, tableutil.EncodeJSON(currval))
end

module["clear"] = function(player)
	local profile = profiles[player]
	if profile then
		profile:Release()
	end

	local data = player:FindFirstChild("data")
	if data then
		data:Destroy()
	end
end

return module
