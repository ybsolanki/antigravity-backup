local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local ObbyService = {}
local OBBY_ORIGIN = Vector3.new(500, 150, 500)
local mapFolder = nil



-- Teleport player to active checkpoint
local function teleportToCheckpoint(player, character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end
	
	local checkpointIndex = player:GetAttribute("ObbyCheckpoint") or 0
	local targetPos = OBBY_ORIGIN + Vector3.new(0, 3, 0) -- default start base
	
	if checkpointIndex > 0 then
		local cpName = "Checkpoint" .. checkpointIndex
		local cpPart = mapFolder:FindFirstChild(cpName)
		if cpPart then
			targetPos = cpPart.Position + Vector3.new(0, 3.5, 0)
		end
	end
	
	-- Teleport player
	task.wait(0.05)
	hrp.CFrame = CFrame.new(targetPos)
	
	-- Play teleport sound locally
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://341336274"
	sound.Volume = 0.3
	sound.Parent = hrp
	sound:Play()
	Debris:AddItem(sound, 2)
end

local function createCheckpoint(index, position)
	local pad = Instance.new("Part")
	pad.Name = "Checkpoint" .. index
	pad.Size = Vector3.new(8, 0.2, 8)
	pad.Position = position
	pad.Color = Color3.fromRGB(150, 150, 150)
	pad.Material = Enum.Material.SmoothPlastic
	pad.Anchored = true
	pad.Parent = mapFolder

	-- Light indicator
	local bulb = Instance.new("Part")
	bulb.Name = "Bulb"
	bulb.Shape = Enum.PartType.Ball
	bulb.Size = Vector3.new(1.5, 1.5, 1.5)
	bulb.Position = position + Vector3.new(0, 0.6, 0)
	bulb.Color = Color3.fromRGB(255, 0, 0) -- starts red
	bulb.Material = Enum.Material.Neon
	bulb.Anchored = true
	bulb.CanCollide = false
	bulb.Parent = pad

	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			player:SetAttribute("InObby", true)
			local currentCP = player:GetAttribute("ObbyCheckpoint") or 0
			if index > currentCP then
				player:SetAttribute("ObbyCheckpoint", index)
				print("[Hangout cafe] " .. player.Name .. " reached checkpoint: " .. index)
				
				-- Play ding sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://6518552103"
				sound.Volume = 0.5
				sound.Parent = pad
				sound:Play()
				Debris:AddItem(sound, 2)
				
				-- Change bulb color to green
				bulb.Color = Color3.fromRGB(0, 255, 0)
			end
		end
	end)
	
	return pad
end

local function setupFadingTile(part)
	local active = false
	part.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and not active then
			active = true
			task.spawn(function()
				for step = 1, 10 do
					task.wait(0.08)
					part.Transparency = step / 10
				end
				part.CanCollide = false
				task.wait(2.0)
				part.CanCollide = true
				part.Transparency = 0
				active = false
			end)
		end
	end)
end

local function setupKillLaser(part)
	part.Touched:Connect(function(hit)
		local char = hit.Parent
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			hum.Health = 0
		end
	end)
end

local function setupWinnerPad(pad)
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			player:SetAttribute("InObby", false)
			player:SetAttribute("ObbyCheckpoint", 0)
			if not player:GetAttribute("ObbyCompleted") then
				player:SetAttribute("ObbyCompleted", true)
				print("[Hangout cafe] " .. player.Name .. " completed the Obby!")
				
				-- Award chat tag
				player:SetAttribute("ChatTag", "Obby Champ")
				player:SetAttribute("TagColor", "#FFFF00") -- Gold
				
				-- Play tada sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://12222008"
				sound.Volume = 1.0
				sound.Parent = pad
				sound:Play()
				Debris:AddItem(sound, 5)
				
				-- System message
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				local prizeEvent = ReplicatedStorage:FindFirstChild("ClawMachinePrizeEvent")
				if prizeEvent then
					prizeEvent:FireAllClients("SystemMessage", string.format("<font color='#FFFF00'>[🏆 OBBY CHAMP] %s successfully beat the Sky Obby! 🏆</font>", player.Name))
				end
			end
		end
	end)
end

local function generateMap()
	-- Create map container folder
	mapFolder = workspace:FindFirstChild("ObbyMap")
	if mapFolder then mapFolder:Destroy() end
	
	mapFolder = Instance.new("Folder")
	mapFolder.Name = "ObbyMap"
	mapFolder.Parent = workspace
	
	-- Start Base Platform
	local startBase = Instance.new("Part")
	startBase.Name = "StartBase"
	startBase.Size = Vector3.new(20, 1, 20)
	startBase.Position = OBBY_ORIGIN
	startBase.Color = Color3.fromRGB(50, 50, 50)
	startBase.Material = Enum.Material.SmoothPlastic
	startBase.Anchored = true
	startBase.Parent = mapFolder
	
	-- Teleport2_End (Entrance Portal Target)
	local startPortalDest = Instance.new("Part")
	startPortalDest.Name = "Teleport2_End"
	startPortalDest.Size = Vector3.new(6, 0.2, 6)
	startPortalDest.Position = OBBY_ORIGIN + Vector3.new(0, 0.6, 0)
	startPortalDest.Transparency = 1
	startPortalDest.CanCollide = false
	startPortalDest.Anchored = true
	startPortalDest.Parent = mapFolder
	
	-- STAGE 1: Pastel Steps
	for i = 1, 5 do
		local step = Instance.new("Part")
		step.Size = Vector3.new(4, 1, 4)
		step.Position = OBBY_ORIGIN + Vector3.new(0, i * 1.5, i * 6 + 8)
		step.Color = Color3.fromHSV(i / 10, 0.6, 0.9)
		step.Material = Enum.Material.SmoothPlastic
		step.Anchored = true
		step.Parent = mapFolder
	end
	
	-- Checkpoint 1
	createCheckpoint(1, OBBY_ORIGIN + Vector3.new(0, 8.5, 46))
	
	-- STAGE 2: Fading Tiles
	for i = 1, 5 do
		local tile = Instance.new("Part")
		tile.Name = "FadingTile"
		tile.Size = Vector3.new(4, 0.5, 4)
		tile.Position = OBBY_ORIGIN + Vector3.new(i % 2 == 0 and 2.5 or -2.5, 8.5, 46 + i * 8)
		tile.Color = Color3.fromRGB(255, 0, 127) -- neon pink
		tile.Material = Enum.Material.Neon
		tile.Anchored = true
		tile.Parent = mapFolder
	end
	
	-- Checkpoint 2
	createCheckpoint(2, OBBY_ORIGIN + Vector3.new(0, 8.5, 94))
	
	-- STAGE 3: Truss Climb
	local truss = Instance.new("TrussPart")
	truss.Size = Vector3.new(2, 20, 2)
	truss.Position = OBBY_ORIGIN + Vector3.new(0, 18.5, 104)
	truss.Anchored = true
	truss.Parent = mapFolder
	
	local topPlat = Instance.new("Part")
	topPlat.Size = Vector3.new(6, 1, 6)
	topPlat.Position = OBBY_ORIGIN + Vector3.new(0, 28, 104)
	topPlat.Color = Color3.fromRGB(120, 80, 50)
	topPlat.Material = Enum.Material.SmoothPlastic
	topPlat.Anchored = true
	topPlat.Parent = mapFolder
	
	-- Checkpoint 3
	createCheckpoint(3, OBBY_ORIGIN + Vector3.new(0, 28, 114))
	
	-- STAGE 4: Kill Lasers
	local bridge = Instance.new("Part")
	bridge.Size = Vector3.new(6, 1, 60)
	bridge.Position = OBBY_ORIGIN + Vector3.new(0, 28, 148)
	bridge.Color = Color3.fromRGB(80, 80, 80)
	bridge.Material = Enum.Material.SmoothPlastic
	bridge.Anchored = true
	bridge.Parent = mapFolder
	
	for i = 1, 4 do
		local laser = Instance.new("Part")
		laser.Name = "KillLaser"
		laser.Size = Vector3.new(6, 0.5, 0.5)
		laser.Position = OBBY_ORIGIN + Vector3.new(0, 29.2, 124 + i * 12)
		laser.Color = Color3.fromRGB(255, 0, 0) -- Bright Red
		laser.Material = Enum.Material.Neon
		laser.CanCollide = false
		laser.Anchored = true
		laser.Parent = mapFolder
	end
	
	-- Checkpoint 4
	createCheckpoint(4, OBBY_ORIGIN + Vector3.new(0, 28, 184))
	
	-- STAGE 5: Low-Gravity Cloud Leap
	for i = 1, 4 do
		local cloud = Instance.new("Part")
		cloud.Size = Vector3.new(6, 1, 6)
		cloud.Position = OBBY_ORIGIN + Vector3.new(i % 2 == 0 and 12 or -12, 28 + i * 4, 184 + i * 18)
		cloud.Color = Color3.fromRGB(200, 240, 255)
		cloud.Material = Enum.Material.SmoothPlastic
		cloud.Anchored = true
		cloud.Parent = mapFolder
	end
	
	-- Winner Base (End)
	local winnerPlat = Instance.new("Part")
	winnerPlat.Name = "WinnerBase"
	winnerPlat.Size = Vector3.new(20, 1, 20)
	winnerPlat.Position = OBBY_ORIGIN + Vector3.new(0, 44, 276)
	winnerPlat.Color = Color3.fromRGB(40, 40, 40)
	winnerPlat.Material = Enum.Material.SmoothPlastic
	winnerPlat.Anchored = true
	winnerPlat.Parent = mapFolder
	
	-- Prize Pad
	local prizePad = Instance.new("Part")
	prizePad.Name = "PrizePad"
	prizePad.Size = Vector3.new(8, 0.2, 8)
	prizePad.Position = OBBY_ORIGIN + Vector3.new(0, 44.6, 268)
	prizePad.Color = Color3.fromRGB(255, 215, 0) -- Gold
	prizePad.Material = Enum.Material.Neon
	prizePad.Anchored = true
	prizePad.Parent = mapFolder
	
	-- Teleport3_Start (Return Portal to Cafe)
	local returnPortal = Instance.new("Part")
	returnPortal.Name = "Teleport3_Start"
	returnPortal.Size = Vector3.new(6, 0.2, 6)
	returnPortal.Position = OBBY_ORIGIN + Vector3.new(0, 44.6, 280)
	returnPortal.Parent = mapFolder
end

local function findInstanceCaseInsensitive(parent, targetName)
	local targetNameLower = targetName:lower():gsub("%s+", "")
	for _, child in ipairs(parent:GetDescendants()) do
		local childNameLower = child.Name:lower():gsub("%s+", "")
		if childNameLower == targetNameLower then
			return child
		end
	end
	return nil
end

local function hookupMap()
	mapFolder = workspace:FindFirstChild("ObbyMap")
	if not mapFolder then return end
	
	for _, child in ipairs(mapFolder:GetDescendants()) do
		if child.Name:match("^Checkpoint%d+$") then
			local index = tonumber(child.Name:match("^Checkpoint(%d+)$"))
			if index then
				local bulb = child:FindFirstChild("Bulb")
				child.Touched:Connect(function(hit)
					local player = Players:GetPlayerFromCharacter(hit.Parent)
					if player then
						player:SetAttribute("InObby", true)
						local currentCP = player:GetAttribute("ObbyCheckpoint") or 0
						if index > currentCP then
							player:SetAttribute("ObbyCheckpoint", index)
							print("[Hangout cafe] " .. player.Name .. " reached checkpoint: " .. index)
							
							-- Play chime sound
							local sound = Instance.new("Sound")
							sound.SoundId = "rbxassetid://6518552103"
							sound.Volume = 0.5
							sound.Parent = child
							sound:Play()
							Debris:AddItem(sound, 2)
							
							-- Change bulb color to green
							if bulb then
								bulb.Color = Color3.fromRGB(0, 255, 0)
							end
						end
					end
				end)
			end
		elseif child.Name == "FadingTile" then
			setupFadingTile(child)
		elseif child.Name == "KillLaser" then
			setupKillLaser(child)
		elseif child.Name == "PrizePad" then
			setupWinnerPad(child)
		end
	end
end

function ObbyService:Initialize()
	print("[Hangout cafe] ObbyService: Initializing Sky Obby...")
	
	-- 1. Check if the map is already created in editor mode
	mapFolder = workspace:FindFirstChild("ObbyMap")
	if not mapFolder then
		print("[Hangout cafe] ObbyService: No ObbyMap folder found, generating programmatic fallback.")
		generateMap()
	else
		print("[Hangout cafe] ObbyService: Found edit-time ObbyMap, skipping generation.")
	end
	
	-- 2. Hook up event listeners to map parts
	hookupMap()
	
	-- 3. Spawn entrance and return portal destinations in the cafe area (only if not manually placed in Studio)
	local cafeEntrance = findInstanceCaseInsensitive(workspace, "Teleport2_Start")
	if not cafeEntrance then
		cafeEntrance = Instance.new("Part")
		cafeEntrance.Name = "Teleport2_Start"
		cafeEntrance.Size = Vector3.new(6, 0.2, 6)
		cafeEntrance.Position = Vector3.new(-70, 10.2, -50) -- Lowered to match ground height
		cafeEntrance.Parent = workspace
		
		-- Floating 3D Text Label above portal
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "PortalLabel"
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 4, 0)
		billboard.AlwaysOnTop = true
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = "☁️ SKY OBBY ☁️"
		label.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
		label.Font = Enum.Font.GothamBold
		label.TextSize = 16
		label.TextStrokeTransparency = 0.2
		label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		label.Parent = billboard
		
		billboard.Parent = cafeEntrance
		billboard.Adornee = cafeEntrance
	end
	
	local cafeExit = findInstanceCaseInsensitive(workspace, "Teleport3_End")
	if not cafeExit then
		cafeExit = Instance.new("Part")
		cafeExit.Name = "Teleport3_End"
		cafeExit.Size = Vector3.new(6, 0.2, 6)
		cafeExit.Position = Vector3.new(-60, 10.2, -50) -- Lowered to match ground height
		cafeExit.Transparency = 1
		cafeExit.CanCollide = false
		cafeExit.Anchored = true
		cafeExit.Parent = workspace
	end
	
	-- Hook portal touch events for Obby state management
	local t2Start = findInstanceCaseInsensitive(workspace, "Teleport2_Start")
	local t2End = findInstanceCaseInsensitive(workspace, "Teleport2_End")
	local t3Start = findInstanceCaseInsensitive(workspace, "Teleport3_Start")
	local t3End = findInstanceCaseInsensitive(workspace, "Teleport3_End")
	
	local function markInObby(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			player:SetAttribute("InObby", true)
		end
	end
	
	local function markExitObby(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			player:SetAttribute("InObby", false)
			player:SetAttribute("ObbyCheckpoint", 0)
		end
	end
	
	if t2Start then t2Start.Touched:Connect(markInObby) end
	if t2End then t2End.Touched:Connect(markInObby) end
	if t3Start then t3Start.Touched:Connect(markExitObby) end
	if t3End then t3End.Touched:Connect(markExitObby) end
	
	-- 4. Connect player character spawn to teleport ONLY if player is currently in the Obby
	local function handleCharacterSpawn(player, character)
		local inObby = player:GetAttribute("InObby")
		local currentCP = player:GetAttribute("ObbyCheckpoint") or 0
		if inObby and currentCP > 0 then
			teleportToCheckpoint(player, character)
		end
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			handleCharacterSpawn(player, character)
		end)
	end)
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			handleCharacterSpawn(player, player.Character)
		end
		player.CharacterAdded:Connect(function(character)
			handleCharacterSpawn(player, character)
		end)
	end
	
	-- 5. Monitor player coordinates for obby state and instant falling recovery
	RunService.Heartbeat:Connect(function()
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local pos = hrp.Position
				-- Check if player is near the Obby horizontal area
				if pos.X >= 350 and pos.X <= 650 and pos.Z >= 450 and pos.Z <= 820 then
					if pos.Y >= 120 then
						if not player:GetAttribute("InObby") then
							player:SetAttribute("InObby", true)
						end
					elseif pos.Y < 120 then
						if player:GetAttribute("InObby") then
							teleportToCheckpoint(player, char)
						end
					end
				else
					-- Player is outside the Obby area (e.g. back in Cafe / main map ground level Y < 100)
					if pos.Y < 100 then
						if player:GetAttribute("InObby") then
							player:SetAttribute("InObby", false)
							player:SetAttribute("ObbyCheckpoint", 0)
						end
					end
				end
			end
		end
	end)
	
	print("[Hangout cafe] ObbyService: Initialized successfully!")
end

return ObbyService
