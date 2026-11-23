local RoadService = {}

function RoadService:Initialize()
	print("[Metro Hangout] RoadService Initialized")
end

function RoadService:GenerateRoadGrid()
	print("[Hangout cafe] Generating 100x100 Road Grid...")
	
	local roadFolder = workspace:FindFirstChild("AutoRoads")
	if roadFolder then roadFolder:Destroy() end
	
	roadFolder = Instance.new("Folder")
	roadFolder.Name = "AutoRoads"
	roadFolder.Parent = workspace
	
	local spacing = 100
	local range = 250 -- Total area 500x500 (from -250 to 250)
	local roadWidth = 20
	
	-- Generate Horizontal Roads (X-Axis)
	for z = -range, range, spacing do
		self:CreateRoadSegment(Vector3.new(0, 0.1, z), Vector3.new(range * 2, 0.5, roadWidth), roadFolder)
	end
	
	-- Generate Vertical Roads (Z-Axis)
	for x = -range, range, spacing do
		self:CreateRoadSegment(Vector3.new(x, 0.1, 0), Vector3.new(roadWidth, 0.5, range * 2), roadFolder)
	end
end

function RoadService:CreateRoadSegment(position, size, parent)
	local road = Instance.new("Part")
	road.Name = "RoadSegment"
	road.Size = size
	road.CFrame = CFrame.new(position)
	road.Anchored = true
	road.Material = Enum.Material.Concrete
	road.Color = Color3.fromRGB(30, 30, 35)
	road.Parent = parent
	
	-- Add Neon Lane Lines
	local lines = Instance.new("Part")
	local isLong = size.X < size.Z
	lines.Size = isLong and Vector3.new(0.5, 0.1, size.Z) or Vector3.new(size.X, 0.1, 0.5)
	
	lines.CFrame = road.CFrame + Vector3.new(0, 0.3, 0)
	lines.Material = Enum.Material.Neon
	lines.Color = Color3.fromRGB(0, 255, 255)
	lines.Anchored = true
	lines.CanCollide = false
	lines.Parent = road
end

return RoadService
