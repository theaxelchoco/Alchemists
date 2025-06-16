-->services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-->modules
local states = require(ReplicatedStorage.modules.shared.states)
local datastore = require(ServerStorage.datastore)
local ingredients = require(ServerStorage.ingredients)

-->variables

-->methods
local function loadcharacter(character)
	local player = Players:GetPlayerFromCharacter(character)
	states.refresh(player)

	local folder = Instance.new("Folder")
	folder.Name = "itemheld"
	folder.Parent = character

	character:SetAttribute("loaded", true)
end

-->functionality
Players.PlayerAdded:Connect(function(player)
	datastore.load(player)
	states.load(player)
	ingredients.load(player)

	player.CharacterAdded:Connect(loadcharacter)

	local character = player.Character
	if not character:GetAttribute("loaded") then
		loadcharacter(character)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	ingredients.clear(player)

	datastore.clear(player)
	states.clear(player)
end)
