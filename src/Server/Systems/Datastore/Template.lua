return {
	["Version"] = "Spellcasters.Development.001",

	["Level"] = 1,
	["Experience"] = 0,
	["MaxExperience"] = 50,

	--TODO: Each element has individual levels
	["SavedLevels"] = {
		["Fire"] = {
			Level = 1,
			Experience = 0,
			MaxExperience = 50,
		},
	},

	["Element"] = "Death",
	["ElementalStorage"] = {
		Max = 5,
		Contents = {},
	},

	["SelectedTitle"] = "",
	["Titles"] = {},

	["Bounty"] = 0,
	["Streak"] = 0,

	["Jewels"] = 0,
	["Spins"] = 5,

	--/Tables ig
	["Codes"] = {},

	["Statistics"] = {
		Deaths = 0,
		Kills = 0,
	},

	--/Rewards
	["DailyRewards"] = {
		["Streak"] = 0,
		["LastLogin"] = os.time(),
	},
}
