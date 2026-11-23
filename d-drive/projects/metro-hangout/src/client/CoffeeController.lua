local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local CoffeeController = {}

function CoffeeController:Initialize()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local coffeeEvent = ReplicatedStorage:WaitForChild("CoffeeEvent", 5)
	if not coffeeEvent then
		warn("[Hangout cafe] CoffeeEvent not found in ReplicatedStorage. Coffee UI disabled.")
	end
	
	-- 1. Create a Premium Metro-themed UI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CoffeeMenu"
	screenGui.Enabled = false
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 400)
	frame.Position = UDim2.new(0.5, -150, 0.5, -200)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 255, 255)
	stroke.Thickness = 2
	stroke.Parent = frame
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "HANGOUT COFFEE"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = frame
	
	-- Close Button
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -35, 0, 5)
	close.BackgroundTransparency = 1
	close.Text = "X"
	close.TextColor3 = Color3.fromRGB(255, 100, 100)
	close.Font = Enum.Font.GothamBold
	close.TextSize = 18
	close.Parent = frame
	close.MouseButton1Click:Connect(function() screenGui.Enabled = false end)
	
	-- Drink Options
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.Parent = frame
	
	-- Helper to create buttons
	local function createDrinkButton(name, displayName)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = UDim2.new(0.9, 0, 0, 60)
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
		btn.Text = displayName
		btn.TextColor3 = Color3.fromRGB(200, 200, 200)
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 16
		btn.Parent = frame
		
		Instance.new("UICorner").Parent = btn
		
		btn.MouseButton1Click:Connect(function()
			if coffeeEvent then
				coffeeEvent:FireServer("GiveDrink", name)
			end
			screenGui.Enabled = false
		end)
		
		btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(0, 255, 255); btn.TextColor3 = Color3.fromRGB(0,0,0) end)
		btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40); btn.TextColor3 = Color3.fromRGB(200, 200, 200) end)
	end
	
	-- Spacing for title
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, 0, 0, 50)
	spacer.BackgroundTransparency = 1
	spacer.Parent = frame
	
	createDrinkButton("Espresso", "Espresso (Strong & Dark)")
	createDrinkButton("Latte", "Caffè Latte (Smooth)")
	createDrinkButton("MetroSpecial", "METRO SPECIAL (Glowing)")
	
	-- 2. Open Menu Event
	if coffeeEvent then
		coffeeEvent.OnClientEvent:Connect(function(action)
			if action == "OpenMenu" then
				screenGui.Enabled = true
			end
		end)
	end

	-- 3. DRINK BUTTON UI
	-- Appears bottom-centre when player has a coffee in backpack or hand
	local COFFEE_TOOLS = { Espresso = true, Latte = true, MetroSpecial = true }

	-- Build the drink button
	local drinkGui = Instance.new("ScreenGui")
	drinkGui.Name = "DrinkGui"
	drinkGui.ResetOnSpawn = false
	drinkGui.DisplayOrder = 20
	drinkGui.Enabled = false
	drinkGui.Parent = playerGui

	local drinkBtn = Instance.new("TextButton")
	drinkBtn.Size = UDim2.new(0, 160, 0, 52)
	drinkBtn.Position = UDim2.new(0.5, -80, 1, -110)
	drinkBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	drinkBtn.Text = "☕  DRINK"
	drinkBtn.TextColor3 = Color3.fromRGB(0, 230, 255)
	drinkBtn.Font = Enum.Font.GothamBold
	drinkBtn.TextSize = 18
	drinkBtn.AutoButtonColor = false
	drinkBtn.Parent = drinkGui

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(0, 14)
	dc.Parent = drinkBtn

	local ds = Instance.new("UIStroke")
	ds.Color = Color3.fromRGB(0, 200, 255)
	ds.Thickness = 2
	ds.Parent = drinkBtn

	-- Hover effect
	drinkBtn.MouseEnter:Connect(function()
		TweenService:Create(drinkBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(0, 180, 220),
			TextColor3 = Color3.fromRGB(0, 0, 0)
		}):Play()
	end)
	drinkBtn.MouseLeave:Connect(function()
		TweenService:Create(drinkBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 30),
			TextColor3 = Color3.fromRGB(0, 230, 255)
		}):Play()
	end)

	-- Helper: check if player has a coffee
	local function hasCoffee()
		local char = player.Character
		-- Check backpack
		for _, item in pairs(player.Backpack:GetChildren()) do
			if COFFEE_TOOLS[item.Name] then return true end
		end
		-- Check character (equipped)
		if char then
			for _, item in pairs(char:GetChildren()) do
				if item:IsA("Tool") and COFFEE_TOOLS[item.Name] then return true end
			end
		end
		return false
	end

	local function updateDrinkButton()
		drinkGui.Enabled = hasCoffee()
	end

	-- Direct arm-raise animation via Motor6D joints (no asset IDs, works everywhere)
	local function playDrinkAnim(character)
		-- Try R6 first
		local torso = character:FindFirstChild("Torso")
		if torso then
			local shoulder = torso:FindFirstChild("Right Shoulder")
			if shoulder then
				local original = shoulder.C0
				-- Raise arm up like holding a cup to drink
				local raised = CFrame.new(1.5, 0.5, 0) * CFrame.fromEulerAnglesXYZ(-math.pi / 1.8, 0, -0.3)
				TweenService:Create(shoulder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { C0 = raised }):Play()
				task.wait(1.2)
				TweenService:Create(shoulder, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { C0 = original }):Play()
				return
			end
		end

		-- Try R15
		local rightUpper = character:FindFirstChild("RightUpperArm")
		if rightUpper then
			local joint = rightUpper:FindFirstChildOfClass("Motor6D")
			if joint then
				local original = joint.C0
				local raised = original * CFrame.fromEulerAnglesXYZ(-math.pi / 2, 0, 0)
				TweenService:Create(joint, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { C0 = raised }):Play()
				task.wait(1.2)
				TweenService:Create(joint, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { C0 = original }):Play()
			end
		end
	end

	-- DRINK button clicked
	drinkBtn.MouseButton1Click:Connect(function()
		if not hasCoffee() then return end

		local char = player.Character
		drinkGui.Enabled = false

		-- Play the arm-raise drink animation
		if char then
			task.spawn(function()
				playDrinkAnim(char)
			end)
		end

		-- Remove coffee from inventory after 1.2s (matches animation)
		task.wait(1.2)
		if coffeeEvent then
			coffeeEvent:FireServer("DrinkCoffee")
		end
	end)

	-- Watch backpack and character for coffee tools
	local function watchInventory()
		player.Backpack.ChildAdded:Connect(updateDrinkButton)
		player.Backpack.ChildRemoved:Connect(updateDrinkButton)
	end

	player.CharacterAdded:Connect(function(char)
		drinkGui.Enabled = false
		watchInventory()
		char.ChildAdded:Connect(updateDrinkButton)
		char.ChildRemoved:Connect(updateDrinkButton)
	end)

	watchInventory()
	if player.Character then
		player.Character.ChildAdded:Connect(updateDrinkButton)
		player.Character.ChildRemoved:Connect(updateDrinkButton)
	end
end

return CoffeeController
