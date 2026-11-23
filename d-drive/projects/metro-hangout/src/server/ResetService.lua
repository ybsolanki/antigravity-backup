local Players = game:GetService("Players")

local ResetService = {}

function ResetService:Initialize()
	-- Listen for new parts being added
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "ResetClothing" then
			self:SetupPart(descendant)
		end
	end)
	
	-- Setup existing parts
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant.Name == "ResetClothing" then
			self:SetupPart(descendant)
		end
	end
	
	print("[Hangout cafe] ResetService Initialized")
end

function ResetService:SetupPart(part)
	if part:FindFirstChild("ResetPrompt") then return end
	
	-- Ensure we have a BasePart
	local targetPart = part:IsA("BasePart") and part or part:FindFirstChildWhichIsA("BasePart", true)
	if not targetPart then return end
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ResetPrompt"
	prompt.ActionText = "Reset Avatar"
	prompt.ObjectText = "Clothing Station"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.Parent = targetPart
	
	-- Add a Highlight so it matches our other interactive machines
	local highlight = Instance.new("Highlight")
	highlight.Name = "ResetHighlight"
	highlight.FillColor = Color3.fromRGB(0, 255, 100) -- Green for "Clean/Reset"
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.Adornee = part
	highlight.Parent = part
	
	-- Anchor EVERYTHING
	for _, p in pairs(part:GetDescendants()) do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	
	prompt.Triggered:Connect(function(player)
		self:ResetPlayer(player)
	end)
end

function ResetService:ResetPlayer(player)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	print("[Hangout cafe] Resetting " .. player.Name .. " via LoadCharacter...")
	
	-- 1. Save current position
	local currentCFrame = character:GetPivot()
	
	-- 2. Force character reload
	player:LoadCharacter()
	
	-- 3. Wait for new character and restore position
	player.CharacterAdded:Once(function(newCharacter)
		local hrp = newCharacter:WaitForChild("HumanoidRootPart", 5)
		if hrp then
			-- Wait a short moment for physics/spawn logic to settle
			task.wait(0.1)
			newCharacter:PivotTo(currentCFrame)
			
			-- Second pass to ensure it sticks
			task.wait()
			newCharacter:PivotTo(currentCFrame)
			
			print("[Hangout cafe] " .. player.Name .. "'s avatar fully restored!")
		end
	end)
end

return ResetService
