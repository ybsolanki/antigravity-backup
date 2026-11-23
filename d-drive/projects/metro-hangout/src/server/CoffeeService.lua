local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CoffeeService = {}

function CoffeeService:Initialize()
	-- 1. Setup RemoteEvent for communication
	local coffeeEvent = Instance.new("RemoteEvent")
	coffeeEvent.Name = "CoffeeEvent"
	coffeeEvent.Parent = ReplicatedStorage
	
	-- 2. Create Coffee Tools (simplified parts since we don't have meshes yet)
	local coffeeFolder = Instance.new("Folder")
	coffeeFolder.Name = "CoffeeTools"
	coffeeFolder.Parent = ServerStorage
	
	self:CreateTool("Espresso", Color3.fromRGB(50, 30, 20), coffeeFolder)
	self:CreateTool("Latte", Color3.fromRGB(180, 150, 120), coffeeFolder)
	self:CreateTool("MetroSpecial", Color3.fromRGB(0, 255, 255), coffeeFolder)
	
	-- 3. Listener for "Order" and "Drink" requests
	coffeeEvent.OnServerEvent:Connect(function(player, action, drinkName)
		if action == "GiveDrink" then
			local tool = coffeeFolder:FindFirstChild(drinkName)
			if tool then
				local clone = tool:Clone()
				clone.Parent = player.Backpack
				print("[Hangout cafe] Gave " .. drinkName .. " to " .. player.Name)
			end

		elseif action == "DrinkCoffee" then
			-- Remove the coffee tool from the player's backpack OR character
			local COFFEE_TOOLS = { Espresso = true, Latte = true, MetroSpecial = true }
			local function destroyCoffee(parent)
				for _, item in pairs(parent:GetChildren()) do
					if item:IsA("Tool") and COFFEE_TOOLS[item.Name] then
						item:Destroy()
						return true
					end
				end
				return false
			end
			local removed = destroyCoffee(player.Backpack)
			if not removed and player.Character then
				destroyCoffee(player.Character)
			end
			print("[Hangout cafe] " .. player.Name .. " drank their coffee!")
		end
	end)
	
	-- 4. Monitor Workspace for Machines
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant.Name == "CoffeeMachine" then
			self:SetupMachine(descendant)
		end
	end)
	
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant.Name == "CoffeeMachine" then
			self:SetupMachine(descendant)
		end
	end
end

function CoffeeService:CreateTool(name, color, parent)
	local tool = Instance.new("Tool")
	tool.Name = name
	
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1.2, 1)
	handle.Color = Color3.fromRGB(255, 255, 255) -- White cup
	handle.Material = Enum.Material.SmoothPlastic
	handle.Parent = tool
	
	-- Inner liquid part
	local liquid = Instance.new("Part")
	liquid.Size = Vector3.new(0.8, 0.2, 0.8)
	liquid.Position = handle.Position + Vector3.new(0, 0.5, 0)
	liquid.Color = color
	liquid.Material = Enum.Material.Neon
	liquid.Name = "Liquid"
	liquid.Parent = handle
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = liquid
	weld.Parent = handle
	
	tool.Parent = parent
	return tool
end

function CoffeeService:SetupMachine(machine)
	if machine:FindFirstChild("OrderPrompt") then return end
	
	-- If it's a model, we need to pick a part to host the prompt
	local targetPart = machine:IsA("BasePart") and machine or machine:FindFirstChildWhichIsA("BasePart", true)
	
	if not targetPart then
		warn("[Hangout cafe] Could not find a Part inside CoffeeMachine for the prompt: " .. machine.Name)
		return
	end
	
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "OrderPrompt"
	prompt.ActionText = "Order Coffee"
	prompt.ObjectText = "Cafe Express"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10
	prompt.Parent = targetPart
	
	-- Add a nice Highlight so the user knows it's interactive
	local highlight = Instance.new("Highlight")
	highlight.Name = "InteractiveHighlight"
	highlight.FillColor = Color3.fromRGB(0, 255, 255)
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.Adornee = machine
	highlight.Parent = machine
	
	prompt.Triggered:Connect(function(player)
		local coffeeEvent = ReplicatedStorage:FindFirstChild("CoffeeEvent")
		if coffeeEvent then
			coffeeEvent:FireClient(player, "OpenMenu")
		end
	end)
	
	print("[Hangout cafe] Coffee Machine Activated: " .. machine.Name)
end

return CoffeeService
