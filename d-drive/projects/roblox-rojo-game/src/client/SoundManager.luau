--!strict
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local SoundManager = {}

local bgm: Sound? = nil
local ORIGINAL_VOL = 0.3

function SoundManager.Init()
	bgm = Instance.new("Sound")
	bgm.Name = "BackgroundMusic"
	-- Swapping to a confirmed high-quality ethereal Roblox audio asset
	bgm.SoundId = "rbxassetid://1843358057" 
	bgm.Volume = ORIGINAL_VOL
	bgm.Looped = true
	bgm.Parent = SoundService
	bgm:Play()
end

function SoundManager.DuckMusic(duration: number)
	if not bgm then return end
	
	local duckIn = TweenService:Create(bgm, TweenInfo.new(0.5), {Volume = ORIGINAL_VOL * 0.3})
	duckIn:Play()
	
	task.delay(duration, function()
		if not bgm then return end
		local duckOut = TweenService:Create(bgm, TweenInfo.new(1.5), {Volume = ORIGINAL_VOL})
		duckOut:Play()
	end)
end

function SoundManager:PlaySound(name: string, volume: number?)
	local soundId = ""
	if name == "Click" then
		soundId = "rbxassetid://147722227"
	elseif name == "Cha-Ching" then
		soundId = "rbxassetid://131102573"
	elseif name == "Found" then
		soundId = "rbxassetid://138090596"
	elseif name == "Fanfare" then
		soundId = "rbxassetid://9120484556" -- Ethereal Victory Fanfare
	end
	
	if soundId ~= "" then
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = volume or 1
		sound.Parent = SoundService
		sound:Play()
		sound.Ended:Connect(function() sound:Destroy() end)
	end
end

-- Auto-initialize on load
task.spawn(SoundManager.Init)

return SoundManager
