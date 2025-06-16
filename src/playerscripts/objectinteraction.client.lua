-->services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-->modules
local objectevent = require(ReplicatedStorage.events.objectevent):Client()
local hoverdata = require(ReplicatedStorage.modules.datastorage.hoverdata)
local objectdata = require(ReplicatedStorage.modules.datastorage.objectdata)
local utility = require(ReplicatedStorage.modules.shared.utility)
local boattween = require(ReplicatedStorage.packages.boattween)
local inpututil = require(ReplicatedStorage.packages.inpututil)

-->variables
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local objectdistance = hoverdata.distance

local hoverui = player.PlayerGui:WaitForChild("objecthover")
local hoverlabel = hoverui:WaitForChild("hovertext")

local mouseutil = inpututil.Mouse.new()
local lastobject

-->character loaded
local character = player.Character or player.CharacterAdded:Wait()
if not character:GetAttribute("loaded") then
	repeat
		task.wait()
	until character:GetAttribute("loaded")
end

-->functions
local function validobject(object)
	return object:GetAttribute("hoverable")
end

local function distancecheck(object)
	return (character.PrimaryPart.Position - object.Position).Magnitude <= objectdistance
end

local function ishovered(mouse)
	local target = mouse.Target
	if not target then
		return
	end

	if validobject(target.Parent) then
		target = target.Parent
	end

	if validobject(target) then
		if distancecheck(target) then
			return target
		end
	end

	return
end

local function objecttext()
	local object = ishovered(mouse)
	local speed = 0.045

	local xoffset = 15
	local yoffset = -6

	if not object then
		hoverlabel.Visible = false
		return
	end

	if hoverlabel.Visible then
		boattween
			:Create(hoverlabel, {
				Time = speed,
				EasingStyle = "Quad",

				Goal = {
					Position = UDim2.new(0, (mouse.X + xoffset), 0, (mouse.Y - yoffset)),
				},
			})
			:Play()
	else
		hoverlabel.Position = UDim2.new(0, (mouse.X + xoffset), 0, (mouse.Y - yoffset))
	end

	local objectinfo = objectdata.get(object.Name)
	local text = objectinfo.type == "ingredient" and objectinfo.description or objectinfo.name

	if object.Parent.Name == "forageables" then
		text = `collect {object.Name}.`
	end

	if objectinfo.type == "ingredient" then
		if not object:GetAttribute("owned") and not object:GetAttribute("forage") then
			hoverlabel.Visible = false
			return
		end
	end

	hoverlabel.Text = text
	hoverlabel.Visible = true
end

local function objectoutline(current)
	local speed = 0.25

	if current and not current:GetAttribute("owned") then
		return
	end

	if lastobject and lastobject ~= current then
		local oldHighlight = lastobject:FindFirstChild("hoverhighlight")
		if oldHighlight then
			boattween
				:Create(oldHighlight, {
					Time = speed,
					EasingStyle = "Quad",
					EasingDirection = "InOut",
					Goal = {
						FillTransparency = 1,
						OutlineTransparency = 1,
					},
				})
				:Play()
			utility.debris(oldHighlight, speed)
		end
	end

	if current then
		local highlight = current:FindFirstChild("hoverhighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "hoverhighlight"
			highlight.FillColor = Color3.new(1, 1, 1)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			highlight.Parent = current

			boattween
				:Create(highlight, {
					Time = speed,
					EasingStyle = "Quad",
					EasingDirection = "InOut",
					Goal = {
						FillTransparency = 0.5,
						OutlineTransparency = 0,
					},
				})
				:Play()
		end
	end

	lastobject = current
end

--[[
local function objectoutline(object)
	if not lastobject or not object then
		print(lastobject, object)
		return
	end

	local highlight = (object or lastobject):FindFirstChild("hoverhighlight")
	local speed = 0.25

	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "hoverhighlight"
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Parent = object

		boattween
			:Create(highlight, {
				Time = speed,
				EasingSTyle = "Quad",
				EasingDirection = "InOut",

				Goal = {
					FillTransparency = 0.5,
					OutlineTransparency = 0,
				},
			})
			:Play()
	elseif highlight then
		boattween
			:Create(highlight, {
				Time = speed,
				EasingStyle = "Quad",
				EasingDirection = "InOut",

				Goal = {
					FillTransparency = 1,
					OutlineTransparency = 1,
				},
			})
			:Play()
		utility.debris(highlight, speed)
	end

	return highlight
end
]]

mouseutil.LeftDown:Connect(function()
	if lastobject and ishovered(mouse) and distancecheck(lastobject) then
		print("clicked an object")
		local data = objectdata.get(lastobject.Name)
		if not data then
			return
		end

		if data.type == "tool" then
			print("prob a cauldron or something equivalent")
		else
			print("pickup an item")
			objectevent:Fire("pickup", lastobject.Name)
		end
	end
end)

while true do
	character = player.Character

	local hovered = ishovered(mouse)
	objecttext()
	objectoutline(hovered)

	--lastobject = hovered or lastobject

	task.wait()
end
