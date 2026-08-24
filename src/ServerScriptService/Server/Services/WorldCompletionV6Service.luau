local WorldCompletionV6Service = {}

local C = {
	White = Color3.fromRGB(242, 244, 246),
	Black = Color3.fromRGB(24, 27, 31),
	Navy = Color3.fromRGB(19, 35, 61),
	Blue = Color3.fromRGB(39, 91, 168),
	Red = Color3.fromRGB(188, 48, 53),
	Purple = Color3.fromRGB(102, 58, 144),
	Road = Color3.fromRGB(48, 51, 54),
	Concrete = Color3.fromRGB(174, 177, 180),
	Pavement = Color3.fromRGB(196, 198, 199),
	Grass = Color3.fromRGB(55, 105, 55),
	DarkGrass = Color3.fromRGB(37, 78, 43),
	Glass = Color3.fromRGB(113, 172, 199),
	Steel = Color3.fromRGB(72, 79, 86),
	Gold = Color3.fromRGB(222, 177, 48),
	Wood = Color3.fromRGB(109, 76, 48),
	Yellow = Color3.fromRGB(231, 214, 137),
	Brick = Color3.fromRGB(148, 91, 69),
	Sand = Color3.fromRGB(176, 149, 111),
}

local function part(parent, name, size, position, color, transparency, canCollide)
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
	p:SetAttribute("WorldDetailV6", true)
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cf, color, transparency, canCollide)
	local p = part(parent, name, size, cf.Position, color, transparency, canCollide)
	p.CFrame = cf
	return p
end

local function wedge(parent, name, size, cf, color, transparency, canCollide)
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color or C.White
	p.Transparency = transparency or 0
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p:SetAttribute("WorldDetailV6", true)
	p.Parent = parent
	return p
end

local function cylinder(parent, name, size, cf, color, transparency, canCollide)
	local p = cfPart(parent, name, size, cf, color, transparency, canCollide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function signText(target, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(1000, 260)
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

local function roadInfrastructure(p)
	p:SetAttribute("RoadInfrastructure", true)
	return p
end

local function roadH(parent, name, x1, x2, z, width)
	width = width or 28
	local minX, maxX = math.min(x1, x2), math.max(x1, x2)
	local length = maxX - minX
	local centre = (minX + maxX) / 2
	local road = roadInfrastructure(part(parent, name, Vector3.new(length, 0.34, width), Vector3.new(centre, 0.13, z), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	for x = minX + 15, maxX - 15, 28 do
		roadInfrastructure(part(parent, name .. "Dash", Vector3.new(10, 0.05, 0.25), Vector3.new(x, 0.33, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadInfrastructure(part(parent, name .. "Edge", Vector3.new(length, 0.05, 0.18), Vector3.new(centre, 0.33, z + side * (width / 2 - 0.6)), C.White, 0, false))
		local walk = roadInfrastructure(part(parent, name .. "Walk", Vector3.new(length, 0.28, 6), Vector3.new(centre, 0.16, z + side * (width / 2 + 3.2)), C.Pavement, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	return road
end

local function roadV(parent, name, x, z1, z2, width)
	width = width or 28
	local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
	local length = maxZ - minZ
	local centre = (minZ + maxZ) / 2
	local road = roadInfrastructure(part(parent, name, Vector3.new(width, 0.34, length), Vector3.new(x, 0.13, centre), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	for z = minZ + 15, maxZ - 15, 28 do
		roadInfrastructure(part(parent, name .. "Dash", Vector3.new(0.25, 0.05, 10), Vector3.new(x, 0.33, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadInfrastructure(part(parent, name .. "Edge", Vector3.new(0.18, 0.05, length), Vector3.new(x + side * (width / 2 - 0.6), 0.33, centre), C.White, 0, false))
		local walk = roadInfrastructure(part(parent, name .. "Walk", Vector3.new(6, 0.28, length), Vector3.new(x + side * (width / 2 + 3.2), 0.16, centre), C.Pavement, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	return road
end

local function streetLamp(parent, position, rotate)
	local pole = part(parent, "DetailLampPole", Vector3.new(0.42, 9, 0.42), position + Vector3.new(0, 4.5, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	local arm = cfPart(parent, "DetailLampArm", Vector3.new(3.6, 0.3, 0.3), CFrame.new(position + Vector3.new(0, 8.5, 0)) * CFrame.Angles(0, math.rad(rotate or 0), 0), C.Steel, 0, false)
	arm.Material = Enum.Material.Metal
	local lamp = part(parent, "DetailLamp", Vector3.new(1.4, 0.25, 0.8), position + Vector3.new(1.55 * math.cos(math.rad(rotate or 0)), 8.3, -1.55 * math.sin(math.rad(rotate or 0))), Color3.fromRGB(247, 241, 202), 0, false)
	lamp.Material = Enum.Material.Neon
end

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = cylinder(parent, "DetailTreeTrunk", Vector3.new(6 * scale, 1.15 * scale, 1.15 * scale), CFrame.new(position + Vector3.new(0, 3 * scale, 0)) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(84, 61, 41), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 7, 0), Vector3.new(-2, 6.5, 0), Vector3.new(2, 6.4, 0), Vector3.new(0, 6.5, 2) }) do
		local crown = part(parent, "DetailTreeCrown", Vector3.new(5.1, 5.1, 5.1) * scale, position + offset * scale, Color3.fromRGB(43, 97, 46), 0, false)
		crown.Shape = Enum.PartType.Ball
		crown.Material = Enum.Material.Grass
	end
end

local function planter(parent, position, length)
	part(parent, "PlanterBase", Vector3.new(length, 1.1, 3.2), position + Vector3.new(0, 0.55, 0), Color3.fromRGB(111, 103, 92), 0, true)
	local hedge = part(parent, "PlanterHedge", Vector3.new(length - 0.6, 1.4, 2.5), position + Vector3.new(0, 1.5, 0), Color3.fromRGB(42, 92, 47), 0, false)
	hedge.Material = Enum.Material.Grass
end

local function bench(parent, position, yaw)
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	cfPart(parent, "BenchSeat", Vector3.new(7, 0.45, 2), cf * CFrame.new(0, 1.7, 0), C.Wood, 0, true).Material = Enum.Material.Wood
	cfPart(parent, "BenchBack", Vector3.new(7, 2.6, 0.35), cf * CFrame.new(0, 2.8, 0.85), C.Wood, 0, true).Material = Enum.Material.Wood
	for _, x in ipairs({ -2.5, 2.5 }) do
		cfPart(parent, "BenchLeg", Vector3.new(0.4, 1.6, 0.4), cf * CFrame.new(x, 0.8, 0), C.Steel, 0, true)
	end
end

local function flag(parent, position, color, text)
	part(parent, "FlagPole", Vector3.new(0.35, 13, 0.35), position + Vector3.new(0, 6.5, 0), C.Steel, 0, true).Material = Enum.Material.Metal
	local banner = part(parent, "FlagBanner", Vector3.new(5.5, 3, 0.2), position + Vector3.new(2.8, 10.8, 0), color, 0, false)
	if text then signText(banner, text, Enum.NormalId.Front) end
end

local function makeRoofGable(parent, centre, width, depth, y, color)
	wedge(parent, "RoofSlopeA", Vector3.new(width / 2, depth, 4), CFrame.new(centre + Vector3.new(-width / 4, y, 0)) * CFrame.Angles(math.rad(90), 0, math.rad(26)), color, 0, true)
	wedge(parent, "RoofSlopeB", Vector3.new(width / 2, depth, 4), CFrame.new(centre + Vector3.new(width / 4, y, 0)) * CFrame.Angles(math.rad(90), math.rad(180), math.rad(26)), color, 0, true)
end

local function detailedShop(parent, name, position, width, depth, height, color, label)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	part(model, "Shell", Vector3.new(width, height, depth), position + Vector3.new(0, height / 2, 0), color, 0, true)
	part(model, "Parapet", Vector3.new(width + 1.5, 1.1, depth + 1.5), position + Vector3.new(0, height + 0.55, 0), C.Navy, 0, true)
	part(model, "GlassFront", Vector3.new(width * 0.72, height * 0.56, 0.22), position + Vector3.new(0, height * 0.43, -(depth / 2 + 0.12)), C.Glass, 0.16, false)
	for _, x in ipairs({ -width * 0.37, width * 0.37 }) do
		part(model, "FacadeColumn", Vector3.new(1.2, height * 0.75, 1), position + Vector3.new(x, height * 0.42, -(depth / 2 + 0.55)), C.Concrete, 0, true)
	end
	local canopy = wedge(model, "EntranceCanopy", Vector3.new(width * 0.65, 6, 2.2), CFrame.new(position + Vector3.new(0, height * 0.72, -(depth / 2 + 2.5))) * CFrame.Angles(0, math.rad(90), 0), color:Lerp(C.White, 0.15), 0, true)
	canopy.Material = Enum.Material.Metal
	local sign = part(model, "StoreSign", Vector3.new(width * 0.7, 3.2, 0.25), position + Vector3.new(0, height - 2, -(depth / 2 + 0.3)), C.Navy, 0, false)
	signText(sign, label, Enum.NormalId.Front)
	part(model, "EntranceDoor", Vector3.new(4.5, 7, 0.25), position + Vector3.new(0, 3.5, -(depth / 2 + 0.15)), C.Glass, 0.1, false)
	return model
end

local function detailedHotel(parent, position)
	local model = Instance.new("Model")
	model.Name = "NorthbridgeGrandHotel"
	model.Parent = parent
	local height = 58
	part(model, "HotelTower", Vector3.new(82, height, 52), position + Vector3.new(0, height / 2, 0), Color3.fromRGB(183, 176, 162), 0, true)
	part(model, "HotelPodium", Vector3.new(112, 14, 72), position + Vector3.new(0, 7, 4), Color3.fromRGB(160, 156, 149), 0, true)
	for floor = 1, 6 do
		local y = 8 + floor * 7
		for _, x in ipairs({ -27, -13.5, 0, 13.5, 27 }) do
			part(model, "HotelWindow", Vector3.new(8, 4.2, 0.22), position + Vector3.new(x, y, -26.1), C.Glass, 0.15, false)
		end
	end
	local entrance = part(model, "HotelEntranceGlass", Vector3.new(24, 10, 0.25), position + Vector3.new(0, 5, -36.1), C.Glass, 0.1, false)
	entrance.Material = Enum.Material.Glass
	wedge(model, "HotelCanopy", Vector3.new(38, 10, 3), CFrame.new(position + Vector3.new(0, 10, -40)) * CFrame.Angles(0, math.rad(90), 0), C.Navy, 0, true)
	local sign = part(model, "HotelSign", Vector3.new(45, 5, 0.3), position + Vector3.new(0, 50, -26.2), C.Navy, 0, false)
	signText(sign, "NORTHBRIDGE GRAND", Enum.NormalId.Front)
	for _, x in ipairs({ -36, -18, 18, 36 }) do tree(model, position + Vector3.new(x, 0, -44), 0.65) end
	return model
end

local function detailedMall(parent, position)
	local model = Instance.new("Model")
	model.Name = "NorthbridgeGalleria"
	model.Parent = parent
	part(model, "MallWestWing", Vector3.new(92, 22, 88), position + Vector3.new(-52, 11, 0), Color3.fromRGB(197, 198, 194), 0, true)
	part(model, "MallEastWing", Vector3.new(92, 22, 88), position + Vector3.new(52, 11, 0), Color3.fromRGB(197, 198, 194), 0, true)
	local atrium = part(model, "MallAtrium", Vector3.new(30, 28, 82), position + Vector3.new(0, 14, -3), C.Glass, 0.22, true)
	atrium.Material = Enum.Material.Glass
	for _, x in ipairs({ -82, -55, -28, 28, 55, 82 }) do
		part(model, "MallFacadeRib", Vector3.new(1, 19, 1), position + Vector3.new(x, 10, -44.5), C.Steel, 0, true)
	end
	local sign = part(model, "MallSign", Vector3.new(55, 5, 0.3), position + Vector3.new(0, 22, -44.7), C.Navy, 0, false)
	signText(sign, "NORTHBRIDGE GALLERIA", Enum.NormalId.Front)
	wedge(model, "MallCanopyA", Vector3.new(55, 13, 3), CFrame.new(position + Vector3.new(-30, 13, -50)) * CFrame.Angles(0, math.rad(90), 0), C.Blue, 0, true)
	wedge(model, "MallCanopyB", Vector3.new(55, 13, 3), CFrame.new(position + Vector3.new(30, 13, -50)) * CFrame.Angles(0, math.rad(90), 0), C.Blue, 0, true)
	return model
end

local function petrolStation(parent, position)
	local model = Instance.new("Model")
	model.Name = "NorthbridgeFuelStop"
	model.Parent = parent
	local apron = part(model, "FuelApron", Vector3.new(92, 0.3, 70), position, Color3.fromRGB(151, 153, 154), 0, true)
	apron.Material = Enum.Material.Concrete
	part(model, "FuelShop", Vector3.new(42, 10, 24), position + Vector3.new(20, 5, 20), Color3.fromRGB(220, 219, 211), 0, true)
	local glass = part(model, "FuelShopGlass", Vector3.new(24, 6, 0.25), position + Vector3.new(20, 5, 7.9), C.Glass, 0.14, false)
	glass.Material = Enum.Material.Glass
	part(model, "FuelCanopy", Vector3.new(68, 1.2, 28), position + Vector3.new(-7, 10.5, -8), C.Navy, 0, true)
	for _, x in ipairs({ -28, 14 }) do
		part(model, "CanopyColumn", Vector3.new(1.2, 10, 1.2), position + Vector3.new(x, 5, -8), C.White, 0, true)
		for _, z in ipairs({ -14, -2 }) do
			part(model, "FuelPump", Vector3.new(2.5, 5, 2.2), position + Vector3.new(x, 2.5, z), C.Blue, 0, true)
			part(model, "PumpScreen", Vector3.new(1.6, 1.4, 0.15), position + Vector3.new(x, 3.3, z - 1.18), C.Black, 0, false)
		end
	end
	local sign = part(model, "FuelPylon", Vector3.new(8, 22, 2), position + Vector3.new(39, 11, -23), C.Navy, 0, true)
	signText(sign, "NORTHBRIDGE\nFUEL", Enum.NormalId.Front)
	return model
end

local function createTownExpansion(root)
	local district = Instance.new("Model")
	district.Name = "TownExpansionV6"
	district.Parent = root

	local roads = Instance.new("Model")
	roads.Name = "WestTownRoadExtension"
	roads.Parent = district
	for _, z in ipairs({ 450, 700, 950 }) do roadH(roads, "WestTownH" .. z, -1050, -300, z, 28) end
	roadV(roads, "WestTownLoop", -1050, 450, 950, 28)
	roadH(roads, "NorthCityRing", -1050, 900, 1120, 30)
	roadV(roads, "NorthWestLink", -1050, 950, 1120, 30)
	roadV(roads, "NorthEastLink", 900, 950, 1120, 30)

	-- Retail / hospitality district occupies enclosed blocks, well clear of carriageways.
	detailedMall(district, Vector3.new(-760, 0.2, 575))
	detailedHotel(district, Vector3.new(-760, 0.2, 825))
	petrolStation(district, Vector3.new(-500, 0.2, 575))
	detailedShop(district, "NorthbridgeSupermarket", Vector3.new(-500, 0.2, 825), 86, 54, 16, Color3.fromRGB(118, 145, 92), "NORTHBRIDGE MARKET")
	detailedShop(district, "NorthbridgeCinema", Vector3.new(-500, 0.2, 1050), 96, 58, 20, Color3.fromRGB(74, 72, 88), "NORTHBRIDGE CINEMA")
	detailedShop(district, "NorthbridgeFashion", Vector3.new(-760, 0.2, 1050), 92, 58, 18, Color3.fromRGB(150, 117, 137), "THE GALLERY • FASHION")

	for _, p in ipairs({
		Vector3.new(-920, 0, 575), Vector3.new(-920, 0, 825), Vector3.new(-920, 0, 1050),
		Vector3.new(-610, 0, 1050), Vector3.new(-350, 0, 1050),
	}) do tree(district, p, 0.85) end
	for _, p in ipairs({ Vector3.new(-645, 0, 635), Vector3.new(-645, 0, 765), Vector3.new(-645, 0, 885) }) do
		bench(district, p, 90)
		planter(district, p + Vector3.new(0, 0, 7), 12)
	end
	return district
end

local function addOriginsDetail(root)
	local origins = root:FindFirstChild("OriginsDistrict")
	if not origins then return end
	local detail = Instance.new("Model")
	detail.Name = "OriginsDetailV6"
	detail.Parent = origins

	-- Character and imperfection without blocking roads: yards, laundry, fences, community fixtures.
	for _, data in ipairs({
		{ Vector3.new(-525, 0.7, -80), 34 }, { Vector3.new(-775, 0.7, -80), 34 }, { Vector3.new(-525, 0.7, 80), 34 },
	}) do
		part(detail, "LowFence", Vector3.new(data[2], 1.4, 0.25), data[1], Color3.fromRGB(101, 105, 99), 0, true).Material = Enum.Material.Metal
	end
	for _, x in ipairs({ -540, -530, -520 }) do
		part(detail, "LaundryPost", Vector3.new(0.25, 3.6, 0.25), Vector3.new(x, 1.8, -92), C.Steel, 0, true)
	end
	part(detail, "LaundryLine", Vector3.new(22, 0.07, 0.07), Vector3.new(-530, 3.3, -92), C.Steel, 0, false)
	for i, x in ipairs({ -537, -532, -527, -522 }) do
		local cloth = part(detail, "Laundry", Vector3.new(3.5, 2.3, 0.08), Vector3.new(x, 2.3, -92), i % 2 == 0 and C.Blue or Color3.fromRGB(231, 211, 183), 0, false)
		cloth.Material = Enum.Material.Fabric
	end
	for _, p in ipairs({ Vector3.new(-865, 0, 160), Vector3.new(-690, 0, 160), Vector3.new(-610, 0, -150) }) do tree(detail, p, 0.75) end
	local mural = part(detail, "CommunityMural", Vector3.new(22, 6, 0.3), Vector3.new(-850, 4, -126.2), C.Blue, 0, false)
	signText(mural, "DREAM BIG\nORIGINS FC", Enum.NormalId.Front)
end

local function addResidentialDetail(root)
	local river = root:FindFirstChild("RiverstoneSuburb")
	if river then
		local d = Instance.new("Model")
		d.Name = "RiverstoneDetailV6"
		d.Parent = river
		for _, p in ipairs({ Vector3.new(470, 0, -170), Vector3.new(830, 0, -170), Vector3.new(470, 0, 170), Vector3.new(830, 0, 170) }) do
			part(d, "GardenWall", Vector3.new(72, 2, 1), p + Vector3.new(0, 1, 0), Color3.fromRGB(189, 187, 179), 0, true)
		end
		for _, p in ipairs({ Vector3.new(545, 0, 175), Vector3.new(755, 0, 175), Vector3.new(545, 0, -175), Vector3.new(755, 0, -175) }) do tree(d, p, 0.75) end
		local gate = part(d, "RiverstoneGateSign", Vector3.new(34, 5, 0.4), Vector3.new(650, 6, -190), C.Navy, 0, false)
		signText(gate, "RIVERSTONE", Enum.NormalId.Front)
		for _, x in ipairs({ 628, 672 }) do part(d, "GateColumn", Vector3.new(3, 10, 3), Vector3.new(x, 5, -190), C.Concrete, 0, true) end
	end

	local kings = root:FindFirstChild("KingsviewHeights")
	if kings then
		local d = Instance.new("Model")
		d.Name = "KingsviewDetailV6"
		d.Parent = kings
		for _, p in ipairs({ Vector3.new(455, 0, 515), Vector3.new(845, 0, 515), Vector3.new(455, 0, 885), Vector3.new(845, 0, 885) }) do tree(d, p, 1.0) end
		for _, z in ipairs({ 510, 890 }) do
			part(d, "EstateWall", Vector3.new(300, 3, 1.1), Vector3.new(650, 1.5, z), Color3.fromRGB(182, 181, 174), 0, true)
		end
		local arch = part(d, "KingsviewArch", Vector3.new(70, 6, 4), Vector3.new(650, 12, 500), C.Navy, 0, true)
		signText(arch, "KINGVIEW HEIGHTS", Enum.NormalId.Front)
		for _, x in ipairs({ 610, 690 }) do part(d, "KingsviewPylon", Vector3.new(6, 21, 6), Vector3.new(x, 10.5, 500), C.Concrete, 0, true) end
	end
end

local function addAcademyDetail(root)
	local academy = root:FindFirstChild("NorthbridgeAcademyCampus")
	if not academy then return end
	local d = Instance.new("Model")
	d.Name = "AcademyDetailV6"
	d.Parent = academy

	-- Perimeter fence around central campus, with deliberate breaks at north/south gates.
	for _, x in ipairs({ -168, 168 }) do
		for z = -130, 130, 18 do
			part(d, "FencePost", Vector3.new(0.35, 8, 0.35), Vector3.new(x, 4, z), C.Steel, 0, true)
		end
		local mesh = part(d, "FenceMesh", Vector3.new(0.12, 7, 260), Vector3.new(x, 4, 0), C.Steel, 0.6, false)
		mesh.Material = Enum.Material.Metal
	end
	for _, z in ipairs({ -148, 148 }) do
		for x = -150, 150, 18 do
			if math.abs(x) > 25 then part(d, "FencePost", Vector3.new(0.35, 8, 0.35), Vector3.new(x, 4, z), C.Steel, 0, true) end
		end
		for _, range in ipairs({ { -150, -28 }, { 28, 150 } }) do
			local length = range[2] - range[1]
			local centreX = (range[1] + range[2]) / 2
			local mesh = part(d, "FenceMesh", Vector3.new(length, 7, 0.12), Vector3.new(centreX, 4, z), C.Steel, 0.6, false)
			mesh.Material = Enum.Material.Metal
		end
	end

	local gate = part(d, "AcademyMainGate", Vector3.new(62, 5, 3), Vector3.new(0, 14, -148), C.Navy, 0, true)
	signText(gate, "NORTHBRIDGE FC\nACADEMY & PERFORMANCE CENTRE", Enum.NormalId.Front)
	for _, x in ipairs({ -35, 35 }) do part(d, "AcademyGatePylon", Vector3.new(5, 24, 5), Vector3.new(x, 12, -148), C.Blue, 0, true) end

	-- Reception / player arrival court.
	part(d, "ArrivalCourt", Vector3.new(100, 0.25, 36), Vector3.new(-85, 0.18, -112), C.Concrete, 0, true).Material = Enum.Material.Concrete
	for _, x in ipairs({ -120, -100, -80, -60 }) do planter(d, Vector3.new(x, 0, -124), 10) end
	flag(d, Vector3.new(-125, 0, -105), C.Blue, "NFC")
	flag(d, Vector3.new(-112, 0, -105), C.Navy, "ACADEMY")

	-- Changing / analysis annexes fill the previously empty building edges.
	detailedShop(d, "AcademyKitRoom", Vector3.new(-128, 0.2, 95), 42, 26, 10, Color3.fromRGB(70, 83, 100), "KIT & EQUIPMENT")
	detailedShop(d, "AcademyAnalysisRoom", Vector3.new(128, 0.2, 86), 44, 28, 11, Color3.fromRGB(71, 79, 91), "VIDEO ANALYSIS")

	-- Spectator rail / benches face central training pitch.
	for _, z in ipairs({ -105, -72, 72, 105 }) do bench(d, Vector3.new(88, 0, z), 90) end
	for _, z in ipairs({ -105, -35, 35, 105 }) do streetLamp(d, Vector3.new(-156, 0, z), 0) end
end

local function addStadiumDetail(root)
	local stadium = root:FindFirstChild("NorthbridgeCityStadium")
	if not stadium then return end
	local d = Instance.new("Model")
	d.Name = "StadiumDetailV6"
	d.Parent = stadium

	-- Club shop, fan zone and hospitality arranged around the existing south approach, clear of z=-500 road.
	detailedShop(d, "NorthbridgeClubShop", Vector3.new(-150, 0.2, -565), 64, 42, 15, C.Blue, "NORTHBRIDGE FC STORE")
	detailedShop(d, "MatchdayCafe", Vector3.new(150, 0.2, -565), 58, 40, 13, Color3.fromRGB(118, 76, 58), "THE NORTH STAND CAFE")
	part(d, "FanZone", Vector3.new(130, 0.25, 44), Vector3.new(0, 0.18, -575), C.Concrete, 0, true).Material = Enum.Material.Concrete
	for _, x in ipairs({ -48, -24, 24, 48 }) do
		local kiosk = part(d, "FanKiosk", Vector3.new(16, 8, 12), Vector3.new(x, 4, -580), x % 48 == 0 and C.Blue or C.Navy, 0, true)
		local front = part(d, "KioskFront", Vector3.new(10, 4.2, 0.2), kiosk.Position + Vector3.new(0, 0.5, -6.1), C.Glass, 0.2, false)
		front.Material = Enum.Material.Glass
	end
	for _, p in ipairs({ Vector3.new(-70, 0, -590), Vector3.new(70, 0, -590) }) do bench(d, p, 0) end
	for _, x in ipairs({ -92, -76, 76, 92 }) do flag(d, Vector3.new(x, 0, -602), x < 0 and C.Blue or C.Navy, "NFC") end

	-- Stadium exterior ribs / stairs give the shell more real architectural depth.
	for _, side in ipairs({ -1, 1 }) do
		local x = side * 120
		for z = -860, -640, 34 do
			wedge(d, "FacadeButtress", Vector3.new(10, 24, 5), CFrame.new(x, 12, z) * CFrame.Angles(0, side < 0 and math.rad(90) or math.rad(-90), 0), C.Steel, 0, true)
		end
		for z = -835, -665, 85 do
			local stairs = wedge(d, "ConcourseStair", Vector3.new(22, 34, 10), CFrame.new(side * 132, 6, z) * CFrame.Angles(0, side < 0 and math.rad(90) or math.rad(-90), 0), C.Concrete, 0, true)
			stairs.Material = Enum.Material.Concrete
		end
	end

	local monumentBase = cylinder(d, "LegendPlinth", Vector3.new(2.5, 18, 18), CFrame.new(0, 1.25, -600) * CFrame.Angles(0, 0, math.rad(90)), C.Concrete, 0, true)
	monumentBase.Material = Enum.Material.Concrete
	part(d, "LegendFigure", Vector3.new(3, 9, 3), Vector3.new(0, 7, -600), C.Gold, 0, false)
	part(d, "LegendBall", Vector3.new(2.5, 2.5, 2.5), Vector3.new(2.8, 3, -600), C.Gold, 0, false).Shape = Enum.PartType.Ball
end

local function addKingsportDetail(root)
	local complex = root:FindFirstChild("KingsportAthleticComplex")
	if not complex then return end
	local d = Instance.new("Model")
	d.Name = "KingsportDetailV6"
	d.Parent = complex
	local plaza = part(d, "KingsportFanPlaza", Vector3.new(220, 0.3, 70), Vector3.new(1275, 0.2, -535), C.Concrete, 0, true)
	plaza.Material = Enum.Material.Concrete
	for _, x in ipairs({ 1195, 1225, 1325, 1355 }) do flag(d, Vector3.new(x, 0, -565), C.Purple, "KA") end
	detailedShop(d, "KingsportMegastore", Vector3.new(1130, 0.2, -545), 72, 45, 17, C.Purple, "KINGSPORT STORE")
	detailedShop(d, "KingsportHospitality", Vector3.new(1420, 0.2, -545), 78, 48, 18, Color3.fromRGB(67, 57, 78), "ATHLETIC LOUNGE")
	for _, p in ipairs({ Vector3.new(1180, 0, -490), Vector3.new(1370, 0, -490) }) do tree(d, p, 0.9) end
end

local function addScenicWorld(root)
	local scenic = Instance.new("Model")
	scenic.Name = "ScenicWorldV6"
	scenic.Parent = root

	-- Low-poly distant terrain frame gives the map a horizon instead of endless flat baseplate.
	for i = 0, 10 do
		local x = -1650 + i * 320
		wedge(scenic, "DistantHill", Vector3.new(220, 85 + (i % 3) * 18, 180), CFrame.new(x, 20, 1210) * CFrame.Angles(0, math.rad(i % 2 == 0 and 0 or 180), 0), Color3.fromRGB(68, 92, 62), 0, true)
	end
	for i = 0, 7 do
		local z = -1100 + i * 300
		wedge(scenic, "WesternHill", Vector3.new(180, 65 + (i % 2) * 18, 220), CFrame.new(-1780, 16, z) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(74, 91, 65), 0, true)
	end

	-- Directional landmarks along major arterials.
	local signs = {
		{ Vector3.new(-240, 7, 25), "← ORIGINS     ACADEMY     RIVERSTONE →" },
		{ Vector3.new(25, 7, 300), "TOWN CENTRE ↑     NORTHBRIDGE FC ↓" },
		{ Vector3.new(930, 7, -330), "KINGSPORT ATHLETIC →" },
	}
	for _, data in ipairs(signs) do
		local board = part(scenic, "DirectionSign", Vector3.new(42, 5, 0.35), data[1], C.Navy, 0, false)
		signText(board, data[2], Enum.NormalId.Front)
		for _, x in ipairs({ -14, 14 }) do part(scenic, "SignPost", Vector3.new(0.45, 8, 0.45), data[1] + Vector3.new(x, -3.5, 0.8), C.Steel, 0, true) end
	end
end

local function createAssetSlots(root)
	local slots = Instance.new("Folder")
	slots.Name = "World3DAssetSlots"
	slots.Parent = root
	local definitions = {
		{ "OriginsVehicleMesh", Vector3.new(-500, 0.5, -150), "Vehicle", "Starter motorbike / hatchback replacement" },
		{ "TownBusMesh", Vector3.new(-350, 0.5, 710), "Vehicle", "City bus" },
		{ "TownStreetFurniture", Vector3.new(-620, 0.5, 700), "PropSet", "Bins, bollards, benches, bike racks" },
		{ "MallInteriorSet", Vector3.new(-760, 1, 575), "Interior", "Retail furniture and shop props" },
		{ "HotelInteriorSet", Vector3.new(-760, 1, 825), "Interior", "Lobby, seating, reception props" },
		{ "AcademyGymSet", Vector3.new(210, 1, 430), "Interior", "Gym machines and weights" },
		{ "AcademyMedicalSet", Vector3.new(130, 1, -72), "Interior", "Treatment tables / medical props" },
		{ "StadiumSeatSet", Vector3.new(0, 8, -750), "Stadium", "Higher-detail seats/crowd modules" },
		{ "StadiumConcourseSet", Vector3.new(0, 2, -625), "Stadium", "Turnstiles, kiosks and concourse props" },
		{ "KingsviewLuxuryVehicle", Vector3.new(550, 0.5, 515), "Vehicle", "Luxury sports car mesh" },
	}
	for _, data in ipairs(definitions) do
		local slot = part(slots, data[1], Vector3.new(1, 1, 1), data[2], C.White, 1, false)
		slot.CanTouch = false
		slot.CanQuery = false
		slot:SetAttribute("AssetSlotType", data[3])
		slot:SetAttribute("AssetSlotPurpose", data[4])
	end
end

function WorldCompletionV6Service:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root or not root.Parent then return end
	local old = root:FindFirstChild("WorldCompletionV6")
	if old then old:Destroy() end

	local layer = Instance.new("Model")
	layer.Name = "WorldCompletionV6"
	layer.Parent = root
	self.Layer = layer

	-- Expansion lives in its own layer; detail functions attach to the district models they enhance.
	createTownExpansion(layer)
	addOriginsDetail(root)
	addResidentialDetail(root)
	addAcademyDetail(root)
	addStadiumDetail(root)
	addKingsportDetail(root)
	addScenicWorld(layer)
	createAssetSlots(layer)

	root:SetAttribute("WorldCompletionVersion", "V6")
	root:SetAttribute("StoryFrozenForWorldBuild", true)
	root:SetAttribute("World3DAssetSlotsReady", true)
	worldBuilder.WorldCompletionV6 = layer
end

return WorldCompletionV6Service
