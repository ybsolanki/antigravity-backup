--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local IDLE_TIME = 15
local lastInputTime = tick()
local isCinematic = false

-- Effects
local dof = Lighting:FindFirstChild("CinematicDOF") or Instance.new("DepthOfFieldEffect")
dof.Name = "CinematicDOF"
dof.Enabled = false
dof.FarIntensity = 1
dof.FocusDistance = 10
dof.InFocusRadius = 5
dof.Parent = Lighting

local function GetAuraGui()
	local pg = player:FindFirstChild("PlayerGui")
	return pg and pg:FindFirstChild("AuraRNGGui")
end

local function SetCinematicMode(enabled: boolean)
	if isCinematic == enabled then return end
	isCinematic = enabled
	
	local gui = GetAuraGui()
	if gui then
		gui:SetAttribute("UIDimmed", enabled)
	end
	
	if enabled then
		camera.CameraType = Enum.CameraType.Scriptable
		dof.Enabled = true
	else
		camera.CameraType = Enum.CameraType.Custom
		dof.Enabled = false
	end
end

-- Input detection to reset timer
UserInputService.InputBegan:Connect(function()
	lastInputTime = tick()
	if isCinematic then SetCinematicMode(false) end
end)

UserInputService.InputChanged:Connect(function()
	lastInputTime = tick()
	if isCinematic then SetCinematicMode(false) end
end)

-- Main Loop
local angle = 0
RunService.RenderStepped:Connect(function()
	if not isCinematic then
		if tick() - lastInputTime > IDLE_TIME then
			SetCinematicMode(true)
		end
		return
	end
	
	-- Orbiting Logic
	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart
	
	if rootPart then
		angle += 0.005 -- Slow rotation
		local radius = 12
		local height = 4
		
		local offset = Vector3.new(
			math.cos(angle) * radius,
			height,
			math.sin(angle) * radius
		)
		
		local targetPos = rootPart.Position + offset
		camera.CFrame = CFrame.new(targetPos, rootPart.Position + Vector3.new(0, 2, 0))
	else
		SetCinematicMode(false)
	end
end)
