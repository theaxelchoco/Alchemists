-->services
local replicatedstorage = game:GetService("ReplicatedStorage")
local serverstorage = game:GetService("ServerStorage")

-->modules
local globalvalues = require(serverstorage.globalvalues)
local loader = require(replicatedstorage.packages.loader)

-->load modules
loader.SpawnAll(loader.LoadChildren(serverstorage), "init")

-->modules loaded
replicatedstorage:SetAttribute("serverloaded", true)
replicatedstorage:SetAttribute("gameversion", globalvalues.version)
