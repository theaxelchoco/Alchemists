local ReplicatedStorage = game:GetService("ReplicatedStorage")

local guard = require(ReplicatedStorage.packages.guard)
local red = require(ReplicatedStorage.packages.red)

return red.Event(script.Name, function(action, data)
	return guard.String(action), guard.Any(data)
end)
