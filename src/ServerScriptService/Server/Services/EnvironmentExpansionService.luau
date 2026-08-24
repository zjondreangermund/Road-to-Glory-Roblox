local EnvironmentExpansionService = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Navy = Color3.fromRGB(23, 37, 58),
	Dark = Color3.fromRGB(31, 35, 39),
	Steel = Color3.fromRGB(74, 82, 89),
	Road = Color3.fromRGB(54, 57, 60),
	Concrete = Color3.fromRGB(173, 176, 178),
	Grass = Color3.fromRGB(39, 112, 50),
	Glass = Color3.fromRGB(126, 177, 199),
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

local function surfaceText(target, text, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(1000, 260)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.White
	label.Font = Enum.Font.GothamBold
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
end

local function cylinder(parent, name, size, cframe, color)
	local p = cfPart(parent, name, size, cframe, color, 0, false)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function createGoal(parent, name, centreX, z, goalFor, functional)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent

	local width = 27
	local height = 8.8
	local depth = 6.5
	local rearHeight = 6.5
	local tube = 0.42
	local direction = z > 0 and 1 or -1
	local backZ = z + (direction * depth)
	local net = Color3.fromRGB(220, 228, 231)

	part(goal, "LeftPost", Vector3.new(tube, height, tube), Vector3.new(centreX - width / 2, height / 2, z), C.White, 0, true)
	part(goal, "RightPost", Vector3.new(tube, height, tube), Vector3.new(centreX + width / 2, height / 2, z), C.White, 0, true)
	part(goal, "Crossbar", Vector3.new(width + tube, tube, tube), Vector3.new(centreX, height, z), C.White, 0, true)

	for _, x in ipairs({ centreX - width / 2, centreX + width / 2 }) do
		local a = Vector3.new(x, height, z)
		local b = Vector3.new(x, rearHeight, backZ)
		cfPart(goal, "RoofSupport", Vector3.new(tube, tube, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), C.White, 0, false)
		part(goal, "RearPost", Vector3.new(tube, rearHeight, tube), Vector3.new(x, rearHeight / 2, backZ), C.White, 0, false)
	end
	part(goal, "RearBar", Vector3.new(width + tube, tube, tube), Vector3.new(centreX, rearHeight, backZ), C.White, 0, false)

	for i = 0, 10 do
		local x = centreX - width / 2 + (width * i / 10)
		part(goal, "NetRearV", Vector3.new(0.055, rearHeight, 0.055), Vector3.new(x, rearHeight / 2, backZ), net, 0.5, false)
		local a = Vector3.new(x, height, z)
		local b = Vector3.new(x, rearHeight, backZ)
		cfPart(goal, "NetRoof", Vector3.new(0.045, 0.045, (b - a).Magnitude), CFrame.lookAt((a + b) / 2, b), net, 0.58, false)
	end
	for i = 0, 6 do
		local y = rearHeight * i / 6
		part(goal, "NetRearH", Vector3.new(width, 0.055, 0.055), Vector3.new(centreX, y, backZ), net, 0.5, false)
	end
	for i = 0, 5 do
		local t = i / 5
		local y = height + ((rearHeight - height) * t)
		local netZ = z + ((backZ - z) * t)
		part(goal, "NetRoofCross", Vector3.new(width, 0.045, 0.045), Vector3.new(centreX, y, netZ), net, 0.58, false)
	end
	for _, x in ipairs({ centreX - width / 2, centreX + width / 2 }) do
		for i = 0, 5 do
			local t = i / 5
			local netZ = z + ((backZ - z) * t)
			local topY = height + ((rearHeight - height) * t)
			part(goal, "NetSideV", Vector3.new(0.05, topY, 0.05), Vector3.new(x, topY / 2, netZ), net, 0.58, false)
			local y = rearHeight * i / 5
			part(goal, "NetSideH", Vector3.new(0.05, 0.05, depth), Vector3.new(x, y, z + (direction * depth / 2)), net, 0.58, false)
		end
	end

	if functional then
		local trigger = part(goal, "GoalTrigger", Vector3.new(width - 1, height - 0.6, 4.6), Vector3.new(centreX, (height - 0.6) / 2, z + (direction * 2.3)), C.White, 1, false)
		trigger.CanTouch = true
		trigger:SetAttribute("GoalFor", goalFor)
	end
end

local function replaceAcademyGoals(worldBuilder)
	for _, name in ipairs({ "NorthGoal", "SouthGoal" }) do
		local old = worldBuilder.Model:FindFirstChild(name)
		if old then old:Destroy() end
	end
	createGoal(worldBuilder.Model, "NorthGoal", 0, 88, "Home", true)
	createGoal(worldBuilder.Model, "SouthGoal", 0, -88, "Away", true)
end

local function fencePanel(parent, a, b, height)
	height = height or 10
	local delta = b - a
	local length = delta.Magnitude
	local mid = (a + b) / 2
	local panel = cfPart(parent, "MeshPanel", Vector3.new(0.18, height, length), CFrame.lookAt(Vector3.new(mid.X, height / 2, mid.Z), Vector3.new(b.X, height / 2, b.Z)), Color3.fromRGB(96, 103, 108), 0.68, true)
	panel.Material = Enum.Material.Metal
	local count = math.max(1, math.floor(length / 12))
	for i = 0, count do
		local t = i / count
		local p = a:Lerp(b, t)
		local post = part(parent, "FencePost", Vector3.new(0.42, height + 1, 0.42), Vector3.new(p.X, (height + 1) / 2, p.Z), Color3.fromRGB(76, 81, 85), 0, true)
		post.Material = Enum.Material.Metal
	end
	cfPart(parent, "TopRail", Vector3.new(0.28, 0.28, length), CFrame.lookAt(Vector3.new(mid.X, height, mid.Z), Vector3.new(b.X, height, b.Z)), Color3.fromRGB(76, 81, 85), 0, false)
end

local function createAcademyFence(worldBuilder)
	local old = worldBuilder.Model:FindFirstChild("AcademyPerimeterFence")
	if old then old:Destroy() end
	local fence = Instance.new("Model")
	fence.Name = "AcademyPerimeterFence"
	fence.Parent = worldBuilder.Model
	local x, z = 61.5, 98
	fencePanel(fence, Vector3.new(-x, 0, -z), Vector3.new(-x, 0, -48))
	fencePanel(fence, Vector3.new(-x, 0, -35), Vector3.new(-x, 0, z))
	fencePanel(fence, Vector3.new(x, 0, -z), Vector3.new(x, 0, -24))
	fencePanel(fence, Vector3.new(x, 0, -10), Vector3.new(x, 0, 40))
	fencePanel(fence, Vector3.new(x, 0, 54), Vector3.new(x, 0, z))
	fencePanel(fence, Vector3.new(-x, 0, -z), Vector3.new(x, 0, -z))
	fencePanel(fence, Vector3.new(-x, 0, z), Vector3.new(x, 0, z))
end

local function createDugout(parent, name, position, facePoint, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	cfPart(model, "Floor", Vector3.new(14, 0.35, 5), base * CFrame.new(0, 0.2, 0), Color3.fromRGB(89, 92, 94), 0, true)
	cfPart(model, "Roof", Vector3.new(14, 0.35, 5), base * CFrame.new(0, 6.1, 0), C.Navy, 0, true)
	cfPart(model, "BackGlass", Vector3.new(14, 5.8, 0.25), base * CFrame.new(0, 3.1, 2.35), C.Glass, 0.48, false)
	for _, x in ipairs({ -6.8, 6.8 }) do
		cfPart(model, "SideGlass", Vector3.new(0.3, 5.8, 5), base * CFrame.new(x, 3.1, 0), C.Glass, 0.48, false)
	end
	for i = -2, 2 do
		local seat = Instance.new("Seat")
		seat.Name = "DugoutSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(2, 0.5, 2)
		seat.Color = accent
		seat.CFrame = base * CFrame.new(i * 2.5, 1.1, 1.2)
		seat.Parent = model
	end
end

local function rebuildScoutStand(worldBuilder)
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
		for s = -4, 4 do
			local seat = Instance.new("Seat")
			seat.Name = "ScoutSeat"
			seat.Anchored = true
			seat.Size = Vector3.new(1.8, 0.45, 1.8)
			seat.Color = row % 2 == 0 and C.Navy or Color3.fromRGB(103, 113, 124)
			local pos = Vector3.new(x + 1.2, row * 1.05 + 1, centreZ + s * 4.4)
			seat.CFrame = CFrame.lookAt(pos, Vector3.new(0, pos.Y, pos.Z))
			seat.Parent = stand
		end
	end
	part(stand, "Roof", Vector3.new(18, 0.6, 50), Vector3.new(-75, 10.2, centreZ), C.Navy, 0, true)
	for _, zz in ipairs({ centreZ - 22, centreZ + 22 }) do
		part(stand, "RoofPost", Vector3.new(0.6, 10, 0.6), Vector3.new(-67.5, 5, zz), C.Steel, 0, true)
	end
	interaction(stand, "ScoutStand", "Scout Viewing Stand", Vector3.new(-66, 2, centreZ), "Scout", "From here we watch your positioning, first touch and decisions — not only goals.", "Listen")
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

	local platform = part(area, "AnalysisPlatform", Vector3.new(13, 1, 14), Vector3.new(72, 7.5, 38), Color3.fromRGB(73, 79, 84), 0, true)
	for _, offset in ipairs({ Vector3.new(-5, -3.5, -5), Vector3.new(-5, -3.5, 5), Vector3.new(5, -3.5, -5), Vector3.new(5, -3.5, 5) }) do
		part(area, "PlatformLeg", Vector3.new(0.6, 8, 0.6), platform.Position + offset, C.Steel, 0, true)
	end
	local camera = part(area, "AnalysisCamera", Vector3.new(2.6, 1.8, 3.5), platform.Position + Vector3.new(-4.5, 2.1, 0), C.Dark, 0, false)
	camera.CFrame = CFrame.lookAt(camera.Position, Vector3.new(0, 4, 20))
	part(area, "Tripod", Vector3.new(0.5, 3, 0.5), platform.Position + Vector3.new(-4.5, 0.6, 0), C.Steel, 0, false)
	interaction(area, "AnalysisDeck", "Performance Analysis Deck", Vector3.new(69, 2, 38), "Analyst", "Every drill and trial match is recorded here for staff review.", "Look")
	part(area, "EquipmentContainer", Vector3.new(8, 5, 14), Vector3.new(73, 2.5, 65), Color3.fromRGB(64, 71, 76), 0, true)
end

local function createCar(parent, name, position, color, yaw, suv)
	local car = Instance.new("Model")
	car.Name = name
	car.Parent = parent
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local bodyH = suv and 2 or 1.55
	local roofH = suv and 1.8 or 1.35
	cfPart(car, "LowerBody", Vector3.new(8.8, bodyH, 4.1), base * CFrame.new(0, 1.35, 0), color, 0, true)
	cfPart(car, "Bonnet", Vector3.new(2.6, 0.65, 3.9), base * CFrame.new(-3.5, 2.15, 0), color:Lerp(C.White, 0.04), 0, true)
	cfPart(car, "Cabin", Vector3.new(4.6, roofH, 3.7), base * CFrame.new(0.6, 2.65 + (suv and 0.25 or 0), 0), color:Lerp(C.White, 0.06), 0, true)
	cfPart(car, "FrontGlass", Vector3.new(0.18, 1.15, 3.25), base * CFrame.new(-1.7, 2.8 + (suv and 0.25 or 0), 0), C.Glass, 0.18, false)
	cfPart(car, "RearGlass", Vector3.new(0.18, 1.05, 3.2), base * CFrame.new(2.7, 2.75 + (suv and 0.25 or 0), 0), C.Glass, 0.2, false)
	for _, zz in ipairs({ -1.9, 1.9 }) do
		cfPart(car, "SideGlass", Vector3.new(3.8, 1.05, 0.12), base * CFrame.new(0.5, 2.8 + (suv and 0.25 or 0), zz), C.Glass, 0.18, false)
	end
	for _, xx in ipairs({ -2.75, 2.75 }) do
		for _, zz in ipairs({ -2.05, 2.05 }) do
			cylinder(car, "Wheel", Vector3.new(1.45, 0.7, 1.45), base * CFrame.new(xx, 0.8, zz) * CFrame.Angles(math.rad(90), 0, 0), Color3.fromRGB(25, 26, 27))
		end
	end
	return car
end

local function upgradeCars(worldBuilder)
	local campus = worldBuilder.Campus
	if not campus then return end
	for _, child in ipairs(campus:GetChildren()) do
		if child:IsA("Model") and string.match(child.Name, "^AcademyCar%d+$") then child:Destroy() end
	end
	local colors = {
		Color3.fromRGB(44, 75, 116), Color3.fromRGB(130, 43, 46), Color3.fromRGB(39, 42, 45), Color3.fromRGB(211, 213, 214), Color3.fromRGB(56, 88, 60),
	}
	for i, color in ipairs(colors) do
		createCar(campus, "AcademyCar" .. i, Vector3.new(-124 + ((i - 1) * 14), 0, -79), color, 0, i == 5)
	end
end

local function createRoad(parent, x, zStart, zEnd)
	local length = math.abs(zEnd - zStart)
	local centreZ = (zStart + zEnd) / 2
	local road = part(parent, "RoadToStadium", Vector3.new(34, 0.35, length), Vector3.new(x, 0.08, centreZ), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	local minZ, maxZ = math.min(zStart, zEnd), math.max(zStart, zEnd)
	for z = minZ + 10, maxZ - 10, 20 do
		part(parent, "RoadCentreLine", Vector3.new(0.35, 0.05, 10), Vector3.new(x, 0.28, z), Color3.fromRGB(232, 222, 157), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, "RoadEdge", Vector3.new(0.28, 0.05, length), Vector3.new(x + side * 16.4, 0.28, centreZ), C.White, 0, false)
		part(parent, "Sidewalk", Vector3.new(7, 0.45, length), Vector3.new(x + side * 20.5, 0.22, centreZ), C.Concrete, 0, true)
	end
end

local function createRoadLamp(parent, position, side)
	local pole = part(parent, "StreetLampPole", Vector3.new(0.5, 14, 0.5), position + Vector3.new(0, 7, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	part(parent, "StreetLampArm", Vector3.new(4, 0.35, 0.35), position + Vector3.new(side * 1.8, 13.6, 0), C.Steel, 0, false)
	local lamp = part(parent, "StreetLamp", Vector3.new(1.6, 0.4, 0.9), position + Vector3.new(side * 3.6, 13.4, 0), Color3.fromRGB(245, 241, 215), 0, false)
	lamp.Material = Enum.Material.Neon
	local light = Instance.new("PointLight")
	light.Range = 24
	light.Brightness = 1.2
	light.Parent = lamp
end

local function createCrowdFigure(parent, position, facePoint, shirtColor)
	local model = Instance.new("Model")
	model.Name = "Crowd"
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	cfPart(model, "Torso", Vector3.new(1.5, 2.1, 0.8), base * CFrame.new(0, 2.2, 0), shirtColor, 0, false)
	local head = part(model, "Head", Vector3.new(1.25, 1.25, 1.25), position + Vector3.new(0, 3.9, 0), Color3.fromRGB(205, 166, 130), 0, false)
	head.Shape = Enum.PartType.Ball
end

local function fillCrowd(parent, centre, side, rows, seatsPerRow, pitchCentre, palette)
	for row = 1, rows do
		for seatIndex = 1, seatsPerRow do
			if (row + seatIndex) % 5 ~= 0 then
				local along = (seatIndex - ((seatsPerRow + 1) / 2)) * 4.2
				local depth = (row - 1) * 3.2
				local p
				if side == "North" then p = centre + Vector3.new(along, row * 1.5 + 1, depth) end
				if side == "South" then p = centre + Vector3.new(along, row * 1.5 + 1, -depth) end
				if side == "West" then p = centre + Vector3.new(-depth, row * 1.5 + 1, along) end
				if side == "East" then p = centre + Vector3.new(depth, row * 1.5 + 1, along) end
				createCrowdFigure(parent, p, pitchCentre, palette[((row * 3 + seatIndex) % #palette) + 1])
			end
		end
	end
end

local function createStadiumPitch(parent, centre)
	local pitch = part(parent, "MatchPitch", Vector3.new(116, 1, 190), centre, C.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	local y, w, l = centre.Y + 0.54, 112, 186
	local lc = Color3.fromRGB(237, 239, 235)
	part(parent, "PitchLineW", Vector3.new(0.18, 0.05, l), Vector3.new(centre.X - w / 2, y, centre.Z), lc, 0, false)
	part(parent, "PitchLineE", Vector3.new(0.18, 0.05, l), Vector3.new(centre.X + w / 2, y, centre.Z), lc, 0, false)
	part(parent, "PitchLineN", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, y, centre.Z + l / 2), lc, 0, false)
	part(parent, "PitchLineS", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, y, centre.Z - l / 2), lc, 0, false)
	part(parent, "Halfway", Vector3.new(w, 0.05, 0.18), Vector3.new(centre.X, y, centre.Z), lc, 0, false)
end

local function createFirstMatchStadium(parent, centre)
	local stadium = Instance.new("Model")
	stadium.Name = "FirstMatchStadium"
	stadium.Parent = parent
	local apron = part(stadium, "StadiumApron", Vector3.new(255, 1, 335), centre + Vector3.new(0, -0.55, 0), Color3.fromRGB(121, 127, 130), 0, true)
	apron.Material = Enum.Material.Concrete
	createStadiumPitch(stadium, centre)
	createGoal(stadium, "StadiumNorthGoal", centre.X, centre.Z + 91, nil, false)
	createGoal(stadium, "StadiumSouthGoal", centre.X, centre.Z - 91, nil, false)

	local standColor = Color3.fromRGB(48, 59, 74)
	for row = 1, 8 do
		part(stadium, "NorthRow" .. row, Vector3.new(150, 1.5, 6), centre + Vector3.new(0, row * 1.5, 112 + (row - 1) * 3.2), standColor, 0, true)
		part(stadium, "SouthRow" .. row, Vector3.new(150, 1.5, 6), centre + Vector3.new(0, row * 1.5, -112 - (row - 1) * 3.2), standColor, 0, true)
		part(stadium, "WestRow" .. row, Vector3.new(6, 1.5, 220), centre + Vector3.new(-70 - (row - 1) * 3.2, row * 1.5, 0), standColor, 0, true)
		part(stadium, "EastRow" .. row, Vector3.new(6, 1.5, 220), centre + Vector3.new(70 + (row - 1) * 3.2, row * 1.5, 0), standColor, 0, true)
	end
	part(stadium, "NorthRoof", Vector3.new(164, 0.8, 42), centre + Vector3.new(0, 21, 123), C.Navy, 0, true)
	part(stadium, "SouthRoof", Vector3.new(164, 0.8, 42), centre + Vector3.new(0, 21, -123), C.Navy, 0, true)
	part(stadium, "WestRoof", Vector3.new(42, 0.8, 235), centre + Vector3.new(-81, 21, 0), C.Navy, 0, true)
	part(stadium, "EastRoof", Vector3.new(42, 0.8, 235), centre + Vector3.new(81, 21, 0), C.Navy, 0, true)
	local sign = part(stadium, "StadiumSign", Vector3.new(75, 7, 1), centre + Vector3.new(0, 27, 143), C.Navy, 0, false)
	surfaceText(sign, "NORTHBRIDGE COMMUNITY STADIUM", Enum.NormalId.Back)

	part(stadium, "TunnelFloor", Vector3.new(12, 0.3, 28), centre + Vector3.new(0, 0.2, 109), Color3.fromRGB(99, 102, 105), 0, true)
	part(stadium, "TunnelLeft", Vector3.new(1, 8, 28), centre + Vector3.new(-6, 4, 109), C.Dark, 0, true)
	part(stadium, "TunnelRight", Vector3.new(1, 8, 28), centre + Vector3.new(6, 4, 109), C.Dark, 0, true)
	part(stadium, "TunnelRoof", Vector3.new(13, 1, 28), centre + Vector3.new(0, 8, 109), C.Dark, 0, true)
	interaction(stadium, "MatchTunnel", "First Match Tunnel", centre + Vector3.new(0, 2, 123), "Coach Daniels", "This is where your first match begins. The career fixture system will plug into this stadium next.", "Enter")

	local crowd = Instance.new("Model")
	crowd.Name = "Crowd"
	crowd.Parent = stadium
	local palette = { C.Blue, C.Red, C.White, Color3.fromRGB(37, 95, 62), Color3.fromRGB(203, 152, 48), Color3.fromRGB(65, 65, 68) }
	fillCrowd(crowd, centre + Vector3.new(0, 1, 113), "North", 6, 28, centre, palette)
	fillCrowd(crowd, centre + Vector3.new(0, 1, -113), "South", 6, 28, centre, palette)
	fillCrowd(crowd, centre + Vector3.new(-71, 1, 0), "West", 6, 38, centre, palette)
	fillCrowd(crowd, centre + Vector3.new(71, 1, 0), "East", 6, 38, centre, palette)

	for _, p in ipairs({ centre + Vector3.new(-100, 0, -130), centre + Vector3.new(100, 0, -130), centre + Vector3.new(-100, 0, 130), centre + Vector3.new(100, 0, 130) }) do
		part(stadium, "FloodPole", Vector3.new(1.4, 44, 1.4), p + Vector3.new(0, 22, 0), C.Steel, 0, true)
		local bar = part(stadium, "FloodBar", Vector3.new(14, 2, 2), p + Vector3.new(0, 43, 0), C.Dark, 0, false)
		for i = -2, 2 do
			local lamp = part(stadium, "FloodLamp", Vector3.new(2, 1.3, 1), bar.Position + Vector3.new(i * 2.5, 0, 0), Color3.fromRGB(249, 246, 220), 0, false)
			lamp.Material = Enum.Material.Neon
		end
	end

	local gateZ = centre.Z + 168
	for i = -4, 4 do
		part(stadium, "Turnstile", Vector3.new(3, 7, 2), Vector3.new(centre.X + i * 5, 3.5, gateZ), Color3.fromRGB(71, 76, 80), 0, true)
	end
	createCar(stadium, "MediaVan", centre + Vector3.new(-54, 0, 156), Color3.fromRGB(223, 224, 225), 90, true)
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
		createRoadLamp(expansion, Vector3.new(roadX - 20.5, 0, z), 1)
		createRoadLamp(expansion, Vector3.new(roadX + 20.5, 0, z + 20), -1)
	end
	local archZ = -165
	for _, x in ipairs({ roadX - 16, roadX + 16 }) do
		part(expansion, "AcademyExitPillar", Vector3.new(2.2, 10, 2.2), Vector3.new(x, 5, archZ), C.Navy, 0, true)
	end
	local arch = part(expansion, "AcademyExitArch", Vector3.new(35, 3, 2.2), Vector3.new(roadX, 10, archZ), C.Navy, 0, true)
	surfaceText(arch, "ROAD TO GLORY", Enum.NormalId.Front)
	interaction(expansion, "AcademyGate", "Academy Main Gate", Vector3.new(roadX, 2, archZ + 6), "Kai Williams", "Past this gate is the route to the match stadium. Training earns the chance; match day decides what happens next.", "Look")

	local stadiumCentre = Vector3.new(roadX, 0, -585)
	createRoad(expansion, roadX, -420, stadiumCentre.Z + 175)
	part(expansion, "StadiumForecourt", Vector3.new(150, 0.45, 70), stadiumCentre + Vector3.new(0, 0.15, 176), C.Concrete, 0, true)
	interaction(expansion, "StadiumApproach", "Northbridge Community Stadium", stadiumCentre + Vector3.new(0, 2, 183), "Matchday Steward", "First-match venue ahead. The crowd, tunnel and stands are ready for the career match system.", "Look")
	worldBuilder.FirstMatchStadium = createFirstMatchStadium(expansion, stadiumCentre)
	worldBuilder.CareerWorldExpansion = expansion
end

function EnvironmentExpansionService:Init(worldBuilder)
	replaceAcademyGoals(worldBuilder)
	createAcademyFence(worldBuilder)
	rebuildScoutStand(worldBuilder)
	createPitchSideFacilities(worldBuilder)
	upgradeCars(worldBuilder)
	createRoadAndStadium(worldBuilder)
end

return EnvironmentExpansionService
