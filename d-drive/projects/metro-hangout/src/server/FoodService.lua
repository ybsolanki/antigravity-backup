local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local FoodService = {}

local function isInsideCharacter(model)
	local current = model
	while current and current ~= workspace do
		if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
			return true
		end
		current = current.Parent
	end
	return false
end

local function detectFoodStandType(model)
	if not model:IsA("Model") then return nil end
	
	-- Ignore player characters, NPCs, and any models/tools nested inside them
	if isInsideCharacter(model) or game:GetService("Players"):GetPlayerFromCharacter(model) then
		return nil
	end
	
	-- Skip parent models if they contain child models that are also food stands
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("Model") and detectFoodStandType(child) then
			return nil
		end
	end
	
	local name = model.Name:lower()
	
	-- 1. Explicit name checks
	if name:match("taco") then
		return "Taco"
	elseif name:match("pho") then
		return "Pho"
	elseif name:match("hotdog") then
		return "Hotdog"
	elseif name:match("burger") then
		return "Burger"
	elseif name:match("ramen") then
		return "Ramen"
	elseif name:match("food stand") or name:match("foodstand") then
		return "Hotdog"
	end
	
	-- 2. Descendant checks (if model name is generic, e.g. "Model")
	for _, child in pairs(model:GetDescendants()) do
		local cName = child.Name:lower()
		if cName:match("taco") then
			return "Taco"
		elseif cName:match("pho") then
			return "Pho"
		elseif cName:match("hotdog") then
			return "Hotdog"
		elseif cName:match("burger") then
			return "Burger"
		elseif cName:match("ramen") then
			return "Ramen"
		elseif cName:match("food stand") or cName:match("foodstand") then
			return "Hotdog"
		elseif child:IsA("BillboardGui") and child:FindFirstChildOfClass("TextLabel") and child:FindFirstChildOfClass("TextLabel").Text:lower():match("buy food") then
			return "Hotdog"
		elseif child:IsA("TextLabel") and child.Text:lower():match("buy food") then
			return "Hotdog"
		elseif child:IsA("BasePart") and child.Name:lower():match("buy food") then
			return "Hotdog"
		end
	end
	
	return nil
end

function FoodService:Initialize()
	print("[Hangout cafe] FoodService: Booting...")
	
	-- 1. Create Replicated Folder for Food Tools
	local foodToolsFolder = Instance.new("Folder")
	foodToolsFolder.Name = "FoodTools"
	foodToolsFolder.Parent = ServerStorage
	self.foodToolsFolder = foodToolsFolder
	
	-- 2. Create the Food Tools
	self:CreateTacoTool(foodToolsFolder)
	self:CreatePhoTool(foodToolsFolder)
	self:CreateHotdogTool(foodToolsFolder)
	
	-- 3. Monitor Workspace for Food Stands
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Model") then
			local foodType = detectFoodStandType(descendant)
			if foodType then
				self:SetupFoodStand(descendant)
			end
		end
	end)
	
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") then
			local foodType = detectFoodStandType(descendant)
			if foodType then
				self:SetupFoodStand(descendant)
			end
		end
	end
end

function FoodService:CreateTacoTool(parent)
	local tool = Instance.new("Tool")
	tool.Name = "Taco"
	
	-- Taco Shell
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 0.8, 1.2)
	handle.Color = Color3.fromRGB(224, 172, 105) -- Taco yellow-brown
	handle.Material = Enum.Material.Sand
	handle.Parent = tool
	
	-- Tomato
	local tomato = Instance.new("Part")
	tomato.Name = "Tomato"
	tomato.Size = Vector3.new(0.4, 0.4, 0.4)
	tomato.Color = Color3.fromRGB(220, 20, 20)
	tomato.Position = handle.Position + Vector3.new(0, 0.3, 0.2)
	tomato.Material = Enum.Material.SmoothPlastic
	tomato.Parent = handle
	
	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = handle
	weld1.Part1 = tomato
	weld1.Parent = handle
	
	-- Lettuce
	local lettuce = Instance.new("Part")
	lettuce.Name = "Lettuce"
	lettuce.Size = Vector3.new(0.4, 0.4, 0.4)
	lettuce.Color = Color3.fromRGB(50, 200, 50)
	lettuce.Position = handle.Position + Vector3.new(0, 0.3, -0.2)
	lettuce.Material = Enum.Material.SmoothPlastic
	lettuce.Parent = handle
	
	local weld2 = Instance.new("WeldConstraint")
	weld2.Part0 = handle
	weld2.Part1 = lettuce
	weld2.Parent = handle
	
	tool.Parent = parent
end

function FoodService:CreatePhoTool(parent)
	local tool = Instance.new("Tool")
	tool.Name = "Pho"
	
	-- Bowl
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1.2, 0.6, 1.2)
	handle.Color = Color3.fromRGB(240, 240, 240)
	handle.Material = Enum.Material.SmoothPlastic
	handle.Parent = tool
	
	-- Soup
	local soup = Instance.new("Part")
	soup.Name = "Soup"
	soup.Size = Vector3.new(1.0, 0.2, 1.0)
	soup.Color = Color3.fromRGB(160, 120, 90) -- Broth color
	soup.Position = handle.Position + Vector3.new(0, 0.25, 0)
	soup.Material = Enum.Material.Glass
	soup.Parent = handle
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = soup
	weld.Parent = handle
	
	tool.Parent = parent
end

function FoodService:CreateHotdogTool(parent)
	local tool = Instance.new("Tool")
	tool.Name = "Hotdog"
	
	-- Bun
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.6, 1.2, 0.6)
	handle.Color = Color3.fromRGB(230, 180, 130)
	handle.Material = Enum.Material.SmoothPlastic
	handle.Parent = tool
	
	-- Sausage
	local sausage = Instance.new("Part")
	sausage.Name = "Sausage"
	sausage.Size = Vector3.new(0.4, 1.4, 0.4)
	sausage.Color = Color3.fromRGB(150, 70, 70)
	sausage.Position = handle.Position
	sausage.Material = Enum.Material.SmoothPlastic
	sausage.Parent = handle
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = sausage
	weld.Parent = handle
	
	tool.Parent = parent
end

function FoodService:SetupFoodStand(stand)
	if stand:FindFirstChild("FoodPrompt") then return end
	
	local foodType = detectFoodStandType(stand)
	if not foodType then return end
	
	-- Anchor all parts of the stand and its items so they don't fall over due to physics
	for _, part in pairs(stand:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = true
		end
	end
	
	-- Find a good part to host the ProximityPrompt
	local targetPart = stand:FindFirstChild("Counter", true) or 
	                   stand:FindFirstChild("Table", true) or 
	                   stand:FindFirstChild("Stand", true) or 
	                   stand:FindFirstChild("Sign", true) or 
	                   stand:FindFirstChildWhichIsA("BasePart", true)
	
	if not targetPart then
		warn("[Hangout cafe] Could not find any part inside food stand: " .. stand.Name)
		return
	end
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "FoodPrompt"
	prompt.ActionText = "Order " .. foodType
	prompt.ObjectText = foodType .. " Stand"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 15
	prompt.RequiresLineOfSight = false
	prompt.Parent = targetPart
	
	-- Add a nice Highlight so the user knows it's interactive
	local highlight = Instance.new("Highlight")
	highlight.Name = "FoodHighlight"
	highlight.FillColor = foodType == "Taco" and Color3.fromRGB(255, 170, 0) or 
	                      foodType == "Pho" and Color3.fromRGB(0, 170, 255) or 
	                      Color3.fromRGB(0, 255, 100)
	highlight.FillTransparency = 0.85
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.Adornee = stand
	highlight.Parent = stand
	
	prompt.Triggered:Connect(function(player)
		local tool = self.foodToolsFolder:FindFirstChild(foodType)
		if tool then
			local clone = tool:Clone()
			
			-- Connect the activation event for eating
			local eating = false
			clone.Activated:Connect(function()
				if eating then return end
				eating = true
				
				local char = player.Character
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
				local handlePart = clone:FindFirstChild("Handle")
				
				if handlePart then
					-- Play eating sound
					local sound = Instance.new("Sound")
					sound.SoundId = "rbxassetid://1398544778"
					sound.Volume = 0.8
					sound.Parent = handlePart
					sound:Play()
					
					-- Crumbs particles
					local attachment = Instance.new("Attachment", handlePart)
					local particles = Instance.new("ParticleEmitter")
					particles.Color = ColorSequence.new(handlePart.Color)
					particles.Size = NumberSequence.new(0.12, 0)
					particles.Rate = 60
					particles.Speed = NumberRange.new(2, 4)
					particles.Lifetime = NumberRange.new(0.5, 0.8)
					particles.Parent = attachment
					
					task.wait(1.0)
					
					particles.Enabled = false
					if humanoid and humanoid.Health > 0 then
						humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 20)
					end
					
					task.wait(0.5)
					sound:Destroy()
					attachment:Destroy()
				end
				
				clone:Destroy()
			end)
			
			clone.Parent = player.Backpack
			print("[Hangout cafe] Gave " .. foodType .. " to " .. player.Name)
		end
	end)
	
	print("[Hangout cafe] Food Stand Activated: " .. stand.Name .. " (" .. foodType .. ")")
end

return FoodService
