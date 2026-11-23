--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShopConfig = require(Shared:WaitForChild("ShopConfig"))

local function ApplyPerks(player: Player, passId: number)
	if passId == ShopConfig.LuckPassID or passId == ShopConfig.BundlePassID then
		player:SetAttribute("LuckMultiplier", ShopConfig.LuckMultiplier)
	end
	if passId == ShopConfig.SpeedPassID or passId == ShopConfig.BundlePassID then
		player:SetAttribute("RollCooldown", ShopConfig.RollCooldown)
	end
	if passId == ShopConfig.AutoRollPassID or passId == ShopConfig.BundlePassID then
		player:SetAttribute("HasAutoRoll", true)
	end
	if passId == ShopConfig.BundlePassID then
		player:SetAttribute("HasZedoxTag", true)
	end
end

local ShopManager = {}

function ShopManager.Init()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
		if not wasPurchased then return end
		
		ApplyPerks(player, gamePassId)
		
		-- Trigger Cinematic Purchase Celebration
		player:SetAttribute("TriggerPurchaseVFX", tick())
	end)

	-- Check ownership on Join
	local function CheckAll(player: Player)
		task.spawn(function()
			task.wait(0.5)
			pcall(function()
				local passes = {
					ShopConfig.LuckPassID, 
					ShopConfig.SpeedPassID, 
					ShopConfig.AutoRollPassID, 
					ShopConfig.BundlePassID
				}
				for _, id in passes do
					if id and id > 0 then
						if MarketplaceService:UserHasGamePassAsync(player.UserId, id) then
							ApplyPerks(player, id)
						end
					end
				end
			end)
		end)
	end

	Players.PlayerAdded:Connect(CheckAll)
	for _, player in Players:GetPlayers() do
		CheckAll(player)
	end
end

return ShopManager
