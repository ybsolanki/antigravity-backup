local TeleportService = {}

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

function TeleportService:Initialize()
	print("[Hangout cafe] TeleportService: Scanning for portals...")
	
	-- Monitor Workspace for teleport parts (case-insensitive matching)
	workspace.DescendantAdded:Connect(function(descendant)
		local nameLower = descendant.Name:lower()
		if nameLower:match("^teleport%d*_%a+$") then
			self:SetupTeleporter(descendant)
		end
	end)
	
	for _, descendant in pairs(workspace:GetDescendants()) do
		local nameLower = descendant.Name:lower()
		if nameLower:match("^teleport%d*_%a+$") then
			self:SetupTeleporter(descendant)
		end
	end
end

function TeleportService:SetupTeleporter(part)
	local nameLower = part.Name:lower()
	local prefix, id, suffix = nameLower:match("(teleport)(%d*)_(%a+)")
	if not id then return end
	
	local targetSuffix = (suffix == "start") and "end" or "start"
	local targetName = prefix .. id .. "_" .. targetSuffix
	
	-- Style the Portal
	part.Transparency = 0.8
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(0, 255, 255) -- Metro Cyan
	part.Size = Vector3.new(6, 0.2, 6)
	part.CanCollide = false
	part.Anchored = true
	
	-- Add a cool Portal Ring
	local ring = part:FindFirstChild("PortalRing") or Instance.new("Part")
	ring.Name = "PortalRing"
	ring.Shape = Enum.PartType.Cylinder
	ring.Size = Vector3.new(0.5, 7, 7)
	ring.CFrame = part.CFrame * CFrame.Angles(0, 0, math.rad(90))
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = part.Color
	ring.Transparency = 0.5
	ring.Parent = part
	
	-- Add Portal Light
	local light = part:FindFirstChild("PortalLight") or Instance.new("PointLight")
	light.Name = "PortalLight"
	light.Color = part.Color
	light.Range = 15
	light.Brightness = 2
	light.Parent = part

	part.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		local hrp = character:FindFirstChild("HumanoidRootPart")
		
		if humanoid and hrp and not character:FindFirstChild("Teleporting") then
			-- Use case-insensitive search for target part
			local targetPart = findInstanceCaseInsensitive(workspace, targetName)
			if targetPart then
				-- Debounce
				local tag = Instance.new("BoolValue", character)
				tag.Name = "Teleporting"
				
				-- Play a sound
				local sound = part:FindFirstChild("TeleportSound")
				if not sound then
					sound = Instance.new("Sound")
					sound.Name = "TeleportSound"
					sound.SoundId = "rbxassetid://341336274" -- Sci-fi teleport sound
					sound.Volume = 0.5
					sound.Parent = part
				end
				sound:Play()
				
				-- Teleport player slightly above the target
				hrp.CFrame = targetPart.CFrame + Vector3.new(0, 4, 0)
				
				task.wait(1.5)
				tag:Destroy()
			end
		end
	end)
end

return TeleportService
