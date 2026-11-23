--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = Shared:WaitForChild("Remotes")
local RedeemCodeEvent = Remotes:WaitForChild("RedeemCode")

local DataService = require(script.Parent:WaitForChild("DataService"))

local CodeService = {}

-- Mission #35: The Zedox Member Vault Codes
local Codes = {
	["ZEDOX2K"] = "AllPerks"
}

-- Perk Definitions
local Perks = {
	["AllPerks"] = {
		LuckMultiplier = 3.0,
		RollCooldown = 0.2,
		AutoRollEnabled = true
	}
}

function CodeService.Init()
	RedeemCodeEvent.OnServerEvent:Connect(function(player, code: string)
		if not code or typeof(code) ~= "string" then return end
		code = string.upper(code)
		
		local rewardName = Codes[code]
		if not rewardName then
			-- Invalid code
			RedeemCodeEvent:FireClient(player, false, "Invalid Code")
			return
		end
		
		-- Access player data for redemption check
		local data = DataService.GetPlayerData(player)
		if not data then 
			RedeemCodeEvent:FireClient(player, false, "Data Error")
			return 
		end
		
		local redeemedCodes = data.RedeemedCodes or {}
		if table.find(redeemedCodes, code) then
			-- Already redeemed
			RedeemCodeEvent:FireClient(player, false, "Already Used")
			return
		end
		
		-- Valid redemption!
		table.insert(redeemedCodes, code)
		data.RedeemedCodes = redeemedCodes
		
		-- Apply Perk
		local perk = Perks[rewardName]
		if perk then
			if perk.LuckMultiplier then
				player:SetAttribute("LuckMultiplier", perk.LuckMultiplier)
			end
			if perk.RollCooldown then
				player:SetAttribute("RollCooldown", perk.RollCooldown)
			end
			if perk.AutoRollEnabled then
				player:SetAttribute("HasAutoRoll", true)
			end
			
			-- Save immediately to the Vault
			DataService.SaveData(player)
			
			-- Feedback to client
			RedeemCodeEvent:FireClient(player, true, rewardName)
			print("Zedox Member Vault: " .. player.Name .. " redeemed " .. code)
		end
	end)
end

-- Initialize the service
task.spawn(CodeService.Init)

return CodeService
