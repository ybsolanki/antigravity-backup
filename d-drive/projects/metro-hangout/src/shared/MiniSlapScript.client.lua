local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local swingTrack = nil

Tool.Activated:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
	
	-- Play horizontal slap swing
	if animator then
		pcall(function()
			if not swingTrack then
				local swingAnim = Instance.new("Animation")
				swingAnim.AnimationId = "rbxassetid://674871189"
				swingTrack = animator:LoadAnimation(swingAnim)
				swingTrack.Priority = Enum.AnimationPriority.Action4
			end
			swingTrack:Play()
			swingTrack:AdjustSpeed(2.2)
		end)
	end
	
	-- High-pitched squeak/slap sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9114223153"
	sound.Volume = 1.0
	sound.PlaybackSpeed = 1.6 -- Squeaky Pitch
	sound.Parent = char:FindFirstChild("HumanoidRootPart") or char
	sound:Play()
	Debris:AddItem(sound, 2)
	
	-- Target detection
	local targetPart = mouse.Target
	local targetChar = targetPart and targetPart.Parent
	local targetPlayer = nil
	
	while targetChar and targetChar ~= workspace do
		local foundPlayer = Players:GetPlayerFromCharacter(targetChar)
		if foundPlayer then
			targetPlayer = foundPlayer
			break
		end
		targetChar = targetChar.Parent
	end
	
	if targetPlayer and targetPlayer ~= player then
		local clawEvent = ReplicatedStorage:WaitForChild("ClawMachinePrizeEvent", 5)
		if clawEvent then
			clawEvent:FireServer("MiniSlap", targetPlayer.Name)
		end
	end
end)

Tool.Unequipped:Connect(function()
	if swingTrack then
		pcall(function() swingTrack:Stop() end)
	end
end)
