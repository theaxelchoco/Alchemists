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
	LabData = GlobalFunctions.GetModule("LabData")
	IngredientTable = GlobalFunctions.GetModule("IngredientTable")
	BezierCurves = GlobalFunctions.GetModule("BezierCurves")

	Remote.OnServerEvent:Connect(function(Player, Action, ObjectName)
		if Module[Action] then
			Module[Action](Player, ObjectName)
		end
	end)
end

Module["AddCauldron"] = function(Player)
	local Character = Player.Character
	local Model = Character.ItemHeld:FindFirstChildOfClass("MeshPart")
	--Rewrite this to check for the player's cauldron
	local Cauldron = workspace.World.Map.Laboratory.Tools.Cauldron

	--Add check for ingredient or potion type
	if Model and HasItem(Character) then
		local Attach = Model:FindFirstChild("CenterAttachment")
		local CharAttach = Character.RightHand:FindFirstChild("RightGripAttachment")

		Model.Anchored = true
		Model.Massless = true
		Model.CanCollide = false
		Model.CanQuery = false
		Model.Parent = workspace.World.Visuals

		local Weld = Model:FindFirstChild("ItemWeld")
		if Weld then
			Weld:Destroy()
		end

		--Bezier Curve to throw object in the cauldron
		local Bezier = BezierCurves.new(Model.Position, Cauldron.Brew.Position)
		Bezier:CreateVector3Tween(Model, {}, TweenInfo.new(0.5, Enum.EasingStyle.Quad), true):Play()
	end
end

Module["Pickup"] = function(Player, ObjectName)
	local Character = Player.Character
	local Model = IngredientTable.GetObject(Player, ObjectName)

	--Add check for ingredient or potion type
	if Model and not Character.ItemHeld:FindFirstChild(ObjectName) and not HasItem(Character) then
		local Clone = Model:Clone()

		local Attach = Model:FindFirstChild("CenterAttachment")
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
		AlignPosition.MaxVelocity = 45
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

		Model.CFrame = Character.RightHand.CFrame * CFrame.new(0, -0.75, 0)

		local Weld = Instance.new("WeldConstraint")
		Weld.Name = "ItemWeld"
		Weld.Part0 = Model
		Weld.Part1 = Character.RightHand
		Weld.Parent = Model

		Model.Anchored = false
	end
end

return Module
