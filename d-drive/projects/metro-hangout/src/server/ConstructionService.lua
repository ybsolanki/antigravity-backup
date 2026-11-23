local CollectionService = game:GetService("CollectionService")

local ConstructionService = {}

function ConstructionService:Initialize()
	print("[Metro Hangout] Starting Premium Neon Construction...")
	self:BuildHub()
	self:BuildNeonCafe()
end

function ConstructionService:BuildHub()
	local hubPos = Vector3.new(0, 10, 0)
	
	-- Main Platform
	local platform = Instance.new("Part")
	platform.Name = "SpawnHub"
	platform.Size = Vector3.new(50, 1, 50)
	platform.CFrame = CFrame.new(hubPos)
	platform.Material = Enum.Material.Glass
	platform.Color = Color3.fromRGB(15, 15, 20)
	platform.Anchored = true
	platform.Parent = workspace
	
	-- Neon Border
	local border = Instance.new("Part")
	border.Name = "HubBorder"
	border.Shape = Enum.PartType.Cylinder
	border.Size = Vector3.new(1.5, 52, 52)
	border.CFrame = CFrame.new(hubPos) * CFrame.Angles(0, 0, math.rad(90))
	border.Material = Enum.Material.Neon
	border.Color = Color3.fromRGB(0, 255, 255)
	border.Transparency = 0.5
	border.Anchored = true
	border.CanCollide = false
	border.Parent = workspace
end

function ConstructionService:BuildNeonCafe()
	local cafePos = Vector3.new(80, 10, 0)
	local size = Vector3.new(60, 25, 40)
	
	local folder = Instance.new("Folder")
	folder.Name = "NeonCafe"
	folder.Parent = workspace
	
	-- 1. Floor
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Size = Vector3.new(size.X, 1, size.Z)
	floor.CFrame = CFrame.new(cafePos)
	floor.Material = Enum.Material.Marble
	floor.Color = Color3.fromRGB(240, 240, 240)
	floor.Anchored = true
	floor.Parent = folder

	-- 2. Roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(size.X + 4, 1, size.Z + 4)
	roof.CFrame = CFrame.new(cafePos + Vector3.new(0, size.Y, 0))
	roof.Material = Enum.Material.SmoothPlastic
	roof.Color = Color3.fromRGB(10, 10, 15)
	roof.Anchored = true
	roof.Parent = folder
	
	-- 3. Neon Trim for Roof
	local trim = Instance.new("Part")
	trim.Name = "RoofTrim"
	trim.Size = Vector3.new(size.X + 4.5, 0.5, size.Z + 4.5)
	trim.CFrame = roof.CFrame
	trim.Material = Enum.Material.Neon
	trim.Color = Color3.fromRGB(255, 0, 255) -- Purple
	trim.Anchored = true
	trim.CanCollide = false
	trim.Parent = folder

	-- 4. Pillars (4 Corners)
	local pillarPositions = {
		Vector3.new(size.X/2 - 1, size.Y/2, size.Z/2 - 1),
		Vector3.new(-size.X/2 + 1, size.Y/2, size.Z/2 - 1),
		Vector3.new(size.X/2 - 1, size.Y/2, -size.Z/2 + 1),
		Vector3.new(-size.X/2 + 1, size.Y/2, -size.Z/2 + 1)
	}
	
	for _, offset in ipairs(pillarPositions) do
		local pillar = Instance.new("Part")
		pillar.Size = Vector3.new(2, size.Y, 2)
		pillar.CFrame = CFrame.new(cafePos + offset)
		pillar.Material = Enum.Material.SmoothPlastic
		pillar.Color = Color3.fromRGB(20, 20, 25)
		pillar.Anchored = true
		pillar.Parent = folder
	end

	-- 5. Glass Windows (Simplified planes)
	local function makeWindow(wSize, offset, rotate)
		local win = Instance.new("Part")
		win.Size = wSize
		win.CFrame = CFrame.new(cafePos + offset) * (rotate or CFrame.new())
		win.Material = Enum.Material.Glass
		win.Color = Color3.fromRGB(200, 230, 255)
		win.Transparency = 0.7
		win.Anchored = true
		win.Parent = folder
	end
	
	makeWindow(Vector3.new(size.X - 2, size.Y - 2, 0.5), Vector3.new(0, size.Y/2, size.Z/2))
	makeWindow(Vector3.new(size.X - 2, size.Y - 2, 0.5), Vector3.new(0, size.Y/2, -size.Z/2))
	makeWindow(Vector3.new(0.5, size.Y - 2, size.Z - 2), Vector3.new(size.X/2, size.Y/2, 0))
	makeWindow(Vector3.new(0.5, size.Y - 2, size.Z - 2), Vector3.new(-size.X/2, size.Y/2, 0))

	-- 6. Coffee Counter
	local counter = Instance.new("Part")
	counter.Name = "Counter"
	counter.Size = Vector3.new(20, 4, 6)
	counter.CFrame = CFrame.new(cafePos + Vector3.new(0, 2, -10))
	counter.Material = Enum.Material.SmoothPlastic
	counter.Color = Color3.fromRGB(30, 30, 35)
	counter.Anchored = true
	counter.Parent = folder
	
	local counterNeon = Instance.new("Part")
	counterNeon.Size = Vector3.new(20.5, 0.5, 6.5)
	counterNeon.CFrame = counter.CFrame + Vector3.new(0, 2, 0)
	counterNeon.Material = Enum.Material.Neon
	counterNeon.Color = Color3.fromRGB(0, 255, 255)
	counterNeon.Anchored = true
	counterNeon.Parent = folder

	-- 7. Seating Areas
	for i = -1, 1 do
		local tablePos = cafePos + Vector3.new(i * 15, 1, 10)
		
		-- Table
		local tbl = Instance.new("Part")
		tbl.Size = Vector3.new(6, 0.5, 6)
		tbl.CFrame = CFrame.new(tablePos + Vector3.new(0, 2.5, 0))
		tbl.Material = Enum.Material.Glass
		tbl.Transparency = 0.5
		tbl.Anchored = true
		tbl.Parent = folder
		
		-- Seats around table
		for j = 0, 3 do
			local angle = math.rad(j * 90)
			local seat = Instance.new("Seat")
			seat.Size = Vector3.new(3, 1, 3)
			seat.CFrame = CFrame.new(tablePos + Vector3.new(math.cos(angle) * 5, 0.5, math.sin(angle) * 5))
			seat.Anchored = true
			seat.Parent = folder
			
			local marker = Instance.new("ObjectValue")
			marker.Name = "Interactive"
			marker.Parent = seat
		end
	end

	print("[Metro Hangout] Premium Neon Cafe Constructed")
end

return ConstructionService
