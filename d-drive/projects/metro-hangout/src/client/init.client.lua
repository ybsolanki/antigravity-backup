local function safeRequire(name)
	local child = script:WaitForChild(name, 5)
	if not child then
		warn("[Hangout cafe] Client Service not found: " .. name)
		return nil
	end
	return require(child)
end

local LoadingController = safeRequire("LoadingController")
local AmbienceController = safeRequire("AmbienceController")
local ZoneVisuals = safeRequire("ZoneVisuals")
local CafeController = safeRequire("CafeController")
local CoffeeController = safeRequire("CoffeeController")
local EmoteController = safeRequire("EmoteController")
local ChatController = safeRequire("ChatController")
local RideController = safeRequire("RideController")
local AdminController = safeRequire("AdminController")
local ProceduralAnimController = safeRequire("ProceduralAnimController")

if LoadingController then LoadingController:Initialize() end
if AmbienceController then AmbienceController:Initialize() end
if ZoneVisuals then ZoneVisuals:Initialize() end
if CafeController then CafeController:Initialize() end
if CoffeeController then CoffeeController:Initialize() end
if EmoteController then EmoteController:Initialize() end
if ChatController then ChatController:Initialize() end
if RideController then RideController:Initialize() end
if AdminController then AdminController:Initialize() end
if ProceduralAnimController then ProceduralAnimController:Initialize() end

print("[Hangout cafe] Client Started")

-- Debug class check
local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 5)
if sharedFolder then
	for _, child in ipairs(sharedFolder:GetChildren()) do
		print("[Debug ClassName]", child.Name, "is a", child.ClassName)
	end
end
