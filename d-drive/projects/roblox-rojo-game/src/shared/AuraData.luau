--!strict
local AuraData = {}

export type AuraInfo = {
	Name: string,
	Chance: number -- 1 in X chance
}

AuraData.Auras = {
	{ Name = "Common", Chance = 2, Color = Color3.fromRGB(255, 255, 255) },
	{ Name = "Uncommon", Chance = 5, Color = Color3.fromRGB(57, 255, 250) },
	{ Name = "Ruby", Chance = 500, Color = Color3.fromRGB(231, 54, 54) },
	{ Name = "Magnetic", Chance = 2084, Color = Color3.fromRGB(177, 121, 210) },
	{ Name = "Smiley", Chance = 5000, Color = Color3.fromRGB(246, 255, 0) },
	{ Name = "Undead", Chance = 10000, Color = Color3.fromRGB(46, 204, 113) },
	{ Name = "Stormal", Chance = 90000, Color = Color3.fromRGB(0, 165, 255) },
	{ Name = "Raven", Chance = 500000, Color = Color3.fromRGB(44, 62, 80) },
	{ Name = "Astral", Chance = 1000000, Color = Color3.fromRGB(155, 89, 182) },
	{ Name = "Duskreaver", Chance = 2500000, Color = Color3.fromRGB(52, 73, 94) },
}

-- Sort auras by chance (rarest first to most common last for easier rolling logic)
table.sort(AuraData.Auras, function(a, b)
	return a.Chance > b.Chance
end)

return AuraData
