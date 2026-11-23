local RideService = {}

-- Helper to check if a part should remain anchored (support posts, frames, etc.)
local function isPartStatic(part, isSeesaw, seatPart)
	local name = part.Name:lower()
	if isSeesaw then
		-- If this is the active moving plank itself, it is NOT static
		if part == seatPart then
			return false
		end
		-- For seesaws, only the base stand, pivot, or frame should be static
		return name:match("base") or 
		       name:match("stand") or 
		       name:match("ground") or 
		       name:match("post") or 
		       name:match("pillar") or
		       name:match("support") or
		       name:match("pivot") or
		       name:match("hinge") or
		       name:match("mount") or
		       name:match("frame")
	else
		-- For swings/others, anchor the frame bars, supports, poles, etc.
		return name:match("base") or 
		       name:match("frame") or 
		       name:match("stand") or 
		       name:match("support") or 
		       name:match("pole") or 
		       name:match("post") or 
		       name:match("pillar") or 
		       name:match("ground") or 
		       name:match("holder") or
		       name:match("anchor") or
		       name:match("bar") or
		       name:match("beam") or
		       name:match("log") or
		       name:match("wood") or
		       name:match("metal") or
		       name:match("steel") or
		       name:match("truss") or
		       name:match("platform") or
		       name:match("floor") or
		       name:match("hanger") or
		       name:match("mount") or
		       name:match("structure") or
		       name:match("roof") or
		       name:match("wall") or
		       name:match("step") or
		       name:match("ladder")
	end
end

-- Helper to weld assembly parts to their main moving parent
local function weldSeatAssembly(seat, parts, keepSeatAnchored, isSeesaw)
	-- Disable collisions and make massless first (while still anchored)
	seat.CanCollide = false
	seat.Massless = true
	seat.Anchored = keepSeatAnchored -- Keep it anchored on server for client animation
	
	-- Create all welds while everything is still safely anchored!
	-- This prevents parts from dropping/shifting due to gravity before being locked.
	for _, part in pairs(parts) do
		part.CanCollide = false
		part.Massless = true
		
		local weld = part:FindFirstChild("RideWeld")
		if not weld then
			weld = Instance.new("WeldConstraint")
			weld.Name = "RideWeld"
			weld.Part0 = seat
			weld.Part1 = part
			weld.Parent = part
		end
	end
	
	-- Once all welds are established, safely unanchor the moving parts (chains/ropes)
	for _, part in pairs(parts) do
		if isPartStatic(part, isSeesaw, seat) then
			part.Anchored = true
		else
			part.Anchored = false
			pcall(function()
				part:SetNetworkOwner(nil)
			end)
		end
	end
	
	-- Network ownership on the main seat (only if unanchored)
	if not keepSeatAnchored then
		pcall(function()
			seat:SetNetworkOwner(nil)
		end)
	end
end

-- Divides non-static moving parts among the closest active seats/planks (Voronoi distance mapping)
local function getAssemblyParts(seat, ride, allSeats, isSwing, isSeesaw)
	local parts = {}
	local parent = seat.Parent
	
	-- If it's structured in sub-models, use the sub-model's descendants
	if parent and parent:IsA("Model") and parent ~= ride then
		for _, part in pairs(parent:GetDescendants()) do
			if part:IsA("BasePart") and part ~= seat then
				if not isPartStatic(part, isSeesaw, seat) then
					table.insert(parts, part)
				end
			end
		end
	else
		-- Flat hierarchy: map each moving part to the nearest seat
		for _, part in pairs(ride:GetDescendants()) do
			if part:IsA("BasePart") and part ~= seat and not table.find(allSeats, part) then
				if not isPartStatic(part, isSeesaw, seat) then
					-- For swings, only include parts horizontally close to the seat (radius < 5.0 studs)
					-- to prevent unanchoring frame posts that have generic names like "Part"
					local isClose = true
					if isSwing then
						local horizDist = (Vector2.new(part.Position.X, part.Position.Z) - Vector2.new(seat.Position.X, seat.Position.Z)).Magnitude
						isClose = horizDist < 5.0
					end
					
					if isClose then
						local closestSeat = nil
						local minDistance = math.huge
						
						for _, s in pairs(allSeats) do
							local dist = (part.Position - s.Position).Magnitude
							if dist < minDistance then
								minDistance = dist
								closestSeat = s
							end
						end
						
						if closestSeat == seat then
							table.insert(parts, part)
						end
					end
				end
			end
		end
	end
	return parts
end

-- Recursively finds all active parts (e.g. seats, planks) based on name or class type
local function findActiveParts(ride, namePattern, isSeatSearch)
	local active = {}
	for _, child in pairs(ride:GetDescendants()) do
		if child:IsA("BasePart") then
			local name = child.Name:lower()
			local match = name:match(namePattern)
			local isActualSeat = isSeatSearch and (
				child:IsA("Seat") or 
				child:IsA("VehicleSeat") or
				name:match("seat") or
				name:match("tire") or
				name:match("wheel")
			)
			
			if match or isActualSeat then
				table.insert(active, child)
			end
		end
	end
	return active
end

-- Smart seesaw plank detector: finds the long horizontal board by shape size (ignoring static checks)
local function findSeesawPlank(ride)
	local explicit = findActiveParts(ride, "plank", false)
	if #explicit == 0 then explicit = findActiveParts(ride, "board", false) end
	if #explicit == 0 then explicit = findActiveParts(ride, "moving", false) end
	if #explicit == 0 then explicit = findActiveParts(ride, "rotate", false) end
	if #explicit == 0 then explicit = findActiveParts(ride, "swingbase", false) end -- Matches custom board names
	if #explicit > 0 then return explicit[1] end
	
	-- Fallback to the largest horizontal part in the model
	local largestPart = nil
	local maxVolume = 0
	for _, child in pairs(ride:GetDescendants()) do
		if child:IsA("BasePart") then
			local size = child.Size
			-- Seesaw planks are long horizontally (length > 5, height < 3)
			if (size.X > 5 or size.Z > 5) and size.Y < 3 then
				local volume = size.X * size.Y * size.Z
				if volume > maxVolume then
					maxVolume = volume
					largestPart = child
				end
			end
		end
	end
	return largestPart or ride.PrimaryPart
end

-- Helper to check if a model is a Seesaw
local function isSeesawModel(model)
	if not model:IsA("Model") then return false end
	local name = model.Name:lower()
	if name:match("seesaw") or name:match("seashow") then
		return true
	end
	-- Check if any direct child is named "swingbase" (case-insensitive)
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("BasePart") and child.Name:lower() == "swingbase" then
			return true
		end
	end
	return false
end

-- Helper to check if a model is nested inside a Seesaw
local function isDescendantOfSeesaw(model)
	local current = model.Parent
	while current and current ~= workspace do
		if isSeesawModel(current) then
			return true
		end
		current = current.Parent
	end
	return false
end

function RideService:Initialize()
	print("[Hangout cafe] RideService: Monitoring for attractions...")
	
	-- Monitor Workspace for Rides
	workspace.DescendantAdded:Connect(function(descendant)
		if self:IsRide(descendant) then
			self:ActivateRide(descendant)
		end
	end)
	
	for _, descendant in pairs(workspace:GetDescendants()) do
		if self:IsRide(descendant) then
			self:ActivateRide(descendant)
		end
	end
end

function RideService:IsRide(model)
	if not model:IsA("Model") then return false end
	local name = model.Name:lower()
	local isSeesaw = isSeesawModel(model)
	local isTarget = name:match("ferris") or 
	                 name:match("carousel") or 
	                 name:match("ride") or 
	                 name:match("spin") or 
	                 isSeesaw or 
	                 name:match("swing")
	if not isTarget then return false end
	
	-- Ignore swing sub-models if they are nested inside a Seesaw model
	if name:match("swing") and not isSeesaw and isDescendantOfSeesaw(model) then
		return false
	end
	
	-- Skip parent models if they contain child models that are also rides
	for _, child in pairs(model:GetChildren()) do
		if child:IsA("Model") and self:IsRide(child) then
			return false
		end
	end
	
	return true
end

function RideService:ActivateRide(ride)
	print("[Hangout cafe] Activating Ride: " .. ride.Name)
	
	local name = ride.Name:lower()
	local isSeesaw = isSeesawModel(ride)
	local isSwingsOrSeesaw = isSeesaw or name:match("swing")
	
	-- 1. Disable legacy/broken ride scripts for swings and seesaws, enable for others
	local hasScript = false
	for _, item in pairs(ride:GetDescendants()) do
		if item:IsA("Script") or item:IsA("LocalScript") then
			if isSwingsOrSeesaw then
				item.Disabled = true
				print("[Hangout cafe] Overriding legacy script: " .. item:GetFullName())
			else
				item.Disabled = false
				hasScript = true
			end
		end
	end
	
	-- 2. If it has a script, we STOP here to avoid clashing (only for spinning rides)
	if not isSwingsOrSeesaw and hasScript then 
		print("[Hangout cafe] Ride has its own script. Letting it run...")
		return 
	end
	
	-- 3. Clean up legacy physical constraints & joints that might fight CFrame animation
	if isSwingsOrSeesaw then
		for _, item in pairs(ride:GetDescendants()) do
			if item:IsA("Constraint") or item:IsA("JointInstance") then
				if item.Name ~= "RideWeld" and not item:IsA("Motor6D") then
					pcall(function()
						item:Destroy()
					end)
				end
			end
		end
	end
	
	if isSeesaw then
		-- ── SEESAW / SEASHOW MODE ──
		local plank = findSeesawPlank(ride)
		
		if plank and plank:IsA("BasePart") then
			local assembly = getAssemblyParts(plank, ride, {plank}, false, true) -- Seesaw mode = true
			weldSeatAssembly(plank, assembly, true, true) -- Keep plank anchored on server, Seesaw mode = true
		end
		print("[Hangout cafe] Seesaw active (client animated) for: " .. ride.Name)
		
	elseif name:match("swing") then
		-- ── SWING MODE ──
		local seats = findActiveParts(ride, "seat", true)
		if #seats == 0 then seats = findActiveParts(ride, "moving", true) end
		if #seats == 0 then seats = findActiveParts(ride, "rotate", true) end
		
		for idx, seat in ipairs(seats) do
			if seat:IsA("BasePart") then
				local assembly = getAssemblyParts(seat, ride, seats, true, false) -- Seesaw mode = false
				weldSeatAssembly(seat, assembly, true, false) -- Keep seat anchored on server, Seesaw mode = false
			end
		end
		print("[Hangout cafe] Swings active (client animated) for: " .. ride.Name .. " (Seats: " .. #seats .. ")")
		
	else
		-- ── SPIN MODE (Ferris wheel, Carousel, Spinner, etc.) ──
		local rotatePart = ride:FindFirstChild("Rotate", true) or 
		                   ride:FindFirstChild("Moving", true) or 
		                   ride.PrimaryPart
		
		if rotatePart and rotatePart:IsA("BasePart") then
			local assembly = getAssemblyParts(rotatePart, ride, {rotatePart}, false, false) -- Seesaw mode = false
			weldSeatAssembly(rotatePart, assembly, false, false) -- Unanchor rotating part on server, Seesaw mode = false
			
			if not rotatePart:FindFirstChildOfClass("AngularVelocity") then
				local att = Instance.new("Attachment", rotatePart)
				local vel = Instance.new("AngularVelocity")
				vel.Attachment0 = att
				vel.MaxTorque = 1000000
				vel.AngularVelocity = Vector3.new(0, 0.5, 0)
				
				local boundsPos, boundsSize = ride:GetBoundingBox()
				if name:match("ferris") then
					if boundsSize.X < boundsSize.Z then
						vel.AngularVelocity = Vector3.new(0.3, 0, 0)
					else
						vel.AngularVelocity = Vector3.new(0, 0, 0.3)
					end
				end
				
				vel.Parent = rotatePart
			end
			
			print("[Hangout cafe] Safe Spin activated for: " .. ride.Name)
		end
	end
end

return RideService
