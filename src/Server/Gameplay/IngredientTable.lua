-->Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

-->Variables
local Laboratory = workspace.World.Map.Laboratory
local IngredientSpaces = Laboratory.Ingredients:GetChildren()

-->Methods
function CheckOwned(Player, ItemName)
	if true then
		return true
	end

	return true
end

Module["Init"] = function()
	Datastore = GlobalFunctions.GetModule("Datastore")
	LabData = GlobalFunctions.GetModule("LabData")

	-->Loading Ingredient Table
	for _, Ingredient in ipairs(IngredientSpaces) do
		if CheckOwned(nil, Ingredient.Name) then
			local IngredientData = LabData.GetObject(Ingredient.Name)
			if IngredientData then
				local Model = IngredientData.Model:Clone()
				Model:SetAttribute("Ingredient", true)
				Model.CFrame = Ingredient.CFrame
				Model.Anchored = true
				Model.Parent = Laboratory.Ingredients

				local Attach = Instance.new("Attachment")
				Attach.Name = "CenterAttachment"
				Attach.Parent = Model

				Laboratory.Ingredients:FindFirstChild(Ingredient.Name):Destroy()
			else
				Ingredient.Transparency = 0.65
			end
		end
	end

	for _, Tool in ipairs(Laboratory.Tools:GetChildren()) do
		Tool:SetAttribute("LabTool", true)

		--Add code to apply skins here
	end
end

Module["AddIngredient"] = function(Player, Object, Delay)
	task.wait(Delay or 0)

	print(Object, Delay)
	if CheckOwned(nil, Object.Name) then
		for _, Ingredient in ipairs(IngredientSpaces) do
			if Object.Name == Ingredient.Name then
				Object.CFrame = Ingredient.CFrame
			end
		end

		Object.Anchored = true
		Object.Parent = Laboratory.Ingredients
	end
end

Module["GetObject"] = function(Player, Name)
	local Check = Laboratory.Ingredients:FindFirstChild(Name)
	if Check then
		return Check
	end
	return
end

Module["LoadTable"] = function(Player) end

Module["UpdateTable"] = function(Player) end

return Module
