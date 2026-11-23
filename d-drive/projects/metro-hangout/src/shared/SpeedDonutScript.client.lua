local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Debris = game:GetService("Debris")

Tool.Activated:Connect(function()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.Health > 0 then
		-- Play munch sound
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://6206016147"
		sound.Volume = 1.5
		sound.Parent = char:FindFirstChild("HumanoidRootPart") or char
		sound:Play()
		Debris:AddItem(sound, 2)
		
		-- Apply speed boost
		local originalSpeed = hum.WalkSpeed
		hum.WalkSpeed = 55
		
		-- Munch particles
		local p = Instance.new("ParticleEmitter")
		p.Color = ColorSequence.new(Color3.fromRGB(240, 150, 180))
		p.Size = NumberSequence.new(0.12)
		p.Lifetime = NumberRange.new(0.4, 0.6)
		p.Speed = NumberRange.new(2, 4)
		p.Rate = 60
		p.Parent = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
		task.delay(0.4, function() 
			p.Enabled = false 
			Debris:AddItem(p, 1) 
		end)
		
		-- Destroy the tool
		Tool:Destroy()
		
		-- Reset speed after 30 seconds
		task.delay(30, function()
			if hum and hum.Parent then
				if hum.WalkSpeed == 55 then
					hum.WalkSpeed = originalSpeed
				end
			end
		end)
	end
end)
