--!strict
local Players = game:GetService("Players")

local PlayerManager = {}

local TITLE_TIERS = {
	{ Min = 10000, Name = "✨ THE CHOSEN ✨", Color = Color3.fromRGB(255, 255, 255), Glow = true }, -- Rainbow logic on client
	{ Min = 1000, Name = "RNG Master", Color = Color3.fromRGB(162, 89, 255), Glow = true },
	{ Min = 100, Name = "Dedicated", Color = Color3.fromRGB(152, 255, 152), Glow = false },
	{ Min = 0, Name = "Novice", Color = Color3.fromRGB(180, 180, 180), Glow = false },
}

local function GetTitleInfo(rolls: number)
	for _, tier in TITLE_TIERS do
		if rolls >= tier.Min then
			return tier
		end
	end
	return TITLE_TIERS[#TITLE_TIERS]
end

local function CreateOverhead(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	local head = character:WaitForChild("Head")
	
	-- Remove old ones
	local existing = head:FindFirstChild("OverheadTitle")
	if existing then existing:Destroy() end
	
	local bgui = Instance.new("BillboardGui")
	bgui.Name = "OverheadTitle"
	bgui.Size = UDim2.new(0, 200, 0, 50)
	bgui.StudsOffset = Vector3.new(0, 3, 0)
	bgui.AlwaysOnTop = false
	bgui.Parent = head
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = bgui
	
	local uiList = Instance.new("UIListLayout")
	uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uiList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uiList.Padding = UDim.new(0, 2)
	uiList.Parent = container
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextScaled = true
	titleLabel.Parent = container
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "DisplayName"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Text = player.DisplayName
	nameLabel.TextScaled = true
	nameLabel.Parent = container

	local function Update()
		local rolls = player:GetAttribute("TotalRolls") or 0
		local info = GetTitleInfo(rolls)
		
		titleLabel.Text = info.Name
		titleLabel.TextColor3 = info.Color
		
		-- Add shadow for glow-tiers
		if info.Glow then
			local shadow = titleLabel:FindFirstChild("UIStroke") or Instance.new("UIStroke", titleLabel)
			shadow.Thickness = 2
			shadow.Color = info.Color
			shadow.Transparency = 0.5
		else
			local shadow = titleLabel:FindFirstChild("UIStroke")
			if shadow then shadow:Destroy() end
		end
		
		-- Tag for rainbow logic on client
		if rolls >= 10000 then
			titleLabel:SetAttribute("IsRainbow", true)
		else
			titleLabel:SetAttribute("IsRainbow", false)
		end
	end
	
	player:GetAttributeChangedSignal("TotalRolls"):Connect(Update)
	Update()
end

function PlayerManager.Init()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			CreateOverhead(player)
		end)
		if player.Character then CreateOverhead(player) end
	end)
	
	for _, player in Players:GetPlayers() do
		player.CharacterAdded:Connect(function()
			CreateOverhead(player)
		end)
		if player.Character then CreateOverhead(player) end
	end
end

PlayerManager.Init()

return PlayerManager
