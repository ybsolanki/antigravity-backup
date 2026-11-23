local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local sharedFolder = ReplicatedStorage:WaitForChild("Shared", 5)
local zoneConfigModule = sharedFolder and sharedFolder:WaitForChild("ZoneConfig", 5)
local ZoneConfig = zoneConfigModule and require(zoneConfigModule)

local ZoneVisuals = {}

function ZoneVisuals:Initialize()
	if not ZoneConfig then
		warn("[Hangout cafe] ZoneConfig module not found! ZoneVisuals disabled.")
		return
	end
	task.spawn(function()
		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local hrp = character:WaitForChild("HumanoidRootPart")
		
		RunService.Heartbeat:Connect(function()
			local pos = hrp.Position
			local currentZone = nil
			
			for _, zone in pairs(ZoneConfig.Zones) do
				local min = zone.Position - (zone.Size / 2)
				local max = zone.Position + (zone.Size / 2)
				
				if pos.X >= min.X and pos.X <= max.X and
				   pos.Y >= min.Y and pos.Y <= max.Y and
				   pos.Z >= min.Z and pos.Z <= max.Z then
					currentZone = zone
					break
				end
			end
			
			if currentZone then
				-- Future: Add screen blur or UI indicator here
				-- print("Currently in: " .. currentZone.Name)
			end
		end)
	end)
end

return ZoneVisuals
