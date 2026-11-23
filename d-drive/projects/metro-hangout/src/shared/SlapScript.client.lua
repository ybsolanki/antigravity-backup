local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminEvent = ReplicatedStorage:WaitForChild("AdminEvent")

local swingTrack = nil

Tool.Activated:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
	
	-- Play slap swing animation using horizontal Crazy Slash
	if animator then
		pcall(function()
			if not swingTrack then
				local swingAnim = Instance.new("Animation")
				swingAnim.AnimationId = "rbxassetid://674871189"
				swingTrack = animator:LoadAnimation(swingAnim)
				swingTrack.Priority = Enum.AnimationPriority.Action4
			end
			swingTrack:Play()
			swingTrack:AdjustSpeed(2.0) -- Fast horizontal slap swing speed
		end)
	end
	
	-- Play slap sound immediately on swing (replicates to all players)
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://126491315346055"
	sound.Volume = 2.0
	sound.Parent = char:FindFirstChild("HumanoidRootPart") or char
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 3.5)
	
	-- Foolproof target detection walking up the parent tree (handles hats, accessories, limbs)
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
		print("[SlapScript] Activating slap on:", targetPlayer.Name)
		adminEvent:FireServer("Slap", targetPlayer.Name)
	end
end)

Tool.Unequipped:Connect(function()
	if swingTrack then
		pcall(function()
			swingTrack:Stop()
		end)
	end
end)
