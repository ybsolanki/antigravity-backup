local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SeatService = {}

function SeatService:Initialize()
	-- Listen for new seats being added to the workspace
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Seat") then
			self:SetupSeat(descendant)
		end
	end)
	
	-- Setup existing seats
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("Seat") then
			self:SetupSeat(descendant)
		end
	end
end

function SeatService:SetupSeat(seat)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Sit Down"
	prompt.ObjectText = "Lounge Chair"
	prompt.HoldDuration = 0.2
	prompt.Parent = seat
	
	prompt.Triggered:Connect(function(player)
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid and not seat.Occupant then
				seat:Sit(humanoid)
			end
		end
	end)
end

return SeatService
