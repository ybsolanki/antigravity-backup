local Workspace = game:GetService("Workspace")

local VillageGenerator = {}

function VillageGenerator.CreatePart(name, size, position, color, material, transparency)
	local mapFolder = Workspace:FindFirstChild("Map") or Instance.new("Folder", Workspace)
	mapFolder.Name = "Map"
	
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color or Color3.fromRGB(163, 162, 165)
	part.Material = material or Enum.Material.Slate
	part.Transparency = transparency or 0
	part.Anchored = true
	part.Parent = mapFolder
	return part
end

function VillageGenerator.BuildShojiWindow(pos, rotation)
	local windowFrame = VillageGenerator.CreatePart("WindowFrame", Vector3.new(4.5, 5.5, 0.4), pos, Color3.fromRGB(30, 20, 10), Enum.Material.Wood)
	windowFrame.Orientation = rotation
	
	-- Glowing glass
	local glass = VillageGenerator.CreatePart("WindowGlass", Vector3.new(4, 5, 0.2), pos, Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
	glass.Orientation = rotation
	
	-- Shoji Grids (Horizontal and Vertical)
	local gridColor = Color3.fromRGB(40, 30, 20)
	for i = -2, 2 do
		local vLine = VillageGenerator.CreatePart("GridLine", Vector3.new(0.1, 5, 0.3), pos, gridColor)
		vLine.CFrame = glass.CFrame * CFrame.new(i * 0.8, 0, 0.1)
		
		local hLine = VillageGenerator.CreatePart("GridLine", Vector3.new(4, 0.1, 0.3), pos, gridColor)
		hLine.CFrame = glass.CFrame * CFrame.new(0, i * 1, 0.1)
	end
end

function VillageGenerator.BuildHighDetailHouse(centerPos)
	local woodColor = Color3.fromRGB(50, 40, 30)
	local wallColor = Color3.fromRGB(240, 235, 230)
	
	-- 1. Stone Foundation
	VillageGenerator.CreatePart("Foundation", Vector3.new(22, 2, 22), centerPos + Vector3.new(0, 1, 0), Color3.fromRGB(100, 100, 105), Enum.Material.Basalt)
	
	-- 2. Main Walls (Recessed)
	local wallSize = Vector3.new(19, 10, 19)
	local houseBase = centerPos + Vector3.new(0, 7, 0)
	VillageGenerator.CreatePart("MainStructure", wallSize, houseBase, wallColor, Enum.Material.Plaster)
	
	-- 3. Corner Pillars
	local pSize = Vector3.new(1.5, 11, 1.5)
	VillageGenerator.CreatePart("Pillar", pSize, houseBase + Vector3.new(9.5, 0, 9.5), woodColor, Enum.Material.Wood)
	VillageGenerator.CreatePart("Pillar", pSize, houseBase + Vector3.new(-9.5, 0, 9.5), woodColor, Enum.Material.Wood)
	VillageGenerator.CreatePart("Pillar", pSize, houseBase + Vector3.new(9.5, 0, -9.5), woodColor, Enum.Material.Wood)
	VillageGenerator.CreatePart("Pillar", pSize, houseBase + Vector3.new(-9.5, 0, -9.5), woodColor, Enum.Material.Wood)

	-- 4. Windows (Front and Side)
	VillageGenerator.BuildShojiWindow(houseBase + Vector3.new(5, -1, -9.6), Vector3.new(0, 0, 0))
	VillageGenerator.BuildShojiWindow(houseBase + Vector3.new(-5, -1, -9.6), Vector3.new(0, 0, 0))
	VillageGenerator.BuildShojiWindow(houseBase + Vector3.new(9.6, -1, 0), Vector3.new(0, 90, 0))

	-- 5. Tiled Roof (The "3D Model" Look)
	local roofBase = houseBase + Vector3.new(0, 5, 0)
	local roofColor = Color3.fromRGB(40, 40, 45)
	
	-- Create two slanted planes
	for side = -1, 1, 2 do
		for row = 0, 12 do
			local rowZ = (row * 1.2) * side
			local rowY = (12 - row) * 0.5
			local tileRow = VillageGenerator.CreatePart("RoofTiles", Vector3.new(24, 0.5, 1.5), roofBase + Vector3.new(0, 2 + rowY, rowZ), roofColor, Enum.Material.Slate)
			tileRow.Orientation = Vector3.new(25 * side, 0, 0)
		end
	end
	
	-- Decorative Ridge Cap
	VillageGenerator.CreatePart("RoofRidge", Vector3.new(25, 1.5, 1.5), roofBase + Vector3.new(0, 8.5, 0), woodColor, Enum.Material.Wood)
end

function VillageGenerator.Build()
	print("Executing High-Detail Village Logic...")
	
	-- Clear old map for fresh build
	local oldMap = Workspace:FindFirstChild("Map")
	if oldMap then oldMap:Destroy() end
	
	-- Ground
	VillageGenerator.CreatePart("Ground", Vector3.new(800, 1, 800), Vector3.new(0, -0.5, 0), Color3.fromRGB(70, 75, 70), Enum.Material.Grass)
	
	-- Main Dirt Path (with edges)
	VillageGenerator.CreatePart("Road", Vector3.new(25, 0.4, 400), Vector3.new(0, 0.1, 0), Color3.fromRGB(130, 115, 100), Enum.Material.Sand)
	
	-- High Detail Houses
	VillageGenerator.BuildHighDetailHighDetailHouse(Vector3.new(-40, 0, -50))
	VillageGenerator.BuildHighDetailHighDetailHouse(Vector3.new(45, 0, -20))
	VillageGenerator.BuildHighDetailHighDetailHouse(Vector3.new(-50, 0, 60))
	VillageGenerator.BuildHighDetailHighDetailHouse(Vector3.new(55, 0, 40))
end

-- Fixed function name in call
function VillageGenerator.BuildHighDetailHighDetailHouse(pos)
	VillageGenerator.BuildHighDetailHouse(pos)
end

VillageGenerator.Build()
return VillageGenerator
