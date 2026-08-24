local WorldMapV5PolishService = {}

local WHITE = Color3.fromRGB(244, 246, 247)
local NET = Color3.fromRGB(232, 237, 239)

local function part(parent, name, size, position, color, transparency, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color or WHITE
	p.Transparency = transparency or 0
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cf, color, transparency, canCollide)
	local p = part(parent, name, size, cf.Position, color, transparency, canCollide)
	p.CFrame = cf
	return p
end

local function tubeBetween(parent, name, a, b, radius, color, transparency, canCollide)
	local delta = b - a
	if delta.Magnitude < 0.001 then return end
	local right = delta.Unit
	local seed = math.abs(right:Dot(Vector3.new(0, 1, 0))) > 0.95 and Vector3.new(0, 0, 1) or Vector3.new(0, 1, 0)
	local back = right:Cross(seed).Unit
	local up = back:Cross(right).Unit
	local p = cfPart(parent, name, Vector3.new(delta.Magnitude, radius * 2, radius * 2), CFrame.fromMatrix((a + b) / 2, right, up, back), color, transparency or 0, canCollide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function createAcademyGoal(parent, name, z, direction, goalFor)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent
	local width, height, depth, rearHeight = 27, 8.8, 6.2, 6.1
	local left, right = -width / 2, width / 2
	local backZ = z + direction * depth
	local baseY = 0.5
	for _, x in ipairs({ left, right }) do
		tubeBetween(goal, "FrontPost", Vector3.new(x, baseY, z), Vector3.new(x, baseY + height, z), 0.2, WHITE, 0, true)
		tubeBetween(goal, "RearPost", Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.11, WHITE, 0.03, false)
		tubeBetween(goal, "RoofSupport", Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ), 0.11, WHITE, 0.03, false)
	end
	tubeBetween(goal, "Crossbar", Vector3.new(left, baseY + height, z), Vector3.new(right, baseY + height, z), 0.2, WHITE, 0, true)
	tubeBetween(goal, "RearBar", Vector3.new(left, baseY + rearHeight, backZ), Vector3.new(right, baseY + rearHeight, backZ), 0.11, WHITE, 0.03, false)
	for i = 0, 10 do
		local x = left + width * i / 10
		tubeBetween(goal, "NetRearV", Vector3.new(x, baseY + 0.05, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.018, NET, 0.83, false)
		tubeBetween(goal, "NetRoofV", Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ), 0.018, NET, 0.85, false)
	end
	for i = 0, 6 do
		local y = baseY + rearHeight * i / 6
		tubeBetween(goal, "NetRearH", Vector3.new(left, y, backZ), Vector3.new(right, y, backZ), 0.018, NET, 0.83, false)
	end
	local trigger = part(goal, "GoalTrigger", Vector3.new(width - 1, height - 0.6, 4.6), Vector3.new(0, baseY + (height - 0.6) / 2, z + direction * 2.3), WHITE, 1, false)
	trigger.CanTouch = true
	trigger:SetAttribute("GoalFor", goalFor)
	return goal
end

local function replaceAcademyGoals(worldBuilder)
	for _, name in ipairs({ "NorthGoal", "SouthGoal" }) do
		local old = worldBuilder.Model:FindFirstChild(name)
		if old then old:Destroy() end
	end
	createAcademyGoal(worldBuilder.Model, "NorthGoal", 88, 1, "Home")
	createAcademyGoal(worldBuilder.Model, "SouthGoal", -88, -1, "Away")
end

local function shiftModel(model, delta)
	if model and model:IsA("Model") then
		model:PivotTo(model:GetPivot() + delta)
	end
end

local function fixTownAndFacilities(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root then return end
	local town = root:FindFirstChild("NorthbridgeTownCentre")
	if town then
		local cafe = town:FindFirstChild("Cafe")
		shiftModel(cafe, Vector3.new(100, 0, 0))
		local square = town:FindFirstChild("TownSquare")
		if square then square.Position = Vector3.new(-75, 0.15, 575); square.Size = Vector3.new(80, 0.3, 82) end
		local fountain = town:FindFirstChild("FountainBasin")
		if fountain then fountain.Position = Vector3.new(-75, 0.7, 575) end
	end

	local academy = root:FindFirstChild("NorthbridgeAcademyCampus")
	if academy then
		local indoor = academy:FindFirstChild("IndoorTrainingHall")
		if indoor then indoor.Position = Vector3.new(-340, 11, 315) end
		local indoorSign = academy:FindFirstChild("IndoorHallSign")
		if indoorSign then indoorSign.Position = Vector3.new(-340, 17, 275.8) end
		local gym = academy:FindFirstChild("Gym")
		if gym then gym.Position = Vector3.new(340, 9, 315) end
		for _, window in ipairs(academy:GetChildren()) do
			if window.Name == "GymWindow" and window:IsA("BasePart") then
				window.Position += Vector3.new(130, 0, -115)
			end
		end
	end

	local stadium = root:FindFirstChild("NorthbridgeCityStadium")
	if stadium then
		local plaza = stadium:FindFirstChild("MatchdayPlaza")
		if plaza then plaza.Position = Vector3.new(0, 0.2, -555); plaza.Size = Vector3.new(240, 0.35, 60) end
		-- TrialMatchService expects MatchPitch as a direct stadium child.
		local matchPitch = stadium:FindFirstChild("MatchPitch", true)
		if matchPitch and matchPitch.Parent ~= stadium then matchPitch.Parent = stadium end
	end

	local kingsport = root:FindFirstChild("KingsportAthleticComplex")
	if kingsport then
		local entrance = kingsport:FindFirstChild("KingsportEntrance")
		if entrance then entrance.Position = Vector3.new(1275, 28, -535) end
	end
end

local function aabbOverlapsRoad(partObject, corridor)
	local halfX = partObject.Size.X / 2
	local halfZ = partObject.Size.Z / 2
	local minX, maxX = partObject.Position.X - halfX, partObject.Position.X + halfX
	local minZ, maxZ = partObject.Position.Z - halfZ, partObject.Position.Z + halfZ
	if corridor.Axis == "H" then
		local roadMinZ = corridor.Centre - corridor.HalfWidth + 0.9
		local roadMaxZ = corridor.Centre + corridor.HalfWidth - 0.9
		return maxX >= corridor.Min and minX <= corridor.Max and maxZ >= roadMinZ and minZ <= roadMaxZ
	end
	local roadMinX = corridor.Centre - corridor.HalfWidth + 0.9
	local roadMaxX = corridor.Centre + corridor.HalfWidth - 0.9
	return maxZ >= corridor.Min and minZ <= corridor.Max and maxX >= roadMinX and minX <= roadMaxX
end

local function enforceRoadClearance(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	local corridors = worldBuilder.RoadCorridorsV5 or {}
	if not root then return end
	local removed = 0
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj:GetAttribute("RoadInfrastructure") ~= true and obj.Position.Y < 7 then
			local ancestorModel = obj:FindFirstAncestorWhichIsA("Model")
			local isVehicle = ancestorModel and ancestorModel:GetAttribute("RTGVehicle") == true
			local largeGround = obj.Size.X > 150 or obj.Size.Z > 150
			if not isVehicle and not largeGround then
				for _, corridor in ipairs(corridors) do
					if aabbOverlapsRoad(obj, corridor) then
						obj:Destroy()
						removed += 1
						break
					end
				end
			end
		end
	end
	root:SetAttribute("V5RoadClearanceRemoved", removed)
end

function WorldMapV5PolishService:Init(worldBuilder)
	replaceAcademyGoals(worldBuilder)
	fixTownAndFacilities(worldBuilder)
	enforceRoadClearance(worldBuilder)
end

return WorldMapV5PolishService
