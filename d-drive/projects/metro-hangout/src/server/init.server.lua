print("!!! CAFÉ SERVER BOOTING (MANUAL BUILD MODE) !!!")


local function safeRequire(name)
	local child = script:WaitForChild(name, 5)
	if not child then
		warn("[Hangout cafe] Service not found: " .. name)
		return nil
	end
	return require(child)
end

-- 1. Load Core Services (Keeping essential social/lighting magic)
local SocialService = safeRequire("SocialService")
local SpawnService = safeRequire("SpawnService")
local SeatService = safeRequire("SeatService")
local LightingSync = safeRequire("LightingSync")
local TeleportService = safeRequire("TeleportService")
local CoffeeService = safeRequire("CoffeeService")
local FoodService = safeRequire("FoodService")
local RideService = safeRequire("RideService")
local ResetService = safeRequire("ResetService")
local SignService = safeRequire("SignService")
local EmoteService = safeRequire("EmoteService")
local StreamingService = safeRequire("StreamingService")
local AdminService = safeRequire("AdminService")
local ClawMachineService = safeRequire("ClawMachineService")
local ObbyService = safeRequire("ObbyService")

local sharedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Shared", 5)
local envUtilsChild = sharedFolder and sharedFolder:WaitForChild("EnvironmentUtils", 5)
local EnvironmentUtils = envUtilsChild and require(envUtilsChild)

-- 2. Initialize Logic
if SocialService then SocialService:Initialize() end
if SpawnService then SpawnService:Initialize() end
if SeatService then SeatService:Initialize() end
if LightingSync then LightingSync:Initialize() end
if TeleportService then TeleportService:Initialize() end
if CoffeeService then CoffeeService:Initialize() end
if FoodService then FoodService:Initialize() end
if RideService then RideService:Initialize() end
if ResetService then ResetService:Initialize() end
if SignService then SignService:Initialize() end
if EmoteService then EmoteService:Initialize() end
if StreamingService then StreamingService:Initialize() end
if AdminService then AdminService:Initialize() end
if ClawMachineService then ClawMachineService:Initialize() end
if ObbyService then ObbyService:Initialize() end

-- 3. FOUNDATION (Safe Mode)
if EnvironmentUtils then
	-- Aggressively hide ALL baseplates (some places have multiple)
	for _, item in pairs(workspace:GetDescendants()) do
		if item:IsA("BasePart") and (item.Name == "Baseplate" or item.Name == "Plate") then
			item.Transparency = 1
			item.CanCollide = false
		end
	end
	
	-- Ensure Terrain is totally clear of background land
	workspace.Terrain:Clear()
	
	EnvironmentUtils:GenerateCustomPlatform()
end



print("!!! CAFÉ SERVER READY - MANUAL BUILDING ENABLED !!!")
