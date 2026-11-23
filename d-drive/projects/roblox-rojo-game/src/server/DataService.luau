--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local DataService = {}

local DATABASE_NAME_V1 = "Zedox_Final_v1"
local DATA_STORE = DataStoreService:GetDataStore(DATABASE_NAME_V1)

local sessionTokens = {}
local cachedData = {} -- In-memory cache for active players

local function GetDefaultData()
	return {
		TotalRolls = 0,
		BestRarity = 0,
		InventoryJSON = "[]",
		CurrentAura = "Common",
		SessionID = 0,
		RedeemedCodes = {}, -- Mission #35
		Perks = { -- Mission #35
			LuckMultiplier = 1,
			RollCooldown = 0.5,
			HasAutoRoll = false
		}
	}
end

function DataService.GetPlayerData(player: Player)
	return cachedData[player.UserId]
end

function DataService.LoadData(player: Player)
	local userId = tostring(player.UserId)
	local sessionID = tick()
	sessionTokens[player.UserId] = sessionID
	
	local success, data = pcall(function()
		return DATA_STORE:UpdateAsync(userId, function(oldData)
			local newData = oldData or GetDefaultData()
			newData.SessionID = sessionID
			return newData
		end)
	end)
	
	if success and data then
		player:SetAttribute("RollCooldown", perks.RollCooldown or 0.5)
		player:SetAttribute("HasAutoRoll", perks.HasAutoRoll or false)
		
		-- Mission #36/38: Centralized JSON Decode
		local inventoryTable = {}
		if data.InventoryJSON and data.InventoryJSON ~= "" then
			local success, decoded = pcall(function()
				return HttpService:JSONDecode(data.InventoryJSON)
			end)
			if success and typeof(decoded) == "table" then
				inventoryTable = decoded
			end
		end
		data.InventoryItems = inventoryTable
		
		cachedData[player.UserId] = data
		-- CollectionData (Inventory) is handled by RNGService via playerInventories table
		print("Zedox Data Vault: Loaded " .. player.Name)
		return data
	else
		warn("Zedox Data Vault: FAILED to load " .. player.Name)
		return GetDefaultData()
	end
end

function DataService.SaveData(player: Player, inventory: table?)
	local userId = tostring(player.UserId)
	local sessionID = sessionTokens[player.UserId]
	if not sessionID then return 	end
	
	local data = cachedData[player.UserId]
	if not data then return end
	
	local rolls = player:GetAttribute("TotalRolls") or 0
	local best = player:GetAttribute("BestRarity") or 0
	local currentAura = player:GetAttribute("CurrentAura") or "Common"
	
	-- Mission #35/38: Sync Perks & Inventory from Attributes/Cache
	data.Perks = {
		LuckMultiplier = player:GetAttribute("LuckMultiplier") or 1,
		RollCooldown = player:GetAttribute("RollCooldown") or 0.5,
		HasAutoRoll = player:GetAttribute("HasAutoRoll") or false
	}
	
	local finalInventory = inventory or data.InventoryItems or {}
	local inventoryJSON = "[]"
	pcall(function()
		inventoryJSON = HttpService:JSONEncode(finalInventory)
	end)
	
	local success, err = pcall(function()
		DATA_STORE:UpdateAsync(userId, function(oldData)
			if not oldData then oldData = GetDefaultData() end
			
			-- Session Lock Check (Mission #32)
			if oldData.SessionID and oldData.SessionID ~= sessionID then
				warn("Zedox Session Lock: Overwrite prevented for " .. player.Name)
				return nil -- Don't save if session ID mismatch
			end
			
			oldData.TotalRolls = rolls
			oldData.BestRarity = best
			oldData.InventoryJSON = inventoryJSON
			oldData.CurrentAura = currentAura
			oldData.SessionID = sessionID
			oldData.RedeemedCodes = data.RedeemedCodes -- Mission #35
			oldData.Perks = data.Perks -- Mission #35
			return oldData
		end)
	end)
	
	if success then
		print("Zedox Data Vault: Saved " .. player.Name)
	else
		warn("Zedox Data Vault: Save error for " .. player.Name .. ": " .. tostring(err))
	end
end

-- 30-Second Heartbeat (Mission #32)
task.spawn(function()
	while true do
		task.wait(30)
		local count = 0
		for _, player in ipairs(Players:GetPlayers()) do
			DataService.SaveData(player)
			count += 1
		end
		if count > 0 then
			print("Data Heartbeat: Saved " .. count .. " players")
		end
	end
end)

-- BindToClose Guard (Mission #32)
game:BindToClose(function()
	print("Zedox Data Vault: Server shutting down. Saving all data...")
	for _, player in ipairs(Players:GetPlayers()) do
		DataService.SaveData(player)
	end
	task.wait(2) -- Give time for async requests
end)

Players.PlayerRemoving:Connect(function(player)
	-- Mission #36: The "Data-Ready" Check
	-- Only save if the data was actually loaded to prevent overwriting with defaults
	if player:GetAttribute("DataLoaded") == true then
		DataService.SaveData(player)
	else
		warn("Zedox Data Vault: SAVE BLOCKED for " .. player.Name .. " (Data not loaded)")
	end
	sessionTokens[player.UserId] = nil
	cachedData[player.UserId] = nil
end)

return DataService
