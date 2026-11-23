--!strict
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local AuraData = require(Shared:WaitForChild("AuraData"))

local function SetupLighting()
	Lighting.ClockTime = 17.5 -- Dusk (Beautiful purple/teal sky)
	Lighting.GlobalShadows = true
	Lighting.Brightness = 2.0 -- Premium brightness
	Lighting.Ambient = Color3.fromRGB(40, 60, 60) -- Soft mint character light
	Lighting.OutdoorAmbient = Color3.fromRGB(30, 45, 45)
	Lighting.EnvironmentDiffuseScale = 0.8
	Lighting.EnvironmentSpecularScale = 0.8
	
	-- Clear old sky/atmosphere/effects
	for _, child in Lighting:GetChildren() do
		if child:IsA("Sky") or child:IsA("Atmosphere") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") then
			child:Destroy()
		end
	end
	
	-- Teal/Green Starry Skybox
	local sky = Instance.new("Sky")
	sky.Name = "MintSky"
	sky.SkyboxBk = "rbxassetid://159454299"
	sky.SkyboxDn = "rbxassetid://159454299"
	sky.SkyboxFt = "rbxassetid://159454299"
	sky.SkyboxLf = "rbxassetid://159454299"
	sky.SkyboxRt = "rbxassetid://159454299"
	sky.SkyboxUp = "rbxassetid://159454299"
	sky.CelestialBodiesShown = false
	sky.StarCount = 5000
	sky.Parent = Lighting
	
	-- Clean Bloom for Pastel Vibe
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.3
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "MintCorrection"
	cc.Saturation = 0.4
	cc.Contrast = 0.2
	cc.Parent = Lighting
end

local function BuildPlatform()
	local folder = Instance.new("Folder")
	folder.Name = "AuraLobby"
	folder.Parent = workspace
	
	-- 1. Create a "Space Void" far below to hold the galaxy particles
	local voidBase = Instance.new("Part")
	voidBase.Name = "SpaceVoid"
	voidBase.Size = Vector3.new(500, 1, 500)
	voidBase.Position = Vector3.new(0, -50, 0)
	voidBase.Transparency = 1
	voidBase.Anchored = true
	voidBase.CanCollide = false
	voidBase.Parent = folder

	local stars = Instance.new("ParticleEmitter")
	stars.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	stars.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	stars.Size = NumberSequence.new(0.5)
	stars.Lifetime = NumberRange.new(5, 10)
	stars.Rate = 50
	stars.Speed = NumberRange.new(0, 0.1)
	stars.SpreadAngle = Vector2.new(180, 180)
	stars.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.5),
		NumberSequenceKeypoint.new(1, 1)
	})
	stars.Parent = voidBase
	
	-- 2. Massive Galaxy Floor (Connects all pads - Enlarged to 500x500)
	local galaxyFloor = Instance.new("Part")
	galaxyFloor.Name = "GalaxyFloor"
	galaxyFloor.Size = Vector3.new(500, 1, 500)
	galaxyFloor.Position = Vector3.new(0, -1, 0)
	galaxyFloor.Material = Enum.Material.SmoothPlastic
	galaxyFloor.Color = Color3.fromRGB(10, 15, 20) -- Dark Space Black
	galaxyFloor.Anchored = true
	galaxyFloor.CanCollide = true
	galaxyFloor.Parent = folder
	
	-- Add decorative grid for depth
	local texture = Instance.new("Texture")
	texture.Texture = "rbxassetid://1214300180" -- Scientific Grid
	texture.Face = Enum.NormalId.Top
	texture.Transparency = 0.8
	texture.Color3 = Color3.fromRGB(152, 255, 152) -- Mint Green Grid
	texture.StudsPerTileU = 10
	texture.StudsPerTileV = 10
	texture.Parent = galaxyFloor

	-- 3. Create the 5 Dedicated Rolling Pads
	local pads = {}
	local ringRadius = 25
	local padCount = 5
	
	for i = 1, padCount do
		local angle = (math.pi * 2 / padCount) * i
		local posX = math.cos(angle) * ringRadius
		local posZ = math.sin(angle) * ringRadius
		
		local pad = Instance.new("Part")
		pad.Name = "RollingPad_" .. i
		pad.Shape = Enum.PartType.Cylinder
		pad.Size = Vector3.new(1.1, 12, 12)
		pad.Position = Vector3.new(posX, -0.45, posZ)
		pad.Orientation = Vector3.new(0, 0, 90)
		pad.Material = Enum.Material.Neon
		pad.Color = Color3.fromRGB(150, 255, 200) -- Default Mint
		pad.Transparency = 0.6
		pad.Anchored = true
		pad.Parent = folder
		table.insert(pads, pad)
		
		-- Private Spawn (Raised for safety)
		local sp = Instance.new("SpawnLocation")
		sp.Name = "PadSpawn_" .. i
		sp.Size = Vector3.new(6, 1, 6)
		sp.Position = Vector3.new(posX, 1.5, posZ)
		sp.Transparency = 1
		sp.CanCollide = false
		sp.Parent = folder
	end
	
	-- 3. Dynamic Color Sync Loop (Mission #18)
	task.spawn(function()
		while true do
			for _, pad in ipairs(pads) do
				local closestPlayer = nil
				local minDist = 10
				
				for _, player in ipairs(Players:GetPlayers()) do
					local char = player.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					if root then
						local dist = (root.Position - pad.Position).Magnitude
						if dist < minDist then
							minDist = dist
							closestPlayer = player
						end
					end
				end
				
				local targetColor = Color3.fromRGB(150, 255, 200) -- Default Mint
				if closestPlayer then
					local auraName = closestPlayer:GetAttribute("CurrentAura")
					if auraName then
						for _, aura in ipairs(AuraData.Auras) do
							if aura.Name == auraName then
								targetColor = aura.Color
								break
							end
						end
					end
				end
				
				-- Smooth transition
				TweenService:Create(pad, TweenInfo.new(0.5), {Color = targetColor}):Play()
			end
			task.wait(0.2)
		end
	end)
	
	-- Center Pedestal (Leaderboard visibility remains)
	local pedestal = Instance.new("Part")
	pedestal.Name = "Pedestal"
	pedestal.Size = Vector3.new(4, 1, 4)
	pedestal.Position = Vector3.new(0, -0.5, 0)
	pedestal.Material = Enum.Material.SmoothPlastic
	pedestal.Color = Color3.fromRGB(10, 10, 15)
	pedestal.Anchored = true
	pedestal.Parent = folder
	
	-- Billboard & Leaderboard
	local board = Instance.new("BillboardGui")
	board.Name = "RarityBoard"
	board.Size = UDim2.fromScale(5, 2)
	board.StudsOffset = Vector3.new(0, 3, 0)
	board.MaxDistance = 100
	board.Parent = pedestal
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Display"
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Text = "Waiting for players..."
	textLabel.Parent = board
	
	local tablet = Instance.new("Part")
	tablet.Name = "LeaderboardTablet"
	tablet.Size = Vector3.new(20, 15, 2)
	tablet.Position = Vector3.new(0, 7.5, -29)
	tablet.Orientation = Vector3.new(0, 180, 0)
	tablet.Material = Enum.Material.Slate
	tablet.Color = Color3.fromRGB(30, 30, 30)
	tablet.Anchored = true
	tablet.Parent = folder
	
	local leaderboardGui = Instance.new("SurfaceGui")
	leaderboardGui.Name = "LeaderboardGui"
	leaderboardGui.Face = Enum.NormalId.Front
	leaderboardGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	leaderboardGui.PixelsPerStud = 50
	leaderboardGui.Parent = tablet
	
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	container.Parent = leaderboardGui
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0.15, 0)
	title.BackgroundTransparency = 1
	title.Text = "GLOBAL TOP 10 RARITIES"
	title.TextColor3 = Color3.fromRGB(246, 255, 0)
	title.TextScaled = true
	title.Font = Enum.Font.FredokaOne
	title.Parent = container
	
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0.01, 0)
	layout.Parent = container
	
	return folder, textLabel, container
end

local function StartPedestalTracker(textLabel: TextLabel)
	local function getAuraChance(auraName)
		for _, a in AuraData.Auras do
			if a.Name == auraName then return a.Chance end
		end
		return 0
	end

	task.spawn(function()
		while task.wait(1) do
			local rarestPlayer = nil
			local highestChance = 0
			local bestAuraName = ""
			
			for _, player in Players:GetPlayers() do
				local currentAura = player:GetAttribute("CurrentAura")
				if currentAura then
					local chance = getAuraChance(currentAura)
					if chance > highestChance then
						highestChance = chance
						rarestPlayer = player
						bestAuraName = currentAura
					end
				end
			end
			
			if rarestPlayer and highestChance > 0 then
				textLabel.Text = rarestPlayer.Name .. "\n" .. bestAuraName .. "\n(1 in " .. highestChance .. ")"
				if highestChance >= 1000000 then
					textLabel.TextColor3 = Color3.fromRGB(155, 89, 182)
				elseif highestChance >= 90000 then
					textLabel.TextColor3 = Color3.fromRGB(0, 165, 255)
				elseif highestChance >= 500 then
					textLabel.TextColor3 = Color3.fromRGB(231, 54, 54)
				else
					textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
			else
				textLabel.Text = "Lobby is empty\nor no auras equipped."
				textLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
		end
	end)
end

local DataStoreService = game:GetService("DataStoreService")

local function StartGlobalLeaderboard(container: Frame)
	local function UpdateLeaderboard()
		local success, pages = pcall(function()
			local store = DataStoreService:GetOrderedDataStore("GlobalAuraLeads")
			return store:GetSortedAsync(false, 10, 1)
		end)
		
		if success and pages then
			local data = pages:GetCurrentPage()
			for _, child in container:GetChildren() do
				if child:IsA("TextLabel") and child.Name ~= "Title" then
					child:Destroy()
				end
			end
			
			for rank, entry in ipairs(data) do
				local userId = tonumber(entry.key)
				local chance = entry.value
				local username = "Unknown"
				pcall(function() username = Players:GetNameFromUserIdAsync(userId) end)
				
				local auraName = "Unknown"
				for _, a in AuraData.Auras do
					if a.Chance == chance then auraName = a.Name break end
				end
				
				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, 0, 0.08, 0)
				label.BackgroundTransparency = 1
				label.Text = string.format("#%d  %s - %s", rank, username, auraName)
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.TextScaled = true
				label.Font = Enum.Font.FredokaOne
				label.Parent = container
			end
		end
	end

	task.spawn(function()
		while true do
			UpdateLeaderboard()
			task.wait(60)
		end
	end)
end

SetupLighting()
local lobbyFolder, displayLabel, leaderboardContainer = BuildPlatform()
StartPedestalTracker(displayLabel)
StartGlobalLeaderboard(leaderboardContainer)

-- 4. Void Shield (Spawn Glitch 2.0 Protection)
task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and root.Position.Y < -20 then
				-- Instant teleport to safety (Pedestal center)
				root.CFrame = CFrame.new(Vector3.new(0, 5, 0))
				print("Void Shield: Safely caught " .. player.Name)
			end
		end
		task.wait(0.1) -- Fast check
	end
end)

-- (Mission #26) Auto-Join Logic: Assign to Pedestals
local function AssignToPedestal(player: Player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	
	-- Find first empty pedestal
	local lobby = workspace:FindFirstChild("AuraLobby")
	if not lobby then return end
	
	local occupied = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local pRoot = p.Character:FindFirstChild("HumanoidRootPart")
			if pRoot then
				for i = 1, 5 do
					local spawn = lobby:FindFirstChild("PadSpawn_" .. i)
					if spawn and (pRoot.Position - spawn.Position).Magnitude < 10 then
						occupied[i] = true
					end
				end
			end
		end
	end
	
	for i = 1, 5 do
		if not occupied[i] then
			local spawn = lobby:FindFirstChild("PadSpawn_" .. i)
			if spawn then
				root.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
				print("Auto-Join: Assigned " .. player.Name .. " to Pedestal " .. i)
				break
			end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.5) -- Wait for character to fully load
		AssignToPedestal(player)
	end)
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		AssignToPedestal(player)
	end
end

print("Mint Green Galaxy Aesthetic Lobby built!")
