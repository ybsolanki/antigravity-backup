--!strict
local Workspace = game:GetService("Workspace")

local function CreateAmbientDust()
	local folder = Workspace:FindFirstChild("AuraLobby")
	if not folder then return end
	
	local dustPart = Instance.new("Part")
	dustPart.Name = "AmbientDustPart"
	dustPart.Size = Vector3.new(60, 20, 60)
	dustPart.Position = Vector3.new(0, 10, 0)
	dustPart.Anchored = true
	dustPart.CanCollide = false
	dustPart.Transparency = 1
	dustPart.Parent = folder
	
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Dust"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(240, 240, 255))
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1, 0)
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.7),
		NumberSequenceKeypoint.new(1, 1)
	})
	emitter.Lifetime = NumberRange.new(5, 10)
	emitter.Rate = 25
	emitter.Speed = NumberRange.new(0.5, 1.5)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(0, -0.1, 0)
	emitter.Drag = 0.5
	emitter.LightEmission = 1
	emitter.LightInfluence = 0
	emitter.Parent = dustPart
end

task.spawn(function()
	-- Wait for lobby to exist
	while not Workspace:FindFirstChild("AuraLobby") do
		task.wait(1)
	end
	CreateAmbientDust()
end)
