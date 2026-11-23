-- Procedural Cracked Chokuto Creator
local WeaponsModule = require(game:GetService("ServerScriptService"):WaitForChild("Server"):WaitForChild("WeaponsModule"))
local Players = game:GetService("Players")

print("KARYŌ: Ready to give weapons.")

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(2) -- Wait for character to load
        
        -- Create a basic tool if it doesn't exist in ReplicatedStorage.Assets
        local Assets = game:GetService("ReplicatedStorage"):WaitForChild("Assets")
        if not Assets:FindFirstChild("Cracked Chokuto") then
            local tool = Instance.new("Tool")
            tool.Name = "Cracked Chokuto"
            tool.RequiresHandle = true
            
            local handle = Instance.new("Part")
            handle.Name = "Handle"
            handle.Size = Vector3.new(0.3, 4, 0.3)
            handle.Color = Color3.fromRGB(50, 50, 50)
            handle.Material = Enum.Material.Metal
            handle.Parent = tool
            
            -- Add a "Cracked" glowing part
            local crack = Instance.new("Part")
            crack.Name = "CrackEffect"
            crack.Size = Vector3.new(0.35, 1, 0.35)
            crack.Position = handle.Position + Vector3.new(0, 1, 0)
            crack.Color = Color3.fromRGB(100, 200, 255)
            crack.Material = Enum.Material.Neon
            crack.Transparency = 0.5
            crack.CanCollide = false
            crack.Parent = handle
            
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = handle
            weld.Part1 = crack
            weld.Parent = crack
            
            tool.Parent = Assets
        end
        
        -- Give the weapon
        WeaponsModule.GiveWeapon(player, "Cracked Chokuto")
        print("KARYŌ: Gave " .. player.Name .. " the Cracked Chokuto.")
    end)
end)
