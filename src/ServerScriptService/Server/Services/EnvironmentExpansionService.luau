local Workspace = game:GetService("Workspace")

local EnvironmentExpansionService = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Navy = Color3.fromRGB(23, 37, 58),
	Dark = Color3.fromRGB(31, 35, 39),
	Steel = Color3.fromRGB(74, 82, 89),
	Road = Color3.fromRGB(54, 57, 60),
	Concrete = Color3.fromRGB(173, 176, 178),
	Grass = Color3.fromRGB(39, 112, 50),
	DarkGrass = Color3.fromRGB(28, 78, 39),
	Glass = Color3.fromRGB(126, 177, 199),
	Gold = Color3.fromRGB(225, 182, 52),
	Red = Color3.fromRGB(163, 49, 51),
	Blue = Color3.fromRGB(49, 78, 132),
}

local function part(parent, name, size, position, color, transparency, collide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color or C.White
	p.Transparency = transparency or 0
	p.CanCollide = collide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cframe, color, transparency, collide)
	local p = part(parent, name, size, cframe.Position, color, transparency, collide)
	p.CFrame = cframe
	return p
end

local function surfaceText(target, text, face, textColor)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(1000, 260)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = textColor or C.White
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function interaction(parent, id, title, position, speaker, text, prompt)
	local node = part(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", prompt or "Explore")
	return node
end

local function cylinder(parent, name, size, cframe, color, transparency, collide)
	local p = cfPart(parent, name, size, cframe, color, transparency, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function createBetterGoal(parent, name, centreX, z, goalFor, functional)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent

	local width = 27
	local height = 8.8
	local depth = 6.5
	local tube = 0.42
	local direction = z > 0 and 1 or -1
	local backZ = z + (direction * depth)
	local rearHeight = 6.5
	local net = Color3.fromRGB(220, 228, 231)

	part(goal, "LeftPost", Vector3.new(tube, height, tube), Vector3.new(centreX - width / 2, height / 2, z), C.White, 0, true)
	part(goal, "RightPost", Vector3.new(tube, height, tube), Vector3.new(centreX + width / 2, height / 2, z), C.White, 0, true)
	part(goal, "Crossbar", Vector3.new(width + tube, tube, tube), Vector3.new(centreX, height, z), C.White, 0, true)

	-- Sloped roof supports and lower rear frame make the profile read like a real football goal.
	for _, x in ipairs({ centreX - width / 2, centreX + width / 2 }) do
		local a = Vector3.new(x, height, z)
		local b = Vector3.new(x, rearHeight, backZ)
		local mid = (a + b) / 2
		cfPart(goal, "RoofSupport", Vector3.new(tube, tube, (b - a).Magnitude), CFrame.lookAt(mid, b), C.White, 0, false)
		part(goal, "RearPost", Vector3.new(tube, rearHeight, tube), Vector3.new(x, rearHeight / 2, backZ), C.White, 0, false)
	end
	part(goal, "RearBar", Vector3.new(width + tube, tube, tube), Vector3.new(centreX, rearHeight, backZ), C.White, 0, false)

	-- Rear net grid.
	for i = 0, 10 do
		local x = centreX - width / 2 + (width * i / 10)
		part(goal, "NetRearV", Vector3.new(0.055, rearHeight, 0.055), Vector3.new(x, rearHeight / 2, backZ), net, 0.5, false)
	end
	for i = 0, 6 do
		local y = rearHeight * i / 6
		part(goal, "NetRearH", Vector3.new(width, 0.055, 0.055), Vector3.new(centreX, y, backZ), net, 0.5, false)
	end

	-- Roof net follows the sloping supports.
	for i = 0, 10 do
		local x = centreX - width / 2 + (width * i / 10)
		local a = Vector3.new(x, height, z)
		local b = Vector3.new(x, rearHeight, backZ)
		local mid = (a + b) / 2
		cfPart(goal, "NetRoof", Vector3.new(0.045, 0.045, (b - a).Magnitude), CFrame.lookAt(mid, b), net, 0.58, false)
	end
	for i = 0, 5 do
		local t = i / 5
		local y = height + ((rearHeight - height) * t)
		local netZ = z + ((backZ - z) * t)
		part(goal, "NetRoofCross", Vector3.new(width, 0.045, 0.045), Vector3.new(centreX, y, netZ), net, 0.58, false)
	end

	-- Side net panels.
	for _, x in ipairs({ centreX - width / 2, centreX + width / 2 }) do
		for i = 0, 5 do
			local t = i / 5
			local netZ = z + ((backZ - z) * t)
			local topY = height + ((rearHeight - height) * t)
			part(goal, "NetSideV", Vector3.new(0.05, topY, 0.05), Vector3.new(x, topY / 2, netZ), net, 0.58, false)
		end
		for i = 0, 5 do
			local y = rearHeight * i / 5
			part(goal, "NetSideH", Vector3.new(0.05, 0.05, depth), Vector3.new(x, y, z + (direction * depth / 2)), net, 0.58, false)
		end
	end

	if functional then
		local trigger = part(goal, "GoalTrigger", Vector3.new(width - 1, height - 0.6, 4.6), Vector3.new(centreX, (height - 0.6) / 2, z + (direction * 2.3)), C.White, 1, false)
		trigger.CanTouch = true
		trigger:SetAttribute("GoalFor", goalFor)
	end
	return goal
end

local function replaceAcademyGoals(worldBuilder)
	for _, name in ipairs({ "NorthGoal", "SouthGoal" }) do
		local old = worldBuilder.Model:FindFirstChild(name)
		if old then old:Destroy() end
	end
	createBetterGoal(worldBuilder.Model, "NorthGoal", 0, 88, "Home", true)
	createBetterGoal(worldBuilder.Model, "SouthGoal", 0, -88, "Away", true)
end

local function fencePanel(parent, a, b, height)
	height = height or 10
	local delta = b - a
	local mid = (a + b) / 2
	local length = delta.Magnitude
	local fence = cfPart(parent, "MeshPanel", Vector3.new(0.18, height, length), CFrame.lookAt(Vector3.new(mid.X, height / 2, mid.Z), Vector3.new(b.X, height / 2, b.Z)), Color3.fromRGB(96, 103, 108), 0.66, true)
	fence.Material = Enum.Material.Metal
	for i = 0, math.floor(length / 12) do
		local t = math.clamp((i * 12) / math.max(length, 1), 0, 1)
		local p = a:Lerp(b, t)
		local post = part(parent, "FencePost", Vector3.new(0.42, height + 1, 0.42), Vector3.new(p.X, (height + 1) / 2, p.Z), Color3.fromRGB(76, 81, 85), 0, true)
		post.Material = Enum.Material.Metal
	end
	local topMid = Vector3.new(mid.X, height, mid.Z)
	cfPart(parent, "TopRail", Vector3.new(0.28, 0.28, length), CFrame.lookAt(topMid, Vector3.new(b.X, height, b.Z)), Color3.fromRGB(76, 81, 85), 0, false)
	return fence
end

local function createAcademyFence(worldBuilder)
	local old = worldBuilder.Model:FindFirstChild("AcademyPerimeterFence")
	if old then old:Destroy() end
	local fence = Instance.new("Model")
	fence.Name = "AcademyPerimeterFence"
	fence.Parent = worldBuilder.Model
	local x = 61.5
	local z = 98

	-- West side: gap by scout stand/player access.
	fencePanel(fence, Vector3.new(-x, 0, -z), Vector3.new(-x, 0, -48), 10)
	fencePanel(fence, Vector3.new(-x, 0, -35), Vector3.new(-x, 0, z), 10)
	-- East side: two access gates to academy building/dugouts.
	fencePanel(fence, Vector3.new(x, 0, -z), Vector3.new(x, 0, -24), 10)
	fencePanel(fence, Vector3.new(x, 0, -10), Vector3.new(x, 0, 40), 10)
	fencePanel(fence, Vector3.new(x, 0, 54), Vector3.new(x, 0, z), 10)
	fencePanel(fence, Vector3.new(-x, 0, -z), Vector3.new(x, 0, -z), 10)
	fencePanel(fence, Vector3.new(-x, 0, z), Vector3.new(x, 0, z), 10)

	for _, gateData in ipairs({
		{ Vector3.new(-x, 0, -41.5), 13, 90 },
		{ Vector3.new(x, 0, -17), 14, 90 },
		{ Vector3.new(x, 0, 47), 14, 90 },
	}) do
		local centre, width, yaw = gateData[1], gateData[2], gateData[3]
		local gate = cfPart(fence, "PedestrianGate", Vector3.new(width, 8, 0.32), CFrame.new(centre + Vector3.new(0, 4, 0)) * CFrame.Angles(0, math.rad(yaw), 0), Color3.fromRGB(93, 101, 106), 0.72, false)
		gate.Material = Enum.Material.Metal
	end
end

local function createDugout(parent, name, position, facePoint, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local baseCF = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	cfPart(model, "Floor", Vector3.new(14, 0.35, 5), baseCF * CFrame.new(0, 0.2, 0), Color3.fromRGB(89, 92, 94), 0, true)
	cfPart(model, "Roof", Vector3.new(14, 0.35, 5), baseCF * CFrame.new(0, 6.1, 0), C.Navy, 0, true)
	cfPart(model, "BackGlass", Vector3.new(14, 5.8, 0.25), baseCF * CFrame.new(0, 3.1, 2.35), C.Glass, 0.48, false)
	for _, x in ipairs({ -6.8, 6.8 }) do
		cfPart(model, "SideGlass", Vector3.new(0.3, 5.8, 5), baseCF * CFrame.new(x, 3.1, 0), C.Glass, 0.48, false)
	end
	for i = -2, 2 do
		local seat = Instance.new("Seat")
		seat.Name = "DugoutSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(2, 0.5, 2)
		seat.Color = accent
		seat.CFrame = baseCF * CFrame.new(i * 2.5, 1.1, 1.2)
		seat.Parent = model
	end
	return model
end

local function createScoutStandFacingPitch(worldBuilder)
	local campus = worldBuilder.Campus
	if not campus then return end
	local old = campus:FindFirstChild("ScoutStand")
	if old then old:Destroy() end

	local stand = Instance.new("Model")
	stand.Name = "ScoutStand"
	stand.Parent = campus
	local centreZ = 42
	for row = 1, 5 do
		local x = -69 - ((row - 1) * 2.3)
		part(stand, "Terrace" .. row, Vector3.new(4.5, 1.05, 44), Vector3.new(x, row * 1.05, centreZ), Color3.fromRGB(78, 87, 98), 0, true)
		for seatIndex = -4, 4 do
			local seat = Instance.new("Seat")
			seat.Name = "ScoutSeat"
			seat.Anchored = true
			seat.Size = Vector3.new(1.8, 0.45, 1.8)
			seat.Color = row % 2 == 0 and C.Navy or Color3.fromRGB(103, 113, 124)
			local pos = Vector3.new(x + 1.2, row * 1.05 + 1.0, centreZ + seatIndex * 4.4)
			seat.CFrame = CFrame.lookAt(pos, Vector3.new(0, pos.Y, pos.Z))
			seat.Parent = stand
		end
	end
	part(stand, "Roof", Vector3.new(18, 0.6, 50), Vector3.new(-75, 10.2, centreZ), C.Navy, 0, true)
	for _, zOffset in ipairs({ -22, 22 }) do
		part(stand, "RoofPost", Vector3.new(0.6, 10, 0.6), Vector3.new(-67.5, 5, centreZ + zOffset), C.Steel, 0, true)
	end
	interaction(stand, "ScoutStand", "Scout Viewing Stand", Vector3.new(-66, 2, centreZ), "Scout", "From here the scouts watch your positioning, first touch and decisions — not only goals.", "Listen")
end

local function createPitchSideFacilities(worldBuilder)
	local parent = worldBuilder.Campus or worldBuilder.Model
	local old = parent:FindFirstChild("PitchSideFacilities")
	if old then old:Destroy() end
	local area = Instance.new("Model")
	area.Name = "PitchSideFacilities"
	area.Parent = parent

	createDugout(area, "HomeDugout", Vector3.new(68, 0, -28), Vector3.new(0, 0, -28), C.Blue)
	createDugout(area, "AwayDugout", Vector3.new(68, 0, 0), Vector3.new(0, 0, 0), C.Red)

	-- Camera/analysis platform opposite scout seating.
	local platform = part(area, "AnalysisPlatform", Vector3.new(13, 1, 14), Vector3.new(72, 7.5, 38), Color3.fromRGB(73, 79, 84), 0, true)
	for _, corner in ipairs({ Vector3.new(-5, -3.5, -5), Vector3.new(-5, -3.5, 5), Vector3.new(5, -3.5, -5), Vector3.new(5, -3.5, 5) }) do
		part(area, "PlatformLeg", Vector3.new(0.6, 8, 0.6), platform.Position + corner, C.Steel, 0, true)
	end
	local camera = part(area, "AnalysisCamera", Vector3.new(2.6, 1.8, 3.5), platform.Position + Vector3.new(-4.5, 2.1, 0), C.Dark, 0, false)
	camera.CFrame = CFrame.lookAt(camera.Position, Vector3.new(0, 4, 20))
	part(area, "Tripod", Vector3.new(0.5, 3, 0.5), platform.Position + Vector3.new(-4.5, 0.6, 0), C.Steel, 0, false)
	interaction(area, "AnalysisDeck", "Performance Analysis Deck", Vector3.new(69, 2, 38), "Analyst", "Every drill and trial match is recorded here. The staff review movement, decision-making and work rate after you leave.", "Look")

	part(area, "EquipmentContainer", Vector3.new(8, 5, 14), Vector3.new(73, 2.5, 65), Color3.fromRGB(64, 71, 76), 0, true)
	part(area, "IceBathArea", Vector3.new(12, 0.5, 10), Vector3.new(72, 0.3, 80), Color3.fromRGB(151, 157, 160), 0, true)
end

local function createDetailedCar(parent, name, position, color, yaw, suv)
	local car = Instance.new("Model")
	car.Name = name
	car.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local bodyH = suv and 2.0 or 1.55
	local roofH = suv and 1.8 or 1.35
	cfPart(car, "LowerBody", Vector3.new(8.8, bodyH, 4.1), base * CFrame.new(0, 1.35, 0), color, 0, true)
	cfPart(car, "Bonnet", Vector3.new(2.6, 0.65, 3.9), base * CFrame.new(-3.5, 2.15, 0), color:Lerp(C.White, 0.04), 0, true)
	cfPart(car, "Cabin", Vector3.new(4.6, roofH, 3.7), base * CFrame.new(0.6, 2.65 + (suv and 0.25 or 0), 0), color:Lerp(C.White, 0.06), 0, true)
	cfPart(car, "FrontGlass", Vector3.new(0.18, 1.15, 3.25), base * CFrame.new(-1.7, 2.8 + (suv and 0.25 or 0), 0), C.Glass, 0.18, false)
	cfPart(car, "RearGlass", Vector3.new(0.18, 1.05, 3.2), base * CFrame.new(2.7, 2.75 + (suv and 0.25 or 0), 0), C.Glass, 0.2, false)
	for _, z in ipairs({ -1.9, 1.9 }) do
		cfPart(car, "SideGlass", Vector3.new(3.8, 1.05, 0.12), base * CFrame.new(0.5, 2.8 + (suv and 0.25 or 0), z), C.Glass, 0.18, false)
	end
	for _, x in ipairs({ -2.75, 2.75 }) do
		for _, z in ipairs({ -2.05, 2.05 }) do
			local wheelCF = base * CFrame.new(x, 0.8, z) * CFrame.Angles(math.rad(90), 0, 0)
			cylinder(car, "Wheel", Vector3.new(1.45, 0.7, 1.45), wheelCF, Color3.fromRGB(25, 26, 27), 0, false)
		end
	end
	for _, z in ipairs({ -1.2, 1.2 }) do
		local head = cfPart(car, "HeadLamp", Vector3.new(0.18, 0.55, 0.75), base * CFrame.new(-4.45, 1.6, z), Color3.fromRGB(246, 238, 199), 0, false)
		head.Material = Enum.Material.Neon
		local tail = cfPart(car, "TailLamp", Vector3.new(0.18, 0.55, 0.75), base * CFrame.new(4.45, 1.6, z), Color3.fromRGB(189, 44, 46), 0, false)
		tail.Material = Enum.Material.Neon
	end
	return car
end

local function upgradeAcademyCars(worldBuilder)
	local campus = worldBuilder.Campus
	if not campus then return end
	for _, child in ipairs(campus:GetChildren()) do
		if child:IsA("Model") and string.match(child.Name, "^AcademyCar%d+$") then child:Destroy() end
	end
	local colours = {
		Color3.fromRGB(44, 75, 116), Color3.fromRGB(130, 43, 46), Color3.fromRGB(39, 42, 45), Color3.fromRGB(211, 213, 214), Color3.fromRGB(56, 88, 60),
	}
	for i, colour in ipairs(colours) do
		createDetailedCar(campus, "AcademyCar" .. i, Vector3.new(-124 + ((i - 1) * 14), 0, -79), colour, 0, i == 5)
	end
end

local function createRoad(parent, x, zStart, zEnd)
	local length = math.abs(zEnd - zStart)
	local centreZ = (zStart + zEnd) / 2
	local road = part(parent, "RoadToStadium", Vector3.new(34, 0.35, length), Vector3.new(x, 0.08, centreZ), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for z = math.min(zStart, zEnd) + 10, math.max(zStart, zEnd) - 10, 20 do
		part(parent, "RoadCentreLine", Vector3.new(0.35, 0.05, 10), Vector3.new(x, 0.28, z), Color3.fromRGB(232, 222, 157), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, "RoadEdge", Vector3.new(0.28, 0.05, length), Vector3.new(x + (side * 16.4), 0.28, centreZ), C.White, 0, false)
		part(parent, "Sidewalk", Vector3.new(7, 0.45, length), Vector3.new(x + (side * 20.5), 0.22, centreZ), C.Concrete, 0, true)
	end
end

local function createRoadLamp(parent, position, faceRoad)
	local pole = part(parent, "StreetLampPole", Vector3.new(0.5, 14, 0.5), position + Vector3.new(0, 7, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	local armX = faceRoad and 2 or -2
	cfPart(parent, "StreetLampArm", Vector3.new(4, 0.35, 0.35), CFrame.new(position + Vector3.new(armX / 2, 13.6, 0)), C.Steel, 0, false)
	local lamp = part(parent, "StreetLamp", Vector3.new(1.6, 0.4, 0.9), position + Vector3.new(armX, 13.4, 0), Color3.fromRGB(245, 241, 215), 0, false)
	lamp.Material = Enum.Material.Neon
	local light = Instance.new("PointLight")
	light.Range = 24
	light.Brightness = 1.2
	light.Parent = lamp
end

local function stadiumStand(parent, name, centre, size, axis, rows, accent)
	local stand = Instance.new("Model")
	stand.Name = name
	stand.Parent = parent
	for row = 1, rows do
		local offset = (row - 1) * 3.2
		local y = row * 1.6
		local position
		local rowSize
		if axis == "X" then
			position = centre + Vector3.new(0, y, offset)
			rowSize = Vector3.new(size, 1.5, 5.5)
		else
			position = centre + Vector3.new(offset, y, 0)
			rowSize = Vector3.new(5.5, 1.5, size)
		end
		part(stand, "Terrace" .. row, rowSize, position, Color3.fromRGB(75, 81, 87), 0, true)
	end
	local roofSize = axis == "X" and Vector3.new(size + 10, 0.8, rows * 3.2 + 12) or Vector3.new(rows * 3.2 + 12, 0.8, size + 10)
	local roofPos = centre + Vector3.new(0, rows * 1.6 + 8, axis == "X" and ((rows - 1) * 1.6) or 0)
	if axis ~= "X" then roofPos = centre + Vector3.new(((rows - 1) * 1.6, rows * 1.6 + 8, 0) end
	part(stand, "Roof", roofSize, roofPos, C.Navy, 0, true)
	local fascia = axis == "X" and part(stand, "Fascia", Vector3.new(size, 3, 1), centre + Vector3.new(0, rows * 1.6 + 5, axis == "X" and 0 or 0), accent, 0, false) or nil
	if fascia then surfaceText(fascia, "NORTHBRIDGE FC", Enum.NormalId.Front, C.White) end
	return stand
end

local function createCrowdFigure(parent, position, facePoint, shirtColor)
	local model = Instance.new("Model")
	model.Name = "Crowd"
	model.Parent = parent
	local baseCF = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	cfPart(model, "Torso", Vector3.new(1.5, 2.1, 0.8), baseCF * CFrame.new(0, 2.2, 0), shirtColor, 0, false)
	local head = part(model, "Head", Vector3.new(1.25, 1.25, 1.25), position + Vector3.new(0, 3.9, 0), Color3.fromRGB(205, 166, 130), 0, false)
	head.Shape = Enum.PartType.Ball
end

local function fillCrowd(parent, centre, axis, rows, seatsPerRow, facePoint, palette, reverse)
	for row = 1, rows do
		for seatIndex = 1, seatsPerRow do
			if (row + seatIndex) % 5 ~= 0 then
				local along = (seatIndex - ((seatsPerRow + 1) / 2)) * 4.2
				local depth = (row - 1) * 3.2
				local p
				if axis == "X" then
					p = centre + Vector3.new(along, row * 1.6 + 1.0, (reverse and -depth or depth))
				else
					p = centre + Vector3.new((reverse and -depth or depth), row * 1.6 + 1.0, along)
				end
				local colour = palette[((row * 3 + seatIndex) % #palette) + 1]
				createCrowdFigure(parent, p, facePoint, colour)
			end
		end
	end
end

local function createStadiumPitch(parent, centre)
	local pitch = part(parent, "MatchPitch", Vector3.new(116, 1, 190), centre + Vector3.new(0, 0, 0), C.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	local lineY = centre.Y + 0.54
	local w, l = 112, 186
	local lc = Color3.fromRGB(237, 239, 235)
	part(parent, "PitchLineW", Vector3.new(0.18, 0.05, l), Vector3.new(centre.X - w / 2, lineY, centre.Z), lc, 0, false)
	part(parent, "PitchLineE", Vector3.new(0.18, 0.05, l), Vector3.new(centre.X + w / 2, lineY, centre.Z), lc, 0, false)
	part(parent, "PitchLineN", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, lineY, centre.Z + l / 2), lc, 0, false)
	part(parent, "PitchLineS", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, lineY, centre.Z - l / 2), lc, 0, false)
	part(parent, "Halfway", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, lineY, centre.Z), lc, 0, false)
	local spot = part(parent, "CentreSpot", Vector3.new(0.75, 0.06, 0.75), Vector3.new(centre.X, lineY + 0.02, centre.Z), lc, 0, false)
	spot.Shape = Enum.PartType.Ball
end

local function createFirstMatchStadium(parent, centre)
	local stadium = Instance.new("Model")
	stadium.Name = "FirstMatchStadium"
	stadium.Parent = parent

	local apron = part(stadium, "StadiumApron", Vector3.new(255, 1, 335), centre + Vector3.new(0, -0.55, 0), Color3.fromRGB(121, 127, 130), 0, true)
	apron.Material = Enum.Material.Concrete
	createStadiumPitch(stadium, centre)
	createBetterGoal(stadium, "StadiumNorthGoal", centre.X, centre.Z + 91, nil, false)
	createBetterGoal(stadium, "StadiumSouthGoal", centre.X, centre.Z - 91, nil, false)

	-- Four compact stands around the first-match ground.
	local standColour = Color3.fromRGB(48, 59, 74)
	local north = Instance.new("Model") north.Name = "NorthStand" north.Parent = stadium
	local south = Instance.new("Model") south.Name = "SouthStand" south.Parent = stadium
	local west = Instance.new("Model") west.Name = "WestStand" west.Parent = stadium
	local east = Instance.new("Model") east.Name = "EastStand" east.Parent = stadium
	for row = 1, 8 do
		part(north, "Row" .. row, Vector3.new(150, 1.5, 6), centre + Vector3.new(0, row * 1.5, 112 + (row - 1) * 3.2), standColour, 0, true)
		part(south, "Row" .. row, Vector3.new(150, 1.5, 6), centre + Vector3.new(0, row * 1.5, -112 - (row - 1) * 3.2), standColour, 0, true)
		part(west, "Row" .. row, Vector3.new(6, 1.5, 220), centre + Vector3.new(-70 - (row - 1) * 3.2, row * 1.5, 0), standColour, 0, true)
		part(east, "Row" .. row, Vector3.new(6, 1.5, 220), centre + Vector3.new(70 + (row - 1) * 3.2, row * 1.5, 0), standColour, 0, true)
	end
	part(north, "Roof", Vector3.new(164, 0.8, 42), centre + Vector3.new(0, 21, 123), C.Navy, 0, true)
	part(south, "Roof", Vector3.new(164, 0.8, 42), centre + Vector3.new(0, 21, -123), C.Navy, 0, true)
	part(west, "Roof", Vector3.new(42, 0.8, 235), centre + Vector3.new(-81, 21, 0), C.Navy, 0, true)
	part(east, "Roof", Vector3.new(42, 0.8, 235), centre + Vector3.new(81, 21, 0), C.Navy, 0, true)

	local mainSign = part(north, "StadiumSign", Vector3.new(75, 7, 1), centre + Vector3.new(0, 27, 143), C.Navy, 0, false)
	surfaceText(mainSign, "NORTHBRIDGE COMMUNITY STADIUM", Enum.NormalId.Back, C.White)

	-- Player tunnel on north side, aligned with the road/players entrance.
	part(stadium, "TunnelFloor", Vector3.new(12, 0.3, 28), centre + Vector3.new(0, 0.2, 109), Color3.fromRGB(99, 102, 105), 0, true)
	part(stadium, "TunnelLeft", Vector3.new(1, 8, 28), centre + Vector3.new(-6, 4, 109), C.Dark, 0, true)
	part(stadium, "TunnelRight", Vector3.new(1, 8, 28), centre + Vector3.new(6, 4, 109), C.Dark, 0, true)
	part(stadium, "TunnelRoof", Vector3.new(13, 1, 28), centre + Vector3.new(0, 8, 109), C.Dark, 0, true)
	interaction(stadium, "MatchTunnel", "First Match Tunnel", centre + Vector3.new(0, 2, 123), "Coach Daniels", "This is where your first match begins. When the career match system is ready, you'll walk from this tunnel into a live stadium.", "Enter")

	-- Crowd: enough to feel alive without building thousands of parts.
	local crowd = Instance.new("Model")
	crowd.Name = "Crowd"
	crowd.Parent = stadium
	local palette = { C.Blue, C.Red, C.White, Color3.fromRGB(37, 95, 62), Color3.fromRGB(203, 152, 48), Color3.fromRGB(65, 65, 68) }
	fillCrowd(crowd, centre + Vector3.new(0, 1, 113), "X", 6, 28, centre, palette, false)
	fillCrowd(crowd, centre + Vector3.new(0, 1, -113), "X", 6, 28, centre, palette, true)
	fillCrowd(crowd, centre + Vector3.new(-71, 1, 0), "Z", 6, 38, centre, palette, true)
	fillCrowd(crowd, centre + Vector3.new(71, 1, 0), "Z", 6, 38, centre, palette, false)

	-- Stadium floodlights.
	for _, p in ipairs({
		centre + Vector3.new(-100, 0, -130), centre + Vector3.new(100, 0, -130),
		centre + Vector3.new(-100, 0, 130), centre + Vector3.new(100, 0, 130),
	}) do
		local pole = part(stadium, "StadiumFloodPole", Vector3.new(1.4, 44, 1.4), p + Vector3.new(0, 22, 0), C.Steel, 0, true)
		pole.Material = Enum.Material.Metal
		local bar = part(stadium, "StadiumFloodBar", Vector3.new(14, 2, 2), p + Vector3.new(0, 43, 0), C.Dark, 0, false)
		for i = -2, 2 do
			local lamp = part(stadium, "StadiumLamp", Vector3.new(2, 1.3, 1), bar.Position + Vector3.new(i * 2.5, 0, 0), Color3.fromRGB(249, 246, 220), 0, false)
			lamp.Material = Enum.Material.Neon
		end
	end

	-- Exterior turnstiles, media van and team coach make the arrival side feel like match day.
	local northGateZ = centre.Z + 168
	for i = -4, 4 do
		part(stadium, "Turnstile", Vector3.new(3, 7, 2), Vector3.new(centre.X + i * 5, 3.5, northGateZ), Color3.fromRGB(71, 76, 80), 0, true)
	end
	createDetailedCar(stadium, "MediaVan", centre + Vector3.new(-54, 0, 156), Color3.fromRGB(223, 224, 225), 90, true)
	local bus = Instance.new("Model")
	bus.Name = "TeamCoach"
	bus.Parent = stadium
	local busCF = CFrame.new(centre + Vector3.new(48, 0, 157)) * CFrame.Angles(0, math.rad(90), 0)
	cfPart(bus, "BusBody", Vector3.new(18, 5, 6), busCF * CFrame.new(0, 3.2, 0), C.Navy, 0, true)
	cfPart(bus, "BusWindows", Vector3.new(12, 2.2, 6.05), busCF * CFrame.new(0, 5.1, 0), C.Glass, 0.2, false)
	for _, x in ipairs({ -6, 6 }) do
		for _, z in ipairs({ -3.1, 3.1 }) do
			cylinder(bus, "BusWheel", Vector3.new(2, 0.8, 2), busCF * CFrame.new(x, 1.2, z) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(23, 24, 25), 0, false)
		end
	end

	return stadium
end

local function createRoadAndStadium(worldBuilder)
	local old = worldBuilder.Model:FindFirstChild("CareerWorldExpansion")
	if old then old:Destroy() end
	local expansion = Instance.new("Model")
	expansion.Name = "CareerWorldExpansion"
	expansion.Parent = worldBuilder.Model

	local roadX = -88
	createRoad(expansion, roadX, -150, -420)
	for z = -175, -400, -45 do
		createRoadLamp(expansion, Vector3.new(roadX - 20.5, 0, z), true)
		createRoadLamp(expansion, Vector3.new(roadX + 20.5, 0, z + 20), false)
	end
	for z = -190, -390, -50 do
		local tree = part(expansion, "RoadTreeTrunk", Vector3.new(1.2, 7, 1.2), Vector3.new(roadX - 30, 3.5, z), Color3.fromRGB(91, 65, 43), 0, true)
		tree.Material = Enum.Material.Wood
		local crown = part(expansion, "RoadTreeCrown", Vector3.new(6, 6, 6), Vector3.new(roadX - 30, 9, z), Color3.fromRGB(42, 103, 51), 0, false)
		crown.Shape = Enum.PartType.Ball
	end

	-- Gateway marking the transition from academy life to match day.
	local gateZ = -165
	for _, x in ipairs({ roadX - 16, roadX + 16 }) do part(expansion, "AcademyExitPillar", Vector3.new(2.2, 10, 2.2), Vector3.new(x, 5, gateZ), C.Navy, 0, true) end
	local arch = part(expansion, "AcademyExitArch", Vector3.new(35, 3, 2.2), Vector3.new(roadX, 10, gateZ), C.Navy, 0, true)
	surfaceText(arch, "ROAD TO GLORY", Enum.NormalId.Front, C.White)
	interaction(expansion, "AcademyGate", "Academy Main Gate", Vector3.new(roadX, 2, gateZ + 6), "Kai Williams", "Past this gate is the route to the match stadium. Training earns the chance; match day decides what happens next.", "Look")

	local stadiumCentre = Vector3.new(roadX, 0, -585)
	-- Stadium approach continues from the academy road.
	createRoad(expansion, roadX, -420, stadiumCentre.Z + 175)
	part(expansion, "StadiumForecourt", Vector3.new(150, 0.45, 70), stadiumCentre + Vector3.new(0, 0.15, 176), C.Concrete, 0, true)
	interaction(expansion, "StadiumApproach", "Northbridge Community Stadium", stadiumCentre + Vector3.new(0, 2, 183), "Matchday Steward", "First-match venue ahead. The crowd, tunnel and stands are in place; the actual career fixture will plug into this ground next.", "Look")
	worldBuilder.FirstMatchStadium = createFirstMatchStadium(expansion, stadiumCentre)
	worldBuilder.CareerWorldExpansion = expansion
end

function EnvironmentExpansionService:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	replaceAcademyGoals(worldBuilder)
	createAcademyFence(worldBuilder)
	createScoutStandFacingPitch(worldBuilder)
	createPitchSideFacilities(worldBuilder)
	upgradeAcademyCars(worldBuilder)
	createRoadAndStadium(worldBuilder)
end

return EnvironmentExpansionService
