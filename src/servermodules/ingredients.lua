local ReplicatedStorage = game:GetService("ReplicatedStorage")

local objectevent = require(ReplicatedStorage.events.objectevent):Server()
local objectdata = require(ReplicatedStorage.modules.datastorage.objectdata)
local tableutil = require(ReplicatedStorage.packages.tableutil)
local datastore = require(script.Parent.datastore)
-->services

-->modules
local module = {}

-->variables
local laboratory = workspace.laboratory
local ingredientspaces = laboratory.ingredients:GetChildren()

-->methods
local function itemowned(player, item)
	local ingredients = datastore.get(player, "ingredients")
	ingredients = tableutil.DecodeJSON(ingredients)

	if table.find(ingredients.base, item) then
		return true
	end

	if table.find(ingredients.paid, item) then
		return true
	end

	if table.find(ingredients.limited, item) then
		return true
	end

	return
end

local function getobject(player, name)
	local object = laboratory.ingredients:FindFirstChild(name)

	if not object then
		object = workspace.forageables:FindFirstChild(name)
	end

	return object
end

local function makeingredient(data)
	for _, ingredient in ipairs(ingredientspaces) do
		if ingredient.Name == data.name then
			local model = data.model:Clone()
			model:SetAttribute("hoverable", true)
			model:SetAttribute("owned", true)
			model.CFrame = ingredient.CFrame
			model.Anchored = true
			model.Parent = laboratory.ingredients

			local center = Instance.new("Attachment")
			center.Name = "center"
			center.Parent = model
		end
	end
end

module["pickup"] = function(player, objectname)
	local character = player.Character
	local model = getobject(player, objectname)

	if model and #character.itemheld:GetChildren() <= 0 then
		local data = objectdata.get(objectname)

		local attach = model:FindFirstChild("center")
		local charattach = character.RightHand:FindFirstChild("RightGripAttachment")

		model.Anchored = false
		model.Massless = true
		model.CanCollide = false
		model.CanQuery = false
		model.CanTouch = false

		model.Parent = character.itemheld
		model:SetNetworkOwner(player)

		local alignposition = Instance.new("AlignPosition")
		alignposition.Name = "ingredientmovement"
		alignposition.Attachment0 = attach
		alignposition.Attachment1 = charattach
		alignposition.MaxForce = 1e6
		alignposition.ApplyAtCenterOfMass = true
		alignposition.Responsiveness = 100
		alignposition.MaxVelocity = 45
		alignposition.Parent = model

		while model:FindFirstChild("ingredientmovement") do
			if (model.Position - charattach.WorldPosition).Magnitude < 1 then
				break
			end

			task.wait()
		end

		alignposition:Destroy()
		model.Anchored = true

		model.CFrame = character.RightHand.CFrame --* CFrame.new(0, -0.75, 0)

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = model
		weld.Part1 = character.RightHand
		weld.Name = "itemweld"
		weld.Parent = model

		model.Anchored = false

		task.delay(2, makeingredient, data)
	end
end

module["load"] = function(player)
	-->loading forageable ingredients
	for _, ingredient in ipairs(workspace.forageables:GetChildren()) do
		ingredient:SetAttribute("hoverable", true)
		ingredient:SetAttribute("forage", true)
	end

	-->loading ingredients in lab
	for _, ingredient in ipairs(ingredientspaces) do
		ingredient:SetAttribute("hoverable", true)

		if itemowned(player, ingredient.Name) then
			local data = objectdata.get(ingredient.Name)
			if data then
				makeingredient(data)
				ingredient:Destroy()
			end
		else
			ingredient:SetAttribute("owned", false)
			ingredient.Transparency = 0.5
			ingredient.TextureID = ""
			ingredient.Color = Color3.fromRGB(95, 95, 95)
		end
	end
end

module["clear"] = function(player)
	print("clear ingredients for " .. player.Name)
end

module["init"] = function()
	objectevent:On(function(player, action, data)
		if module[action] then
			module[action](player, data)
		end
	end)
end

return module
