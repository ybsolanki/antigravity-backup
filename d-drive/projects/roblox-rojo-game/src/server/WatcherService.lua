local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local WatcherService = {}

function WatcherService.BuildGuardian(name, position)
	local model = Instance.new("Model", Workspace:WaitForChild("Map"))
	model.Name = name
	
	local function createPart(pName, size, offset, color, mat)
		local p = Instance.new("Part", model)
		p.Name = pName
		p.Size = size
		p.Position = position + offset
		p.Color = color or Color3.fromRGB(50, 50, 55)
		p.Material = mat or Enum.Material.Marble
		p.Anchored = false
		p.CanCollide = true
		return p
	end

	-- Giant R6 Scale (x2.5)
	local hrp = createPart("HumanoidRootPart", Vector3.new(5, 5, 2.5), Vector3.new(0, 7.5, 0))
	hrp.Transparency = 1
	model.PrimaryPart = hrp
	
	local torso = createPart("Torso", Vector3.new(5, 5, 2.5), Vector3.new(0, 7.5, 0))
	local head = createPart("Head", Vector3.new(3, 3, 3), Vector3.new(0, 11.5, 0))
	head.Color = Color3.fromRGB(100, 0, 0)
	head.Material = Enum.Material.Neon
	
	local ra = createPart("Right Arm", Vector3.new(2.5, 5, 2.5), Vector3.new(3.75, 7.5, 0))
	local la = createPart("Left Arm", Vector3.new(2.5, 5, 2.5), Vector3.new(-3.75, 7.5, 0))
	local rl = createPart("Right Leg", Vector3.new(2.5, 5, 2.5), Vector3.new(1.25, 2.5, 0))
	local ll = createPart("Left Leg", Vector3.new(2.5, 5, 2.5), Vector3.new(-1.25, 2.5, 0))

	local human = Instance.new("Humanoid", model)
	human.MaxHealth = 2000
	human.Health = 2000
	
	-- Joints
	local function createJoint(name, p0, p1, c0, c1)
		local j = Instance.new("Motor6D", p0)
		j.Name = name
		j.Part0 = p0
		j.Part1 = p1
		j.C0 = c0 or CFrame.new()
		j.C1 = c1 or CFrame.new()
	end
	
	createJoint("Root", hrp, torso)
	createJoint("Neck", torso, head, CFrame.new(0, 2.5, 0), CFrame.new(0, -1.5, 0))
	createJoint("RS", torso, ra, CFrame.new(3.75, 1.25, 0), CFrame.new(0, 2.5, 0))
	createJoint("LS", torso, la, CFrame.new(-3.75, 1.25, 0), CFrame.new(0, 2.5, 0))
	createJoint("RH", torso, rl, CFrame.new(1.25, -2.5, 0), CFrame.new(0, 2.5, 0))
	createJoint("LH", torso, ll, CFrame.new(-1.25, -2.5, 0), CFrame.new(0, 2.5, 0))

	-- Anchor everything but the HRP to start
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("Part") and p ~= hrp then p.Anchored = true end
	end
	hrp.Anchored = true
	
	return model
end

function WatcherService.Initialize()
	local watcher = WatcherService.BuildGuardian("The Watcher", Vector3.new(0, 0, -120))
	local head = watcher:FindFirstChild("Head")
	
	local aggressionTimer = 0
	
	task.spawn(function()
		while true do
			task.wait(1)
			local aggroTarget = nil
			
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				if char and char:FindFirstChild("Humanoid") then
					local dist = (watcher.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude
					local tool = char:FindFirstChildOfClass("Tool")
					
					if dist < 50 and tool then
						aggroTarget = player
						aggressionTimer = aggressionTimer + 1
						
						if aggressionTimer >= 5 then
							head.Color = Color3.fromRGB(255, 0, 0)
							head.Size = Vector3.new(5, 5, 5)
							if dist < 20 then
								char.Humanoid:TakeDamage(10)
								print("THE WATCHER: 'Leave this place.'")
							end
						else
							print("THE WATCHER: 'Beware.'")
							head.Color = Color3.fromRGB(150, 50, 0)
						end
					end
				end
			end
			
			if not aggroTarget then
				aggressionTimer = 0
				head.Color = Color3.fromRGB(100, 0, 0)
				head.Size = Vector3.new(3, 3, 3)
			end
		end
	end)
end

WatcherService.Initialize()

return WatcherService
