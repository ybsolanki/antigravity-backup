--!strict
local ShopConfig = {
	-- REPLACE THESE WITH YOUR REAL GAMEPASS IDs FROM CREATOR DASHBOARD
	LuckPassID = 1735972949, 
	SpeedPassID = 1738545532, 
	AutoRollPassID = 1737012927,
	BundlePassID = 1735359161,
	
	Prices = {
		Luck = 200,
		Speed = 100,
		Auto = 200,
		Bundle = 450
	},
	
	LuckMultiplier = 3, -- +200% Bonus
	RollCooldown = 0.2,
	AutoRollInterval = 1.5,
	GroupLuckBonus = 1.1 -- +10%
}

return ShopConfig
