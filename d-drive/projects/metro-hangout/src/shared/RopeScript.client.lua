local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local adminEvent = ReplicatedStorage:WaitForChild("AdminEvent")

Tool.Activated:Connect(function()
	-- Foolproof target detection walking up the parent tree (handles hats, accessories, limbs)
	local targetPart = mouse.Target
	local targetChar = targetPart and targetPart.Parent
	local targetPlayer = nil
	
	while targetChar and targetChar ~= workspace do
		local foundPlayer = Players:GetPlayerFromCharacter(targetChar)
		if foundPlayer then
			targetPlayer = foundPlayer
			break
		end
		targetChar = targetChar.Parent
	end
	
	if targetPlayer and targetPlayer ~= player then
		print("[RopeScript] Activating rope connection on:", targetPlayer.Name)
		adminEvent:FireServer("Rope", targetPlayer.Name)
	end
end)
