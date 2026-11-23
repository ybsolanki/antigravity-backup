local ResetService = {} -- Logic placeholder to avoid errors if referenced before require

local SignService = {}

function SignService:Initialize()
	-- Listen for new parts being added
	workspace.DescendantAdded:Connect(function(descendant)
		local name = descendant.Name
		if string.match(name, "^SignBoard") or string.match(name, "^Sign") then
			self:SetupSign(descendant)
		end
	end)
	
	-- Setup existing parts
	for _, descendant in pairs(workspace:GetDescendants()) do
		local name = descendant.Name
		if string.match(name, "^SignBoard") or string.match(name, "^Sign") then
			self:SetupSign(descendant)
		end
	end
	
	print("[Hangout cafe] SignService Initialized")
end

function SignService:SetupSign(part)
	-- 1. Try to find where the original text was located
	local targetPart = nil
	local targetFace = Enum.NormalId.Front
	local extractedText = nil
	
	-- Look through all descendants for existing GUIs or Text
	for _, child in pairs(part:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextBox") then
			if child.Text ~= "" and child.Text ~= "Label" and child.Text ~= "Text" then
				extractedText = child.Text
			end
			
			-- If this label is inside a SurfaceGui, that's our target!
			local pgui = child:FindFirstAncestorWhichIsA("SurfaceGui")
			if pgui and pgui.Adornee then
				targetPart = pgui.Adornee
				targetFace = pgui.Face
			elseif pgui and pgui.Parent:IsA("BasePart") then
				targetPart = pgui.Parent
				targetFace = pgui.Face
			end
		end
	end
	
	-- 2. Fallback: If no GUI found, find the largest part
	if not targetPart then
		if part:IsA("BasePart") then
			targetPart = part
		else
			local largestSize = 0
			for _, p in pairs(part:GetDescendants()) do
				if p:IsA("BasePart") then
					local vol = p.Size.X * p.Size.Y * p.Size.Z
					if vol > largestSize then
						largestSize = vol
						targetPart = p
					end
				end
			end
		end
	end
	
	if not targetPart then return end
	
	-- 3. Clean up legacy GUIs
	for _, child in pairs(part:GetDescendants()) do
		if child:IsA("SurfaceGui") or child:IsA("BillboardGui") then
			child:Destroy()
		end
	end
	
	if targetPart:FindFirstChild("SignGui") then return end
	
	-- Use extracted text if no destination attribute exists
	if extractedText and not part:GetAttribute("Destination") then
		part:SetAttribute("Destination", extractedText)
	end
	
	-- 4. Create the HIGH-QUALITY UI
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = targetFace
	gui.LightInfluence = 0
	gui.Brightness = 3 -- Balanced for readability
	gui.PixelsPerStud = 100 -- Sharper text
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = targetPart
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundTransparency = 1 -- Keep it clean
	frame.Parent = gui
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 0.9)
	textLabel.Position = UDim2.fromScale(0, 0.05)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextScaled = true
	textLabel.RichText = true
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Parent = frame
	
	local function updateText()
		local dest = part:GetAttribute("Destination")
		if not dest or dest == "" then
			local nameParts = string.split(part.Name, "_")
			dest = nameParts[2] or "LOCATION"
		end
		
		textLabel.Text = "<b>WAY TO</b>\n" .. string.upper(dest)
		
		local lowerDest = string.lower(dest)
		if string.find(lowerDest, "cafe") then
			textLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
		elseif string.find(lowerDest, "park") then
			textLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
		elseif string.find(lowerDest, "arcade") then
			textLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
		else
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	
	part:GetAttributeChangedSignal("Destination"):Connect(updateText)
	updateText()
	
	-- 5. Final Polishing
	targetPart.Material = Enum.Material.SmoothPlastic
	targetPart.Color = Color3.fromRGB(20, 20, 25) -- Deep Dark Grey
	
	-- Anchor EVERYTHING
	if part:IsA("BasePart") then part.Anchored = true end
	for _, p in pairs(part:GetDescendants()) do
		if p:IsA("BasePart") then p.Anchored = true end
	end
end

return SignService
