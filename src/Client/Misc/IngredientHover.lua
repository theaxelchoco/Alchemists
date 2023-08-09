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
local ObjectDistance = 25

local HoverUI = Player.PlayerGui:WaitForChild("IngredientHover")
local HoverText = HoverUI:FindFirstChild("Label")

local Remote = GlobalFunctions.GetRemote("IngredientActions")
local LastObject

-->Methods
function DistanceCheck(Target)
	local Distance = (Player.Character:WaitForChild("HumanoidRootPart").Position - Target.Position).Magnitude
	return Distance < ObjectDistance
end

function IsHovered(Mouse)
	local Target = Mouse.Target
	if Target and Target:GetAttribute("Ingredient") then
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
	local Speed = 0.065

	if Object then
		--HoverText.Position = -UDim2.new(0, (Mouse.X + 15), 0, (Mouse.Y + 20))
		if HoverText.Visible then
			TweenService:Create(HoverText, TweenInfo.new(Speed, Enum.EasingStyle.Quad), {
				Position = UDim2.new(0, (Mouse.X + 15), 0, (Mouse.Y - 12.5)),
			}):Play()
		else
			HoverText.Position = UDim2.new(0, (Mouse.X + 15), 0, (Mouse.Y - 12.5))
		end

		HoverText.Text = Object.Name
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
			print(LastObject.Name .. "picked up")
			Remote:FireServer("Pickup", LastObject.Name)
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
