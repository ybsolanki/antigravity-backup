-- ChatController.lua
-- Restores Roblox default Chat window and bubble chat

local Players          = game:GetService("Players")
local TextChatService  = game:GetService("TextChatService")
local VoiceChatService = game:GetService("VoiceChatService")

local player     = Players.LocalPlayer
local playerGui  = player:WaitForChild("PlayerGui")

local ChatController = {}
ChatController.__index = ChatController

function ChatController.new()
	return setmetatable({}, ChatController)
end

local function requestMicPermission()
	local ok, hasVoice = pcall(function()
		return VoiceChatService:IsVoiceEnabledForUserIdAsync(player.UserId)
	end)
	if ok and hasVoice then
		print("[Hangout cafe] 🎙️ Voice chat enabled for " .. player.Name)
	else
		print("[Hangout cafe] 🎙️ Voice chat not available (age-gated or disabled)")
	end
end

function ChatController:Initialize()
	-- Request mic permission (async, won't block init)
	task.spawn(requestMicPermission)

	-- Restore default Roblox TextChatService Chat
	pcall(function()
		TextChatService.ChatWindowConfiguration.Enabled  = true
		TextChatService.BubbleChatConfiguration.Enabled  = true
	end)

	-- Enable custom chat tags from player attributes (new TextChatService support)
	pcall(function()
		TextChatService.OnIncomingMessage = function(message)
			local properties = Instance.new("TextChatMessageProperties")
			if message.TextSource then
				local sender = Players:GetPlayerByUserId(message.TextSource.UserId)
				if sender then
					local tag = sender:GetAttribute("ChatTag")
					local color = sender:GetAttribute("TagColor") or "#00FFDD"
					if tag and tag ~= "" then
						properties.PrefixText = string.format("<font color='%s'>[%s]</font> %s", color, tag, message.PrefixText)
					end
				end
			end
			return properties
		end
	end)

	-- Listen to Claw Machine announcements and display them in general chat
	task.spawn(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local clawEvent = ReplicatedStorage:WaitForChild("ClawMachinePrizeEvent", 10)
		if clawEvent then
			clawEvent.OnClientEvent:Connect(function(command, value)
				if command == "SystemMessage" then
					local textChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
					if textChannel then
						textChannel:DisplaySystemMessage(value)
					else
						-- Fallback search inside TextChannels
						for _, channel in ipairs(TextChatService.TextChannels:GetChildren()) do
							if channel:IsA("TextChannel") then
								channel:DisplaySystemMessage(value)
							end
						end
					end
				end
			end)
		end
	end)

	-- Destroy custom chat GUI if it exists
	local old = playerGui:FindFirstChild("MetroChatGui")
	if old then old:Destroy() end

	print("[Hangout cafe] Default Chat Restored ✅")
end

return ChatController.new()
