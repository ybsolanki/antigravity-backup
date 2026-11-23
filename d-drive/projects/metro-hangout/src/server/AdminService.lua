-- AdminService.lua
-- Server-side Admin service managing the whitelist and executing administrative commands.
-- Includes secure checks, environment control, and funny prank actions (Slap, Rope, Morph, Hand Gun).
-- Features custom multi-part models for all tools and advanced collision visual effects (muzzle flashes, sparks, slap rings).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local AdminService = {}

-- ──────────────────────────────────────────────
-- Admin Whitelist (Usernames or UserIds)
-- ──────────────────────────────────────────────
local ADMIN_WHITELIST = {
	["solankiyb43"] = true, -- Whitelists you
}

local function isAdmin(player)
	-- Automatically whitelist the game creator / Studio owner
	if player.UserId == game.CreatorId or player.UserId <= 0 then
		return true
	end
	
	if ADMIN_WHITELIST[player.Name:lower()] or ADMIN_WHITELIST[player.UserId] then
		return true
	end
	
	return false
end

-- Helper to find or cache Koenigsegg Jesko model
local function getKoenigseggCarModel()
	-- 1. Search Workspace for studio-inserted car model (excluding spawned instances)
	for _, descendant in ipairs(workspace:GetDescendants()) do
		if descendant:IsA("Model") and not descendant.Name:match("^AdminCar_") then
			local dName = descendant.Name:lower()
			if dName:find("koenigsegg") or dName:find("jesko") or dName:find("rosh") then
				return descendant
			end
		end
	end
	
	-- 2. Check ServerStorage
	local names = {
		"2021 Koenigsegg Jesko // Rosh",
		"Koenigsegg",
		"Jesko",
		"Car"
	}
	
	for _, name in ipairs(names) do
		local found = ServerStorage:FindFirstChild(name, true) or ReplicatedStorage:FindFirstChild(name, true)
		if found and found:IsA("Model") and not found.Name:match("^AdminCar_") then
			return found
		end
	end
	
	return nil
end

-- Helper to weld parts programmatically
local function addPart(tool, name, size, color, material, offsetCFrame)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material
	part.CanCollide = false
	part.Massless = true
	part.CFrame = tool.Handle.CFrame * offsetCFrame
	part.Parent = tool
	
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = tool.Handle
	weld.Part1 = part
	weld.Parent = tool.Handle
	
	return part
end

-- Helper to get or build the funny Hand Gun tool
local function getOrCreateHandGun()
	local gun = ReplicatedStorage:FindFirstChild("Hand Gun")
	if not gun then
		gun = Instance.new("Tool")
		gun.Name = "Hand Gun"
		gun.RequiresHandle = true
		gun.ToolTip = "Left Click to Shoot and Kill/Fling Players!"
		
		-- Base Grip Handle
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.3, 0.7, 0.4)
		handle.Color = Color3.fromRGB(35, 35, 40)
		handle.Material = Enum.Material.Metal
		handle.Parent = gun
		
		-- Build sci-fi aesthetic components
		-- 1. Main body receiver
		addPart(gun, "Receiver", Vector3.new(0.3, 0.45, 0.9), Color3.fromRGB(20, 20, 25), Enum.Material.Metal, CFrame.new(0, 0.35, -0.2))
		-- 2. Metallic barrel
		addPart(gun, "Barrel", Vector3.new(0.2, 0.2, 1.2), Color3.fromRGB(170, 170, 180), Enum.Material.Metal, CFrame.new(0, 0.4, -0.9))
		-- 3. Red laser scope
		addPart(gun, "LaserScope", Vector3.new(0.12, 0.12, 0.75), Color3.fromRGB(255, 35, 35), Enum.Material.Neon, CFrame.new(0, 0.65, -0.3))
		-- 4. Grip neon glow indicator
		addPart(gun, "GripGlow", Vector3.new(0.32, 0.5, 0.1), Color3.fromRGB(255, 35, 35), Enum.Material.Neon, CFrame.new(0, -0.05, 0.05))
		-- 5. Black muzzle tip
		addPart(gun, "Muzzle", Vector3.new(0.25, 0.25, 0.2), Color3.fromRGB(10, 10, 10), Enum.Material.Metal, CFrame.new(0, 0.4, -1.5))
		
		-- Clone the precompiled LocalScript from ReplicatedStorage
		local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
		local gunScriptTemplate = sharedFolder:WaitForChild("GunScript")
		local localScript = gunScriptTemplate:Clone()
		localScript.Name = "GunScript"
		localScript.Parent = gun
		
		gun.Parent = ReplicatedStorage
	end
	return gun
end

-- Helper to get or build the Slap tool
local function getOrCreateSlapTool()
	local tool = ReplicatedStorage:FindFirstChild("Slap")
	if not tool then
		tool = Instance.new("Tool")
		tool.Name = "Slap"
		tool.RequiresHandle = true
		tool.ToolTip = "Left Click on a player to Slap Fling them (No Health loss)!"
		
		-- Long thin black stick Handle
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.15, 1.2, 0.15)
		handle.Color = Color3.fromRGB(20, 20, 20) -- Black
		handle.Material = Enum.Material.SmoothPlastic
		handle.Parent = tool
		
		-- White tip at bottom of handle
		addPart(tool, "Tip", Vector3.new(0.22, 0.22, 0.22), Color3.fromRGB(240, 240, 240), Enum.Material.SmoothPlastic, CFrame.new(0, -0.55, 0))
		
		-- Giant cartoon white hand on top of handle
		-- 1. Palm block
		addPart(tool, "Palm", Vector3.new(0.2, 0.9, 0.9), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 0.8, 0))
		-- 2. Four distinct fingers
		addPart(tool, "Finger1", Vector3.new(0.16, 0.6, 0.18), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 1.4, -0.3))
		addPart(tool, "Finger2", Vector3.new(0.16, 0.7, 0.18), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 1.45, -0.1))
		addPart(tool, "Finger3", Vector3.new(0.16, 0.7, 0.18), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 1.45, 0.1))
		addPart(tool, "Finger4", Vector3.new(0.16, 0.6, 0.18), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 1.4, 0.3))
		-- 3. Side thumb
		addPart(tool, "Thumb", Vector3.new(0.16, 0.35, 0.25), Color3.fromRGB(245, 245, 245), Enum.Material.SmoothPlastic, CFrame.new(0, 0.9, -0.55) * CFrame.Angles(0, 0, math.rad(-25)))
		
		-- Clone the precompiled LocalScript from ReplicatedStorage
		local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
		local slapScriptTemplate = sharedFolder:WaitForChild("SlapScript")
		local localScript = slapScriptTemplate:Clone()
		localScript.Name = "SlapScript"
		localScript.Parent = tool
		
		tool.Parent = ReplicatedStorage
	end
	return tool
end

-- Helper to get or build the Rope tool
local function getOrCreateRopeTool()
	local tool = ReplicatedStorage:FindFirstChild("Rope")
	if not tool then
		tool = Instance.new("Tool")
		tool.Name = "Rope"
		tool.RequiresHandle = true
		tool.ToolTip = "Left Click on a player to Tie them to you!"
		
		-- Base grip handle
		local handle = Instance.new("Part")
		handle.Name = "Handle"
		handle.Size = Vector3.new(0.3, 0.8, 0.3)
		handle.Color = Color3.fromRGB(80, 50, 30)
		handle.Material = Enum.Material.Wood
		handle.Parent = tool
		
		-- Build a magic wand wrapped in gold rope cords with a glowing crystal tip
		-- 1. Wand shaft
		addPart(tool, "Shaft", Vector3.new(0.2, 1.1, 0.2), Color3.fromRGB(110, 80, 50), Enum.Material.Wood, CFrame.new(0, 0.6, 0))
		-- 2. Rope coil binding
		addPart(tool, "Coil", Vector3.new(0.5, 0.3, 0.5), Color3.fromRGB(210, 160, 45), Enum.Material.Fabric, CFrame.new(0, 0.2, 0))
		-- 3. Glowing rope magic tip
		addPart(tool, "Tip", Vector3.new(0.35, 0.35, 0.35), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, CFrame.new(0, 1.25, 0))
		
		-- Clone the precompiled LocalScript from ReplicatedStorage
		local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
		local ropeScriptTemplate = sharedFolder:WaitForChild("RopeScript")
		local localScript = ropeScriptTemplate:Clone()
		localScript.Name = "RopeScript"
		localScript.Parent = tool
		
		tool.Parent = ReplicatedStorage
	end
	return tool
end

function AdminService:Initialize()
	print("[Hangout cafe] AdminService: Initializing...")
	
	-- 1. Setup RemoteEvent and RemoteFunction for communication
	local adminEvent = ReplicatedStorage:FindFirstChild("AdminEvent")
	if not adminEvent then
		adminEvent = Instance.new("RemoteEvent")
		adminEvent.Name = "AdminEvent"
		adminEvent.Parent = ReplicatedStorage
	end
	
	local adminCheck = ReplicatedStorage:FindFirstChild("AdminCheck")
	if not adminCheck then
		adminCheck = Instance.new("RemoteFunction")
		adminCheck.Name = "AdminCheck"
		adminCheck.Parent = ReplicatedStorage
	end
	
	-- Initialize/Build templates on startup
	getOrCreateHandGun()
	getOrCreateSlapTool()
	getOrCreateRopeTool()
	
	-- Secure the Gold Chain Gun if inserted into Workspace or ServerStorage on startup
	local ServerStorage = game:GetService("ServerStorage")
	local startupSecured = ReplicatedStorage:FindFirstChild("6 gold chain guns") 
		or ReplicatedStorage:FindFirstChild("Admin Gun")
		or ServerStorage:FindFirstChild("6 gold chain guns")
		or ServerStorage:FindFirstChild("Admin Gun")
		
	if not startupSecured then
		local found = workspace:FindFirstChild("6 gold chain guns") or workspace:FindFirstChild("Admin Gun")
		if found and found:IsA("Tool") then
			found.Parent = ReplicatedStorage
			print("[Hangout cafe] Gold Gun found in Workspace on startup and secured in ReplicatedStorage.")
		end
	end
	
	-- 2. Handle client admin check requests
	adminCheck.OnServerInvoke = function(player)
		return isAdmin(player)
	end
	
	-- 3. Handle admin command executions
	adminEvent.OnServerEvent:Connect(function(player, commandName, targetName, value)
		-- Security check: Verify sender is actually an admin!
		if not isAdmin(player) then
			warn("[Hangout cafe] Security alert: Non-admin " .. player.Name .. " attempted to fire admin event!")
			return
		end
		
		print("[Hangout cafe] Admin " .. player.Name .. " executed command: " .. tostring(commandName) .. " (Target: " .. tostring(targetName) .. ", Value: " .. tostring(value) .. ")")
		
		if commandName == "Kick" then
			local target = Players:FindFirstChild(targetName)
			if target then
				target:Kick("Kicked by admin: " .. player.Name)
			end
			
		elseif commandName == "Teleport" then
			local target = Players:FindFirstChild(targetName)
			if target and target.Character and player.Character then
				local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
				local adminHRP = player.Character:FindFirstChild("HumanoidRootPart")
				
				if targetHRP and adminHRP then
					if value == "ToPlayer" then
						adminHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, -3)
					elseif value == "ToMe" then
						targetHRP.CFrame = adminHRP.CFrame * CFrame.new(0, 0, -3)
					end
				end
			end
			
		elseif commandName == "Speed" then
			local target = Players:FindFirstChild(targetName)
			if target and target.Character then
				local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = tonumber(value) or 16
				end
			end
			
		elseif commandName == "Heal" then
			local target = Players:FindFirstChild(targetName)
			if target and target.Character then
				local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Health = humanoid.MaxHealth
				end
			end
			
		elseif commandName == "TimeOfDay" then
			local timeVal = tonumber(value)
			if timeVal then
				Lighting.ClockTime = timeVal
			end
			
		-- ──────────────────────────────────────────────
		-- Prank Commands
		-- ──────────────────────────────────────────────
		elseif commandName == "Slap" then
			local target = Players:FindFirstChild(targetName)
			if target and target.Character and player.Character then
				local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
				local adminHRP = player.Character:FindFirstChild("HumanoidRootPart")
				local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
				
				if targetHRP and adminHRP then
					-- Visual slap shockwave expansion ring
					local ring = Instance.new("Part")
					ring.Name = "SlapRing"
					ring.Material = Enum.Material.Neon
					ring.Color = Color3.fromRGB(220, 50, 150)
					ring.Shape = Enum.PartType.Cylinder
					ring.Size = Vector3.new(0.1, 2.5, 2.5)
					ring.Anchored = true
					ring.CanCollide = false
					ring.CFrame = targetHRP.CFrame * CFrame.Angles(math.rad(90), 0, 0)
					ring.Parent = workspace
					
					task.spawn(function()
						for i = 1, 10 do
							task.wait(0.02)
							if ring and ring.Parent then
								ring.Size = ring.Size + Vector3.new(0, 0.45, 0.45)
								ring.Transparency = i / 10
							end
						end
						if ring and ring.Parent then ring:Destroy() end
					end)
					
					-- Fling target player (does NOT take health)
					local pushDir = (targetHRP.Position - adminHRP.Position).Unit
					if pushDir.Magnitude == 0 or pushDir ~= pushDir then
						pushDir = Vector3.new(0, 0, -1)
					end
					
					-- Use a temporary BodyVelocity to reliably override client-side locomotion and physics network ownership
					local bv = Instance.new("BodyVelocity")
					bv.MaxForce = Vector3.new(1e6, 1e6, 1e6) -- Overpowers any player mass/friction
					bv.Velocity = pushDir * 95 + Vector3.new(0, 45, 0)
					bv.Parent = targetHRP
					Debris:AddItem(bv, 0.2) -- Applies strong impulse force for 0.2 seconds
					
					-- Platformstand them briefly so they fall over and slide
					if targetHum then
						targetHum.PlatformStand = true
						task.delay(1.5, function()
							if targetHum and targetHum.Parent then
								targetHum.PlatformStand = false
							end
						end)
					end
				end
			end
			
		elseif commandName == "Rope" then
			local target = Players:FindFirstChild(targetName)
			if target and target.Character and player.Character then
				local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
				local adminHRP = player.Character:FindFirstChild("HumanoidRootPart")
				
				if targetHRP and adminHRP then
					local ropeName = "RopePrank_" .. player.Name .. "_" .. target.Name
					local existingRope = adminHRP:FindFirstChild(ropeName)
					
					if existingRope then
						existingRope:Destroy()
						local att = targetHRP:FindFirstChild(ropeName .. "_att")
						if att then att:Destroy() end
						local att2 = adminHRP:FindFirstChild(ropeName .. "_att")
						if att2 then att2:Destroy() end
					else
						local attAdmin = Instance.new("Attachment")
						attAdmin.Name = ropeName .. "_att"
						attAdmin.Parent = adminHRP
						
						local attTarget = Instance.new("Attachment")
						attTarget.Name = ropeName .. "_att"
						attTarget.Parent = targetHRP
						
						local rope = Instance.new("RopeConstraint")
						rope.Name = ropeName
						rope.Attachment0 = attAdmin
						rope.Attachment1 = attTarget
						rope.Length = 10
						rope.Visible = true
						rope.Thickness = 0.15
						rope.Color = BrickColor.new("Gold")
						rope.Parent = adminHRP
					end
				end
			end
			
		elseif commandName == "Morph" then
			local target = Players:FindFirstChild(targetName)
			if target and player.Character then
				local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local success, desc = pcall(function()
						return Players:GetHumanoidDescriptionFromUserId(target.UserId)
					end)
					if success and desc then
						pcall(function()
							humanoid:ApplyDescription(desc)
						end)
					end
				end
			end
			
		elseif commandName == "GiveGun" then
			local target = Players:FindFirstChild(targetName)
			if target then
				local backpack = target:FindFirstChild("Backpack")
				if backpack then
					local gun = getOrCreateHandGun()
					local clone = gun:Clone()
					
					-- Hot-reload latest client script from ReplicatedStorage.Shared
					local oldScript = clone:FindFirstChild("GunScript")
					if oldScript then oldScript:Destroy() end
					
					local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
					local scriptTemplate = sharedFolder:WaitForChild("GunScript")
					local localScript = scriptTemplate:Clone()
					localScript.Name = "GunScript"
					localScript.Parent = clone
					
					clone.Parent = backpack
				end
			end
			
		elseif commandName == "GiveSlap" then
			local target = Players:FindFirstChild(targetName)
			if target then
				local backpack = target:FindFirstChild("Backpack")
				if backpack then
					local tool = getOrCreateSlapTool()
					local clone = tool:Clone()
					
					-- Hot-reload latest client script from ReplicatedStorage.Shared
					local oldScript = clone:FindFirstChild("SlapScript")
					if oldScript then oldScript:Destroy() end
					
					local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
					local scriptTemplate = sharedFolder:WaitForChild("SlapScript")
					local localScript = scriptTemplate:Clone()
					localScript.Name = "SlapScript"
					localScript.Parent = clone
					
					clone.Parent = backpack
				end
			end
			
		elseif commandName == "GiveRope" then
			local target = Players:FindFirstChild(targetName)
			if target then
				local backpack = target:FindFirstChild("Backpack")
				if backpack then
					local tool = getOrCreateRopeTool()
					local clone = tool:Clone()
					
					-- Hot-reload latest client script from ReplicatedStorage.Shared
					local oldScript = clone:FindFirstChild("RopeScript")
					if oldScript then oldScript:Destroy() end
					
					local sharedFolder = ReplicatedStorage:WaitForChild("Shared")
					local scriptTemplate = sharedFolder:WaitForChild("RopeScript")
					local localScript = scriptTemplate:Clone()
					localScript.Name = "RopeScript"
					localScript.Parent = clone
					
					clone.Parent = backpack
				end
			end
			
		elseif commandName == "GiveGoldGun" then
			local target = Players:FindFirstChild(targetName)
			if target then
				local backpack = target:FindFirstChild("Backpack")
				if backpack then
					-- Find the tool template
					local ServerStorage = game:GetService("ServerStorage")
					local goldGun = ReplicatedStorage:FindFirstChild("6 gold chain guns") 
						or ReplicatedStorage:FindFirstChild("Admin Gun")
						or ServerStorage:FindFirstChild("6 gold chain guns")
						or ServerStorage:FindFirstChild("Admin Gun")
						
					-- Fallback search in Workspace (and secure it in ReplicatedStorage)
					if not goldGun then
						local found = workspace:FindFirstChild("6 gold chain guns") or workspace:FindFirstChild("Admin Gun")
						if found and found:IsA("Tool") then
							found.Parent = ReplicatedStorage
							goldGun = found
							print("[Hangout cafe] Secured gold gun from Workspace during give command.")
						end
					end
					
					if goldGun then
						local clone = goldGun:Clone()
						clone.Parent = backpack
						print("[Hangout cafe] Successfully gave gold chain guns to: " .. target.Name)
					else
						warn("[Hangout cafe] Gold chain guns tool template not found!")
					end
				end
			end
			
		elseif commandName == "SpawnCar" then
			local target = Players:FindFirstChild(targetName) or player
			if target and target.Character then
				local char = target.Character
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Clean up existing spawned car for this target if present
					local existingCar = workspace:FindFirstChild("AdminCar_" .. target.Name)
					if existingCar then
						existingCar:Destroy()
					end
					
					-- Find the pristine Koenigsegg Jesko car model
					local carModel = getKoenigseggCarModel()
					if carModel then
						local clone = carModel:Clone()
						clone.Name = "AdminCar_" .. target.Name
						
						-- Calculate precise bounding box to position car safely ABOVE ground
						local bboxCFrame, bboxSize = clone:GetBoundingBox()
						local lookDir = hrp.CFrame.LookVector
						local spawnDist = math.max(bboxSize.Z, bboxSize.X) / 2 + 8
						local targetPos = hrp.Position + (lookDir * spawnDist)
						
						-- Position center of bounding box 2 studs above floor
						targetPos = Vector3.new(targetPos.X, hrp.Position.Y + (bboxSize.Y / 2) + 2, targetPos.Z)
						local finalCFrame = CFrame.lookAt(targetPos, targetPos + lookDir)
						
						clone:PivotTo(finalCFrame)
						clone.Parent = workspace
						
						print("[Hangout cafe] Successfully spawned pristine Koenigsegg Jesko car for: " .. target.Name)
					else
						warn("[Hangout cafe] Koenigsegg Jesko car model not found! Place '2021 Koenigsegg Jesko // Rosh' in ServerStorage, ReplicatedStorage, or Workspace.")
					end
				end
			end
			
		elseif commandName == "ShootGun" then
			-- Shoot logic for the Hand Gun (fires a laser ray and KILLS the player hit)
			local targetPos = value
			if typeof(targetPos) == "Vector3" and player.Character then
				local char = player.Character
				local tool = char:FindFirstChild("Hand Gun")
				local handle = tool and tool:FindFirstChild("Handle")
				
				local origin = handle and handle.Position or (char:FindFirstChild("Head") and char.Head.Position) or Vector3.new(0, 10, 0)
				
				-- 1. Aim Vector & Muzzle position
				local muzzlePos = handle and (handle.CFrame * CFrame.new(0, 0.4, -1.5)).Position or origin
				
				-- 2. Play gun shot sound
				local sound = Instance.new("Sound")
				sound.SoundId = "rbxassetid://130113322"
				sound.Volume = 1.2
				sound.Parent = handle or char:FindFirstChild("Head") or char
				sound:Play()
				Debris:AddItem(sound, 3)
				
				-- 3. Visual Muzzle Flash sphere
				local flash = Instance.new("Part")
				flash.Name = "MuzzleFlash"
				flash.Material = Enum.Material.Neon
				flash.Color = Color3.fromRGB(255, 180, 50)
				flash.Shape = Enum.PartType.Ball
				flash.Size = Vector3.new(0.8, 0.8, 0.8)
				flash.Anchored = true
				flash.CanCollide = false
				flash.CFrame = CFrame.new(muzzlePos)
				flash.Parent = workspace
				Debris:AddItem(flash, 0.05)
				
				-- 4. Raycast calculation
				local direction = (targetPos - muzzlePos).Unit * 350
				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {char}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
				
				local result = workspace:Raycast(muzzlePos, direction, rayParams)
				local hitPos = targetPos
				
				if result then
					hitPos = result.Position
					local hitPart = result.Instance
					local hitChar = hitPart:FindFirstAncestorOfClass("Model")
					local hitHum = hitChar and hitChar:FindFirstChildOfClass("Humanoid")
					local hitHRP = hitChar and hitChar:FindFirstChild("HumanoidRootPart")
					
					if hitHum and hitHRP then
						-- Kill the target player instantly!
						hitHum.Health = 0
						
						-- Fling target player's dead body (ragdoll)
						local forceDir = (hitHRP.Position - muzzlePos).Unit
						if forceDir.Magnitude == 0 or forceDir ~= forceDir then
							forceDir = Vector3.new(0, 0, -1)
						end
						hitHRP.AssemblyLinearVelocity = forceDir * 110 + Vector3.new(0, 55, 0)
					end
					
					-- 5. Visual Bullet Collision Sparks
					for i = 1, 6 do
						local p = Instance.new("Part")
						p.Name = "BulletSpark"
						p.Material = Enum.Material.Neon
						p.Color = Color3.fromRGB(255, 80, 30)
						p.Size = Vector3.new(0.18, 0.18, 0.18)
						p.CanCollide = false
						p.Position = hitPos
						p.AssemblyLinearVelocity = Vector3.new(
							math.random(-25, 25),
							math.random(15, 35),
							math.random(-25, 25)
						)
						p.Parent = workspace
						
						task.spawn(function()
							for trans = 1, 10 do
								task.wait(0.04)
								if p and p.Parent then
									p.Transparency = trans / 10
								end
							end
							if p and p.Parent then p:Destroy() end
						end)
					end
				end
				
				-- 6. Create a neon laser visual beam
				local beam = Instance.new("Part")
				beam.Name = "LaserBeam"
				beam.Material = Enum.Material.Neon
				beam.Color = Color3.fromRGB(255, 30, 30)
				beam.Anchored = true
				beam.CanCollide = false
				
				local dist = (hitPos - muzzlePos).Magnitude
				beam.Size = Vector3.new(0.2, 0.2, dist)
				beam.CFrame = CFrame.lookAt(muzzlePos, hitPos) * CFrame.new(0, 0, -dist/2)
				beam.Parent = workspace
				
				-- Fade out laser
				task.spawn(function()
					for i = 1, 10 do
						task.wait(0.02)
						if beam and beam.Parent then
							beam.Transparency = i / 10
						end
					end
					if beam and beam.Parent then
						beam:Destroy()
					end
				end)
			end
		end
	end)
end

return AdminService
