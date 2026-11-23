-- AdminController.lua
-- Sleek, premium Admin Dashboard for whitelisted admins.
-- Programmatically builds a gorgeous glassmorphism UI with Players, World, and Prank administration tools.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AdminController = {}
AdminController.__index = AdminController

function AdminController.new()
	return setmetatable({}, AdminController)
end

-- Flying physics state variables
local flying = false
local flySpeed = 60
local bodyVelocity = nil
local bodyGyro = nil
local flyConnection = nil
local speedBoostActive = false

-- Function to stop client-side flying
local function stopFlying()
	flying = false
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
	
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

-- Function to start client-side flying
local function startFlying()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum then return end
	
	stopFlying() -- reset just in case
	
	flying = true
	hum.PlatformStand = true
	
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = hrp
	
	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.CFrame = hrp.CFrame
	bodyGyro.Parent = hrp
	
	local camera = workspace.CurrentCamera
	
	flyConnection = RunService.RenderStepped:Connect(function()
		local curChar = player.Character
		local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
		local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
		
		if not flying or not curChar or not curHrp or not curHum or curHum.Health <= 0 then
			stopFlying()
			return
		end
		
		-- Direct body gyro to follow camera rotation
		bodyGyro.CFrame = camera.CFrame
		
		-- Movement vector
		local moveDir = Vector3.new(0, 0, 0)
		
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDir = moveDir + camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDir = moveDir - camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDir = moveDir - camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDir = moveDir + camera.CFrame.RightVector
		end
		
		-- Ascent / Descent
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDir = moveDir + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDir = moveDir - Vector3.new(0, 1, 0)
		end
		
		if moveDir.Magnitude > 0 then
			bodyVelocity.Velocity = moveDir.Unit * flySpeed
		else
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

-- Toggle flying mode
local function toggleFly()
	if flying then
		stopFlying()
	else
		startFlying()
	end
	return flying
end

function AdminController:Initialize()
	print("[Hangout cafe] AdminController: Checking admin status...")
	
	-- Wait for RemoteFunction
	local adminCheck = ReplicatedStorage:WaitForChild("AdminCheck", 10)
	if not adminCheck then
		warn("[Hangout cafe] AdminCheck RemoteFunction not found!")
		return
	end
	
	-- Verify if player is admin
	local success, isAdmin = pcall(function()
		return adminCheck:InvokeServer()
	end)
	
	if not success or not isAdmin then
		print("[Hangout cafe] Admin status check failed or returned false. Dashboard disabled.")
		return
	end
	
	print("[Hangout cafe] Admin status verified! Building Admin Panel...")
	
	-- Clean up old GUI if exists
	local old = playerGui:FindFirstChild("AdminGui")
	if old then old:Destroy() end
	
	-- Clean up fly on death
	player.CharacterAdded:Connect(function()
		stopFlying()
		speedBoostActive = false
	end)
	
	-- ──────────────────────────────────────────────
	-- 1. ScreenGui
	-- ──────────────────────────────────────────────
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AdminGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 15
	screenGui.Parent = playerGui
	
	-- RemoteEvent for server commands
	local adminEvent = ReplicatedStorage:WaitForChild("AdminEvent", 5)
	if not adminEvent then
		warn("[Hangout cafe] AdminEvent RemoteEvent not found! Commands will not work.")
		return
	end
	
	-- ──────────────────────────────────────────────
	-- 2. Floating Toggle Button (🔧 ADMIN)
	-- ──────────────────────────────────────────────
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 110, 0, 44)
	toggleBtn.Position = UDim2.new(0, 20, 0.4, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	toggleBtn.BackgroundTransparency = 0.2
	toggleBtn.Text = "🔧 ADMIN"
	toggleBtn.Font = Enum.Font.MontserratBold
	toggleBtn.TextSize = 13
	toggleBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	
	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleBtn
	
	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = Color3.fromRGB(110, 100, 140)
	toggleStroke.Thickness = 1.5
	toggleStroke.Parent = toggleBtn
	
	-- ──────────────────────────────────────────────
	-- 3. Main Admin Panel Frame
	-- ──────────────────────────────────────────────
	local panelWidth = 560
	local panelHeight = 540 -- Expanded height to support car spawn actions
	
	local panel = Instance.new("Frame")
	panel.Name = "AdminPanel"
	panel.Size = UDim2.new(0, panelWidth, 0, panelHeight)
	panel.Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
	panel.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	panel.BackgroundTransparency = 0.15
	panel.Visible = false
	panel.ClipsDescendants = false
	panel.Parent = screenGui
	
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 16)
	panelCorner.Parent = panel
	
	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(80, 75, 100)
	panelStroke.Thickness = 1.5
	panelStroke.Parent = panel
	
	-- Header Bar for dragging
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 45)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundTransparency = 1
	header.Text = "ADMIN CONTROL PANEL"
	header.TextSize = 15
	header.Font = Enum.Font.MontserratBold
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Parent = panel
	
	-- Dragging Logic
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(startPos.Width.Scale, startPos.Width.Offset + delta.X, startPos.Height.Scale, startPos.Height.Offset + delta.Y)
	end
	
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = panel.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	
	-- Close Button (X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.Position = UDim2.new(1, -36, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(30, 26, 36)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.MontserratBold
	closeBtn.TextSize = 12
	closeBtn.TextColor3 = Color3.fromRGB(220, 210, 230)
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = panel
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(150, 40, 40), TextColor3 = Color3.new(1, 1, 1) }):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(30, 26, 36), TextColor3 = Color3.fromRGB(220, 210, 230) }):Play()
	end)
	
	local function togglePanel()
		panel.Visible = not panel.Visible
		if panel.Visible then
			panel.Size = UDim2.new(0, 0, 0, 0)
			panel.Position = UDim2.new(0.5, 0, 0.5, 0)
			TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, panelWidth, 0, panelHeight),
				Position = UDim2.new(0.5, -panelWidth/2, 0.5, -panelHeight/2)
			}):Play()
		end
	end
	
	closeBtn.MouseButton1Click:Connect(togglePanel)
	toggleBtn.MouseButton1Click:Connect(togglePanel)
	
	-- Divider Line
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -30, 0, 1)
	divider.Position = UDim2.new(0, 15, 0, 45)
	divider.BackgroundColor3 = Color3.fromRGB(50, 45, 60)
	divider.BorderSizePixel = 0
	divider.Parent = panel
	
	-- ──────────────────────────────────────────────
	-- 4. Left Column: Players List
	-- ──────────────────────────────────────────────
	local leftCol = Instance.new("Frame")
	leftCol.Name = "LeftColumn"
	leftCol.Size = UDim2.new(0.38, 0, 0.82, 0)
	leftCol.Position = UDim2.new(0.03, 0, 0.14, 0)
	leftCol.BackgroundTransparency = 1
	leftCol.Parent = panel
	
	local playerHeader = Instance.new("TextLabel")
	playerHeader.Size = UDim2.new(1, 0, 0, 20)
	playerHeader.BackgroundTransparency = 1
	playerHeader.Text = "PLAYERS"
	playerHeader.TextSize = 12
	playerHeader.Font = Enum.Font.MontserratBold
	playerHeader.TextColor3 = Color3.fromRGB(150, 145, 170)
	playerHeader.TextXAlignment = Enum.TextXAlignment.Left
	playerHeader.Parent = leftCol
	
	local playerScroll = Instance.new("ScrollingFrame")
	playerScroll.Name = "PlayerScroll"
	playerScroll.Size = UDim2.new(1, 0, 1, -25)
	playerScroll.Position = UDim2.new(0, 0, 0, 25)
	playerScroll.BackgroundTransparency = 1
	playerScroll.ScrollBarThickness = 4
	playerScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 65, 85)
	playerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	playerScroll.Parent = leftCol
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 5)
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Parent = playerScroll
	
	-- ──────────────────────────────────────────────
	-- 5. Right Column: Command Controls
	-- ──────────────────────────────────────────────
	local rightCol = Instance.new("Frame")
	rightCol.Name = "RightColumn"
	rightCol.Size = UDim2.new(0.53, 0, 0.82, 0)
	rightCol.Position = UDim2.new(0.44, 0, 0.14, 0)
	rightCol.BackgroundTransparency = 1
	rightCol.Parent = panel
	
	-- Target Status Header
	local targetHeader = Instance.new("TextLabel")
	targetHeader.Size = UDim2.new(1, 0, 0, 20)
	targetHeader.BackgroundTransparency = 1
	targetHeader.Text = "SELECT A PLAYER"
	targetHeader.TextSize = 12
	targetHeader.Font = Enum.Font.MontserratBold
	targetHeader.TextColor3 = Color3.fromRGB(150, 145, 170)
	targetHeader.TextXAlignment = Enum.TextXAlignment.Left
	targetHeader.Parent = rightCol
	
	-- Empty state helper label when no player selected
	local noTargetLabel = Instance.new("TextLabel")
	noTargetLabel.Size = UDim2.new(1, 0, 0.4, 0)
	noTargetLabel.Position = UDim2.new(0, 0, 0.15, 0)
	noTargetLabel.BackgroundTransparency = 1
	noTargetLabel.Text = "Click a player in the list\nto enable admin & prank actions."
	noTargetLabel.TextSize = 13
	noTargetLabel.Font = Enum.Font.Montserrat
	noTargetLabel.TextColor3 = Color3.fromRGB(110, 105, 125)
	noTargetLabel.Parent = rightCol
	
	-- Group frame for player controls
	local pControlFrame = Instance.new("Frame")
	pControlFrame.Name = "PlayerControls"
	pControlFrame.Size = UDim2.new(1, 0, 0.54, 0)
	pControlFrame.Position = UDim2.new(0, 0, 0.08, 0)
	pControlFrame.BackgroundTransparency = 1
	pControlFrame.Visible = false
	pControlFrame.Parent = rightCol
	
	-- Helper function to style buttons
	local function styleBtn(btn, normalColor, hoverColor)
		btn.BackgroundColor3 = normalColor
		btn.AutoButtonColor = false
		btn.Font = Enum.Font.MontserratBold
		btn.TextSize = 11
		btn.TextColor3 = Color3.fromRGB(245, 245, 250)
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = btn
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(70, 70, 85)
		stroke.Thickness = 1
		stroke.Parent = btn
		
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = hoverColor }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(120, 120, 140) }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = normalColor }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 85) }):Play()
		end)
	end
	
	-- Action row 1: Kick & Heal
	local kickBtn = Instance.new("TextButton")
	kickBtn.Name = "KickBtn"
	kickBtn.Size = UDim2.new(0.48, 0, 0, 32)
	kickBtn.Position = UDim2.new(0, 0, 0, 0)
	kickBtn.Text = "KICK"
	styleBtn(kickBtn, Color3.fromRGB(150, 40, 40), Color3.fromRGB(190, 50, 50))
	kickBtn.Parent = pControlFrame
	
	local healBtn = Instance.new("TextButton")
	healBtn.Name = "HealBtn"
	healBtn.Size = UDim2.new(0.48, 0, 0, 32)
	healBtn.Position = UDim2.new(0.52, 0, 0, 0)
	healBtn.Text = "HEAL"
	styleBtn(healBtn, Color3.fromRGB(35, 120, 65), Color3.fromRGB(45, 150, 80))
	healBtn.Parent = pControlFrame
	
	-- Action row 2: Teleport Goto & Bring
	local gotoBtn = Instance.new("TextButton")
	gotoBtn.Name = "GotoBtn"
	gotoBtn.Size = UDim2.new(0.48, 0, 0, 32)
	gotoBtn.Position = UDim2.new(0, 0, 0, 38)
	gotoBtn.Text = "TELEPORT TO"
	styleBtn(gotoBtn, Color3.fromRGB(40, 45, 60), Color3.fromRGB(55, 65, 85))
	gotoBtn.Parent = pControlFrame
	
	local bringBtn = Instance.new("TextButton")
	bringBtn.Name = "BringBtn"
	bringBtn.Size = UDim2.new(0.48, 0, 0, 32)
	bringBtn.Position = UDim2.new(0.52, 0, 0, 38)
	bringBtn.Text = "BRING ME"
	styleBtn(bringBtn, Color3.fromRGB(40, 45, 60), Color3.fromRGB(55, 65, 85))
	bringBtn.Parent = pControlFrame
	
	-- Action row 3: WalkSpeed Quick selections
	local speedLabel = Instance.new("TextLabel")
	speedLabel.Size = UDim2.new(1, 0, 0, 15)
	speedLabel.Position = UDim2.new(0, 0, 0, 76)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Text = "WALKSPEED SETTINGS"
	speedLabel.TextSize = 9
	speedLabel.Font = Enum.Font.MontserratBold
	speedLabel.TextColor3 = Color3.fromRGB(120, 115, 135)
	speedLabel.TextXAlignment = Enum.TextXAlignment.Left
	speedLabel.Parent = pControlFrame
	
	local speedGrid = Instance.new("Frame")
	speedGrid.Size = UDim2.new(1, 0, 0, 28)
	speedGrid.Position = UDim2.new(0, 0, 0, 94)
	speedGrid.BackgroundTransparency = 1
	speedGrid.Parent = pControlFrame
	
	local speedLayout = Instance.new("UIListLayout")
	speedLayout.FillDirection = Enum.FillDirection.Horizontal
	speedLayout.Padding = UDim.new(0, 6)
	speedLayout.Parent = speedGrid
	
	local speedOptions = {
		{ name = "DEFAULT (16)", val = 16 },
		{ name = "FAST (35)", val = 35 },
		{ name = "SUPER (80)", val = 80 }
	}
	
	for _, opt in ipairs(speedOptions) do
		local sBtn = Instance.new("TextButton")
		sBtn.Name = "Speed_" .. tostring(opt.val)
		sBtn.Size = UDim2.new(0.31, 0, 1, 0)
		sBtn.Text = opt.name
		styleBtn(sBtn, Color3.fromRGB(35, 35, 45), Color3.fromRGB(55, 55, 70))
		sBtn.Parent = speedGrid
		
		sBtn.MouseButton1Click:Connect(function()
			local targetPlayerName = string.match(targetHeader.Text, "MANAGING: (.+)")
			if targetPlayerName then
				adminEvent:FireServer("Speed", targetPlayerName, opt.val)
			end
		end)
	end
	
	-- Action row 4: Prank Section Header
	local prankLabel = Instance.new("TextLabel")
	prankLabel.Size = UDim2.new(1, 0, 0, 15)
	prankLabel.Position = UDim2.new(0, 0, 0, 128)
	prankLabel.BackgroundTransparency = 1
	prankLabel.Text = "ADMIN PRANKS"
	prankLabel.TextSize = 9
	prankLabel.Font = Enum.Font.MontserratBold
	prankLabel.TextColor3 = Color3.fromRGB(120, 115, 135)
	prankLabel.TextXAlignment = Enum.TextXAlignment.Left
	prankLabel.Parent = pControlFrame
	
	-- Action row 5: Slap & Rope
	local slapBtn = Instance.new("TextButton")
	slapBtn.Name = "SlapBtn"
	slapBtn.Size = UDim2.new(0.48, 0, 0, 32)
	slapBtn.Position = UDim2.new(0, 0, 0, 146)
	slapBtn.Text = "💥 GIVE SLAP"
	styleBtn(slapBtn, Color3.fromRGB(80, 40, 100), Color3.fromRGB(105, 50, 130))
	slapBtn.Parent = pControlFrame
	
	local ropeBtn = Instance.new("TextButton")
	ropeBtn.Name = "RopeBtn"
	ropeBtn.Size = UDim2.new(0.48, 0, 0, 32)
	ropeBtn.Position = UDim2.new(0.52, 0, 0, 146)
	ropeBtn.Text = "🎗️ GIVE ROPE"
	styleBtn(ropeBtn, Color3.fromRGB(80, 40, 100), Color3.fromRGB(105, 50, 130))
	ropeBtn.Parent = pControlFrame
	
	-- Action row 6: Morph & Give Gun
	local morphBtn = Instance.new("TextButton")
	morphBtn.Name = "MorphBtn"
	morphBtn.Size = UDim2.new(0.48, 0, 0, 32)
	morphBtn.Position = UDim2.new(0, 0, 0, 184)
	morphBtn.Text = "👥 COPY AVATAR"
	styleBtn(morphBtn, Color3.fromRGB(80, 40, 100), Color3.fromRGB(105, 50, 130))
	morphBtn.Parent = pControlFrame
	
	local gunBtn = Instance.new("TextButton")
	gunBtn.Name = "GunBtn"
	gunBtn.Size = UDim2.new(0.48, 0, 0, 32)
	gunBtn.Position = UDim2.new(0.52, 0, 0, 184)
	gunBtn.Text = "🔫 GIVE HAND GUN"
	styleBtn(gunBtn, Color3.fromRGB(80, 40, 100), Color3.fromRGB(105, 50, 130))
	gunBtn.Parent = pControlFrame
	
	-- Action row 7: Give Gold Chain Guns (Toolbox insertion)
	local goldGunBtn = Instance.new("TextButton")
	goldGunBtn.Name = "GoldGunBtn"
	goldGunBtn.Size = UDim2.new(1, 0, 0, 32)
	goldGunBtn.Position = UDim2.new(0, 0, 0, 222)
	goldGunBtn.Text = "🔱 GIVE GOLD CHAIN GUNS"
	styleBtn(goldGunBtn, Color3.fromRGB(150, 110, 30), Color3.fromRGB(190, 140, 40))
	goldGunBtn.Parent = pControlFrame
	
	-- Action row 8: Spawn Admin Car
	local carBtn = Instance.new("TextButton")
	carBtn.Name = "CarBtn"
	carBtn.Size = UDim2.new(1, 0, 0, 32)
	carBtn.Position = UDim2.new(0, 0, 0, 260)
	carBtn.Text = "🏎️ SPAWN CAR FOR PLAYER"
	styleBtn(carBtn, Color3.fromRGB(20, 110, 160), Color3.fromRGB(30, 140, 200))
	carBtn.Parent = pControlFrame
	
	carBtn.MouseButton1Click:Connect(function()
		local targetPlayerName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetPlayerName then
			adminEvent:FireServer("SpawnCar", targetPlayerName)
		end
	end)
	
	-- Separator (shifted down)
	local hSep = Instance.new("Frame")
	hSep.Size = UDim2.new(1, 0, 0, 1)
	hSep.Position = UDim2.new(0, 0, 0, 298)
	hSep.BackgroundColor3 = Color3.fromRGB(45, 40, 55)
	hSep.BorderSizePixel = 0
	hSep.Parent = rightCol
	
	-- ──────────────────────────────────────────────
	-- 6. World & Self Actions section (shifted down)
	-- ──────────────────────────────────────────────
	local worldFrame = Instance.new("Frame")
	worldFrame.Name = "WorldControls"
	worldFrame.Size = UDim2.new(1, 0, 0.40, 0)
	worldFrame.Position = UDim2.new(0, 0, 0, 304)
	worldFrame.BackgroundTransparency = 1
	worldFrame.Parent = rightCol
	
	local worldLabel = Instance.new("TextLabel")
	worldLabel.Size = UDim2.new(1, 0, 0, 20)
	worldLabel.BackgroundTransparency = 1
	worldLabel.Text = "WORLD & SELF ACTIONS"
	worldLabel.TextSize = 10
	worldLabel.Font = Enum.Font.MontserratBold
	worldLabel.TextColor3 = Color3.fromRGB(150, 145, 170)
	worldLabel.TextXAlignment = Enum.TextXAlignment.Left
	worldLabel.Parent = worldFrame
	
	-- World Time Grid
	local timeGrid = Instance.new("Frame")
	timeGrid.Size = UDim2.new(1, 0, 0, 32)
	timeGrid.Position = UDim2.new(0, 0, 0, 22)
	timeGrid.BackgroundTransparency = 1
	timeGrid.Parent = worldFrame
	
	local timeLayout = Instance.new("UIListLayout")
	timeLayout.FillDirection = Enum.FillDirection.Horizontal
	timeLayout.Padding = UDim.new(0, 6)
	timeLayout.Parent = timeGrid
	
	local timeOptions = {
		{ name = "☀️ DAY", time = 12 },
		{ name = "🌅 SUNSET", time = 18 },
		{ name = "🌙 NIGHT", time = 0 }
	}
	
	for _, opt in ipairs(timeOptions) do
		local tBtn = Instance.new("TextButton")
		tBtn.Name = "Time_" .. tostring(opt.time)
		tBtn.Size = UDim2.new(0.31, 0, 1, 0)
		tBtn.Text = opt.name
		styleBtn(tBtn, Color3.fromRGB(30, 30, 42), Color3.fromRGB(45, 45, 65))
		tBtn.Parent = timeGrid
		
		tBtn.MouseButton1Click:Connect(function()
			adminEvent:FireServer("TimeOfDay", "", opt.time)
		end)
	end
	
	-- Self Grid (Fly & Speed Boost)
	local selfGrid = Instance.new("Frame")
	selfGrid.Size = UDim2.new(1, 0, 0, 32)
	selfGrid.Position = UDim2.new(0, 0, 0, 60)
	selfGrid.BackgroundTransparency = 1
	selfGrid.Parent = worldFrame
	
	local selfLayout = Instance.new("UIListLayout")
	selfLayout.FillDirection = Enum.FillDirection.Horizontal
	selfLayout.Padding = UDim.new(0, 8)
	selfLayout.Parent = selfGrid
	
	-- Fly Button
	local flyBtn = Instance.new("TextButton")
	flyBtn.Name = "FlyBtn"
	flyBtn.Size = UDim2.new(0.48, 0, 1, 0)
	flyBtn.Text = "🚀 FLY MODE: OFF"
	styleBtn(flyBtn, Color3.fromRGB(40, 50, 45), Color3.fromRGB(55, 70, 60))
	flyBtn.Parent = selfGrid
	
	flyBtn.MouseButton1Click:Connect(function()
		local isFlying = toggleFly()
		if isFlying then
			flyBtn.Text = "🚀 FLY MODE: ON"
			TweenService:Create(flyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(35, 120, 65) }):Play()
		else
			flyBtn.Text = "🚀 FLY MODE: OFF"
			TweenService:Create(flyBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 50, 45) }):Play()
		end
	end)
	
	-- Speed Boost Button
	local speedBoostBtn = Instance.new("TextButton")
	speedBoostBtn.Name = "SpeedBoostBtn"
	speedBoostBtn.Size = UDim2.new(0.48, 0, 1, 0)
	speedBoostBtn.Text = "⚡ SPEED BOOST: OFF"
	styleBtn(speedBoostBtn, Color3.fromRGB(40, 50, 45), Color3.fromRGB(55, 70, 60))
	speedBoostBtn.Parent = selfGrid
	
	speedBoostBtn.MouseButton1Click:Connect(function()
		speedBoostActive = not speedBoostActive
		if speedBoostActive then
			speedBoostBtn.Text = "⚡ SPEED BOOST: ON"
			TweenService:Create(speedBoostBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(35, 120, 65) }):Play()
			-- Fire server speed setting on self
			adminEvent:FireServer("Speed", player.Name, 100)
		else
			speedBoostBtn.Text = "⚡ SPEED BOOST: OFF"
			TweenService:Create(speedBoostBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(40, 50, 45) }):Play()
			adminEvent:FireServer("Speed", player.Name, 16)
		end
	end)
	
	-- Self Action: Spawn My Admin Car
	local myCarBtn = Instance.new("TextButton")
	myCarBtn.Name = "MyCarBtn"
	myCarBtn.Size = UDim2.new(1, 0, 0, 32)
	myCarBtn.Position = UDim2.new(0, 0, 0, 98)
	myCarBtn.Text = "🏎️ SPAWN MY ADMIN CAR"
	styleBtn(myCarBtn, Color3.fromRGB(20, 110, 160), Color3.fromRGB(30, 140, 200))
	myCarBtn.Parent = worldFrame
	
	myCarBtn.MouseButton1Click:Connect(function()
		adminEvent:FireServer("SpawnCar", player.Name)
	end)
	
	-- ──────────────────────────────────────────────
	-- 7. Dynamic Player Selection
	-- ──────────────────────────────────────────────
	local selectedPlayerButton = nil
	
	local function selectPlayer(playerObj, btn)
		-- Unhighlight previous
		if selectedPlayerButton and selectedPlayerButton:FindFirstChild("UIStroke") then
			selectedPlayerButton.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			selectedPlayerButton.UIStroke.Color = Color3.fromRGB(50, 45, 60)
		end
		
		selectedPlayerButton = btn
		selectedPlayerButton.BackgroundColor3 = Color3.fromRGB(60, 45, 95)
		selectedPlayerButton.UIStroke.Color = Color3.fromRGB(120, 90, 200)
		
		-- Update panel
		targetHeader.Text = "MANAGING: " .. playerObj.Name
		noTargetLabel.Visible = false
		pControlFrame.Visible = true
	end
	
	local function updatePlayerList()
		-- Clear old buttons
		for _, child in ipairs(playerScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		
		selectedPlayerButton = nil
		targetHeader.Text = "SELECT A PLAYER"
		noTargetLabel.Visible = true
		pControlFrame.Visible = false
		
		-- Build list
		for _, p in ipairs(Players:GetPlayers()) do
			local btn = Instance.new("TextButton")
			btn.Name = p.Name
			btn.Size = UDim2.new(1, -8, 0, 34)
			btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
			btn.Text = ""
			btn.AutoButtonColor = false
			btn.Parent = playerScroll
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = btn
			
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(50, 45, 60)
			stroke.Thickness = 1
			stroke.Parent = btn
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -20, 1, 0)
			label.Position = UDim2.new(0, 10, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = p.Name
			label.TextSize = 12
			label.Font = Enum.Font.MontserratBold
			label.TextColor3 = Color3.fromRGB(230, 225, 240)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = btn
			
			-- Hover effects
			btn.MouseEnter:Connect(function()
				if selectedPlayerButton ~= btn then
					TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 45) }):Play()
				end
			end)
			btn.MouseLeave:Connect(function()
				if selectedPlayerButton ~= btn then
					TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(24, 24, 30) }):Play()
				end
			end)
			
			btn.MouseButton1Click:Connect(function()
				selectPlayer(p, btn)
			end)
		end
	end
	
	-- Connect list updating events
	Players.PlayerAdded:Connect(updatePlayerList)
	Players.PlayerRemoving:Connect(updatePlayerList)
	updatePlayerList()
	
	-- ──────────────────────────────────────────────
	-- 8. Hook Actions to Buttons
	-- ──────────────────────────────────────────────
	kickBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("Kick", targetName)
		end
	end)
	
	healBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("Heal", targetName)
		end
	end)
	
	gotoBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("Teleport", targetName, "ToPlayer")
		end
	end)
	
	bringBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("Teleport", targetName, "ToMe")
		end
	end)
	
	slapBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("GiveSlap", targetName)
		end
	end)
	
	ropeBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("GiveRope", targetName)
		end
	end)
	
	morphBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("Morph", targetName)
		end
	end)
	
	gunBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("GiveGun", targetName)
		end
	end)
	
	goldGunBtn.MouseButton1Click:Connect(function()
		local targetName = string.match(targetHeader.Text, "MANAGING: (.+)")
		if targetName then
			adminEvent:FireServer("GiveGoldGun", targetName)
		end
	end)
	
	-- Toggle button hover styling
	toggleBtn.MouseEnter:Connect(function()
		TweenService:Create(toggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(35, 30, 50) }):Play()
		TweenService:Create(toggleStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(150, 130, 200) }):Play()
	end)
	toggleBtn.MouseLeave:Connect(function()
		TweenService:Create(toggleBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(22, 22, 28) }):Play()
		TweenService:Create(toggleStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(110, 100, 140) }):Play()
	end)
end

return AdminController
