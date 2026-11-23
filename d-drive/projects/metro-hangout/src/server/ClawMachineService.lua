-- ClawMachineService.lua
-- Server-side Service managing Claw Machine prizes, RNG rates, dynamic item spawning, and chat tags.
-- Includes weighted RNG (Common, Rare, Legendary), custom programmatic accessories (Bear Hat, Golden Halo),
-- bubble spawning for the Bubble Blower, and squeaky mini-slaps.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

local function getNearestPlayer(position, maxDistance)
	local nearestPlayer = nil
	local shortestDistance = maxDistance or 15
	
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local dist = (hrp.Position - position).Magnitude
			if dist < shortestDistance then
				shortestDistance = dist
				nearestPlayer = player
			end
		end
	end
	
	return nearestPlayer
end

local function isNestedMachine(model)
	local parent = model.Parent
	while parent and parent ~= workspace do
		if parent:IsA("Model") and (parent.Name == "Maxi Claw Machine" or parent.Name == "Claw Machine" or parent.Name == "ClawMachine") then
			return true
		end
		parent = parent.Parent
	end
	return false
end

local ClawMachineService = {}

-- Weighted RNG Prize Categories:
-- Common (70%): Speed Donut, Zero-G Soda, Glowstick
-- Rare (25%): Bubble Blower, Bear Hat, Chat Tag (Claw Champ)
-- Legendary (5%): Mini Slap Glove, Golden Halo, Chat Tag (Claw Legend)

local PRIZE_POOL = {
	Common = {
		{ Name = "Speed Donut", Type = "Tool" },
		{ Name = "Zero-G Soda", Type = "Tool" },
		{ Name = "Glowstick", Type = "Tool" }
	},
	Rare = {
		{ Name = "Bubble Blower", Type = "Tool" },
		{ Name = "Bear Hat", Type = "Accessory" },
		{ Name = "Claw Champ Tag", Type = "Tag" }
	},
	Legendary = {
		{ Name = "Mini Slap Glove", Type = "Tool" },
		{ Name = "Golden Halo", Type = "Accessory" },
		{ Name = "Claw Legend Tag", Type = "Tag" }
	}
}

local carryingMachines = {}

-- Helper to weld hat models onto character heads
local function weldHat(character, modelName)
	-- Clean up old hat
	local old = character:FindFirstChild(modelName)
	if old then old:Destroy() end
	
	local head = character:FindFirstChild("Head")
	if not head then return end
	
	local hat = Instance.new("Part")
	hat.Name = modelName
	hat.CanCollide = false
	hat.Massless = true
	
	if modelName == "Golden Halo" then
		hat.Size = Vector3.new(0.8, 0.1, 0.8)
		hat.Color = Color3.fromRGB(255, 215, 0)
		hat.Material = Enum.Material.Neon
		hat.CFrame = head.CFrame * CFrame.new(0, 0.85, 0)
		hat.Parent = character
		
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.FileMesh
		mesh.MeshId = "rbxassetid://3270017" -- Ring mesh
		mesh.Scale = Vector3.new(1.2, 1.2, 1.2)
		mesh.Parent = hat
		
		-- Add a gentle golden light
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 215, 0)
		light.Brightness = 2
		light.Range = 8
		light.Parent = hat
	elseif modelName == "Bear Hat" then
		hat.Size = Vector3.new(0.9, 0.4, 0.9)
		hat.Color = Color3.fromRGB(120, 80, 50)
		hat.Material = Enum.Material.SmoothPlastic
		hat.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
		hat.Parent = character
		
		-- Ear left
		local earL = Instance.new("Part")
		earL.Size = Vector3.new(0.3, 0.3, 0.3)
		earL.Color = Color3.fromRGB(120, 80, 50)
		earL.Shape = Enum.PartType.Ball
		earL.CanCollide = false
		earL.Massless = true
		earL.CFrame = hat.CFrame * CFrame.new(-0.35, 0.25, 0)
		earL.Parent = hat
		local weldL = Instance.new("WeldConstraint")
		weldL.Part0 = hat
		weldL.Part1 = earL
		weldL.Parent = hat
		
		-- Ear right
		local earR = Instance.new("Part")
		earR.Size = Vector3.new(0.3, 0.3, 0.3)
		earR.Color = Color3.fromRGB(120, 80, 50)
		earR.Shape = Enum.PartType.Ball
		earR.CanCollide = false
		earR.Massless = true
		earR.CFrame = hat.CFrame * CFrame.new(0.35, 0.25, 0)
		earR.Parent = hat
		local weldR = Instance.new("WeldConstraint")
		weldR.Part0 = hat
		weldR.Part1 = earR
		weldR.Parent = hat
	end
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = head
	weld.Part1 = hat
	weld.Parent = head
end

-- Programmatically construct prize tools
local function createPrizeTool(name)
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.RequiresHandle = true
	
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	
	local scriptName = nil
	
	if name == "Speed Donut" then
		handle.Size = Vector3.new(0.5, 0.2, 0.5)
		handle.Color = Color3.fromRGB(240, 150, 180) -- pink icing
		handle.Material = Enum.Material.SmoothPlastic
		tool.ToolTip = "Eat this donut for a huge WalkSpeed boost!"
		
		-- Donut mesh shape using standard Cylinder
		local cylinder = Instance.new("SpecialMesh")
		cylinder.MeshType = Enum.MeshType.Cylinder
		cylinder.Scale = Vector3.new(1, 1, 1)
		cylinder.Parent = handle
		
		scriptName = "SpeedDonutScript"
		
	elseif name == "Zero-G Soda" then
		handle.Size = Vector3.new(0.3, 0.6, 0.3)
		handle.Color = Color3.fromRGB(30, 200, 220) -- cyan can
		handle.Material = Enum.Material.SmoothPlastic
		tool.ToolTip = "Drink this soda to lower your gravity locally!"
		
		local cylinder = Instance.new("SpecialMesh")
		cylinder.MeshType = Enum.MeshType.Cylinder
		cylinder.Scale = Vector3.new(1, 1, 1)
		cylinder.Parent = handle
		
		scriptName = "ZeroGSodaScript"
		
	elseif name == "Glowstick" then
		handle.Size = Vector3.new(0.15, 1.2, 0.15)
		-- Randomized neon color on spawn
		local colors = {
			Color3.fromRGB(0, 255, 0), -- Lime Green
			Color3.fromRGB(255, 0, 255), -- Purple
			Color3.fromRGB(0, 255, 255) -- Neon Cyan
		}
		handle.Color = colors[math.random(#colors)]
		handle.Material = Enum.Material.Neon
		tool.ToolTip = "Equip to emit a glow and leaving beautiful trails!"
		
		scriptName = "GlowstickScript"
		
	elseif name == "Bubble Blower" then
		handle.Size = Vector3.new(0.15, 1.0, 0.15)
		handle.Color = Color3.fromRGB(210, 100, 45)
		handle.Material = Enum.Material.SmoothPlastic
		tool.ToolTip = "Click to blow floating transparent bubbles in the air!"
		
		-- Ring head
		local ring = Instance.new("Part")
		ring.Name = "Ring"
		ring.Size = Vector3.new(0.4, 0.4, 0.15)
		ring.Color = Color3.fromRGB(240, 210, 40)
		ring.Material = Enum.Material.SmoothPlastic
		ring.CanCollide = false
		ring.Massless = true
		ring.CFrame = handle.CFrame * CFrame.new(0, 0.6, 0)
		ring.Parent = tool
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = ring
		weld.Parent = handle
		
		scriptName = "BubbleBlowerScript"
		
	elseif name == "Mini Slap Glove" then
		handle.Size = Vector3.new(0.1, 0.7, 0.1)
		handle.Color = Color3.fromRGB(30, 30, 30)
		handle.Material = Enum.Material.SmoothPlastic
		tool.ToolTip = "Prank tool: slaps players with low fling force!"
		
		-- Mini glove shape
		local palm = Instance.new("Part")
		palm.Name = "Palm"
		palm.Size = Vector3.new(0.12, 0.45, 0.45)
		palm.Color = Color3.fromRGB(245, 245, 245)
		palm.Material = Enum.Material.SmoothPlastic
		palm.CanCollide = false
		palm.Massless = true
		palm.CFrame = handle.CFrame * CFrame.new(0, 0.45, 0)
		palm.Parent = tool
		
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = handle
		weld.Part1 = palm
		weld.Parent = handle
		
		scriptName = "MiniSlapScript"
	end
	
	-- Attach the matching client script from Shared folder
	if scriptName then
		local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
		local template = sharedFolder:WaitForChild(scriptName)
		local scriptClone = template:Clone()
		scriptClone.Name = scriptName
		scriptClone.Parent = tool
	end
	
	return tool
end

-- Server-side celebratory effects around player character on winning
local function playWinningEffects(player, rarity)
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	-- Play tada/victory sound globally
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://12222008" -- tada victory fanfare
	sound.Volume = 1.2
	sound.Parent = hrp
	sound:Play()
	Debris:AddItem(sound, 4)
	
	-- Confetti blast particles
	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp
	Debris:AddItem(attachment, 3.5)
	
	local colors = {
		Color3.fromRGB(255, 50, 50),
		Color3.fromRGB(50, 255, 50),
		Color3.fromRGB(50, 50, 255),
		Color3.fromRGB(255, 240, 50),
		Color3.fromRGB(255, 50, 255)
	}
	
	for _, col in ipairs(colors) do
		local p = Instance.new("ParticleEmitter")
		p.Color = ColorSequence.new(col)
		p.Size = NumberSequence.new({
			TypeSequenceKeypoint.new(0, 0.25),
			TypeSequenceKeypoint.new(1, 0.15)
		})
		p.Lifetime = NumberRange.new(1.2, 2.2)
		p.Speed = NumberRange.new(15, 30)
		p.SpreadAngle = Vector2.new(180, 180)
		p.Rate = 120
		p.VelocitySpread = 180
		p.Parent = attachment
		
		task.delay(0.25, function() p.Enabled = false end)
	end
end

-- Main function to Award a Prize (called directly by claw machine script)
function ClawMachineService:AwardPrize(player)
	if not player or not player:IsA("Player") then return end
	
	-- Roll RNG (1 - 100)
	local roll = math.random(100)
	local category = "Common"
	local rarityColor = "#00FF00" -- Green
	
	if roll <= 70 then
		category = "Common"
		rarityColor = "#FFFFFF" -- White
	elseif roll <= 95 then
		category = "Rare"
		rarityColor = "#00FFFF" -- Neon Cyan
	else
		category = "Legendary"
		rarityColor = "#FFAA00" -- Golden Orange
	end
	
	-- Select a random prize from the rolled category
	local pool = PRIZE_POOL[category]
	local prize = pool[math.random(#pool)]
	
	print("[Hangout cafe] " .. player.Name .. " won prize: " .. prize.Name .. " (" .. category .. ")")
	
	-- Deliver the prize based on its type
	if prize.Type == "Tool" then
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local tool = createPrizeTool(prize.Name)
			tool.Parent = backpack
		end
		
	elseif prize.Type == "Accessory" then
		if prize.Name == "Bear Hat" then
			player:SetAttribute("EquippedAccessory", "BearHat")
			if player.Character then
				weldHat(player.Character, "Bear Hat")
			end
		elseif prize.Name == "Golden Halo" then
			player:SetAttribute("EquippedAccessory", "GoldenHalo")
			if player.Character then
				weldHat(player.Character, "Golden Halo")
			end
		end
		
	elseif prize.Type == "Tag" then
		if prize.Name == "Claw Champ Tag" then
			player:SetAttribute("ChatTag", "Claw Champ")
			player:SetAttribute("TagColor", "#00FFAA")
		elseif prize.Name == "Claw Legend Tag" then
			player:SetAttribute("ChatTag", "Claw Legend")
			player:SetAttribute("TagColor", "#FFAA00")
		end
	end
	
	-- Play winning sound and confetti explosion
	playWinningEffects(player, category)
	
	-- Notify all players via server-wide chat message for Rare and Legendary wins
	local clawEvent = ReplicatedStorage:FindFirstChild("ClawMachinePrizeEvent")
	if clawEvent then
		local messageText = ""
		if category == "Legendary" then
			messageText = string.format("<font color='%s'>[🎉 LEGENDARY WIN] %s won a rare [%s] from the Claw Machine! 🎉</font>", rarityColor, player.Name, prize.Name)
		elseif category == "Rare" then
			messageText = string.format("<font color='%s'>[🎁 RARE WIN] %s won [%s] from the Claw Machine!</font>", rarityColor, player.Name, prize.Name)
		else
			messageText = string.format("[Claw Machine] %s won [%s].", player.Name, prize.Name)
		end
		clawEvent:FireAllClients("SystemMessage", messageText)
	end
end

function ClawMachineService:Initialize()
	print("[Hangout cafe] ClawMachineService: Initializing...")
	
	-- 1. Setup RemoteEvent
	local clawEvent = ReplicatedStorage:FindFirstChild("ClawMachinePrizeEvent")
	if not clawEvent then
		clawEvent = Instance.new("RemoteEvent")
		clawEvent.Name = "ClawMachinePrizeEvent"
		clawEvent.Parent = ReplicatedStorage
	end
	
	-- 2. Listen to client requests (Bubble Spawning, MiniSlapping)
	clawEvent.OnServerEvent:Connect(function(player, command, value)
		if command == "SpawnBubble" then
			-- Spawn physical transparent floating bubbles at the tipped position
			local tipPos = value
			if typeof(tipPos) == "Vector3" then
				for i = 1, 3 do
					task.spawn(function()
						task.wait(math.random() * 0.25)
						local bubble = Instance.new("Part")
						bubble.Name = "Bubble"
						bubble.Shape = Enum.PartType.Ball
						bubble.Size = Vector3.new(0.5, 0.5, 0.5)
						bubble.Color = Color3.fromRGB(220, 245, 255)
						bubble.Material = Enum.Material.Glass
						bubble.Transparency = 0.5
						pcall(function() bubble.Reflectance = 0.4 end)
						bubble.CanCollide = false
						bubble.Position = tipPos + Vector3.new(math.random(-1, 1), 0, math.random(-1, 1))
						bubble.Parent = workspace
						
						-- Soft float upwards force using BodyVelocity
						local bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(100, 100, 100)
						bv.Velocity = Vector3.new(math.random(-20, 20)/10, 1.8, math.random(-20, 20)/10)
						bv.Parent = bubble
						
						-- Size swell
						task.spawn(function()
							for sw = 1, 10 do
								task.wait(0.08)
								if bubble and bubble.Parent then
									local scale = 0.5 + (sw * 0.08)
									bubble.Size = Vector3.new(scale, scale, scale)
								end
							end
						end)
						
						-- Destroy and pop sound after randomized duration
						task.wait(math.random(30, 48)/10)
						if bubble and bubble.Parent then
							-- Pop sound
							local popSound = Instance.new("Sound")
							popSound.SoundId = "rbxassetid://9113642732" -- tiny bubble pop click
							popSound.Volume = 0.6
							popSound.Parent = workspace
							popSound.PlayOnRemove = true
							popSound:Destroy()
							
							bubble:Destroy()
						end
					end)
				end
			end
			
		elseif command == "MiniSlap" then
			local targetName = value
			local target = Players:FindFirstChild(targetName)
			if target and target.Character and player.Character then
				local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
				local adminHRP = player.Character:FindFirstChild("HumanoidRootPart")
				local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
				
				if targetHRP and adminHRP and targetHRP.Position and adminHRP.Position then
					local dist = (targetHRP.Position - adminHRP.Position).Magnitude
					if dist <= 9 then -- Melee range check
						local pushDir = (targetHRP.Position - adminHRP.Position).Unit
						if pushDir.Magnitude == 0 or pushDir ~= pushDir then
							pushDir = Vector3.new(0, 0, -1)
						end
						
						-- Mini slap: gentle slap velocity fling
						local bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(80000, 80000, 80000) -- Gentle force
						bv.Velocity = pushDir * 32 + Vector3.new(0, 18, 0)
						bv.Parent = targetHRP
						Debris:AddItem(bv, 0.25)
						
						if targetHum then
							targetHum.PlatformStand = true
							task.delay(0.6, function()
								if targetHum and targetHum.Parent then
									targetHum.PlatformStand = false
								end
							end)
						end
					end
				end
			end
		end
	end)
	
	-- 3. Automatically re-apply accessories on player character respawn
	local function setupPlayer(player)
		player.CharacterAdded:Connect(function(character)
			task.wait(0.8) -- wait for character rig assembly to build
			if not character or not character.Parent then return end
			
			local accessory = player:GetAttribute("EquippedAccessory")
			if accessory then
				pcall(weldHat, character, accessory == "BearHat" and "Bear Hat" or "Golden Halo")
			end
		end)
		if player.Character then
			local accessory = player:GetAttribute("EquippedAccessory")
			if accessory then
				pcall(weldHat, player.Character, accessory == "BearHat" and "Bear Hat" or "Golden Halo")
			end
		end
	end

	Players.PlayerAdded:Connect(setupPlayer)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupPlayer, player)
	end
	
	-- Programmatically generate exactly 50 non-overlapping positions in 4 nestled layers
	local CAPSULE_OFFSETS = {}
	
	-- Layer 0 (Y = 0): 4x4 grid (16)
	for _, x in ipairs({-3.3, -1.1, 1.1, 3.3}) do
		for _, z in ipairs({-3.3, -1.1, 1.1, 3.3}) do
			table.insert(CAPSULE_OFFSETS, Vector3.new(x, 0, z))
		end
	end
	
	-- Layer 1 (Y = 1.8): 3x3 grid (9)
	for _, x in ipairs({-2.2, 0, 2.2}) do
		for _, z in ipairs({-2.2, 0, 2.2}) do
			table.insert(CAPSULE_OFFSETS, Vector3.new(x, 1.8, z))
		end
	end
	
	-- Layer 2 (Y = 3.6): 4x4 grid (16)
	for _, x in ipairs({-3.3, -1.1, 1.1, 3.3}) do
		for _, z in ipairs({-3.3, -1.1, 1.1, 3.3}) do
			table.insert(CAPSULE_OFFSETS, Vector3.new(x, 3.6, z))
		end
	end
	
	-- Layer 3 (Y = 5.4): 3x3 grid (9)
	for _, x in ipairs({-2.2, 0, 2.2}) do
		for _, z in ipairs({-2.2, 0, 2.2}) do
			table.insert(CAPSULE_OFFSETS, Vector3.new(x, 5.4, z))
		end
	end

	local function spawnCapsulesForMachine(machine)
		-- Count current capsules
		local count = 0
		for _, child in ipairs(machine:GetDescendants()) do
			if child.Name == "Prize" and child:IsA("BasePart") then
				count = count + 1
			end
		end

		local needed = #CAPSULE_OFFSETS - count
		if needed <= 0 then return end

		-- Search for structural bottom parts to align spawn height and enforce collisions
		local floor = machine:FindFirstChild("Floor", true)
			or machine:FindFirstChild("Base", true)
			or machine:FindFirstChild("Bottom", true)
			or machine:FindFirstChild("Glass", true)

		local spawnCenter = nil
		local success, cframe, size = pcall(function() return machine:GetBoundingBox() end)
		
		if floor and floor:IsA("BasePart") then
			spawnCenter = floor.CFrame * CFrame.new(0.6, 1.2, -0.6)
			print("[Hangout cafe] Spawn center calculated using Floor part: " .. tostring(spawnCenter.Position))
		elseif success and cframe and size then
			-- Align to the bottom floor area locally
			spawnCenter = cframe * CFrame.new(0.6, -size.Y/4, -0.6)
			print("[Hangout cafe] Spawn center calculated using BoundingBox: " .. tostring(spawnCenter.Position))
		else
			spawnCenter = machine:GetPivot() * CFrame.new(0.6, 1.2, -0.6)
			print("[Hangout cafe] Spawn center calculated using Pivot: " .. tostring(spawnCenter.Position))
		end

		-- Ensure base parts are solid
		for _, child in ipairs(machine:GetDescendants()) do
			if child:IsA("BasePart") and (child.Name == "Floor" or child.Name == "Base" or child.Name == "Bottom") then
				child.CanCollide = true
			end
		end

		print(string.format("[Hangout cafe] Machine: %s, Current prizes: %d, Spawning missing: %d", machine:GetFullName(), count, needed))

		-- Find unoccupied offsets
		local availableOffsets = {}
		for _, offset in ipairs(CAPSULE_OFFSETS) do
			local worldPos = (spawnCenter * offset)
			local occupied = false
			for _, desc in ipairs(machine:GetDescendants()) do
				if desc.Name == "Prize" and desc:IsA("BasePart") then
					if (desc.Position - worldPos).Magnitude < 1.1 then
						occupied = true
						break
					end
				end
			end
			if not occupied then
				table.insert(availableOffsets, offset)
			end
		end

		-- Spawn static anchored capsules
		local spawned = 0
		print("[Hangout cafe] Spawning " .. #availableOffsets .. " capsules at offsets...")
		for _, offset in ipairs(availableOffsets) do
			if spawned >= needed then break end
			
			local prize = Instance.new("Part")
			prize.Name = "Prize"
			prize.Shape = Enum.PartType.Ball
			prize.Size = Vector3.new(2.0, 2.0, 2.0)
			
			local colors = {
				Color3.fromRGB(255, 160, 160), -- pink
				Color3.fromRGB(160, 255, 160), -- green
				Color3.fromRGB(160, 160, 255), -- blue
				Color3.fromRGB(255, 255, 160), -- yellow
				Color3.fromRGB(255, 160, 255)  -- purple
			}
			prize.Color = colors[math.random(#colors)]
			prize.Material = Enum.Material.SmoothPlastic
			prize.CanCollide = true
			prize.Anchored = true -- Always spawn anchored first for perfect startup stability!
			prize.CustomPhysicalProperties = PhysicalProperties.new(0.85, 0.9, 0.5) -- High friction (0.9) makes them much easier to grab!
			prize:SetAttribute("IsClawMachineCapsule", true)
			
			local targetPos = (spawnCenter * offset)
			prize.Position = targetPos
			prize.Parent = machine
			
			task.delay(1.5, function()
				if prize and prize.Parent then
					prize.Anchored = false -- Unanchor after startup so they are active physics bodies!
				end
			end)
			
			print(string.format("[Hangout cafe] Spawned capsule %d at %s", spawned + 1, tostring(targetPos)))
			spawned = spawned + 1
		end
	end

	local function setupClawTouchHookup(machine)
		-- Find the original physics Grabber model inside the machine
		local grabber = machine:FindFirstChild("Grabber", true) 
			or machine:FindFirstChild("Claw", true) 
			or machine
			
		for _, desc in ipairs(grabber:GetDescendants()) do
			if desc:IsA("BasePart") then
				if not desc:GetAttribute("TouchHooked") then
					desc:SetAttribute("TouchHooked", true)
					desc.Touched:Connect(function(hit)
						if hit.Name == "Prize" and hit:IsA("BasePart") then
							-- Ensure it is active/unanchored
							hit.Anchored = false
							
							-- Weld Assist to prevent dropping due to shaking/jitter
							local carrying = carryingMachines[machine]
							if not carrying and not hit:GetAttribute("IsWelded") then
								carryingMachines[machine] = hit
								hit:SetAttribute("IsWelded", true)
								
								-- Keep CanCollide = true so it never falls through floors,
								-- but make it weightless to not weigh down the claw.
								hit.Massless = true
								
								print("[Hangout cafe] Claw prong/part touched capsule: " .. desc.Name .. ". Securing with Weld Assist...")
								
								local weld = Instance.new("WeldConstraint")
								weld.Name = "ClawWeldAssist"
								weld.Part0 = desc
								weld.Part1 = hit
								weld.Parent = hit
								
								-- Create NoCollisionConstraints between capsule and all Grabber parts
								-- to prevent physics shaking/fighting while carried
								local constraints = {}
								for _, grabberPart in ipairs(grabber:GetDescendants()) do
									if grabberPart:IsA("BasePart") then
										local nc = Instance.new("NoCollisionConstraint")
										nc.Name = "ClawNoCollide"
										nc.Part0 = hit
										nc.Part1 = grabberPart
										nc.Parent = hit
										table.insert(constraints, nc)
									end
								end
								
								-- Monitor capsule position to release it when it reaches the chute
								task.spawn(function()
									local sensor = machine:FindFirstChild("PrizeSensor", true) 
										or machine:FindFirstChild("Sensor", true)
										or machine:FindFirstChild("Chute", true)
										or machine:FindFirstChild("chute", true)
										
									if sensor and sensor:IsA("BasePart") then
										local sensorPos = sensor.Position
										while hit and hit.Parent and weld and weld.Parent do
											local dx = hit.Position.X - sensorPos.X
											local dz = hit.Position.Z - sensorPos.Z
											local distHorizontal = math.sqrt(dx*dx + dz*dz)
											
											-- If we are vertically above or near the chute
											if distHorizontal < 1.5 then
												print("[Hangout cafe] Reached chute zone. Releasing capsule...")
												task.wait(0.4)
												if weld and weld.Parent then
													weld:Destroy()
												end
												break
											end
											task.wait(0.1)
										end
									else
										-- Fallback: release after 8 seconds
										task.wait(8)
										if weld and weld.Parent then
											weld:Destroy()
										end
									end
									
									-- Let the capsule fall clear of the prongs first before restoring prong collisions
									task.wait(0.4)
									
									for _, nc in ipairs(constraints) do
										if nc and nc.Parent then
											nc:Destroy()
										end
									end
									
									if hit and hit.Parent then
										hit.Massless = false
									end
									
									-- Reset tracking states
									task.wait(2)
									if hit and hit.Parent then
										hit:SetAttribute("IsWelded", nil)
									end
									if carryingMachines[machine] == hit then
										carryingMachines[machine] = nil
									end
								end)
							end
						end
					end)
				end
			end
		end
	end

	local function isCarriageSensor(part)
		local nameLower = part.Name:lower()
		if nameLower == "sensor" or nameLower == "sensortwo" then
			return true
		end
		-- Check if it contains movement scripts or claw models
		if part:FindFirstChild("Move") or part:FindFirstChild("Drop") or part:FindFirstChild("Retreat") or part:FindFirstChild("Grabber", true) or part:FindFirstChild("Claw", true) then
			return true
		end
		return false
	end

	local function setupSensorHookup(machine)
		local sensorNames = {"prizesensor", "sensor", "chute", "winsensor", "winner"}
		for _, child in ipairs(machine:GetDescendants()) do
			if child:IsA("BasePart") then
				local nameLower = child.Name:lower()
				if table.find(sensorNames, nameLower) then
					-- If this is actually the moving carriage/base of the claw, ignore it as a chute sensor!
					if isCarriageSensor(child) then
						-- Auto-heal movement scripts if they got disabled
						for _, sub in ipairs(child:GetChildren()) do
							if (sub:IsA("Script") or sub:IsA("LocalScript")) and (sub.Name == "Move" or sub.Name == "Drop" or sub.Name == "Retreat") then
								if sub.Disabled then
									sub.Disabled = false
									print("[Hangout cafe] Restored and enabled carriage movement script: " .. sub:GetFullName())
								end
							end
						end
						continue
					end

					-- Only disable original scripts inside the actual win sensor part (WinSensor / Winner / WINNER)
					-- to prevent disabling mechanical movement scripts on the carriage
					local isActualWinSensor = nameLower == "winsensor" or nameLower == "winner"
					if isActualWinSensor then
						for _, sub in ipairs(child:GetChildren()) do
							if (sub:IsA("Script") or sub:IsA("LocalScript")) and sub.Name ~= "Move" and sub.Name ~= "Drop" and sub.Name ~= "Retreat" then
								if not sub.Disabled then
									sub.Disabled = true
									print("[Hangout cafe] Disabled original sensor script: " .. sub:GetFullName())
								end
							end
						end
					end
					
					if not child:GetAttribute("SensorConnected") then
						child:SetAttribute("SensorConnected", true)
						print("[Hangout cafe] Sensor connected. Name: " .. child.Name .. ", Size: " .. tostring(child.Size) .. ", Position: " .. tostring(child.Position))
						
						child.Touched:Connect(function(otherPart)
							if otherPart.Name == "Prize" and otherPart:IsA("BasePart") then
								if otherPart:GetAttribute("IsBeingProcessed") then return end
								otherPart:SetAttribute("IsBeingProcessed", true)
								
								print("[Hangout cafe] Sensor touched by capsule: " .. otherPart:GetFullName() .. " at " .. tostring(otherPart.Position))
								
								local player = getNearestPlayer(child.Position, 20)
								if player then
									ClawMachineService:AwardPrize(player)
								end
								
								-- Play Arcade win sound locally at sensor
								local sound = Instance.new("Sound")
								sound.SoundId = "rbxassetid://6518552103"
								sound.Volume = 1.0
								sound.Parent = child
								sound:Play()
								Debris:AddItem(sound, 3)
								
								otherPart:Destroy()
							end
						end)
					end
				end
			end
		end
	end

	local spawnedMachines = setmetatable({}, { __mode = "k" }) -- Weak table to prevent memory leaks

	local function printClawMachineScripts(machine)
		print("[Hangout cafe] --- DIAGNOSTIC: SEARCHING ALL CLAW SCRIPTS IN GAME ---")
		local services = {game:GetService("Workspace"), game:GetService("ServerScriptService"), game:GetService("ReplicatedStorage"), game:GetService("StarterPlayer"), game:GetService("StarterPack"), game:GetService("StarterGui")}
		for _, svc in ipairs(services) do
			for _, desc in ipairs(svc:GetDescendants()) do
				if desc:IsA("LuaSourceContainer") then
					local fullName = desc:GetFullName()
					local nameLower = desc.Name:lower()
					if nameLower:find("claw") or nameLower:find("prize") or nameLower:find("catcher") or nameLower:find("chute") or nameLower:find("sensor") then
						print("  Script Match: " .. fullName .. " (" .. desc.ClassName .. ")")
						local success, src = pcall(function() return desc.Source end)
						if success then
							print("    --- SOURCE START (" .. desc.Name .. ") ---")
							print(src)
							print("    --- SOURCE END (" .. desc.Name .. ") ---")
						else
							print("    Could not read source: " .. tostring(src))
						end
					end
				end
			end
		end
		print("[Hangout cafe] --- END DIAGNOSTIC ---")
	end

	local function setupPhysicalClawMachines()
		local myId = os.clock() .. "_" .. math.random()
		_G.ClawMachineService_ActiveId = myId
		
		-- Periodically scan the Workspace to handle late-loading, streaming, or newly inserted machines
		task.spawn(function()
			local printedList = false
			local diagnosticsRun = false
			while _G.ClawMachineService_ActiveId == myId do
				local machines = {}
				local allModels = {}
				local matchModels = {}
				
				for _, child in ipairs(workspace:GetDescendants()) do
					if child:IsA("Model") then
						local name = child.Name
						if name:lower():find("claw") or name:lower():find("machine") then
							table.insert(matchModels, name .. " (Nested: " .. tostring(isNestedMachine(child)) .. ")")
						end
						if name == "Maxi Claw Machine" or name == "Claw Machine" or name == "ClawMachine" then
							if not isNestedMachine(child) then
								table.insert(machines, child)
							end
						end
					end
				end
				
				if not printedList then
					printedList = true
					print(string.format("[Hangout cafe] Claw Machine Scanner: Started. Matching models: [%s], Active found: %d", table.concat(matchModels, ", "), #machines))
					if #machines > 0 then
						for idx, mach in ipairs(machines) do
							print(string.format("  [%d] Path: %s, Position: %s", idx, mach:GetFullName(), tostring(mach:GetPivot().Position)))
						end
					end
				end
				
				for _, child in ipairs(machines) do
					if not diagnosticsRun then
						diagnosticsRun = true
						print("[Hangout cafe] CLAW MACHINE CHILDREN DIAGNOSTIC:")
						for _, item in ipairs(child:GetChildren()) do
							print("  - " .. item.Name .. " (" .. item.ClassName .. ")")
						end
						pcall(printClawMachineScripts, child)
					end
					
					local ok1, err1 = pcall(setupSensorHookup, child)
					if not ok1 then warn("[Hangout cafe] Error in setupSensorHookup: " .. tostring(err1)) end
					
					local ok2, err2 = pcall(setupClawTouchHookup, child)
					if not ok2 then warn("[Hangout cafe] Error in setupClawTouchHookup: " .. tostring(err2)) end
					
					local ok3, err3 = pcall(spawnCapsulesForMachine, child)
					if not ok3 then warn("[Hangout cafe] Error in spawnCapsulesForMachine: " .. tostring(err3)) end
				end
				task.wait(3) -- scan every 3 seconds
			end
		end)
	end
	
	-- Run physical setup
	setupPhysicalClawMachines()
end

return ClawMachineService
