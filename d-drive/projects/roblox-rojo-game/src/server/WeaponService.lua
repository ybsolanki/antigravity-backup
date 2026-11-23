local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WeaponService = {}

print("WeaponService Initialized")

function WeaponService.CreateCrackedChokuto()
	local tool = Instance.new("Tool")
	tool.Name = "Cracked Chokuto"
	tool.RequiresHandle = true
	
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(0.2, 0.2, 4) -- Thinner blade
	handle.Color = Color3.fromRGB(180, 180, 185)
	handle.Material = Enum.Material.Metal
	handle.Parent = tool
	
	return tool
end

function WeaponService.GiveStarterWeapon(player)
	local backpack = player:WaitForChild("Backpack")
	
	-- Check if player already has it
	if backpack:FindFirstChild("Cracked Chokuto") or player.Character:FindFirstChild("Cracked Chokuto") then 
		return 
	end
	
	print("Attempting to give weapon to: " .. player.Name)
	
	-- Try to find synced asset first
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local starterSword = assets and assets:FindFirstChild("Cracked Chokuto")
	
	if starterSword then
		starterSword:Clone().Parent = backpack
		print("SUCCESS: Cloned Cracked Chokuto from Assets")
	else
		-- Fallback: Create it manually if sync failed
		local fallbackSword = WeaponService.CreateCrackedChokuto()
		fallbackSword.Parent = backpack
		print("SUCCESS: Created fallback Cracked Chokuto for " .. player.Name)
	end
end

-- Function to handle new and existing players
local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function()
		WeaponService.GiveStarterWeapon(player)
	end)
	
	if player.Character then
		WeaponService.GiveStarterWeapon(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

return WeaponService
