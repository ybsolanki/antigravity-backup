local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local NPCService = {}

function NPCService.ShowDialogue(npc, text)
	local head = npc:FindFirstChild("Head")
	if not head then return end
	
	local old = head:FindFirstChild("DialogueGui")
	if old then old:Destroy() end
	
	local bgui = Instance.new("BillboardGui", head)
	bgui.Name = "DialogueGui"
	bgui.Size = UDim2.new(0, 200, 0, 60)
	bgui.StudsOffset = Vector3.new(0, 4, 0)
	
	local label = Instance.new("TextLabel", bgui)
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.Antique
	label.Parent = bgui
	
	task.delay(5, function()
		if bgui.Parent then bgui:Destroy() end
	end)
end

function NPCService.BuildR6(name, position, bodyColor)
	local npc = Instance.new("Model", Workspace:WaitForChild("Map"))
	npc.Name = name
	
	local function createPart(pName, size, offset)
		local p = Instance.new("Part", npc)
		p.Name = pName
		p.Size = size
		p.Position = position + offset
		p.Color = bodyColor or Color3.fromRGB(240, 200, 180)
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = false
		return p
	end

	local hrp = createPart("HumanoidRootPart", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0))
	hrp.Transparency = 1
	npc.PrimaryPart = hrp
	
	local torso = createPart("Torso", Vector3.new(2, 2, 1), Vector3.new(0, 3, 0))
	local head = createPart("Head", Vector3.new(1.2, 1.2, 1.2), Vector3.new(0, 4.5, 0))
	local ra = createPart("Right Arm", Vector3.new(1, 2, 1), Vector3.new(1.5, 3, 0))
	local la = createPart("Left Arm", Vector3.new(1, 2, 1), Vector3.new(-1.5, 3, 0))
	local rl = createPart("Right Leg", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0))
	local ll = createPart("Left Leg", Vector3.new(1, 2, 1), Vector3.new(-0.5, 1, 0))

	local human = Instance.new("Humanoid", npc)
	human.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	local function createJoint(p0, p1, c0, c1)
		local j = Instance.new("Motor6D", p0)
		j.Part0 = p0
		j.Part1 = p1
		j.C0 = c0 or CFrame.new()
		j.C1 = c1 or CFrame.new()
	end
	
	createJoint(hrp, torso)
	createJoint(torso, head, CFrame.new(0, 1, 0), CFrame.new(0, -0.5, 0))
	createJoint(torso, ra, CFrame.new(1.5, 0.5, 0), CFrame.new(0, 0.5, 0))
	createJoint(torso, la, CFrame.new(-1.5, 0.5, 0), CFrame.new(0, 0.5, 0))
	createJoint(torso, rl, CFrame.new(0.5, -1, 0), CFrame.new(0, 1, 0))
	createJoint(torso, ll, CFrame.new(-0.5, -1, 0), CFrame.new(0, 1, 0))

	-- Simple Face
	Instance.new("Decal", head).Texture = "rbxasset://textures/face.png"
	
	-- Prompt
	local prompt = Instance.new("ProximityPrompt", torso)
	prompt.ActionText = "Talk"
	prompt.ObjectText = name
	
	return npc
end

function NPCService.Initialize()
	-- Ena
	local ena = NPCService.BuildR6("Ena", Vector3.new(20, 2, 10), Color3.fromRGB(180, 160, 220))
	local enaPrompt = ena.Torso:FindFirstChildOfClass("ProximityPrompt")
	
	local enaDialogues = {
		"The sword is heavy, but silence is heavier.",
		"The Watcher only attacks if you show your steel.",
		"Demonstrate your resolve, and he will let you pass."
	}
	
	enaPrompt.Triggered:Connect(function(player)
		NPCService.ShowDialogue(ena, enaDialogues[math.random(1, #enaDialogues)])
	end)

	-- Elder Taku
	local taku = NPCService.BuildR6("Elder Taku", Vector3.new(0, 2, 15), Color3.fromRGB(140, 140, 110))
	local takuPrompt = taku.Torso:FindFirstChildOfClass("ProximityPrompt")
	
	takuPrompt.Triggered:Connect(function(player)
		NPCService.ShowDialogue(taku, "Bearer... your path begins beyond the gate.")
	end)
end

NPCService.Initialize()

return NPCService
