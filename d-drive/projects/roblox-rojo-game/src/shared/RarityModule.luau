--[[
    ZedoxTECh RNG System v1.0
    A professional, scalable rarity system for RNG games.
]]

local RarityModule = {}

-- Define your rarities here
-- Format: {Name, Chance (1 in X), Color}
RarityModule.Rarities = {
	{Name = "Common", Chance = 2, Color = Color3.fromRGB(200, 200, 200)},
	{Name = "Uncommon", Chance = 5, Color = Color3.fromRGB(100, 255, 100)},
	{Name = "Rare", Chance = 20, Color = Color3.fromRGB(100, 100, 255)},
	{Name = "Epic", Chance = 100, Color = Color3.fromRGB(255, 100, 255)},
	{Name = "Legendary", Chance = 1000, Color = Color3.fromRGB(255, 255, 100)},
	{Name = "Mythical", Chance = 10000, Color = Color3.fromRGB(255, 50, 50)},
	{Name = "GODLY", Chance = 100000, Color = Color3.fromRGB(255, 255, 255)}, -- Glowing/Animated in UI
}

function RarityModule.Roll()
	local randomNumber = math.random(1, 1000000) / 10 -- Support for 0.1 precision
	
	-- Sort rarities by chance (hardest first)
	local sorted = table.clone(RarityModule.Rarities)
	table.sort(sorted, function(a, b) return a.Chance > b.Chance end)
	
	for _, rarity in ipairs(sorted) do
		-- Convert "1 in X" to a probability threshold
		local threshold = (1 / rarity.Chance) * 100000
		if randomNumber <= threshold then
			return rarity
		end
	end
	
	return RarityModule.Rarities[1] -- Default to Common
end

return RarityModule
