--/Services
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--/Modules
local Module = {}
local GlobalFunctions = require(game.ReplicatedStorage.Modules.Shared.GlobalFunctions)

--/Variables
--local Visuals = workspace.World.Visuals
Module.Visualize = false

--/Methods
function Visualize(StartPosition, EndPosition, Color)
	local Distance = (EndPosition - StartPosition).Magnitude

	local Beam = Instance.new("Part")
	Beam.Anchored = true
	Beam.Color = Color or Color3.fromRGB(255, 255, 255)
	Beam.Locked = true
	Beam.CanCollide = false
	Beam.Size = Vector3.new(0.1, 0.1, Distance)
	Beam.CFrame = CFrame.new(StartPosition, EndPosition) * CFrame.new(0, 0, -Distance / 2)
	Beam.Parent = workspace.World.Visuals
end

Module["GetBoxPoints"] = function(Coordinate, Size, Accuracy)
	Accuracy = Accuracy or 1
	local Points = {}

	for X = 0, Size.X, Accuracy do
		for Y = 0, Size.Y, Accuracy do
			local Point = Coordinate * CFrame.new((X - Size.X / 2), (Y - Size.Y / 2), Size.Z / 2)
			table.insert(Points, Point.Position)
		end
	end

	return Points
end

Module["GetBallPoints"] = function(Coordinate, Radius, Accuracy)
	Accuracy = Accuracy >= 10 and Accuracy or 10

	local Step = math.rad(180 / Accuracy)
	local Points = {}

	Coordinate *= CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))

	for i = math.rad(90), math.rad(270), Step do
		local R = math.sin(i) * Radius
		local Y = math.cos(i) * Radius
		for j = 0, math.pi * 2, Step do
			local X = math.cos(j) * R
			local Z = math.sin(j) * R

			local Point = Coordinate * CFrame.new(X, Y, Z)
			table.insert(Points, Point.Position)
		end
	end

	return Points
end

Module["Fire"] = function(Data)
	local Points = Data.Points
	local Direction = Data.Direction
	local Speed = Data.Speed
	local Gravity = Data.Gravity or Vector3.new()
	local Lifetime = Data.Lifetime or 1
	local Function = Data.Function
	local Blacklist = Data.Blacklist

	local Object = Data.Object

	local StartTime = os.clock()
	local Conn

	local function EndLoop()
		Conn:Disconnect()
		Conn = nil
		return
	end

	Conn = RunService.Stepped:Connect(function(CurrentTime, DeltaTime)
		if os.clock() - StartTime >= Lifetime then
			print("exceeded lifetime")
			EndLoop()
		end

		for Index, Point in pairs(Points) do
			Direction += (Gravity * DeltaTime)
			local EndPosition = Point + (Direction * (Speed * DeltaTime))
			local Difference = (EndPosition - Point)

			local TweenSpeed = DeltaTime * Difference.Magnitude
			local RayDirection = Difference.Unit * Difference.Magnitude

			local Results = GlobalFunctions.Raycast(Point, RayDirection, Blacklist)

			if Module.Visualize then
				Visualize(Point, EndPosition, Color3.fromRGB(255, 98, 101))
			end

			if Object then
				Object.CFrame = CFrame.lookAt(Point, EndPosition)
				task.spawn(function()
					TweenService:Create(Object, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Linear), {
						Position = EndPosition,
					}):Play()
				end)
			end

			if Results then
				if Function then
					task.delay(TweenSpeed, Function, Results, Object)
				end
				EndLoop()
				break
			end

			Points[Index] = EndPosition
		end
	end)
end

return Module
