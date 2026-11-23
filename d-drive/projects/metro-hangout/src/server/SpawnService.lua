local Players = game:GetService("Players")

local SpawnService = {}

function SpawnService:Initialize()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			self:HandleNewCharacter(player, character)
		end)
	end)
end

function SpawnService:HandleNewCharacter(player, character)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	local head = character:WaitForChild("Head", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	
	if head and humanoid then
		-- Hide default Roblox name tag
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		
		-- Destroy old overhead tags if any
		local old = head:FindFirstChild("OverheadNameTag")
		if old then old:Destroy() end
		
		-- Create custom name tag
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "OverheadNameTag"
		billboard.Size = UDim2.new(0, 200, 0, 45)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = false -- Render behind walls for clean cafe aesthetics
		billboard.MaxDistance = 150
		
		local container = Instance.new("Frame")
		container.Size = UDim2.new(1, 0, 1, 0)
		container.BackgroundTransparency = 1
		container.Parent = billboard
		
		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.VerticalAlignment = Enum.VerticalAlignment.Center
		layout.Padding = UDim.new(0, 2)
		layout.Parent = container
		
		-- Display Name Label
		local displayNameLabel = Instance.new("TextLabel")
		displayNameLabel.Name = "DisplayNameLabel"
		displayNameLabel.Size = UDim2.new(1, 0, 0, 20)
		displayNameLabel.BackgroundTransparency = 1
		displayNameLabel.Text = player.DisplayName
		displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		displayNameLabel.Font = Enum.Font.GothamBold
		displayNameLabel.TextSize = 14
		displayNameLabel.TextStrokeTransparency = 0
		displayNameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		displayNameLabel.Parent = container
		
		-- Username Label
		local usernameLabel = Instance.new("TextLabel")
		usernameLabel.Name = "UsernameLabel"
		usernameLabel.Size = UDim2.new(1, 0, 0, 15)
		usernameLabel.BackgroundTransparency = 1
		usernameLabel.Text = "@" .. player.Name
		usernameLabel.TextColor3 = Color3.fromRGB(0, 220, 255) -- neon cyan
		usernameLabel.Font = Enum.Font.Gotham
		usernameLabel.TextSize = 11
		usernameLabel.TextStrokeTransparency = 0.3
		usernameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		usernameLabel.Parent = container
		
		billboard.Parent = head
		billboard.Adornee = head
	end
	
	print("[Hangout cafe] " .. player.Name .. " spawned at Hub with custom name tag")
end

return SpawnService
