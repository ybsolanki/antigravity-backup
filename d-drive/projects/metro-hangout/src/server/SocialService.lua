local Players = game:GetService("Players")

local SocialService = {}

function SocialService:Initialize()
	Players.PlayerAdded:Connect(function(player)
		print("[Hangout cafe] Welcome, " .. player.Name)
		
		player.CharacterAdded:Connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = 32 -- Double the default speed
			print("[Hangout cafe] Applied Speed Boost to " .. player.Name)
		end)
	end)
end

return SocialService
