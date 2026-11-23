-- Run this script in the Roblox Studio Command Bar to generate the Obby map permanently in editor mode!

local OBBY_ORIGIN = Vector3.new(500, 150, 500)
local mapFolder = workspace:FindFirstChild("ObbyMap")
if mapFolder then mapFolder:Destroy() end

mapFolder = Instance.new("Folder")
mapFolder.Name = "ObbyMap"
mapFolder.Parent = workspace

local function createCheckpoint(index, position)
	local pad = Instance.new("Part")
	pad.Name = "Checkpoint" .. index
	pad.Size = Vector3.new(8, 0.2, 8)
	pad.Position = position
	pad.Color = Color3.fromRGB(150, 150, 150)
	pad.Material = Enum.Material.SmoothPlastic
	pad.Anchored = true
	pad.Parent = mapFolder

	local bulb = Instance.new("Part")
	bulb.Name = "Bulb"
	bulb.Shape = Enum.PartType.Ball
	bulb.Size = Vector3.new(1.5, 1.5, 1.5)
	bulb.Position = position + Vector3.new(0, 0.6, 0)
	bulb.Color = Color3.fromRGB(255, 0, 0)
	bulb.Material = Enum.Material.Neon
	bulb.Anchored = true
	bulb.CanCollide = false
	bulb.Parent = pad
end

-- Start Base Platform
local startBase = Instance.new("Part")
startBase.Name = "StartBase"
startBase.Size = Vector3.new(20, 1, 20)
startBase.Position = OBBY_ORIGIN
startBase.Color = Color3.fromRGB(50, 50, 50)
startBase.Material = Enum.Material.SmoothPlastic
startBase.Anchored = true
startBase.Parent = mapFolder

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
createCheckpoint(1, OBBY_ORIGIN + Vector3.new(0, 8.5, 46))

-- STAGE 2: Fading Tiles
for i = 1, 5 do
	local tile = Instance.new("Part")
	tile.Name = "FadingTile"
	tile.Size = Vector3.new(4, 0.5, 4)
	tile.Position = OBBY_ORIGIN + Vector3.new(i % 2 == 0 and 2.5 or -2.5, 8.5, 46 + i * 8)
	tile.Color = Color3.fromRGB(255, 0, 127)
	tile.Material = Enum.Material.Neon
	tile.Anchored = true
	tile.Parent = mapFolder
end
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
	laser.Color = Color3.fromRGB(255, 0, 0)
	laser.Material = Enum.Material.Neon
	laser.CanCollide = false
	laser.Anchored = true
	laser.Parent = mapFolder
end
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
prizePad.Color = Color3.fromRGB(255, 215, 0)
prizePad.Material = Enum.Material.Neon
prizePad.Anchored = true
prizePad.Parent = mapFolder

-- Teleport3_Start (Return Portal to Cafe)
local returnPortal = Instance.new("Part")
returnPortal.Name = "Teleport3_Start"
returnPortal.Size = Vector3.new(6, 0.2, 6)
returnPortal.Position = OBBY_ORIGIN + Vector3.new(0, 44.6, 280)
returnPortal.Parent = mapFolder

print("[Obby Generator] Success! Generated 5-Stage Obby in Workspace!")
