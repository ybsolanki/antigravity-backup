-- Karyo Weapons Module
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = ReplicatedStorage:WaitForChild("Assets")

local Weapons = {}

function Weapons.GiveWeapon(player, weaponName)
    local tool = Assets:FindFirstChild(weaponName)
    if tool then
        local clone = tool:Clone()
        clone.Parent = player.Backpack
        return clone
    end
end

return Weapons
