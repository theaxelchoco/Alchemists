-->services
local replicatedstorage = game:GetService("ReplicatedStorage")

-->modules
local loader = require(replicatedstorage.packages.loader)

-->load modules
loader.SpawnAll(loader.LoadChildren(replicatedstorage.modules.client), "init")
