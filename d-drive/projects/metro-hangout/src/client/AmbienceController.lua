local Lighting = game:GetService("Lighting")

local AmbienceController = {}

function AmbienceController:Initialize()
	-- User Specs: Phase 1: The Foundation (Bright & Clean)
	Lighting.ClockTime = 14
	Lighting.Brightness = 3
	Lighting.EnvironmentDiffuseScale = 1
	Lighting.EnvironmentSpecularScale = 1
	Lighting.GlobalShadows = true
	
	-- Clean Atmosphere setup
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	
	atmosphere.Density = 0.15
	atmosphere.Haze = 0
	atmosphere.Glare = 0
	
	-- Terrain Decoration (3D Grass)
	pcall(function()
		workspace.Terrain.Decoration = true
	end)
	
	-- Add subtle post-processing for that "Hangout" clean look
	local colorCorrection = Lighting:FindFirstChild("CafeColor") or Instance.new("ColorCorrectionEffect")
	colorCorrection.Name = "CafeColor"
	colorCorrection.Saturation = 0.05
	colorCorrection.Contrast = 0.05
	colorCorrection.Parent = Lighting
	
	print("[Hangout cafe] Phase 1 Lighting & Atmosphere Initialized")
end

return AmbienceController
