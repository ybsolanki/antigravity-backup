local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local CombatEvent = Remotes:WaitForChild("CombatEvent")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local LocalPlayer = Players.LocalPlayer
local CombatController = {}

local isSwinging = false

local function ProceduralSwing()
	local character = LocalPlayer.Character
	local sword = character and character:FindFirstChild("Cracked Chokuto")
	local handle = sword and sword:FindFirstChild("Handle")
	
	if handle and not isSwinging then
		isSwinging = true
		
		-- Simple procedural swing (Pivot/Rotate handle)
		local originalCFrame = handle.CFrame
		local joint = Instance.new("Motor6D") -- Temporary joint for the swing
		joint.Part0 = character:WaitForChild("RightHand")
		joint.Part1 = handle
		joint.C0 = CFrame.new(0, -1, 0)
		joint.Parent = handle
		
		-- Tween or simple loop for the arc
		for i = 1, 10 do
			joint.C0 = joint.C0 * CFrame.Angles(0, math.rad(-10), 0)
			task.wait(0.02)
		end
		
		task.wait(0.1)
		joint:Destroy()
		isSwinging = false
	end
end

local function OnInputBegan(input, gameProcessed)
	if gameProcessed then return end
	
	-- Light Attack (Left Click)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if not isSwinging then
			ProceduralSwing()
			CombatEvent:FireServer("LightAttack")
		end
	
	-- Heavy Attack (E)
	elseif input.KeyCode == Enum.KeyCode.E then
		CombatEvent:FireServer("HeavyAttack")
		
	-- Parry (Q)
	elseif input.KeyCode == Enum.KeyCode.Q then
		CombatEvent:FireServer("Parry")
		
	-- Dash (Space - Contextual)
	-- In a real game, you might want a double-tap or Shift, but let's stick to basics.
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		CombatEvent:FireServer("Dash")
	end
end

function CombatController.Start()
	UserInputService.InputBegan:Connect(OnInputBegan)
	print("Combat Controller Started")
end

return CombatController
