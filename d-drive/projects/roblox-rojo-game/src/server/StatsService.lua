local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local StatsService = {}

function StatsService.InitializePlayer(player)
	-- Create a folder for stats (for easy viewing/debugging in Studio)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local resolve = Instance.new("IntValue")
	resolve.Name = "Resolve"
	resolve.Value = 1
	resolve.Parent = leaderstats
	
	-- Attributes are better for dynamic stats (HP/Stamina)
	player:SetAttribute("MaxHealth", Constants.DEFAULT_HEALTH)
	player:SetAttribute("Health", Constants.DEFAULT_HEALTH)
	player:SetAttribute("MaxStamina", Constants.DEFAULT_STAMINA)
	player:SetAttribute("Stamina", Constants.DEFAULT_STAMINA)
	
	print("Stats initialized for " .. player.Name)
end

-- Stamina Regeneration Loop
task.spawn(function()
	while true do
		local dt = task.wait(0.1)
		for _, player in ipairs(Players:GetPlayers()) do
			local currentStamina = player:GetAttribute("Stamina")
			local maxStamina = player:GetAttribute("MaxStamina")
			
			if currentStamina and maxStamina and currentStamina < maxStamina then
				local newStamina = math.min(maxStamina, currentStamina + (Constants.STAMINA_REGEN_RATE * dt))
				player:SetAttribute("Stamina", newStamina)
			end
		end
	end
end)

Players.PlayerAdded:Connect(StatsService.InitializePlayer)

return StatsService
