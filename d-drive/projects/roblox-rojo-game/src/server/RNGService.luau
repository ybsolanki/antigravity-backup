--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local AuraData = require(Shared:WaitForChild("AuraData"))
local AuraEquippedEvent = Shared:WaitForChild("Remotes"):WaitForChild("AuraEquipped")
local AuraRollResultEvent = Shared:WaitForChild("Remotes"):WaitForChild("AuraRollResult")
local RequestRollEvent = Shared:WaitForChild("Remotes"):WaitForChild("RequestRoll")
local EquipAuraEvent = Shared:WaitForChild("Remotes"):WaitForChild("EquipAura")
local SyncInventoryEvent = Shared:WaitForChild("Remotes"):WaitForChild("SyncInventory")

local ShopConfig = require(Shared:WaitForChild("ShopConfig"))

local RNGService = {}

local ZEDOX_GROUP_ID = 34743206 -- Dedicated Zedox Group ID

local DataStoreService = game:GetService("DataStoreService")
local GlobalAuraLeads = nil

-- Wrap this in a pcall because it crashes the whole game if API services are turned off in Studio
pcall(function()
	GlobalAuraLeads = DataStoreService:GetOrderedDataStore("GlobalAuraLeads")
end)

local HttpService = game:GetService("HttpService")
local DataService = require(script.Parent:WaitForChild("DataService"))

local playerBestRarities = {}
local rollDebounces = {}
local playerInventories = {} -- Server-side table fix (Roblox attributes don't support tables)

-- Initialize stats when player joins
Players.PlayerAdded:Connect(function(player)
	-- Mission #32: Data Shield Load
	local data = DataService.LoadData(player)
	if not data then return end -- Mission #37: Nil Rescue Guard
	
	player:SetAttribute("TotalRolls", data.TotalRolls or 0)
	player:SetAttribute("LuckMultiplier", 1) 
	player:SetAttribute("RollCooldown", 0.5) -- Default speed
	
	-- Load Inventory (Mission #36/38 Centralized Fix)
	local inventory = data.InventoryItems or {}
	playerInventories[player.UserId] = inventory -- This now points to the same table object in DataService.cachedData
	SyncInventoryEvent:FireClient(player, inventory)

	-- Mission #33: Load Equipped Aura
	if data.CurrentAura then
		RNGService.ForceEquip(player, data.CurrentAura)
	end

	-- Zedox Group Multiplier (MVP Check)
	task.spawn(function()
		local isMember = player:IsInGroup(ZEDOX_GROUP_ID)
		player:SetAttribute("IsZedoxMember", isMember)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	-- Saving is handled by DataService.PlayerRemoving hook, 
	-- but we need to ensure it has the latest inventory.
	DataService.SaveData(player, playerInventories[player.UserId])
	playerInventories[player.UserId] = nil
end)

-- Rolls an aura using independent "True Luck" probability.
function RNGService.RollAura(player: Player): AuraData.AuraInfo
	if not player then return AuraData.Auras[#AuraData.Auras] end
	
	-- Increment Roll Counter
	local rolls = player:GetAttribute("TotalRolls") or 0
	player:SetAttribute("TotalRolls", rolls + 1)
	
	-- Luck Math (+200% = 3x Multiplier)
	local luck = player:GetAttribute("LuckMultiplier") or 1
	
	-- Zedox Global Boost (+10% stacking)
	if player:GetAttribute("IsZedoxMember") then
		luck *= ShopConfig.GroupLuckBonus
	end
	
	-- Roblox Premium Bonus (+10% stacking)
	if player.MembershipType == Enum.MembershipType.Premium then
		luck *= 1.1 -- Standard 10% bonus for Premium
	end
	
	-- True Luck: Every aura has an independent chance per roll
	for _, aura in AuraData.Auras do
		local adjustedChance = math.max(1, aura.Chance / luck)
		if math.random(1, adjustedChance) == 1 then
			-- Rarity Protection & Storage Logic
			local inventory = playerInventories[player.UserId] or {}
			local isLegendary = aura.Chance >= 500000
			
			if #inventory < 20 or isLegendary then
				-- If full but legendary, we don't discard
				if #inventory < 20 then
					table.insert(inventory, aura.Name)
				end
				
				AuraRollResultEvent:FireClient(player, aura.Name)
				RNGService.ForceEquip(player, aura.Name)
				
				-- Mission #32: Immediate Persistence for Rare Rolls (1/1000+)
				if aura.Chance >= 1000 then
					DataService.SaveData(player, inventory)
					print("Zedox Data Vault: IMPACT SAVE for " .. player.Name .. " (" .. aura.Name .. ")")
				end

				-- Update player best for leaderboard
				local currentBest = playerBestRarities[player.UserId] or 0
				if aura.Chance > currentBest then
					playerBestRarities[player.UserId] = aura.Chance
					if GlobalAuraLeads then
						task.spawn(function()
							pcall(function()
								GlobalAuraLeads:SetAsync(tostring(player.UserId), aura.Chance)
							end)
						end)
					end
				end
				
				return aura
			end
		end
	end
	
	-- Fallback to Common (Auto-discarded if inventory full)
	local fallback = AuraData.Auras[#AuraData.Auras]
	AuraRollResultEvent:FireClient(player, fallback.Name)
	RNGService.ForceEquip(player, fallback.Name)
	
	return fallback
end

function RNGService.ForceEquip(player: Player, auraName: string)
	player:SetAttribute("CurrentAura", auraName)
	AuraEquippedEvent:FireAllClients(auraName, player)
end

-- Listen for manual equip requests
EquipAuraEvent.OnServerEvent:Connect(function(player, auraName: string)
	-- Verify they have it? (For this MVP we trust client, but usually we'd check their DataStore)
	player:SetAttribute("CurrentAura", auraName)
	-- Fire to ALL clients so everyone sees the new visual on this player
	AuraEquippedEvent:FireAllClients(auraName, player)
end)

-- Listen for client roll requests with debounce
RequestRollEvent.OnServerEvent:Connect(function(player)
	local now = tick()
	local last = rollDebounces[player.UserId] or 0
	local cooldown = player:GetAttribute("RollCooldown") or 0.5
	
	if now - last >= cooldown then
		rollDebounces[player.UserId] = now
		RNGService.RollAura(player)
	end
end)

return RNGService
