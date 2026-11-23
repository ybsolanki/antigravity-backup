local LightingSync = {}

function LightingSync:Initialize()
	-- Thematic Colors
	local THEME_COLORS = {
		Cyan = Color3.fromRGB(0, 255, 255),
		Purple = Color3.fromRGB(170, 0, 255),
		White = Color3.fromRGB(255, 255, 255)
	}

	local function processPart(part)
		if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
			-- If it's neon but has no specific name, give it a theme color
			-- We prioritize cyan but can randomize or use specific markers later
			if part.Color == Color3.new(1, 1, 1) or part.Color == Color3.fromRGB(163, 162, 165) then
				part.Color = THEME_COLORS.Cyan
			end
			
			part.Transparency = 0.3 -- Glow effect optimization
		end
	end

	-- Monitor Workspace for new neon parts
	workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			processPart(descendant)
		end
	end)

	-- Process existing parts
	for _, descendant in pairs(workspace:GetDescendants()) do
		if descendant:IsA("BasePart") then
			processPart(descendant)
		end
	end

	print("[Hangout cafe] LightingSync: Ambient Neon protection active")
end

return LightingSync
