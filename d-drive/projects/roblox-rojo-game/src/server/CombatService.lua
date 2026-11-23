local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatEvent = Remotes:WaitForChild("CombatEvent")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local CombatService = {}

print("CombatService Loaded")

local function OnCombatEvent(player, actionType)
	print("Combat Input: " .. tostring(actionType) .. " | User: " .. player.Name)
	local currentStamina = player:GetAttribute("Stamina")
	
	if actionType == "LightAttack" then
		print("--- " .. player.Name .. " performed a Light Attack ---")
		
	elseif actionType == "HeavyAttack" then
		if currentStamina >= Constants.HEAVY_ATTACK_STAMINA_COST then
			player:SetAttribute("Stamina", currentStamina - Constants.HEAVY_ATTACK_STAMINA_COST)
			print("--- " .. player.Name .. " performed a Heavy Attack ---")
		else
			print("!!! " .. player.Name .. " NOT ENOUGH STAMINA for Heavy Attack")
		end
		
	elseif actionType == "Dash" then
		if currentStamina >= Constants.DASH_STAMINA_COST then
			player:SetAttribute("Stamina", currentStamina - Constants.DASH_STAMINA_COST)
			print("--- " .. player.Name .. " dashed ---")
		else
			print("!!! " .. player.Name .. " NOT ENOUGH STAMINA for Dash")
		end
		
	elseif actionType == "Parry" then
		print("Action: " .. player.Name .. " is parrying")
	end
end

CombatEvent.OnServerEvent:Connect(OnCombatEvent)

return CombatService
