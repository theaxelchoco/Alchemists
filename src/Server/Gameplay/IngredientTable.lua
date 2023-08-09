-->Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

-->Variables
local IngredientTable = workspace.World.Map.IngredientTable
local IngredientSpaces = IngredientTable.Ingredients:GetChildren()

-->Methods
function CheckOwned(Player, ItemName)
	if true then
		return true
	end

	return true
end

Module["Init"] = function()
	Datastore = GlobalFunctions.GetModule("Datastore")
	IngredientStorage = GlobalFunctions.GetModule("Ingredients")

	for _, Ingredient in ipairs(IngredientSpaces) do
		if CheckOwned(nil, Ingredient.Name) then
			local IngredientData = IngredientStorage.GetIngredient(Ingredient.Name)
			if IngredientData then
				local Model = IngredientData.Model:Clone()
				Model:SetAttribute("Ingredient", true)
				Model.CFrame = Ingredient.CFrame
				Model.Anchored = true
				Model.Parent = IngredientTable.Ingredients

				IngredientTable.Ingredients:FindFirstChild(Ingredient.Name):Destroy()
			end
		end
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
		Object.Parent = IngredientTable.Ingredients
	end
end

Module["GetIngredient"] = function(Player, Name)
	local Check = IngredientTable.Ingredients:FindFirstChild(Name)
	if Check then
		return Check
	end
	return
end

Module["LoadTable"] = function(Player) end

Module["UpdateTable"] = function(Player) end

return Module
