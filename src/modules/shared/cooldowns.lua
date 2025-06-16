local utility = require(script.Parent.utility)
-->services

-->modules
local module = {}

-->variables

-->methods
module["active"] = function(player, name)
	local folder = player:FindFirstChild("cooldowns")
	if not folder then
		return
	end

	return folder:FindFirstChild(name) ~= nil
end

module["start"] = function(player, name, duration)
	local folder = player:FindFirstChild("cooldowns")
	if not folder then
		return
	end

	local object = Instance.new("NumberValue")
	object.Name = name
	object.Value = duration
	object.Parent = folder
	utility.debris(object, duration)

	return object
end

module["load"] = function(player)
	local folder = Instance.new("Folder")
	folder.Name = "cooldowns"
	folder.Parent = player
end

module["clear"] = function(player)
	local folder = player:FindFirstChild("cooldowns")
	if folder then
		folder:Destroy()
	end
end
