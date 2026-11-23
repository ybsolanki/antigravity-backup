local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ProceduralAnimController = {}
local trackedCharacters = {}

local function trackCharacter(character)
	-- Clean up old tracking if any
	trackedCharacters[character] = nil
	
	local humanoid = character:WaitForChild("Humanoid", 5)
	local torso = character:WaitForChild("Torso", 5)
	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	
	if not humanoid or not torso or not hrp then return end
	
	-- Disable default Roblox animate script to let procedural loop take full control
	local defaultAnimate = character:WaitForChild("Animate", 5)
	if defaultAnimate then
		defaultAnimate.Disabled = true
	end
	
	-- Fetch all R6 Motor6D joints
	local joints = {
		Root = hrp:WaitForChild("RootJoint", 5),
		Neck = torso:WaitForChild("Neck", 5),
		LeftShoulder = torso:WaitForChild("Left Shoulder", 5),
		RightShoulder = torso:WaitForChild("Right Shoulder", 5),
		LeftHip = torso:WaitForChild("Left Hip", 5),
		RightHip = torso:WaitForChild("Right Hip", 5),
	}
	
	-- Store original C0 values to apply relative rotations/offsets
	local originalC0 = {}
	local hasAllJoints = true
	for name, joint in pairs(joints) do
		if joint then
			originalC0[name] = joint.C0
		else
			hasAllJoints = false
		end
	end
	
	if not hasAllJoints then return end
	
	trackedCharacters[character] = {
		joints = joints,
		originalC0 = originalC0,
		humanoid = humanoid,
		hrp = hrp,
		torso = torso,
		cycle = 0,
		speedWeight = 0,
	}
end

local function untrackCharacter(character)
	trackedCharacters[character] = nil
end

function ProceduralAnimController:Initialize()
	print("[Hangout cafe] ProceduralAnimController: Initializing...")
	
	-- Listen for characters
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(trackCharacter)
		player.CharacterRemoving:Connect(untrackCharacter)
	end)
	
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			task.spawn(trackCharacter, player.Character)
		end
		player.CharacterAdded:Connect(trackCharacter)
		player.CharacterRemoving:Connect(untrackCharacter)
	end
	
	-- Connect client-side region check to lower gravity in Stage 5 of the Obby
	local originalGravity = workspace.Gravity
	local localPlayer = Players.LocalPlayer
	RunService.Heartbeat:Connect(function()
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = hrp.Position
			-- If in Stage 5 Z-zone of the Obby (Z between 680 and 820, Y high, X near obby line)
			if pos.X >= 350 and pos.X <= 650 and pos.Z >= 680 and pos.Z <= 820 and pos.Y >= 120 then
				if workspace.Gravity ~= 50 then
					workspace.Gravity = 50
				end
			else
				if workspace.Gravity ~= originalGravity then
					workspace.Gravity = originalGravity
				end
			end
		end
	end)
	
	-- Run procedural loop on Heartbeat (runs locally on client for all active characters)
	RunService.Heartbeat:Connect(function(dt)
		for char, data in pairs(trackedCharacters) do
			if not char.Parent or not data.humanoid or not data.hrp or not data.hrp.Parent then
				trackedCharacters[char] = nil
				continue
			end
			
			-- Calculate current horizontal movement speed
			local velocity = data.hrp.AssemblyLinearVelocity
			local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			local isMoving = horizontalSpeed > 0.5 and data.humanoid.MoveDirection.Magnitude > 0.1
			
			-- Check state: jumping, falling, or grounded
			local state = data.humanoid:GetState()
			local isJumping = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.FreeFall
			
			-- Interpolate target speed weight for smooth transition between walk and idle
			local targetWeight = isMoving and 1 or 0
			if isJumping then
				targetWeight = 0
			end
			data.speedWeight = data.speedWeight + (targetWeight - data.speedWeight) * 12 * dt
			
			-- Advance cycle time
			if isMoving then
				local speedMultiplier = horizontalSpeed / 16
				data.cycle = data.cycle + dt * 14 * speedMultiplier
			else
				-- Slowly return cycle to 0 when stationary
				data.cycle = data.cycle + (0 - data.cycle) * 10 * dt
			end
			
			local cycle = data.cycle
			local sw = data.speedWeight
			
			-- Declare local transform offsets
			local rootOffset = CFrame.new()
			local neckOffset = CFrame.new()
			local leftShoulderOffset = CFrame.new()
			local rightShoulderOffset = CFrame.new()
			local leftHipOffset = CFrame.new()
			local rightHipOffset = CFrame.new()
			
			if isJumping then
				-- JUMPING/FALLING POSE
				-- Arms rise up and out
				leftShoulderOffset = CFrame.Angles(math.rad(-30), 0, math.rad(-15))
				rightShoulderOffset = CFrame.Angles(math.rad(-30), 0, math.rad(15))
				
				-- Legs angle down and slightly back
				leftHipOffset = CFrame.Angles(math.rad(10), 0, math.rad(-5))
				rightHipOffset = CFrame.Angles(math.rad(10), 0, math.rad(5))
				
				-- Torso tilts forward slightly
				rootOffset = CFrame.Angles(math.rad(5), 0, 0)
			else
				-- GROUNDED (WALKING OR IDLE)
				local legSwing = math.sin(cycle) * math.rad(30) * sw
				local armSwing = math.sin(cycle) * math.rad(35) * sw
				
				-- Torso bobbing (up & down) and tilt forward while walking
				local bob = math.abs(math.sin(cycle)) * 0.1 * sw
				local tilt = math.rad(5) * sw
				local sway = math.cos(cycle) * math.rad(2) * sw
				
				rootOffset = CFrame.new(0, -bob, 0) * CFrame.Angles(tilt, 0, sway)
				neckOffset = CFrame.Angles(-tilt * 0.8, 0, -sway)
				
				-- Leg swing
				leftHipOffset = CFrame.Angles(legSwing, 0, 0)
				rightHipOffset = CFrame.Angles(-legSwing, 0, 0)
				
				-- Arm swing (opposite to legs) + gentle side-to-side spread
				leftShoulderOffset = CFrame.Angles(-armSwing, 0, math.sin(cycle) * math.rad(4) * sw)
				rightShoulderOffset = CFrame.Angles(armSwing, 0, -math.sin(cycle) * math.rad(4) * sw)
				
				-- Breathing/Idle animation
				if sw < 0.05 then
					local breathingFactor = math.sin(os.clock() * 2) * 0.02
					rootOffset = CFrame.new(0, -breathingFactor * 0.5, 0)
					neckOffset = CFrame.Angles(-breathingFactor * 0.2, 0, 0)
					leftShoulderOffset = CFrame.Angles(0, 0, -breathingFactor)
					rightShoulderOffset = CFrame.Angles(0, 0, breathingFactor)
				end
			end
			
			-- Apply modifications in parent (torso/root) space using multiplication order
			if data.joints.Root then
				data.joints.Root.C0 = rootOffset * data.originalC0.Root
			end
			if data.joints.Neck then
				data.joints.Neck.C0 = neckOffset * data.originalC0.Neck
			end
			if data.joints.LeftShoulder then
				data.joints.LeftShoulder.C0 = leftShoulderOffset * data.originalC0.LeftShoulder
			end
			if data.joints.RightShoulder then
				data.joints.RightShoulder.C0 = rightShoulderOffset * data.originalC0.RightShoulder
			end
			if data.joints.LeftHip then
				data.joints.LeftHip.C0 = leftHipOffset * data.originalC0.LeftHip
			end
			if data.joints.RightHip then
				data.joints.RightHip.C0 = rightHipOffset * data.originalC0.RightHip
			end
		end
	end)
	
	print("[Hangout cafe] ProceduralAnimController Initialized")
end

return ProceduralAnimController
