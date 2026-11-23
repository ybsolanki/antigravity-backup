local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local CafeController = {}

function CafeController:Initialize()
	-- This will handle Cafe-specific client logic
	-- e.g. Music volume boost, UI menus for drinks
	print("[Hangout cafe] Cafe Controller Initialized")
end

function CafeController:OnEntry()
	-- Visual effects when entering the dome
end

return CafeController
