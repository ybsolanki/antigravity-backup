local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LoadingController = {}

function LoadingController:Initialize()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Create a clean, minimalist loading screen
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoadingScreen"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100
	screenGui.Parent = playerGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 50)
	label.Position = UDim2.new(0, 0, 0.45, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Text = "HANGOUT CAFE"
	label.Font = Enum.Font.GothamBold
	label.TextSize = 36
	label.TextTransparency = 1
	label.Parent = frame
	
	local subLabel = Instance.new("TextLabel")
	subLabel.Size = UDim2.new(1, 0, 0, 30)
	subLabel.Position = UDim2.new(0, 0, 0.52, 0)
	subLabel.BackgroundTransparency = 1
	subLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	subLabel.Text = "Initializing Atmosphere..."
	subLabel.Font = Enum.Font.Gotham
	subLabel.TextSize = 18
	subLabel.TextTransparency = 1
	subLabel.Parent = frame
	
	-- Animating in
	TweenService:Create(label, TweenInfo.new(1), {TextTransparency = 0}):Play()
	task.wait(0.5)
	TweenService:Create(subLabel, TweenInfo.new(1), {TextTransparency = 0}):Play()
	
	-- Simulate loading/wait for world
	task.wait(2.5)
	
	-- Animating out
	TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(subLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	task.wait(0.5)
	TweenService:Create(frame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
	task.wait(1)
	
	screenGui:Destroy()
	print("[Hangout cafe] Loading Screen Finished")
end

return LoadingController
