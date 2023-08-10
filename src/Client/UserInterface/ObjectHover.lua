-->Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-->Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

-->Variables
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local ObjectDistance = 15

local PlayerGui = Player.PlayerGui

local Remote = GlobalFunctions.GetRemote("IngredientActions")
local LastObject

-->Methods
Module["Init"] = function()
	LabData = GlobalFunctions.GetModule("LabData")
	local Roact = GlobalFunctions.GetModule("Roact")

	local HoverUI = Roact.createElement("ScreenGui", {
		Name = "ObjectHover",
		IgnoreGuiInset = true,
	}, {
		HoverText = Roact.createElement("TextLabel", {
			Name = "Label",
			Text = "Object Name",
			Size = UDim2.new(0.123, 0, 0.021, 0),
		}),
	})

	HoverText = Roact.mount(HoverUI, PlayerGui)
end

function DistanceCheck(Target)
	local Distance = (Player.Character:WaitForChild("HumanoidRootPart").Position - Target.Position).Magnitude
	return Distance < ObjectDistance
end

function ValidObject(Object)
	return Object:GetAttribute("Ingredient") or Object:GetAttribute("LabTool")
end

function IsHovered(Mouse)
	local Target = Mouse.Target
	if not Target then
		return
	end

	if ValidObject(Target.Parent) then
		Target = Target.Parent
	end

	if Target and ValidObject(Target) then
		if DistanceCheck(Target) then
			return Target
		end
		return
	else
		return
	end
end

function ObjectText()
	local Object = IsHovered(Mouse)
	local Speed = 0.085

	if Object then
		if HoverText.Visible then
			TweenService:Create(HoverText, TweenInfo.new(Speed, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0, (Mouse.X + 15), 0, (Mouse.Y - 12.5)),
			}):Play()
		else
			HoverText.Position = UDim2.new(0, (Mouse.X + 15), 0, (Mouse.Y - 12.5))
		end

		local IngredientData = LabData.GetObject(Object.Name)
		local Name = Object:GetAttribute("LabTool") and IngredientData.Description or Object.Name

		HoverText.Text = Name
		HoverText.Visible = true
	else
		HoverText.Visible = false
	end
end

function ObjectOutline(Object)
	if not LastObject then
		return
	end

	local Highlight = (Object or LastObject):FindFirstChild("HoverHighlight")
	local Speed = 0.25

	if Object and not Highlight then
		Highlight = Instance.new("Highlight")
		Highlight.Name = "HoverHighlight"
		Highlight.FillColor = Color3.new(1, 1, 1)
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 1
		Highlight.Parent = Object

		TweenService:Create(Highlight, TweenInfo.new(Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
			FillTransparency = 0.5,
			OutlineTransparency = 0,
		}):Play()
	elseif not Object and Highlight then
		TweenService:Create(Highlight, TweenInfo.new(Speed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			FillTransparency = 1,
			OutlineTransparency = 1,
		}):Play()

		game.Debris:AddItem(Highlight, Speed)
	end

	return Highlight
end

-->Functionality
UserInputService.InputBegan:Connect(function(Input, Typing)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		if LastObject and IsHovered(Mouse) and DistanceCheck(LastObject) then
			if LastObject:GetAttribute("LabTool") then
				print(LastObject.Name .. "added to cauldron")
				Remote:FireServer("AddCauldron")
			else
				print(LastObject.Name .. "picked up")
				Remote:FireServer("Pickup", LastObject.Name)
			end
		end
	end
end)

task.spawn(function()
	while Players:FindFirstChild(Player.Name) do
		local Hovered = IsHovered(Mouse)
		LastObject = Hovered and Hovered or LastObject

		ObjectText()
		ObjectOutline(Hovered)
		task.wait()
	end
end)

return Module
