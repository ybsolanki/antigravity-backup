--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:WaitForChild("AuraRNGGui")
local RollGroup = ScreenGui:WaitForChild("MainCanvas"):WaitForChild("RollGroup")
local LuckLabel = RollGroup:WaitForChild("LuckLabel")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ShopConfig = require(Shared:WaitForChild("ShopConfig"))
local SoundManager = require(script.Parent:WaitForChild("SoundManager"))

local LuckController = {}

-- Mission #27: Pulse Animation
local function StartPulse()
	local info = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(LuckLabel, info, {
		TextTransparency = 0.3,
		Size = UDim2.new(1.1, 0, 0.28, 0)
	})
	tween:Play()
end

local function CheckOwnership()
	-- Mission #28: Data Retry
	task.wait(3) 

	local hasLuck = false
	local success, result = pcall(function()
		return MarketplaceService:UserHasGamePassAsync(player.UserId, ShopConfig.LuckPassID)
			or MarketplaceService:UserHasGamePassAsync(player.UserId, ShopConfig.BundlePassID)
	end)
	
	if success and result then
		hasLuck = true
	end

	-- Mission #28: Creator Bypass
	if player.UserId == game.CreatorId or player.UserId == 1 then -- Standard dev/studio bypass
		hasLuck = true
	end
	
	-- Mission #27: Dynamic Update
	if hasLuck and not LuckLabel.Visible then
		LuckLabel.Visible = true
		SoundManager:PlaySound("Success", 1) -- Mission #27: Success sound
		StartPulse()
		print("Zedox Luck HUD: Active") -- Mission #28: Log Confirmation
	elseif not hasLuck then
		LuckLabel.Visible = false
	end
end

function LuckController.Init()
	-- initial check
	task.spawn(CheckOwnership)
	
	-- Mission #27: Dynamics - Check on attribute change or timer fallback
	player:GetAttributeChangedSignal("LuckMultiplier"):Connect(CheckOwnership)
	
	-- Fallback for purchase detection if attribute sync is slow
	task.spawn(function()
		while true do
			if not LuckLabel.Visible then
				CheckOwnership()
			end
			task.wait(5)
		end
	end)
end

LuckController.Init()

return LuckController
