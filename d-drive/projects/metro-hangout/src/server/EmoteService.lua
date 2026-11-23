-- EmoteService.lua
-- Server-side service that creates interactive emote zones.
-- When a player triggers the proximity prompt, a RemoteEvent is fired to the client to play an animation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Ensure RemoteEvent exists
local EmoteEvent = ReplicatedStorage:FindFirstChild("EmoteEvent")
if not EmoteEvent then
    EmoteEvent = Instance.new("RemoteEvent")
    EmoteEvent.Name = "EmoteEvent"
    EmoteEvent.Parent = ReplicatedStorage
end

local EmoteService = {}
EmoteService.__index = EmoteService

function EmoteService.new()
    local self = setmetatable({}, EmoteService)
    self:Initialize()
    return self
end

function EmoteService:Initialize()
    -- Listen for parts named "EmoteZone" (or with attribute EmoteZone = true)
    workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("BasePart") then
            if descendant.Name == "EmoteZone" or descendant.Name == "DiscoZone" or descendant:GetAttribute("EmoteZone") then
                self:SetupZone(descendant)
            end
        end
    end)
    -- Existing parts
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name == "EmoteZone" or part:GetAttribute("EmoteZone")) then
            self:SetupZone(part)
        end
    end
end

function EmoteService:SetupZone(part)
    -- Avoid duplicate prompts
    if part:FindFirstChild("EmotePrompt") then return end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "EmotePrompt"
    prompt.ActionText = "Dance"
    prompt.ObjectText = "Emote Zone"
    prompt.HoldDuration = 0
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 10
    prompt.Parent = part

    prompt.Triggered:Connect(function(player)
        -- Fire to client to play the default dance animation
        EmoteEvent:FireClient(player, "Dance")
    end)
end

return EmoteService
