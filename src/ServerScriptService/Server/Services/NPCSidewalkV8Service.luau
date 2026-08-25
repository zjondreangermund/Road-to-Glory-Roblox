local NPCSidewalkV8Service = {}

local function collectRoads(root)
	local roads = {}
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("RoadInfrastructure") == true and obj.Material == Enum.Material.Asphalt and obj.Size.Y <= 1 then
			table.insert(roads, obj)
		end
	end
	return roads
end

local function pointInsideRoad(position, road, margin)
	margin = margin or 0
	return math.abs(position.X - road.Position.X) <= road.Size.X / 2 + margin
		and math.abs(position.Z - road.Position.Z) <= road.Size.Z / 2 + margin
end

local function pointInsideAnyRoad(position, roads, margin)
	for _, road in ipairs(roads) do
		if pointInsideRoad(position, road, margin) then return true end
	end
	return false
end

local function nearestSafeSidewalk(position, roads)
	if not pointInsideAnyRoad(position, roads, 0) then return position end

	-- Search outward in a small radial grid. The first candidate outside all
	-- carriageways is effectively the nearest pavement/road-edge location.
	local best, bestDistance
	for radius = 16, 64, 4 do
		local offsets = {
			Vector3.new(radius, 0, 0), Vector3.new(-radius, 0, 0),
			Vector3.new(0, 0, radius), Vector3.new(0, 0, -radius),
			Vector3.new(radius, 0, radius), Vector3.new(radius, 0, -radius),
			Vector3.new(-radius, 0, radius), Vector3.new(-radius, 0, -radius),
		}
		for _, offset in ipairs(offsets) do
			local candidate = position + offset
			if not pointInsideAnyRoad(candidate, roads, 2.5) then
				local distance = offset.Magnitude
				if not bestDistance or distance < bestDistance then
					best = candidate
					bestDistance = distance
				end
			end
		end
		if best then break end
	end
	return best or (position + Vector3.new(0, 0, 40))
end

function NPCSidewalkV8Service:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root then return end
	local roads = collectRoads(root)
	local moved = 0

	for _, anchor in ipairs(root:GetDescendants()) do
		if anchor:IsA("BasePart") and anchor:GetAttribute("NPCAnchor") == true then
			local oldPosition = anchor.Position
			if pointInsideAnyRoad(oldPosition, roads, 0.5) then
				local oldLook = oldPosition + anchor.CFrame.LookVector * 12
				local newPosition = nearestSafeSidewalk(oldPosition, roads)
				newPosition = Vector3.new(newPosition.X, oldPosition.Y, newPosition.Z)
				local target = Vector3.new(oldLook.X, newPosition.Y, oldLook.Z)
				if (target - newPosition).Magnitude < 1 then
					target = newPosition + Vector3.new(0, 0, -10)
				end
				anchor.CFrame = CFrame.lookAt(newPosition, target)
				anchor:SetAttribute("MovedToSidewalkV8", true)
				anchor:SetAttribute("OriginalRoadX", oldPosition.X)
				anchor:SetAttribute("OriginalRoadZ", oldPosition.Z)
				moved += 1
			end
		end
	end

	root:SetAttribute("NPCSidewalkRelocationsV8", moved)
	worldBuilder.NPCSidewalkRoadsV8 = roads
end

return NPCSidewalkV8Service
