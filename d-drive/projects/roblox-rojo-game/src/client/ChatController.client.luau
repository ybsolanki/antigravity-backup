--!strict
local TextChatService = game:GetService("TextChatService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local TITLE_TIERS = {
	{ Min = 10000, Name = "✨ THE CHOSEN ✨", Color = Color3.fromRGB(255, 255, 255) },
	{ Min = 1000, Name = "RNG Master", Color = Color3.fromRGB(162, 89, 255) },
	{ Min = 100, Name = "Dedicated", Color = Color3.fromRGB(152, 255, 152) },
	{ Min = 0, Name = "Novice", Color = Color3.fromRGB(180, 180, 180) },
}

local ZEDOX_GROUP_ID = 34743206 -- Placeholder ID, would be updated by user

local function GetTitleName(rolls: number)
	for _, tier in TITLE_TIERS do
		if rolls >= tier.Min then
			return tier.Name
		end
	end
	return "Novice"
end

-- 1. Chat Tag Integration
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties = Instance.new("TextChatMessageProperties")
	
	if message.TextSource then
		local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
		if sender then
			local rolls = sender:GetAttribute("TotalRolls") or 0
			local title = GetTitleName(rolls)
			local prefix = string.format("<font color='#AAAAAA'>[%s]</font>", title)
			
			-- Zedox Group Tag
			if sender:GetAttribute("IsZedoxMember") then
				prefix = string.format("<font color='#98FF98'>[ZEDOX MEMBER]</font> %s", prefix)
			end
			
			-- Zedox Master (Bundle Owner) Tag
			if sender:GetAttribute("HasZedoxTag") then
				prefix = string.format("<font color='#FFD700'>[ZEDOX MASTER]</font> %s", prefix)
			end
			
			properties.PrefixText = string.format("%s %s", prefix, message.PrefixText)
		end
	end
	
	return properties
end

-- 2. Rainbow Animation for THE CHOSEN
RunService.RenderStepped:Connect(function()
	for _, character in workspace:GetChildren() do
		local head = character:FindFirstChild("Head")
		if head then
			local overhead = head:FindFirstChild("OverheadTitle")
			if overhead then
				local container = overhead:FindFirstChild("Frame")
				local titleLabel = container and container:FindFirstChild("Title") :: TextLabel
				
				if titleLabel and titleLabel:GetAttribute("IsRainbow") == true then
					titleLabel.TextColor3 = Color3.fromHSV(tick() % 1, 0.8, 1)
					local stroke = titleLabel:FindFirstChild("UIStroke") :: UIStroke
					if stroke then
						stroke.Color = titleLabel.TextColor3
					end
				end
			end
		end
	end
end)
