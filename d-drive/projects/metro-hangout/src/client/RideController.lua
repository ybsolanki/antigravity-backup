-- RideController.lua
-- Animates swings and seesaws on the client for butter-smooth, lag-free motion.
-- Uses workspace:GetServerTimeNow() for synchronization.

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local RideController = {}
RideController.__index = RideController

function RideController.new()
	return setmetatable({
		activeRides = {}
	}, RideController)
end

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

-- Helper to find active parts (seats, planks)
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
	while current and current ~= Workspace do
		if isSeesawModel(current) then
			return true
		end
		current = current.Parent
	end
	return false
end

function RideController:Initialize()
	print("[Hangout cafe] RideController: Monitoring rides on client...")
	
	-- Register existing rides
	for _, descendant in pairs(Workspace:GetDescendants()) do
		if self:IsRide(descendant) then
			self:RegisterRide(descendant)
		end
	end
	
	-- Listen for new rides
	Workspace.DescendantAdded:Connect(function(descendant)
		if self:IsRide(descendant) then
			self:RegisterRide(descendant)
		end
	end)
	
	-- Start client-side animation loop
	RunService.Heartbeat:Connect(function()
		local serverTime = Workspace:GetServerTimeNow()
		
		for _, rideData in pairs(self.activeRides) do
			if rideData.ride.Parent then
				self:AnimateRideData(rideData, serverTime)
			end
		end
	end)
end

function RideController:IsRide(model)
	if not model:IsA("Model") then return false end
	local name = model.Name:lower()
	local isSeesaw = isSeesawModel(model)
	local isTarget = isSeesaw or name:match("swing")
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

function RideController:RegisterRide(ride)
	if self.activeRides[ride] then return end
	
	local name = ride.Name:lower()
	local boundsPos, boundsSize = ride:GetBoundingBox()
	local isSeesaw = isSeesawModel(ride)
	
	if isSeesaw then
		local plank = findSeesawPlank(ride)
		local plankData = {}
		if plank and plank:IsA("BasePart") then
			local rotAxis = Vector3.new(1, 0, 0)
			if plank.Size.X > plank.Size.Z then
				rotAxis = Vector3.new(0, 0, 1)
			end
			
			table.insert(plankData, {
				part = plank,
				startCFrame = plank.CFrame,
				rotAxis = rotAxis,
				index = 1
			})
		end
		
		self.activeRides[ride] = {
			type = "seesaw",
			ride = ride,
			planks = plankData
		}
		print("[Hangout cafe] Registered client seesaw: " .. ride.Name)
		
	elseif name:match("swing") then
		local seats = findActiveParts(ride, "seat", true)
		if #seats == 0 then seats = findActiveParts(ride, "moving", true) end
		if #seats == 0 then seats = findActiveParts(ride, "rotate", true) end
		
		local seatData = {}
		for idx, seat in ipairs(seats) do
			if seat:IsA("BasePart") then
				local pivotPos = Vector3.new(seat.Position.X, boundsPos.Y + boundsSize.Y/2, seat.Position.Z)
				if pivotPos.Y <= seat.Position.Y then
					pivotPos = seat.Position + Vector3.new(0, 8, 0)
				end
				
				local startPivotCFrame = CFrame.new(pivotPos) * (seat.CFrame - seat.CFrame.Position)
				local relativeCFrame = startPivotCFrame:ToObjectSpace(seat.CFrame)
				
				local rotAxis = Vector3.new(1, 0, 0)
				if seat.Size.Z > seat.Size.X then
					rotAxis = Vector3.new(0, 0, 1)
				end
				
				table.insert(seatData, {
					part = seat,
					startPivotCFrame = startPivotCFrame,
					relativeCFrame = relativeCFrame,
					rotAxis = rotAxis,
					index = idx
				})
			end
		end
		
		self.activeRides[ride] = {
			type = "swing",
			ride = ride,
			seats = seatData
		}
		print("[Hangout cafe] Registered client swing: " .. ride.Name .. " (Seats: " .. #seats .. ")")
	end
end

function RideController:AnimateRideData(rideData, serverTime)
	if rideData.type == "seesaw" then
		local amplitude = 12
		local speed = 2.2
		
		for _, plank in ipairs(rideData.planks) do
			local t = serverTime * speed
			local angle = math.rad(amplitude * math.sin(t + (plank.index * math.pi)))
			plank.part.CFrame = plank.startCFrame * CFrame.fromAxisAngle(plank.rotAxis, angle)
		end
		
	elseif rideData.type == "swing" then
		local amplitude = 22
		local speed = 1.6
		
		for _, seat in ipairs(rideData.seats) do
			local t = serverTime * speed
			local angle = math.rad(amplitude * math.sin(t + (seat.index * 0.7 * math.pi)))
			local rotation = CFrame.fromAxisAngle(seat.rotAxis, angle)
			seat.part.CFrame = seat.startPivotCFrame * rotation * seat.relativeCFrame
		end
	end
end

return RideController.new()
