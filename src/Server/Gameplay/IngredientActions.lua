-->Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

-->Variables
local Remote = GlobalFunctions.MakeRemote(script.Name, game.ReplicatedStorage.Remotes.Gameplay)

-->Methods
function HasItem(Character)
	for _, Item in ipairs(Character.ItemHeld:GetChildren()) do
		if Item:GetAttribute("Ingredient") then --Add when potions are made to check for potion objects too
			return true
		end
	end
	return false
end

Module["Init"] = function()
	Datastore = GlobalFunctions.GetModule("Datastore")
	IngredientStorage = GlobalFunctions.GetModule("Ingredients")
	IngredientTable = GlobalFunctions.GetModule("IngredientTable")

	Remote.OnServerEvent:Connect(function(Player, Action, ObjectName)
		if Module[Action] then
			Module[Action](Player, ObjectName)
		end
	end)
end

Module["Pickup"] = function(Player, ObjectName)
	print("hallo")

	local Character = Player.Character
	local Model = IngredientTable.GetIngredient(Player, ObjectName)
	print(Model)

	if Model and not Character.ItemHeld:FindFirstChild(ObjectName) and not HasItem(Character) then
		local Clone = Model:Clone()

		local Attach = Instance.new("Attachment")
		Attach.Parent = Model

		local CharAttach = Character.RightHand:FindFirstChild("RightGripAttachment")

		Model.Anchored = false
		Model.Massless = true
		Model.CanCollide = false
		Model.Parent = Character.ItemHeld
		Model:SetNetworkOwner(Player)

		local AlignPosition = Instance.new("AlignPosition")
		AlignPosition.Name = "IngredientMovement"
		AlignPosition.Attachment0 = Attach
		AlignPosition.Attachment1 = CharAttach
		AlignPosition.MaxForce = 1e6
		AlignPosition.ApplyAtCenterOfMass = true
		AlignPosition.Responsiveness = 20
		AlignPosition.MaxVelocity = 35
		AlignPosition.Parent = Attach
		while Attach:FindFirstChild("IngredientMovement") do
			if (Model.Position - CharAttach.WorldPosition).Magnitude < 1 then
				break
			end
			task.wait()
		end
		AlignPosition:Destroy()
		Model.Anchored = true

		task.spawn(IngredientTable.AddIngredient, Player, Clone, 3.5)
		--[[
            IngredientTable.AddIngredient(Player, Clone, 3.5)
        ]]

		Model.CFrame = Character.RightHand.CFrame * CFrame.new(0, -0.75, 0)

		local Weld = Instance.new("WeldConstraint")
		Weld.Part0 = Model
		Weld.Part1 = Character.RightHand
		Weld.Parent = Model

		Model.Anchored = false
	end
end

return Module
