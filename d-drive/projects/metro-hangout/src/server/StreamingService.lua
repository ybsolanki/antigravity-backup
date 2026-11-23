-- StreamingService.lua
-- Configures workspace StreamingEnabled and related performance settings.
-- This runs once at server startup.

local StreamingService = {}

function StreamingService:Initialize()
	-- Wrap configuration in pcall to prevent property errors from halting server startup
	local success, err = pcall(function()
		workspace.StreamingEnabled = true
		workspace.StreamingMinRadius = 64
		workspace.StreamingTargetRadius = 256
		workspace.StreamingPauseMode = Enum.StreamingPauseMode.Default
	end)
	
	if success then
		print("[Hangout cafe] StreamingEnabled configured ✅")
	else
		warn("[Hangout cafe] Failed to configure Streaming: " .. tostring(err))
	end
end

return StreamingService
