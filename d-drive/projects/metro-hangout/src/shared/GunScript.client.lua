local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminEvent = ReplicatedStorage:WaitForChild("AdminEvent")

-- Shoot Animation Setup (Roblox Official Tool Recoil)
local shootAnim = Instance.new("Animation")
shootAnim.AnimationId = "rbxassetid://507768375"
local shootTrack = nil

Tool.Activated:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local animator = hum and (hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum))
	
	-- Play shoot recoil animation
	if animator then
		pcall(function()
			if not shootTrack then
				shootTrack = animator:LoadAnimation(shootAnim)
				-- Force highest action priority to override default Roblox tool holding arm states
				shootTrack.Priority = Enum.AnimationPriority.Action4
			end
			shootTrack:Play()
			print("[GunScript] Clicked! Playing shoot recoil track with Priority:", shootTrack.Priority)
		end)
	end
	
	-- Play local gunshot sound for instant client feedback
	local handle = Tool:FindFirstChild("Handle")
	local shotSound = Instance.new("Sound")
	shotSound.SoundId = "rbxassetid://130113322"
	shotSound.Volume = 1
	shotSound.Parent = handle or char:FindFirstChild("HumanoidRootPart") or char
	shotSound:Play()
	game:GetService("Debris"):AddItem(shotSound, 2)
	
	local targetPos = mouse.Hit.Position
	print("[GunScript] Activated! Target Position:", targetPos)
	adminEvent:FireServer("ShootGun", "", targetPos)
end)

Tool.Unequipped:Connect(function()
	if shootTrack then
		pcall(function()
			shootTrack:Stop()
		end)
	end
end)
