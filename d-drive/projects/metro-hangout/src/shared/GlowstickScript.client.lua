local Tool = script.Parent
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Debris = game:GetService("Debris")

local handle = Tool:WaitForChild("Handle")
local trail = nil
local att0, att1 = nil, nil

Tool.Equipped:Connect(function()
	local char = player.Character
	if char and handle then
		att0 = Instance.new("Attachment")
		att0.Position = Vector3.new(0, -0.6, 0)
		att0.Parent = handle
		
		att1 = Instance.new("Attachment")
		att1.Position = Vector3.new(0, 0.6, 0)
		att1.Parent = handle
		
		trail = Instance.new("Trail")
		trail.Attachment0 = att0
		trail.Attachment1 = att1
		trail.Color = ColorSequence.new(handle.Color)
		trail.WidthScale = NumberSequence.new(1)
		trail.Lifetime = 0.4
		trail.LightEmission = 0.8
		trail.Parent = handle
		
		local light = Instance.new("PointLight")
		light.Color = handle.Color
		light.Range = 12
		light.Brightness = 1.5
		light.Parent = handle
	end
end)

Tool.Unequipped:Connect(function()
	if trail then trail:Destroy() trail = nil end
	if att0 then att0:Destroy() att0 = nil end
	if att1 then att1:Destroy() att1 = nil end
	local light = handle:FindFirstChildOfClass("PointLight")
	if light then light:Destroy() end
end)
