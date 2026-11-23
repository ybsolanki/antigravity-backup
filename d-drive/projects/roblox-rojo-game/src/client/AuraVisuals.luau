--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local AuraVisuals = {}

local AURA_TAG = "CurrentAuraInstance"

-- The Aesthetic Vibe Color Map & Sounds
-- (Using placeholder Roblox HQ audio catalog IDs for the sound types)
local AuraAttributes = {
	-- Basic (Pop)
	["Common"] = { Color = Color3.fromRGB(255, 255, 255), Boom = "rbxassetid://136192982258685", Tier = "Basic" },   
	["Uncommon"] = { Color = Color3.fromRGB(57, 255, 250), Boom = "rbxassetid://136192982258685", Tier = "Basic" },  
	
	-- Rare / Epic (Chime)
	["Ruby"] = { Color = Color3.fromRGB(231, 54, 54), Boom = "rbxassetid://139699799282289", Tier = "Rare" },       
	["Magnetic"] = { Color = Color3.fromRGB(177, 121, 210), Boom = "rbxassetid://139699799282289", Tier = "Rare" }, 
	["Smiley"] = { Color = Color3.fromRGB(246, 255, 0), Boom = "rbxassetid://139699799282289", Tier = "Epic" },
	["Undead"] = { Color = Color3.fromRGB(46, 204, 113), Boom = "rbxassetid://139699799282289", Tier = "Epic" },
	
	-- Unique & Legendary & Mythic (Boom)
	-- Unique & Legendary & Mythic (Boom)
	["Stormal"] = { Color = Color3.fromRGB(0, 165, 255), Boom = "rbxassetid://139699799282289", Tier = "Unique" },    
	["Raven"] = { Color = Color3.fromRGB(44, 62, 80), Boom = "rbxassetid://139699799282289", Tier = "Legendary" },
	["Astral"] = { Color = Color3.fromRGB(155, 89, 182), Boom = "rbxassetid://139699799282289", Tier = "Mythic" },
	["Duskreaver"] = { Color = Color3.fromRGB(52, 73, 94), Boom = "rbxassetid://139699799282289", Tier = "Mythic" },
	
	-- Fallback
	["Default"] = { Color = Color3.fromRGB(200, 200, 200), Boom = "rbxassetid://136192982258685", Tier = "Basic" }
}

-------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------

local function CreateSmoothTransparency(): NumberSequence
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),    -- Start invisible
		NumberSequenceKeypoint.new(0.3, 0.4), -- Fade in to slightly transparent
		NumberSequenceKeypoint.new(0.7, 0.4), -- Hold
		NumberSequenceKeypoint.new(1, 1)     -- Fade out invisible
	})
end

function AuraVisuals.CleanupAura(character: Model)
	if not character then return end
	
	-- Clean anything tagged with AURA_TAG inside the character (lights, attachments, particles)
	for _, desc in character:GetDescendants() do
		if desc.Name == AURA_TAG then
			desc:Destroy()
		end
	end
end

local function ApplyScreenShake(intensity: number)
	local camera = Workspace.CurrentCamera
	if not camera then return end
	
	local duration = 0.5
	local startTime = os.clock()
	
	local connection
	connection = RunService.RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed >= duration then
			connection:Disconnect()
			return
		end
		
		local fade = 1 - (elapsed / duration)
		local offset = Vector3.new(
			(math.random() - 0.5) * intensity * fade,
			(math.random() - 0.5) * intensity * fade,
			(math.random() - 0.5) * intensity * fade
		)
		camera.CFrame = camera.CFrame * CFrame.new(offset)
	end)
end

-------------------------------------------------------------------------------
-- FULL-BODY AURA GENERATOR
-------------------------------------------------------------------------------

local function ApplyFullBodyAura(character: Model, attr: table, targetTotalRate: number)
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if not rootPart then return end
	
	-- The PointLight needs a brighter version of the color to be visible if the Hex is very dark (like Raven/Duskreaver)
	local h, s, v = attr.Color:ToHSV()
	local glowColor = attr.Color
	if v < 0.5 then
		glowColor = Color3.fromHSV(h, s, 1) -- Maximize the Value (Brightness) for the light source
	end
	
	-- Dynamic Light Brightness Scaling
	local brightness = 1 -- Basic Tiers
	if attr.Tier == "Rare" or attr.Tier == "Epic" then brightness = 3
	elseif attr.Tier == "Unique" or attr.Tier == "Legendary" then brightness = 4
	elseif attr.Tier == "Mythic" then brightness = 5 end
	
	-- 1. Glow Light on HumanoidRootPart matching the aura's color
	local light = Instance.new("PointLight")
	light.Name = AURA_TAG
	light.Color = glowColor
	light.Range = 15
	light.Brightness = brightness
	light.Shadows = true
	light.Parent = rootPart
	
	-- We loop through all children in the character model (Limbs, Head, Torso, etc.)
	local limbParts = {}
	for _, part in character:GetChildren() do
		-- Only apply to actual physical parts, and maybe skip the invisible RootPart itself 
		-- so we don't get double particles in the center of the torso.
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			table.insert(limbParts, part)
		end
	end
	
	-- We divide the targetTotalRate by the number of limbs so the total sum matches what we want
	local ratePerLimb = math.max(1, math.floor(targetTotalRate / #limbParts))
	
	for _, part in limbParts do
		local attachment = Instance.new("Attachment")
		attachment.Name = AURA_TAG
		attachment.Parent = part
		
		local particle = Instance.new("ParticleEmitter")
		particle.Name = AURA_TAG
		
		-- Ultra-Aesthetic Properties
		particle.Color = ColorSequence.new(attr.Color)
		particle.LightInfluence = 0
		particle.LightEmission = 1.0
		particle.SpreadAngle = Vector2.new(180, 180) -- 360 degree coverage
		
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Transparency = CreateSmoothTransparency()
		
		-- Sizing (start small, grow a bit, then shrink)
		particle.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.5, 0.8),
			NumberSequenceKeypoint.new(1, 0)
		})
		
		particle.Lifetime = NumberRange.new(0.6, 1.2)
		particle.Speed = NumberRange.new(1, 2)
		particle.Rate = ratePerLimb 
		particle.Drag = 2
		particle.Parent = attachment
		
		-- Lag Prevention (Mission #26): Disable heavy particles for far away players
		if attr.Tier == "Mythic" then
			task.spawn(function()
				while particle and particle.Parent do
					local camera = Workspace.CurrentCamera
					if camera then
						local dist = (rootPart.Position - camera.CFrame.Position).Magnitude
						local isLocal = player == Players.LocalPlayer
						
						if isLocal or dist < 30 then
							particle.Enabled = true
						else
							particle.Enabled = false
						end
					end
					task.wait(0.5)
				end
			end)
		end
		
		-- Layering: Add Dark Smoke if Mythic Tier
		if attr.Tier == "Mythic" then
			local smoke = Instance.new("ParticleEmitter")
			smoke.Name = AURA_TAG
			smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
			smoke.Color = ColorSequence.new(Color3.fromRGB(15, 15, 18)) -- Very dark grey/black
			smoke.Transparency = CreateSmoothTransparency()
			smoke.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.5, 3),
				NumberSequenceKeypoint.new(1, 5)
			})
			smoke.LightEmission = 0
			smoke.LightInfluence = 1 -- Reacts to world lighting unlike the glowing elements
			smoke.Lifetime = NumberRange.new(1, 2.5)
			smoke.Speed = NumberRange.new(0.5, 1)
			smoke.Rate = math.max(1, math.floor(30 / #limbParts)) -- Caps smoke rate to 30 globally
			smoke.SpreadAngle = Vector2.new(180, 180)
			smoke.Drag = 1
			smoke.Parent = attachment

			-- Lag Prevention (Mission #26)
			task.spawn(function()
				while smoke and smoke.Parent do
					local camera = Workspace.CurrentCamera
					if camera then
						local dist = (rootPart.Position - camera.CFrame.Position).Magnitude
						local isLocal = player == Players.LocalPlayer
						
						if isLocal or dist < 30 then
							smoke.Enabled = true
						else
							smoke.Enabled = false
						end
					end
					task.wait(0.5)
				end
			end)
		end
	end
end

-------------------------------------------------------------------------------
-- 3D SPATIAL SOUND GENERATOR
-------------------------------------------------------------------------------

local function PlayAuraSound(rootPart: BasePart, soundId: string, isLoop: boolean)
	local snd = Instance.new("Sound")
	snd.Name = AURA_TAG
	snd.SoundId = soundId
	
	-- 3D Spatial Audio Settings
	snd.RollOffMode = Enum.RollOffMode.Inverse
	snd.MaxDistance = 50 
	
	snd.Parent = rootPart
	
	if isLoop then
		snd.Looped = true
		snd.Volume = 0.3 -- Keep ambient hums quiet
		snd:Play()
	else
		snd.Volume = 1
		snd.Ended:Connect(function()
			snd:Destroy()
		end)
		snd:Play()
	end
end

-------------------------------------------------------------------------------
-- MAIN EXECUTION
-------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local AuraData = require(Shared:WaitForChild("AuraData"))
local SoundManager = require(script.Parent:WaitForChild("SoundManager"))

function AuraVisuals.EquipAura(player: Player, auraName: string)
	local character = player.Character or player.CharacterAdded:Wait()
	
	AuraVisuals.CleanupAura(character)
	
	-- Determine the rarity to scale the particle density
	local chance = 2 -- Default to Common rate if not found
	for _, a in AuraData.Auras do
		if a.Name == auraName then
			chance = a.Chance
			break
		end
	end
	
	-- Dynamic Rate Formula (Limits at around 200 total particles across the whole body for the rarest auras)
	-- Common (1 in 2) = ~12 total particles
	-- Uncommon (1 in 5) = ~20 total particles
	-- Ruby (1 in 500) = ~50 total particles
	-- Stormal (1 in 90k) = ~120 total particles
	-- Astral (1 in 1M) = ~200 total particles
	local baseTarget = 10 -- Minimum base rate for Common
	local bonusRate = math.clamp(math.log10(chance) * 30, 0, 190) -- Uses log10 so it scales smoothly even up to 2,500,000
	local totalParticleRate = math.floor(baseTarget + bonusRate)
	
	local attr = AuraAttributes[auraName] or AuraAttributes["Default"]
	ApplyFullBodyAura(character, attr, totalParticleRate)
	
	-- Play the impact sound (Pop, Chime, or Boom)
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart
	if rootPart and attr.Boom then
		PlayAuraSound(rootPart, attr.Boom, false)
	end
	
	-- Play Ambient Loop for God-Tiers
	if rootPart and attr.Loop then
		PlayAuraSound(rootPart, attr.Loop, true)
	end
	
	-- Final Polish: Screen Shake and Music Ducking for Rare+ (1 in 500)
	if chance >= 500 then
		local intensity = math.clamp(math.log10(chance) * 0.5, 0.1, 2)
		ApplyScreenShake(intensity)
		SoundManager.DuckMusic(3) -- Duck music for 3 seconds
	end
	
	print("Visually equipped Dynamic Full-Body " .. auraName .. " on " .. player.Name .. " (Density: " .. totalParticleRate .. ")")
end

return AuraVisuals
