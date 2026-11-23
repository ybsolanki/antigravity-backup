local Lighting = game:GetService("Lighting")

local AtmosphereService = {}

function AtmosphereService.ApplySilentVillageTheme()
	-- Atmosphere settings for Foggy/Melancholic feel
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
	atmosphere.Density = 0.5
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(180, 190, 200)
	atmosphere.Decay = Color3.fromRGB(100, 100, 110)
	atmosphere.Glare = 0
	atmosphere.Haze = 2
	
	-- Lighting settings
	Lighting.Ambient = Color3.fromRGB(40, 40, 50)
	Lighting.OutdoorAmbient = Color3.fromRGB(60, 60, 75)
	Lighting.Brightness = 0.5
	Lighting.ClockTime = 18 -- Twilight/Sunset feel
	Lighting.FogEnd = 300
	Lighting.FogStart = 0
	Lighting.FogColor = Color3.fromRGB(150, 160, 170)
	
	-- Color Correction for cinematic look
	local cc = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
	cc.Brightness = 0.1
	cc.Contrast = 0.2
	cc.Saturation = -0.3 -- desaturate for lonely feel
	cc.TintColor = Color3.fromRGB(220, 230, 255)
	
	print("Silent Village atmosphere applied.")
end

AtmosphereService.ApplySilentVillageTheme()

return AtmosphereService
