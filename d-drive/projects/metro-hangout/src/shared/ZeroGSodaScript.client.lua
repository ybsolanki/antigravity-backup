local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Debris = game:GetService("Debris")

Tool.Activated:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		-- Play drinking sound
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://2813134958"
		sound.Volume = 1.8
		sound.Parent = char:FindFirstChild("HumanoidRootPart") or char
		sound:Play()
		Debris:AddItem(sound, 2)
		
		-- Lower gravity locally for this client
		local originalGravity = workspace.Gravity
		workspace.Gravity = 40
		
		-- Float particles
		local p = Instance.new("ParticleEmitter")
		p.Color = ColorSequence.new(Color3.fromRGB(30, 200, 220))
		p.Size = NumberSequence.new(0.2)
		p.Lifetime = NumberRange.new(1.0, 1.8)
		p.Speed = NumberRange.new(2, 5)
		p.Rate = 25
		p.Parent = char:FindFirstChild("HumanoidRootPart")
		
		-- Destroy the tool
		Tool:Destroy()
		
		-- Reset gravity after 30 seconds
		task.delay(30, function()
			workspace.Gravity = originalGravity
			p.Enabled = false
			Debris:AddItem(p, 2)
		end)
	end
end)
