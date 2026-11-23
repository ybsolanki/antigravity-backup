-- KARYŌ UI Controller
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KaryoUI"
ScreenGui.Parent = PlayerGui

-- Main HUD Container
local HUD = Instance.new("Frame")
HUD.Name = "HUD"
HUD.Size = UDim2.fromScale(1, 1)
HUD.BackgroundTransparency = 1
HUD.Parent = ScreenGui

-- Bottom Center Stats
local Stats = Instance.new("Frame")
Stats.Name = "Stats"
Stats.Size = UDim2.new(0, 300, 0, 40)
Stats.Position = UDim2.new(0.5, 0, 0.95, 0)
Stats.AnchorPoint = Vector2.new(0.5, 1)
Stats.BackgroundTransparency = 1
Stats.Parent = HUD

-- Health Bar Background
local HealthBG = Instance.new("Frame")
HealthBG.Name = "HealthBG"
HealthBG.Size = UDim2.new(1, 0, 0.45, 0)
HealthBG.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
HealthBG.BorderSizePixel = 0
HealthBG.Parent = Stats
Instance.new("UICorner", HealthBG)

-- Health Bar Fill
local HealthFill = Instance.new("Frame")
HealthFill.Name = "Fill"
HealthFill.Size = UDim2.fromScale(1, 1)
HealthFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
HealthFill.BorderSizePixel = 0
HealthFill.Parent = HealthBG
Instance.new("UICorner", HealthFill)

-- Stamina Bar Background
local StaminaBG = Instance.new("Frame")
StaminaBG.Name = "StaminaBG"
StaminaBG.Size = UDim2.new(1, 0, 0.25, 0)
StaminaBG.Position = UDim2.new(0, 0, 0.6, 0)
StaminaBG.BackgroundColor3 = Color3.fromRGB(20, 30, 40)
StaminaBG.BorderSizePixel = 0
StaminaBG.Parent = Stats
Instance.new("UICorner", StaminaBG)

-- Stamina Bar Fill
local StaminaFill = Instance.new("Frame")
StaminaFill.Name = "Fill"
StaminaFill.Size = UDim2.fromScale(1, 1)
StaminaFill.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
StaminaFill.BorderSizePixel = 0
StaminaFill.Parent = StaminaBG
Instance.new("UICorner", StaminaFill)

-- Emotional State Indicator (Bottom Right)
local EmotionLabel = Instance.new("TextLabel")
EmotionLabel.Name = "EmotionLabel"
EmotionLabel.Size = UDim2.new(0, 150, 0, 50)
EmotionLabel.Position = UDim2.new(0.95, 0, 0.95, 0)
EmotionLabel.AnchorPoint = Vector2.new(1, 1)
EmotionLabel.BackgroundTransparency = 1
EmotionLabel.Font = Enum.Font.Garamond
EmotionLabel.Text = "Sorrow"
EmotionLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
EmotionLabel.TextSize = 32
EmotionLabel.TextXAlignment = Enum.TextXAlignment.Right
EmotionLabel.Parent = HUD

-- Mission: Add subtle pulse to emotion
local function PulseEmotion()
    while true do
        TweenService:Create(EmotionLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0.5}):Play()
        task.wait(2)
        TweenService:Create(EmotionLabel, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextTransparency = 0}):Play()
        task.wait(2)
    end
end
task.spawn(PulseEmotion)

-- Data Sync (Placeholder for now)
player:GetAttributeChangedSignal("Health"):Connect(function()
    local hp = player:GetAttribute("Health") or 100
    TweenService:Create(HealthFill, TweenInfo.new(0.3), {Size = UDim2.fromScale(hp/100, 1)}):Play()
end)

player:GetAttributeChangedSignal("Stamina"):Connect(function()
    local st = player:GetAttribute("Stamina") or 100
    TweenService:Create(StaminaFill, TweenInfo.new(0.3), {Size = UDim2.fromScale(st/100, 1)}):Play()
end)

print("KARYŌ: UI Controller Initialized.")
