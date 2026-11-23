--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShopConfig = require(Shared:WaitForChild("ShopConfig"))

-- Mission #24 (Final Overhaul): The Zedox Auto-Unlock
-- Direct ID Binding
local AUTO_ROLL_ID = 1737012927
local BUNDLE_ID = 1735359161

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
-- Mission #24 Fix: 30-second safe wait for UI to avoid Infinite Yield
local ScreenGui = PlayerGui:WaitForChild("AuraRNGGui", 30) 

local RequestRollEvent = Shared:WaitForChild("Remotes"):WaitForChild("RequestRoll")

local AutoRollController = {}

-- Mission #24 (Final Overhaul): The Force-Unlock Logic
local function ZedoxAutoUnlock()
	if not ScreenGui then return end
	
	local MainCanvas = ScreenGui:FindFirstChild("MainCanvas")
	local RollGroup = MainCanvas and MainCanvas:FindFirstChild("RollGroup")
	local ButtonFrame = RollGroup and RollGroup:FindFirstChild("ButtonFrame")
	local AutoButton = ButtonFrame and ButtonFrame:FindFirstChild("AutoRollBtn")
	
	if not AutoButton then return end
	
	-- 1. Owner Bypass: Creators always get it unlocked
	local isCreator = (player.UserId == game.CreatorId) or (player.Name == "solankiyb43")
	
	-- 2. Retry Loop for Ownership
	local owned = false
	for i = 1, 5 do
		local success, result = pcall(function()
			return MarketplaceService:UserHasGamePassAsync(player.UserId, AUTO_ROLL_ID)
				or MarketplaceService:UserHasGamePassAsync(player.UserId, BUNDLE_ID)
		end)
		if success and result == true then
			owned = true
			break
		end
		task.wait(1)
	end
	
	-- 3. The Lock Killer Logic
	if owned or isCreator then
		-- Destroy the lock so it can never come back
		local lock = AutoButton:FindFirstChild("LockIcon")
		if lock then lock:Destroy() end
		
		AutoButton.Active = true
		AutoButton.Interactable = true
		
		-- Force sync attribute
		player:SetAttribute("HasAutoRoll", true)
		print("Mission #24: Zedox Auto-Unlock Successful.")
	else
		-- Only lock if check fails
		local lock = AutoButton:FindFirstChild("LockIcon")
		if lock then 
			lock.Visible = true 
		else
			-- If lock doesn't exist, create it and set properties
			local newLock = Instance.new("ImageLabel")
			newLock.Name = "LockIcon"
			newLock.BackgroundTransparency = 1
			newLock.Size = UDim2.new(0.5, 0, 0.5, 0)
			newLock.Position = UDim2.new(0.5, 0, 0.5, 0)
			newLock.AnchorPoint = Vector2.new(0.5, 0.5)
			newLock.Image = "rbxassetid://6031094678" -- Lock Icon
			newLock.ImageColor3 = Color3.fromRGB(200, 200, 200)
			newLock.Visible = true -- Mission #24: Start Unlocked (this will be set to true if ownership fails)
			newLock.Parent = AutoButton
		end
		AutoButton.Text = "AUTO ROLL"
		print("Mission #24: Ownership check failed, button locked.")
	end
end

function AutoRollController.Init()
	-- Instant Trigger Logic
	task.spawn(ZedoxAutoUnlock)
	player.CharacterAppearanceLoaded:Connect(ZedoxAutoUnlock)
	
	task.spawn(function()
		while true do
			task.wait(ShopConfig.AutoRollInterval)
			
			if ScreenGui and ScreenGui:GetAttribute("AutoRolling") == true then
				-- Mission #24: Trigger same logic as big ROLL button
				RequestRollEvent:FireServer()
			end
		end
	end)
end

-- Auto-initialize on load
task.spawn(AutoRollController.Init)

return AutoRollController
