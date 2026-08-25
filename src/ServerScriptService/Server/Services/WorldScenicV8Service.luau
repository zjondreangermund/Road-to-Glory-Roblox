local WorldScenicV8Service = {}

local C = {
	White = Color3.fromRGB(242, 244, 246),
	Black = Color3.fromRGB(22, 25, 29),
	Navy = Color3.fromRGB(18, 34, 60),
	Blue = Color3.fromRGB(38, 91, 168),
	Teal = Color3.fromRGB(34, 126, 135),
	Purple = Color3.fromRGB(104, 58, 145),
	Gold = Color3.fromRGB(221, 178, 54),
	Road = Color3.fromRGB(47, 50, 53),
	Concrete = Color3.fromRGB(171, 175, 178),
	Pavement = Color3.fromRGB(198, 200, 201),
	Grass = Color3.fromRGB(43, 108, 52),
	DarkGrass = Color3.fromRGB(33, 76, 40),
	Glass = Color3.fromRGB(114, 173, 202),
	Steel = Color3.fromRGB(71, 78, 86),
	Wood = Color3.fromRGB(108, 76, 49),
	Yellow = Color3.fromRGB(232, 214, 137),
	Red = Color3.fromRGB(184, 48, 53),
}

local function part(parent, name, size, position, color, transparency, canCollide, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color or C.White
	p.Transparency = transparency or 0
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = material or Enum.Material.SmoothPlastic
	p:SetAttribute("WorldDetailV8", true)
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cf, color, transparency, canCollide, material)
	local p = part(parent, name, size, cf.Position, color, transparency, canCollide, material)
	p.CFrame = cf
	return p
end

local function textFace(target, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(1200, 300)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or C.White
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function roadPart(p)
	p:SetAttribute("RoadInfrastructure", true)
	return p
end

local function roadH(parent, name, x1, x2, z, width)
	width = width or 30
	local minX, maxX = math.min(x1, x2), math.max(x1, x2)
	local length = maxX - minX
	local cx = (minX + maxX) / 2
	local road = roadPart(part(parent, name, Vector3.new(length, 0.34, width), Vector3.new(cx, 0.13, z), C.Road, 0, true, Enum.Material.Asphalt))
	for x = minX + 16, maxX - 16, 30 do
		roadPart(part(parent, name .. "Dash", Vector3.new(10, 0.05, 0.24), Vector3.new(x, 0.34, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadPart(part(parent, name .. "Edge", Vector3.new(length, 0.05, 0.18), Vector3.new(cx, 0.34, z + side * (width / 2 - 0.7)), C.White, 0, false))
		roadPart(part(parent, name .. "Sidewalk", Vector3.new(length, 0.28, 6), Vector3.new(cx, 0.17, z + side * (width / 2 + 3.2)), C.Pavement, 0, true, Enum.Material.Concrete))
	end
	return road
end

local function roadV(parent, name, x, z1, z2, width)
	width = width or 30
	local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
	local length = maxZ - minZ
	local cz = (minZ + maxZ) / 2
	local road = roadPart(part(parent, name, Vector3.new(width, 0.34, length), Vector3.new(x, 0.13, cz), C.Road, 0, true, Enum.Material.Asphalt))
	for z = minZ + 16, maxZ - 16, 30 do
		roadPart(part(parent, name .. "Dash", Vector3.new(0.24, 0.05, 10), Vector3.new(x, 0.34, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadPart(part(parent, name .. "Edge", Vector3.new(0.18, 0.05, length), Vector3.new(x + side * (width / 2 - 0.7), 0.34, cz), C.White, 0, false))
		roadPart(part(parent, name .. "Sidewalk", Vector3.new(6, 0.28, length), Vector3.new(x + side * (width / 2 + 3.2), 0.17, cz), C.Pavement, 0, true, Enum.Material.Concrete))
	end
	return road
end

local function tree(parent, position, scale)
	scale = scale or 1
	part(parent, "ScenicTreeTrunk", Vector3.new(1.1, 6.5, 1.1) * scale, position + Vector3.new(0, 3.25 * scale, 0), Color3.fromRGB(84, 60, 40), 0, true, Enum.Material.Wood)
	for _, offset in ipairs({ Vector3.new(0, 7.2, 0), Vector3.new(-2, 6.6, 0), Vector3.new(2, 6.5, 0), Vector3.new(0, 6.5, 2) }) do
		local crown = part(parent, "ScenicTreeCrown", Vector3.new(5.5, 5.5, 5.5) * scale, position + offset * scale, Color3.fromRGB(44, 101, 49), 0, false, Enum.Material.Grass)
		crown.Shape = Enum.PartType.Ball
	end
end

local function bench(parent, position, yaw)
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	cfPart(parent, "ScenicBenchSeat", Vector3.new(7, 0.5, 2), cf * CFrame.new(0, 1.5, 0), C.Wood, 0, true, Enum.Material.Wood)
	cfPart(parent, "ScenicBenchBack", Vector3.new(7, 2.8, 0.35), cf * CFrame.new(0, 2.7, 0.85), C.Wood, 0, true, Enum.Material.Wood)
	for _, x in ipairs({ -2.5, 2.5 }) do
		cfPart(parent, "ScenicBenchLeg", Vector3.new(0.35, 1.4, 0.35), cf * CFrame.new(x, 0.7, 0), C.Steel, 0, true, Enum.Material.Metal)
	end
end

local function lamp(parent, position)
	part(parent, "ScenicLampPole", Vector3.new(0.42, 10, 0.42), position + Vector3.new(0, 5, 0), C.Steel, 0, true, Enum.Material.Metal)
	local light = part(parent, "ScenicLampHead", Vector3.new(2.1, 0.35, 1.1), position + Vector3.new(0, 9.8, 0), Color3.fromRGB(247, 242, 210), 0, false, Enum.Material.Neon)
	local point = Instance.new("PointLight")
	point.Range = 22
	point.Brightness = 1.2
	point.Color = Color3.fromRGB(255, 244, 214)
	point.Parent = light
end

local function tubeBetween(parent, name, a, b, radius, color, transparency, canCollide)
	local d = b - a
	if d.Magnitude < 0.001 then return nil end
	local right = d.Unit
	local seed = math.abs(right:Dot(Vector3.new(0, 1, 0))) > 0.95 and Vector3.new(0, 0, 1) or Vector3.new(0, 1, 0)
	local back = right:Cross(seed).Unit
	local up = back:Cross(right).Unit
	local p = cfPart(parent, name, Vector3.new(d.Magnitude, radius * 2, radius * 2), CFrame.fromMatrix((a + b) / 2, right, up, back), color, transparency or 0, canCollide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function goal(parent, centreX, frontZ, sign, baseY, width, height)
	width = width or 27
	height = height or 9
	local depth = 6.2
	local backZ = frontZ + sign * depth
	local left, right = centreX - width / 2, centreX + width / 2
	for _, x in ipairs({ left, right }) do
		tubeBetween(parent, "GoalPost", Vector3.new(x, baseY, frontZ), Vector3.new(x, baseY + height, frontZ), 0.2, C.White, 0, true)
		tubeBetween(parent, "GoalRearPost", Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + height * 0.7, backZ), 0.1, C.White, 0.05, false)
		tubeBetween(parent, "GoalRoofSupport", Vector3.new(x, baseY + height, frontZ), Vector3.new(x, baseY + height * 0.7, backZ), 0.1, C.White, 0.05, false)
	end
	tubeBetween(parent, "GoalCrossbar", Vector3.new(left, baseY + height, frontZ), Vector3.new(right, baseY + height, frontZ), 0.2, C.White, 0, true)
	for i = 0, 10 do
		local x = left + width * i / 10
		tubeBetween(parent, "GoalNet", Vector3.new(x, baseY + 0.05, backZ), Vector3.new(x, baseY + height * 0.7, backZ), 0.017, C.White, 0.84, false)
	end
	for i = 0, 6 do
		local y = baseY + height * 0.7 * i / 6
		tubeBetween(parent, "GoalNetH", Vector3.new(left, y, backZ), Vector3.new(right, y, backZ), 0.017, C.White, 0.84, false)
	end
end

local function createPitch(parent, centre, width, length)
	local field = part(parent, "MatchPitch", Vector3.new(width, 0.42, length), Vector3.new(centre.X, 0.2, centre.Z), C.Grass, 0, true, Enum.Material.Grass)
	local y = 0.43
	for i = -5, 5 do
		local shade = i % 2 == 0 and Color3.fromRGB(41, 111, 50) or Color3.fromRGB(47, 120, 56)
		part(parent, "PitchStripe", Vector3.new(width / 11, 0.025, length), Vector3.new(centre.X + i * width / 11, y, centre.Z), shade, 0, false, Enum.Material.Grass)
	end
	local line = C.White
	local t = 0.16
	part(parent, "TouchlineW", Vector3.new(t, 0.04, length - 1), Vector3.new(centre.X - width / 2 + 0.5, y + 0.03, centre.Z), line, 0, false)
	part(parent, "TouchlineE", Vector3.new(t, 0.04, length - 1), Vector3.new(centre.X + width / 2 - 0.5, y + 0.03, centre.Z), line, 0, false)
	part(parent, "GoalLineN", Vector3.new(width - 1, 0.04, t), Vector3.new(centre.X, y + 0.03, centre.Z + length / 2 - 0.5), line, 0, false)
	part(parent, "GoalLineS", Vector3.new(width - 1, 0.04, t), Vector3.new(centre.X, y + 0.03, centre.Z - length / 2 + 0.5), line, 0, false)
	part(parent, "Halfway", Vector3.new(width - 1, 0.04, t), Vector3.new(centre.X, y + 0.03, centre.Z), line, 0, false)
	local spot = part(parent, "CentreSpot", Vector3.new(0.8, 0.05, 0.8), Vector3.new(centre.X, y + 0.04, centre.Z), line, 0, false)
	spot.Shape = Enum.PartType.Cylinder
	goal(parent, centre.X, centre.Z + length / 2 - 3, 1, 0.43, 27, 9)
	goal(parent, centre.X, centre.Z - length / 2 + 3, -1, 0.43, 27, 9)
	return field
end

local function tierStand(parent, name, centre, side, direction, pitchWidth, pitchLength, accent)
	local stand = Instance.new("Model")
	stand.Name = name
	stand.Parent = parent
	local along = side == "X" and pitchLength + 62 or pitchWidth + 68
	local fieldEdge = side == "X" and pitchWidth / 2 or pitchLength / 2
	local lowerRows, upperRows = 9, 10
	for row = 1, lowerRows do
		local setback = fieldEdge + 9 + row * 2.25
		local rise = row * 1.22
		local pos, size
		if side == "X" then
			pos = Vector3.new(centre.X + direction * setback, rise, centre.Z)
			size = Vector3.new(4.5, 1.0, along)
		else
			pos = Vector3.new(centre.X, rise, centre.Z + direction * setback)
			size = Vector3.new(along, 1.0, 4.5)
		end
		part(stand, "LowerTerrace", size, pos, row % 2 == 0 and Color3.fromRGB(61, 67, 75) or Color3.fromRGB(52, 58, 66), 0, true, Enum.Material.Concrete)
		local seatPos = side == "X" and pos + Vector3.new(-direction * 1.15, 0.82, 0) or pos + Vector3.new(0, 0.82, -direction * 1.15)
		local seatSize = side == "X" and Vector3.new(1.3, 0.7, along - 4) or Vector3.new(along - 4, 0.7, 1.3)
		part(stand, "LowerSeatBand", seatSize, seatPos, row % 3 == 0 and C.White or accent, 0, false)
	end

	local concourseSetback = fieldEdge + 9 + lowerRows * 2.25 + 7
	local concoursePos, concourseSize
	if side == "X" then
		concoursePos = Vector3.new(centre.X + direction * concourseSetback, 13.5, centre.Z)
		concourseSize = Vector3.new(14, 3, along + 8)
	else
		concoursePos = Vector3.new(centre.X, 13.5, centre.Z + direction * concourseSetback)
		concourseSize = Vector3.new(along + 8, 3, 14)
	end
	part(stand, "TierConcourse", concourseSize, concoursePos, C.Concrete, 0, true, Enum.Material.Concrete)

	for row = 1, upperRows do
		local setback = concourseSetback + 6 + row * 2.25
		local rise = 16 + row * 1.28
		local pos, size
		if side == "X" then
			pos = Vector3.new(centre.X + direction * setback, rise, centre.Z)
			size = Vector3.new(4.5, 1.0, along)
		else
			pos = Vector3.new(centre.X, rise, centre.Z + direction * setback)
			size = Vector3.new(along, 1.0, 4.5)
		end
		part(stand, "UpperTerrace", size, pos, row % 2 == 0 and Color3.fromRGB(56, 62, 70) or Color3.fromRGB(47, 53, 61), 0, true, Enum.Material.Concrete)
		local seatPos = side == "X" and pos + Vector3.new(-direction * 1.15, 0.82, 0) or pos + Vector3.new(0, 0.82, -direction * 1.15)
		local seatSize = side == "X" and Vector3.new(1.3, 0.7, along - 4) or Vector3.new(along - 4, 0.7, 1.3)
		part(stand, "UpperSeatBand", seatSize, seatPos, row % 4 == 0 and C.White or accent, 0, false)
	end

	local outerSetback = concourseSetback + 6 + upperRows * 2.25 + 5
	local facadePos, facadeSize
	if side == "X" then
		facadePos = Vector3.new(centre.X + direction * outerSetback, 17, centre.Z)
		facadeSize = Vector3.new(8, 34, along + 14)
	else
		facadePos = Vector3.new(centre.X, 17, centre.Z + direction * outerSetback)
		facadeSize = Vector3.new(along + 14, 34, 8)
	end
	local facade = part(stand, "OuterFacade", facadeSize, facadePos, C.Navy, 0, true, Enum.Material.Metal)
	facade:SetAttribute("StadiumFacade", true)
	return stand, outerSetback
end

local function createStadiumComplex(parent, name, centre, accent, clubName, capacityText, covered)
	local stadium = Instance.new("Model")
	stadium.Name = name
	stadium:SetAttribute("DoubleTierStadium", true)
	stadium:SetAttribute("CoveredPitch", covered == true)
	stadium.Parent = parent

	local pitchWidth, pitchLength = 124, 196
	createPitch(stadium, centre, pitchWidth, pitchLength)
	local _, westOuter = tierStand(stadium, "WestDoubleTierStand", centre, "X", -1, pitchWidth, pitchLength, accent)
	tierStand(stadium, "EastDoubleTierStand", centre, "X", 1, pitchWidth, pitchLength, accent)
	tierStand(stadium, "NorthDoubleTierStand", centre, "Z", 1, pitchWidth, pitchLength, accent)
	tierStand(stadium, "SouthDoubleTierStand", centre, "Z", -1, pitchWidth, pitchLength, accent)

	-- Upper-tier canopy on all four sides. Open stadium leaves the playing surface exposed.
	part(stadium, "WestCanopy", Vector3.new(54, 1.5, pitchLength + 92), Vector3.new(centre.X - pitchWidth / 2 - 42, 34, centre.Z), accent, 0, true, Enum.Material.Metal)
	part(stadium, "EastCanopy", Vector3.new(54, 1.5, pitchLength + 92), Vector3.new(centre.X + pitchWidth / 2 + 42, 34, centre.Z), accent, 0, true, Enum.Material.Metal)
	part(stadium, "NorthCanopy", Vector3.new(pitchWidth + 100, 1.5, 52), Vector3.new(centre.X, 34, centre.Z + pitchLength / 2 + 40), accent, 0, true, Enum.Material.Metal)
	part(stadium, "SouthCanopy", Vector3.new(pitchWidth + 100, 1.5, 52), Vector3.new(centre.X, 34, centre.Z - pitchLength / 2 - 40), accent, 0, true, Enum.Material.Metal)

	if covered then
		local roof = part(stadium, "PitchRoof", Vector3.new(pitchWidth + 34, 1.0, pitchLength + 30), Vector3.new(centre.X, 48, centre.Z), C.Glass, 0.32, true, Enum.Material.Glass)
		roof.Reflectance = 0.08
		for x = centre.X - pitchWidth / 2 - 8, centre.X + pitchWidth / 2 + 8, 22 do
			tubeBetween(stadium, "RoofTruss", Vector3.new(x, 46.8, centre.Z - pitchLength / 2 - 12), Vector3.new(x, 46.8, centre.Z + pitchLength / 2 + 12), 0.45, C.Steel, 0, true)
		end
		for z = centre.Z - pitchLength / 2 - 8, centre.Z + pitchLength / 2 + 8, 28 do
			tubeBetween(stadium, "RoofCrossTruss", Vector3.new(centre.X - pitchWidth / 2 - 12, 47.2, z), Vector3.new(centre.X + pitchWidth / 2 + 12, 47.2, z), 0.35, C.Steel, 0, true)
		end
		for _, x in ipairs({ centre.X - 45, centre.X, centre.X + 45 }) do
			for _, z in ipairs({ centre.Z - 65, centre.Z, centre.Z + 65 }) do
				local panel = part(stadium, "RoofPitchLight", Vector3.new(14, 0.25, 5), Vector3.new(x, 46.2, z), C.White, 0, false, Enum.Material.Neon)
				local light = Instance.new("SurfaceLight")
				light.Face = Enum.NormalId.Bottom
				light.Range = 65
				light.Angle = 120
				light.Brightness = 1.6
				light.Parent = panel
			end
		end
	else
		-- Traditional corner floodlights for the open stadium.
		for _, offset in ipairs({ Vector3.new(-120, 0, -155), Vector3.new(120, 0, -155), Vector3.new(-120, 0, 155), Vector3.new(120, 0, 155) }) do
			local base = centre + offset
			part(stadium, "FloodlightMast", Vector3.new(1.5, 54, 1.5), Vector3.new(base.X, 27, base.Z), C.Steel, 0, true, Enum.Material.Metal)
			local array = part(stadium, "FloodlightArray", Vector3.new(19, 3.2, 1), Vector3.new(base.X, 53, base.Z), C.White, 0, false, Enum.Material.Neon)
			local light = Instance.new("SurfaceLight")
			light.Face = Enum.NormalId.Bottom
			light.Range = 80
			light.Angle = 105
			light.Brightness = 1.8
			light.Parent = array
		end
	end

	-- Press/VIP suite between tiers on west stand.
	local press = part(stadium, "PressAndVIP", Vector3.new(22, 11, 86), Vector3.new(centre.X - pitchWidth / 2 - 36, 22, centre.Z), Color3.fromRGB(48, 55, 64), 0, true, Enum.Material.Metal)
	local glass = part(stadium, "PressGlass", Vector3.new(0.28, 7, 72), press.Position + Vector3.new(11.15, 0, 0), C.Glass, 0.14, false, Enum.Material.Glass)
	glass.Reflectance = 0.05

	local scoreboard = part(stadium, "MainScoreboard", Vector3.new(50, 18, 1.0), Vector3.new(centre.X, 39, centre.Z + pitchLength / 2 + 34), C.Black, 0, false, Enum.Material.SmoothPlastic)
	textFace(scoreboard, clubName .. "\n" .. capacityText, Enum.NormalId.Front)

	-- Player tunnel and support spaces are self-contained.
	local tunnel = part(stadium, "PlayerTunnel", Vector3.new(24, 10, 34), Vector3.new(centre.X, 5, centre.Z - pitchLength / 2 - 20), C.Navy, 0, true, Enum.Material.Concrete)
	part(stadium, "TunnelOpening", Vector3.new(14, 7.5, 0.3), Vector3.new(centre.X, 4, centre.Z - pitchLength / 2 - 2.8), C.Black, 0, false)
	part(stadium, "HomeChanging", Vector3.new(42, 12, 34), tunnel.Position + Vector3.new(-34, 1, -2), Color3.fromRGB(73, 81, 90), 0, true, Enum.Material.Concrete)
	part(stadium, "AwayChanging", Vector3.new(42, 12, 34), tunnel.Position + Vector3.new(34, 1, -2), Color3.fromRGB(73, 81, 90), 0, true, Enum.Material.Concrete)
	part(stadium, "MedicalRoom", Vector3.new(26, 10, 25), tunnel.Position + Vector3.new(-55, 0, -2), Color3.fromRGB(205, 211, 212), 0, true, Enum.Material.Concrete)
	part(stadium, "MediaRoom", Vector3.new(32, 10, 25), tunnel.Position + Vector3.new(55, 0, -2), Color3.fromRGB(88, 96, 104), 0, true, Enum.Material.Concrete)

	stadium:SetAttribute("OuterStandOffset", westOuter)
	return stadium
end

local function parkingLot(parent, centre, width, depth)
	local lot = part(parent, "StadiumParking", Vector3.new(width, 0.25, depth), Vector3.new(centre.X, 0.15, centre.Z), Color3.fromRGB(61, 64, 67), 0, true, Enum.Material.Asphalt)
	for x = centre.X - width / 2 + 10, centre.X + width / 2 - 10, 12 do
		part(parent, "ParkingLine", Vector3.new(0.16, 0.04, depth - 8), Vector3.new(x, 0.3, centre.Z), C.White, 0, false)
	end
	return lot
end

local function stadiumSupportVillage(parent, centre, accent, label)
	local plaza = part(parent, "ArrivalPlaza", Vector3.new(190, 0.3, 72), Vector3.new(centre.X, 0.18, centre.Z - 220), C.Concrete, 0, true, Enum.Material.Concrete)
	for _, x in ipairs({ -75, -45, 45, 75 }) do
		local kiosk = part(parent, "MatchdayKiosk", Vector3.new(20, 9, 14), plaza.Position + Vector3.new(x, 4.5, 5), math.abs(x) < 60 and accent or C.Navy, 0, true, Enum.Material.Metal)
		local window = part(parent, "KioskWindow", Vector3.new(12, 4, 0.25), kiosk.Position + Vector3.new(0, 0.5, -7.1), C.Glass, 0.18, false, Enum.Material.Glass)
		window.Reflectance = 0.04
	end
	local arch = part(parent, "StadiumGateway", Vector3.new(145, 7, 8), Vector3.new(centre.X, 28, centre.Z - 236), C.Navy, 0, true, Enum.Material.Metal)
	textFace(arch, label, Enum.NormalId.Front)
	for _, x in ipairs({ -66, 66 }) do
		part(parent, "GatewayPylon", Vector3.new(7, 32, 7), Vector3.new(centre.X + x, 16, centre.Z - 236), accent, 0, true, Enum.Material.Metal)
	end
	for _, x in ipairs({ -90, -60, 60, 90 }) do lamp(parent, Vector3.new(centre.X + x, 0, centre.Z - 205)) end
	bench(parent, Vector3.new(centre.X - 78, 0, centre.Z - 205), 0)
	bench(parent, Vector3.new(centre.X + 78, 0, centre.Z - 205), 0)
end

local function createNewStadiumDistricts(layer)
	local roads = Instance.new("Model")
	roads.Name = "FutureStadiumRoadsV8"
	roads.Parent = layer

	-- Westhaven loop connects directly to existing TownH950 at x=-300.
	roadH(roads, "WesthavenNorthConnector", -1450, -300, 950, 30)
	roadH(roads, "WesthavenSouthLoop", -1450, -1050, 500, 30)
	roadV(roads, "WesthavenWestLoop", -1450, 500, 950, 30)
	roadV(roads, "WesthavenEastLoop", -1050, 500, 950, 30)

	-- Royal City loop connects to the existing town/east orbital at x=900.
	roadH(roads, "RoyalNorthConnector", 900, 2050, 950, 32)
	roadH(roads, "RoyalSouthLoop", 1650, 2050, 450, 32)
	roadV(roads, "RoyalWestLoop", 1650, 450, 950, 32)
	roadV(roads, "RoyalEastLoop", 2050, 450, 950, 32)

	local west = Instance.new("Model")
	west.Name = "WesthavenUnitedComplex"
	west.Parent = layer
	local westCentre = Vector3.new(-1250, 0, 720)
	part(west, "DistrictGround", Vector3.new(360, 0.5, 410), Vector3.new(westCentre.X, -0.35, westCentre.Z), Color3.fromRGB(61, 105, 59), 0, true, Enum.Material.Grass)
	createStadiumComplex(west, "WesthavenHarbourStadium", westCentre, C.Teal, "WESTHAVEN UNITED", "DOUBLE-TIER HARBOUR STADIUM", false)
	stadiumSupportVillage(west, westCentre, C.Teal, "WESTHAVEN UNITED • HARBOUR STADIUM")
	parkingLot(west, Vector3.new(-1370, 0, 720), 92, 250)
	parkingLot(west, Vector3.new(-1130, 0, 720), 92, 250)
	part(west, "ClubStore", Vector3.new(58, 14, 34), Vector3.new(-1330, 7, 900), C.Teal, 0, true, Enum.Material.Concrete)
	part(west, "SupportersPub", Vector3.new(62, 13, 36), Vector3.new(-1170, 6.5, 900), Color3.fromRGB(115, 76, 58), 0, true, Enum.Material.Brick)
	for _, p in ipairs({ Vector3.new(-1415, 0, 920), Vector3.new(-1085, 0, 920), Vector3.new(-1415, 0, 520), Vector3.new(-1085, 0, 520) }) do tree(west, p, 0.9) end

	local royal = Instance.new("Model")
	royal.Name = "RoyalCityFootballDistrict"
	royal.Parent = layer
	local royalCentre = Vector3.new(1850, 0, 700)
	part(royal, "DistrictGround", Vector3.new(360, 0.5, 430), Vector3.new(royalCentre.X, -0.35, royalCentre.Z), Color3.fromRGB(58, 102, 58), 0, true, Enum.Material.Grass)
	createStadiumComplex(royal, "RoyalCrownArena", royalCentre, C.Purple, "ROYAL CITY FC", "DOUBLE-TIER CROWN DOME", true)
	stadiumSupportVillage(royal, royalCentre, C.Purple, "ROYAL CITY FC • CROWN DOME")
	parkingLot(royal, Vector3.new(1730, 0, 700), 92, 250)
	parkingLot(royal, Vector3.new(1970, 0, 700), 92, 250)
	part(royal, "ClubMegastore", Vector3.new(70, 16, 38), Vector3.new(1745, 8, 915), C.Purple, 0, true, Enum.Material.Concrete)
	part(royal, "StadiumHotel", Vector3.new(76, 36, 46), Vector3.new(1955, 18, 910), Color3.fromRGB(86, 91, 99), 0, true, Enum.Material.Concrete)
	for floor = 1, 4 do
		part(royal, "HotelGlass", Vector3.new(60, 3.8, 0.24), Vector3.new(1955, floor * 7.2, 886.8), C.Glass, 0.16, false, Enum.Material.Glass)
	end
	for _, p in ipairs({ Vector3.new(1685, 0, 920), Vector3.new(2015, 0, 920), Vector3.new(1685, 0, 475), Vector3.new(2015, 0, 475) }) do tree(royal, p, 0.95) end
end

local function collectRoadSurfaces(root)
	local roads = {}
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("RoadInfrastructure") == true and obj.Material == Enum.Material.Asphalt and obj.Size.Y <= 1 then
			table.insert(roads, obj)
		end
	end
	return roads
end

local function overlapsXZ(a, b)
	return math.abs(a.Position.X - b.Position.X) <= (a.Size.X + b.Size.X) / 2 and math.abs(a.Position.Z - b.Position.Z) <= (a.Size.Z + b.Size.Z) / 2
end

local function buildIntersectionCleanup(layer, root)
	local roads = collectRoadSurfaces(root)
	local clean = Instance.new("Model")
	clean.Name = "IntersectionCleanupV8"
	clean.Parent = layer
	local made = {}
	local count = 0
	for i = 1, #roads do
		local a = roads[i]
		local aHorizontal = a.Size.X > a.Size.Z * 1.5
		local aVertical = a.Size.Z > a.Size.X * 1.5
		if aHorizontal or aVertical then
			for j = i + 1, #roads do
				local b = roads[j]
				local bHorizontal = b.Size.X > b.Size.Z * 1.5
				local bVertical = b.Size.Z > b.Size.X * 1.5
				if ((aHorizontal and bVertical) or (aVertical and bHorizontal)) and overlapsXZ(a, b) then
					local h = aHorizontal and a or b
					local v = aVertical and a or b
					local x, z = v.Position.X, h.Position.Z
					local key = tostring(math.floor(x + 0.5)) .. ":" .. tostring(math.floor(z + 0.5))
					if not made[key] then
						made[key] = true
						count += 1
						local cap = roadPart(part(clean, "IntersectionCap", Vector3.new(v.Size.X + 1.0, 0.08, h.Size.Z + 1.0), Vector3.new(x, 0.39, z), C.Road, 0, false, Enum.Material.Asphalt))
						cap:SetAttribute("IntersectionKey", key)
						-- Clean stop lines at each approach after old overlapping markings are covered.
						part(clean, "StopLineN", Vector3.new(v.Size.X - 3, 0.035, 0.35), Vector3.new(x, 0.45, z + h.Size.Z / 2 - 2.1), C.White, 0, false)
						part(clean, "StopLineS", Vector3.new(v.Size.X - 3, 0.035, 0.35), Vector3.new(x, 0.45, z - h.Size.Z / 2 + 2.1), C.White, 0, false)
						part(clean, "StopLineE", Vector3.new(0.35, 0.035, h.Size.Z - 3), Vector3.new(x + v.Size.X / 2 - 2.1, 0.45, z), C.White, 0, false)
						part(clean, "StopLineW", Vector3.new(0.35, 0.035, h.Size.Z - 3), Vector3.new(x - v.Size.X / 2 + 2.1, 0.45, z), C.White, 0, false)
					end
				end
			end
		end
	end
	layer:SetAttribute("IntersectionCapsBuilt", count)
end

local PROP_NAME_WORDS = { "Tree", "Bench", "Lamp", "Sign", "Kiosk", "Flag", "Bollard", "Planter", "Fence", "Shelter", "Cone", "Post" }

local function looksLikeRemovableProp(obj)
	if obj:GetAttribute("WorldDetailV6") == true or obj:GetAttribute("WorldDetailV8") == true then return true end
	for _, word in ipairs(PROP_NAME_WORDS) do
		if string.find(obj.Name, word) then return true end
	end
	return false
end

local function insideRoadFootprint(obj, road)
	local halfObjX, halfObjZ = obj.Size.X / 2, obj.Size.Z / 2
	local halfRoadX, halfRoadZ = road.Size.X / 2 - 0.6, road.Size.Z / 2 - 0.6
	return math.abs(obj.Position.X - road.Position.X) < halfObjX + halfRoadX and math.abs(obj.Position.Z - road.Position.Z) < halfObjZ + halfRoadZ
end

local function auditScenicRoadOverlap(layer, root)
	local roads = collectRoadSurfaces(root)
	local removed = 0
	local candidates = {}
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj:GetAttribute("RoadInfrastructure") ~= true and obj.Position.Y < 6 and looksLikeRemovableProp(obj) then
			table.insert(candidates, obj)
		end
	end
	for _, obj in ipairs(candidates) do
		if obj.Parent then
			for _, road in ipairs(roads) do
				if obj.Parent and insideRoadFootprint(obj, road) then
					local vehicle = obj:FindFirstAncestorWhichIsA("Model")
					if not (vehicle and vehicle:GetAttribute("RTGVehicle") == true) then
						obj:Destroy()
						removed += 1
					end
					break
				end
			end
		end
	end
	layer:SetAttribute("ScenicRoadOverlapPartsRemoved", removed)
end

local function addScenicBuffers(layer)
	local scenic = Instance.new("Model")
	scenic.Name = "ScenicBuffersV8"
	scenic.Parent = layer

	-- Stadium approach boulevards and green buffers, intentionally outside carriageways.
	for x = -1420, -1080, 55 do
		tree(scenic, Vector3.new(x, 0, 470), 0.85)
		tree(scenic, Vector3.new(x, 0, 980), 0.85)
	end
	for x = 1680, 2020, 55 do
		tree(scenic, Vector3.new(x, 0, 420), 0.9)
		tree(scenic, Vector3.new(x, 0, 980), 0.9)
	end

	local westPark = part(scenic, "WesthavenSupportersPark", Vector3.new(170, 0.24, 80), Vector3.new(-1250, 0.15, 1040), C.DarkGrass, 0, true, Enum.Material.Grass)
	for _, p in ipairs({ Vector3.new(-1310, 0, 1020), Vector3.new(-1270, 0, 1050), Vector3.new(-1230, 0, 1020), Vector3.new(-1190, 0, 1050) }) do tree(scenic, p, 0.8) end
	bench(scenic, westPark.Position + Vector3.new(-45, 0, 0), 90)
	bench(scenic, westPark.Position + Vector3.new(45, 0, 0), -90)

	local royalPark = part(scenic, "RoyalCityFanGardens", Vector3.new(170, 0.24, 80), Vector3.new(1850, 0.15, 1040), C.DarkGrass, 0, true, Enum.Material.Grass)
	for _, p in ipairs({ Vector3.new(1790, 0, 1020), Vector3.new(1830, 0, 1050), Vector3.new(1870, 0, 1020), Vector3.new(1910, 0, 1050) }) do tree(scenic, p, 0.85) end
	bench(scenic, royalPark.Position + Vector3.new(-45, 0, 0), 90)
	bench(scenic, royalPark.Position + Vector3.new(45, 0, 0), -90)
end

function WorldScenicV8Service:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root or not root.Parent then return end
	local old = root:FindFirstChild("WorldScenicV8")
	if old then old:Destroy() end

	local layer = Instance.new("Model")
	layer.Name = "WorldScenicV8"
	layer.Parent = root

	createNewStadiumDistricts(layer)
	addScenicBuffers(layer)
	buildIntersectionCleanup(layer, root)
	auditScenicRoadOverlap(layer, root)

	root:SetAttribute("WorldScenicVersion", "V8")
	root:SetAttribute("DoubleTierStadiumCount", 2)
	root:SetAttribute("CoveredPitchStadiumCount", 1)
	worldBuilder.WorldScenicV8 = layer
end

return WorldScenicV8Service
