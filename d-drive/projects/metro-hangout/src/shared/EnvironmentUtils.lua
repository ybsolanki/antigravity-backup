local Terrain = workspace:WaitForChild("Terrain")

local EnvironmentUtils = {}

function EnvironmentUtils:ClearTerrainUnder(position, size)
	local clearSize = size + Vector3.new(2, 5, 2)
	local clearCFrame = CFrame.new(position)
	Terrain:FillBlock(clearCFrame, clearSize, Enum.Material.Air)
end

function EnvironmentUtils:GenerateCustomPlatform()
	print("[Hangout cafe] Generating Stylized Green Foundation...")
	
	-- 1. Clear ALL Terrain
	Terrain:Clear()
	
	-- 2. Create/Update the Foundation Part
	local foundation = workspace:FindFirstChild("MetroFoundation")
	if not foundation then
		foundation = Instance.new("Part")
		foundation.Name = "MetroFoundation"
		foundation.Anchored = true
		foundation.Locked = true
		foundation.Parent = workspace
	end
	
	foundation.Size = Vector3.new(500, 2, 500)
	foundation.Position = Vector3.new(0, -1, 0)
	foundation.Material = Enum.Material.Grass -- On a Part, this is a clean 2D texture
	foundation.Color = Color3.fromRGB(50, 80, 40) -- Darker Lush Green
	foundation.Reflectance = 0
	
	-- 3. Add a more natural Grass Texture for extra detail
	local texture = foundation:FindFirstChild("GridTexture") or Instance.new("Texture")
	texture.Name = "GridTexture"
	texture.Texture = "rbxassetid://13110531" -- Stylized Grass Texture
	texture.Transparency = 0.5
	texture.Face = Enum.NormalId.Top
	texture.StudsPerTileU = 20
	texture.StudsPerTileV = 20
	texture.Parent = foundation
	
	-- 4. Clean up any leftover trim
	local trimFolder = foundation:FindFirstChild("Trim")
	if trimFolder then trimFolder:Destroy() end

	print("[Hangout cafe] Stylized Green Foundation Ready!")
end

return EnvironmentUtils
