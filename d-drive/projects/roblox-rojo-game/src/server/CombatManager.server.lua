local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatEvent = Remotes:WaitForChild("CombatEvent")

CombatEvent.OnServerEvent:Connect(function(player, actionType)
    print("KARYŌ Server: " .. player.Name .. " performed " .. actionType)
    
    -- Basic combat logic placeholder
    if actionType == "LightAttack" then
        -- Play animation, check hits
    elseif actionType == "HeavyAttack" then
        -- Shield break logic
    elseif actionType == "Parry" then
        -- Check timing
    end
end)
