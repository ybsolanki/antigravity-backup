local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local lastBlow = 0
local COOLDOWN = 0.8

Tool.Activated:Connect(function()
	local now = os.clock()
	if now - lastBlow < COOLDOWN then return end
	lastBlow = now
	
	local char = player.Character
	local handle = Tool:FindFirstChild("Handle")
	local tipPos = handle and (handle.CFrame * CFrame.new(0, 0.6, 0)).Position or (char and char:FindFirstChild("Head") and char.Head.Position)
	
	if tipPos then
		-- Fire Server event to spawn bubbles globally
		local clawEvent = ReplicatedStorage:WaitForChild("ClawMachinePrizeEvent", 5)
		if clawEvent then
			clawEvent:FireServer("SpawnBubble", tipPos)
		end
		
		-- Play blowing sound
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://9114387848"
		sound.Volume = 0.8
		sound.Parent = handle or char:FindFirstChild("HumanoidRootPart") or char
		sound:Play()
		Debris:AddItem(sound, 2)
	end
end)
