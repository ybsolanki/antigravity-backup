--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Mission #36: 5-Second UI Refresh
task.wait(5)

local Shared = ReplicatedStorage:WaitForChild("Shared")
local SyncInventoryEvent = Shared:WaitForChild("Remotes"):WaitForChild("SyncInventory")

-- Trigger a re-sync request or just wait for the server? 
-- The mission says "forces the Collection window to 're-draw' itself".
-- We can fire the event to the client locally if we have the data, 
-- but usually the server would have sent it by now. 
-- Let's check if the UIController has a way to re-draw.

local PlayerGui = player:WaitForChild("PlayerGui")
local ScreenGui = PlayerGui:FindFirstChild("AuraRNGGui")

if ScreenGui then
    -- Mission #36: Force Attribute Change or call a function if exposed
    -- For now, let's signal the UIController via an attribute
    ScreenGui:SetAttribute("RefreshRequest", tick())
    print("Mission #36: Inventory Refresh Triggered.")
end
