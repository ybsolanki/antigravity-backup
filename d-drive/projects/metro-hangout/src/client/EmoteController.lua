-- EmoteController.lua
-- Sleek, premium Expressions / Emote menu with a sliding drawer UI.
-- Uses local character animations to bypass Roblox catalog permission restrictions.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ──────────────────────────────────────────────
-- Emote Definitions (Linked to character's local Animate folders)
-- ──────────────────────────────────────────────
local EMOTES = {
	{ name = "DANCE 1",  folder = "dance" },
	{ name = "DANCE 2",  folder = "dance2" },
	{ name = "DANCE 3",  folder = "dance3" },
	{ name = "WAVE",     folder = "wave" },
	{ name = "CHEER",    folder = "cheer" },
	{ name = "POINT",    folder = "point" },
	{ name = "LAUGH",    folder = "laugh" },
}

local EmoteController = {}
EmoteController.__index = EmoteController

function EmoteController.new()
	return setmetatable({}, EmoteController)
end

-- Track active animation
local currentTrack = nil

local function stopCurrent()
	if currentTrack then
		pcall(function()
			if currentTrack.IsPlaying then
				currentTrack:Stop()
			end
			currentTrack:Destroy()
		end)
		currentTrack = nil
	end
end

-- Plays animations directly from the character rig's local Animate folder
local function playLocalEmote(folderName)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local animate = character:FindFirstChild("Animate")
	if not animate then return end

	local folder = animate:FindFirstChild(folderName)
	local anim = folder and folder:FindFirstChildOfClass("Animation")
	if not anim then
		warn("[Hangout cafe] Could not find local animation for: " .. folderName)
		return
	end

	stopCurrent()

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local success, track = pcall(function()
		return animator:LoadAnimation(anim)
	end)
	
	if success and track then
		track:Play()
		currentTrack = track
	else
		warn("[Hangout cafe] Failed to load local animation: " .. folderName)
	end
end

function EmoteController:Initialize()
	-- Clean up old GUI if exists
	local old = playerGui:FindFirstChild("EmoteGui")
	if old then old:Destroy() end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EmoteGui"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 10
	screenGui.Parent = playerGui

	-- ── 1. Toggle Button (Sleek text capsule button) ──
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 80, 0, 44)
	toggleBtn.Position = UDim2.new(1, -100, 0.5, 100) -- Clean right side placement
	toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 25, 45)
	toggleBtn.Text = "EMOTES"
	toggleBtn.Font = Enum.Font.MontserratBold
	toggleBtn.TextSize = 12
	toggleBtn.TextColor3 = Color3.fromRGB(245, 240, 255)
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 12)
	toggleCorner.Parent = toggleBtn

	local toggleStroke = Instance.new("UIStroke")
	toggleStroke.Color = Color3.fromRGB(90, 80, 130)
	toggleStroke.Thickness = 1.5
	toggleStroke.Parent = toggleBtn

	-- ── 2. Sliding Emotes Drawer ──
	local drawerWidth = 260
	local drawerHeight = 350
	
	local panel = Instance.new("Frame")
	panel.Name = "EmotePanel"
	panel.Size = UDim2.new(0, drawerWidth, 0, drawerHeight)
	-- Start offscreen (right side)
	panel.Position = UDim2.new(1, 20, 0.5, -drawerHeight/2)
	panel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
	panel.BackgroundTransparency = 0.2
	panel.Parent = screenGui

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 16)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Color3.fromRGB(75, 70, 100)
	panelStroke.Thickness = 1.5
	panelStroke.Parent = panel

	-- ── Header ──
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 40)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundTransparency = 1
	header.Text = "EXPRESSIONS"
	header.TextSize = 14
	header.Font = Enum.Font.MontserratBold
	header.TextColor3 = Color3.fromRGB(255, 255, 255)
	header.Parent = panel

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -20, 0, 1)
	divider.Position = UDim2.new(0, 10, 0, 40)
	divider.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
	divider.BorderSizePixel = 0
	divider.Parent = panel

	-- ── Scrolling Frame for Emote Buttons ──
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -20, 1, -110) -- Space for header and stop button
	scrollFrame.Position = UDim2.new(0, 10, 0, 50)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 75, 105)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Auto-calculated by list/grid layout
	scrollFrame.Parent = panel

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 110, 0, 50)
	gridLayout.CellPadding = UDim2.new(0, 12, 0, 12)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = scrollFrame

	-- Adjust ScrollingFrame CanvasSize automatically based on contents
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

	-- Create emote buttons
	for idx, emote in ipairs(EMOTES) do
		local btn = Instance.new("TextButton")
		btn.Name = emote.name
		btn.Size = UDim2.new(0, 110, 0, 50)
		btn.BackgroundColor3 = Color3.fromRGB(28, 25, 40)
		btn.BackgroundTransparency = 0.3
		btn.Text = "" -- Empty to use custom layout
		btn.AutoButtonColor = false
		btn.LayoutOrder = idx
		btn.Parent = scrollFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 12)
		btnCorner.Parent = btn

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromRGB(60, 55, 80)
		btnStroke.Thickness = 1
		btnStroke.Parent = btn

		-- Emote Name Label
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = emote.name
		nameLabel.TextSize = 11
		nameLabel.Font = Enum.Font.MontserratBold
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		nameLabel.Parent = btn

		-- Hover effects
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 45, 100),
				BackgroundTransparency = 0.1
			}):Play()
			TweenService:Create(btnStroke, TweenInfo.new(0.2), {
				Color = Color3.fromRGB(130, 110, 200)
			}):Play()
			TweenService:Create(nameLabel, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(255, 255, 255)
			}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(28, 25, 40),
				BackgroundTransparency = 0.3
			}):Play()
			TweenService:Create(btnStroke, TweenInfo.new(0.2), {
				Color = Color3.fromRGB(60, 55, 80)
			}):Play()
			TweenService:Create(nameLabel, TweenInfo.new(0.2), {
				TextColor3 = Color3.fromRGB(200, 200, 220)
			}):Play()
		end)

		-- Play emote on click
		btn.MouseButton1Click:Connect(function()
			playLocalEmote(emote.folder)
		end)
	end

	-- ── 3. Stop Emote Button (at the bottom of the drawer) ──
	local stopBtn = Instance.new("TextButton")
	stopBtn.Name = "StopBtn"
	stopBtn.Size = UDim2.new(1, -20, 0, 42)
	stopBtn.Position = UDim2.new(0, 10, 1, -52)
	stopBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
	stopBtn.Text = "STOP EMOTE"
	stopBtn.Font = Enum.Font.MontserratBold
	stopBtn.TextSize = 13
	stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	stopBtn.AutoButtonColor = false
	stopBtn.Parent = panel

	local stopCorner = Instance.new("UICorner")
	stopCorner.CornerRadius = UDim.new(0, 10)
	stopCorner.Parent = stopBtn

	local stopStroke = Instance.new("UIStroke")
	stopStroke.Color = Color3.fromRGB(220, 80, 80)
	stopStroke.Thickness = 1
	stopStroke.Parent = stopBtn

	stopBtn.MouseEnter:Connect(function()
		TweenService:Create(stopBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(220, 60, 60) }):Play()
	end)
	stopBtn.MouseLeave:Connect(function()
		TweenService:Create(stopBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(180, 45, 45) }):Play()
	end)

	stopBtn.MouseButton1Click:Connect(function()
		stopCurrent()
	end)

	-- ── Toggle Slide Logic ──
	local open = false
	local function setDrawerOpen(shouldOpen)
		open = shouldOpen
		
		-- Target Position for the drawer panel
		local targetPos = open and UDim2.new(1, -drawerWidth - 20, 0.5, -drawerHeight/2) or UDim2.new(1, 20, 0.5, -drawerHeight/2)
		
		-- Tween panel position
		TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetPos
		}):Play()

		-- Tween toggle button color
		TweenService:Create(toggleBtn, TweenInfo.new(0.3), {
			BackgroundColor3 = open and Color3.fromRGB(60, 40, 90) or Color3.fromRGB(30, 25, 45)
		}):Play()
	end

	toggleBtn.MouseButton1Click:Connect(function()
		setDrawerOpen(not open)
	end)

	-- ── 3.5 Close Button (X at the top right of the panel) ──
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.Position = UDim2.new(1, -36, 0, 7)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.MontserratBold
	closeBtn.TextSize = 12
	closeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = panel

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	local closeStroke = Instance.new("UIStroke")
	closeStroke.Color = Color3.fromRGB(60, 55, 75)
	closeStroke.Thickness = 1
	closeStroke.Parent = closeBtn

	closeBtn.MouseEnter:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(150, 40, 40),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}):Play()
		TweenService:Create(closeStroke, TweenInfo.new(0.15), {
			Color = Color3.fromRGB(200, 80, 80)
		}):Play()
	end)

	closeBtn.MouseLeave:Connect(function()
		TweenService:Create(closeBtn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35, 30, 45),
			TextColor3 = Color3.fromRGB(180, 180, 200)
		}):Play()
		TweenService:Create(closeStroke, TweenInfo.new(0.15), {
			Color = Color3.fromRGB(60, 55, 75)
		}):Play()
	end)

	closeBtn.MouseButton1Click:Connect(function()
		setDrawerOpen(false)
	end)

	-- ── 4. Listen for Server-Triggered Emote Zones ──
	local EmoteEvent = ReplicatedStorage:WaitForChild("EmoteEvent", 5)
	if EmoteEvent then
		EmoteEvent.OnClientEvent:Connect(function(action)
			if action == "Dance" then
				playLocalEmote("dance")
			end
		end)
	end

	-- Close panel when character resets or respawns
	player.CharacterAdded:Connect(function()
		stopCurrent()
		setDrawerOpen(false)
	end)

	print("[Hangout cafe] Emote UI successfully updated to premium sliding drawer style")
end

return EmoteController.new()
