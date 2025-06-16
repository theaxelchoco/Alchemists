-->services

-->modules
local module = {}

-->methods
module["debris"] = function(object, lifetime)
	if not object then
		return
	end

	if not lifetime or lifetime <= 0 then
		object:Destroy()
		return
	end

	task.delay(lifetime, object.Destroy, object)
end

return module
