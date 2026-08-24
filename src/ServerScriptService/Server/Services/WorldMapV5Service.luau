local WorldMapV5Service = {}

local C = {
	White = Color3.fromRGB(242, 244, 246),
	Black = Color3.fromRGB(24, 27, 31),
	Navy = Color3.fromRGB(19, 35, 61),
	Blue = Color3.fromRGB(39, 91, 168),
	Red = Color3.fromRGB(188, 48, 53),
	Road = Color3.fromRGB(48, 51, 54),
	Concrete = Color3.fromRGB(174, 177, 180),
	Pavement = Color3.fromRGB(196, 198, 199),
	Grass = Color3.fromRGB(55, 105, 55),
	DarkGrass = Color3.fromRGB(37, 78, 43),
	Dirt = Color3.fromRGB(142, 111, 77),
	Glass = Color3.fromRGB(113, 172, 199),
	Steel = Color3.fromRGB(72, 79, 86),
	Gold = Color3.fromRGB(222, 177, 48),
	Wood = Color3.fromRGB(109, 76, 48),
	Yellow = Color3.fromRGB(231, 214, 137),
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
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cf, color, transparency, canCollide)
	local p = part(parent, name, size, cf.Position, color, transparency, canCollide)
	p.CFrame = cf
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

local function invisibleNode(parent, name, position)
	local p = part(parent, name, Vector3.new(2, 3, 2), position, C.White, 1, false)
	p.CanTouch = false
	return p
end

local function storyNode(parent, action, title, position, prompt)
	local p = invisibleNode(parent, "Story_" .. action, position)
	p:SetAttribute("StoryAction", action)
	p:SetAttribute("StoryTitle", title)
	p:SetAttribute("StoryPrompt", prompt or "Talk")
	return p
end

local function exploreNode(parent, id, title, position, speaker, text, prompt)
	local p = invisibleNode(parent, "Explore_" .. id, position)
	p:SetAttribute("ExplorationId", id)
	p:SetAttribute("ExplorationTitle", title)
	p:SetAttribute("ExplorationSpeaker", speaker)
	p:SetAttribute("ExplorationText", text)
	p:SetAttribute("ExplorationPrompt", prompt or "Explore")
	return p
end

local function npcAnchor(parent, name, style, position, lookAt, action, prompt)
	local cf = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	local p = invisibleNode(parent, "NPCAnchor_" .. string.gsub(name, " ", ""), position)
	p.CFrame = cf
	p:SetAttribute("NPCAnchor", true)
	p:SetAttribute("NPCName", name)
	p:SetAttribute("NPCStyle", style)
	if action then
		p:SetAttribute("StoryAction", action)
		p:SetAttribute("StoryTitle", name)
		p:SetAttribute("StoryPrompt", prompt or "Talk")
	end
	return p
end

local function propertyNode(parent, id, displayName, price, position)
	local p = invisibleNode(parent, "Property_" .. id, position)
	p:SetAttribute("PropertyId", id)
	p:SetAttribute("PropertyName", displayName)
	p:SetAttribute("PropertyPrice", price)
	return p
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

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = part(parent, "TreeTrunk", Vector3.new(1.2, 6, 1.2) * scale, position + Vector3.new(0, 3 * scale, 0), Color3.fromRGB(85, 61, 40), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 7, 0), Vector3.new(-2, 6.5, 0), Vector3.new(2, 6.3, 0), Vector3.new(0, 6.5, 2) }) do
		local leaf = part(parent, "TreeCrown", Vector3.new(5.4, 5.4, 5.4) * scale, position + offset * scale, Color3.fromRGB(47, 101, 49), 0, false)
		leaf.Shape = Enum.PartType.Ball
		leaf.Material = Enum.Material.Grass
	end
end

local function hedge(parent, position, size)
	local h = part(parent, "Hedge", size, position, Color3.fromRGB(42, 92, 47), 0, true)
	h.Material = Enum.Material.Grass
	return h
end

local function roadPart(p)
	p:SetAttribute("RoadInfrastructure", true)
	return p
end

local function streetLight(parent, position, alongX)
	local pole = roadPart(part(parent, "StreetLightPole", Vector3.new(0.45, 10, 0.45), position + Vector3.new(0, 5, 0), C.Steel, 0, true))
	pole.Material = Enum.Material.Metal
	local armSize = alongX and Vector3.new(4, 0.35, 0.35) or Vector3.new(0.35, 0.35, 4)
	local arm = roadPart(part(parent, "StreetLightArm", armSize, position + Vector3.new(0, 9.5, 0), C.Steel, 0, false))
	arm.Material = Enum.Material.Metal
	local lampOffset = alongX and Vector3.new(1.7, 9.25, 0) or Vector3.new(0, 9.25, 1.7)
	local lamp = roadPart(part(parent, "StreetLamp", Vector3.new(1.4, 0.25, 0.8), position + lampOffset, Color3.fromRGB(245, 240, 206), 0, false))
	lamp.Material = Enum.Material.Neon
end

local function addRoadH(roads, corridors, name, x1, x2, z, width)
	width = width or 28
	local minX, maxX = math.min(x1, x2), math.max(x1, x2)
	local length = maxX - minX
	local centreX = (minX + maxX) / 2
	local road = roadPart(part(roads, name, Vector3.new(length, 0.34, width), Vector3.new(centreX, 0.12, z), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	table.insert(corridors, { Axis = "H", Min = minX, Max = maxX, Centre = z, HalfWidth = width / 2 })
	for x = minX + 12, maxX - 12, 26 do
		roadPart(part(roads, name .. "Dash", Vector3.new(10, 0.05, 0.25), Vector3.new(x, 0.32, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadPart(part(roads, name .. "Edge", Vector3.new(length, 0.05, 0.18), Vector3.new(centreX, 0.32, z + side * (width / 2 - 0.6)), C.White, 0, false))
		local walk = roadPart(part(roads, name .. "Pavement", Vector3.new(length, 0.28, 6), Vector3.new(centreX, 0.16, z + side * (width / 2 + 3.2)), C.Pavement, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	for x = minX + 45, maxX - 30, 110 do
		streetLight(roads, Vector3.new(x, 0, z + width / 2 + 6.5), true)
	end
	return road
end

local function addRoadV(roads, corridors, name, x, z1, z2, width)
	width = width or 28
	local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
	local length = maxZ - minZ
	local centreZ = (minZ + maxZ) / 2
	local road = roadPart(part(roads, name, Vector3.new(width, 0.34, length), Vector3.new(x, 0.12, centreZ), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	table.insert(corridors, { Axis = "V", Min = minZ, Max = maxZ, Centre = x, HalfWidth = width / 2 })
	for z = minZ + 12, maxZ - 12, 26 do
		roadPart(part(roads, name .. "Dash", Vector3.new(0.25, 0.05, 10), Vector3.new(x, 0.32, z), C.Yellow, 0, false))
	end
	for _, side in ipairs({ -1, 1 }) do
		roadPart(part(roads, name .. "Edge", Vector3.new(0.18, 0.05, length), Vector3.new(x + side * (width / 2 - 0.6), 0.32, centreZ), C.White, 0, false))
		local walk = roadPart(part(roads, name .. "Pavement", Vector3.new(6, 0.28, length), Vector3.new(x + side * (width / 2 + 3.2), 0.16, centreZ), C.Pavement, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	for z = minZ + 45, maxZ - 30, 110 do
		streetLight(roads, Vector3.new(x + width / 2 + 6.5, 0, z), false)
	end
	return road
end

local function crosswalk(roads, x, z, horizontal)
	for i = -4, 4 do
		local stripe
		if horizontal then
			stripe = part(roads, "Crosswalk", Vector3.new(2, 0.055, 18), Vector3.new(x + i * 3.2, 0.34, z), C.White, 0, false)
		else
			stripe = part(roads, "Crosswalk", Vector3.new(18, 0.055, 2), Vector3.new(x, 0.34, z + i * 3.2), C.White, 0, false)
		end
		roadPart(stripe)
	end
end

local function createRoadNetwork(root)
	local roads = Instance.new("Model")
	roads.Name = "ConnectedRoadNetwork"
	roads.Parent = root
	local corridors = {}

	-- Academy ring and four arterial roads. Every endpoint meets another road.
	addRoadH(roads, corridors, "AcademyNorthRing", -180, 180, 160, 28)
	addRoadH(roads, corridors, "AcademySouthRing", -180, 180, -160, 28)
	addRoadV(roads, corridors, "AcademyWestRing", -180, -160, 160, 28)
	addRoadV(roads, corridors, "AcademyEastRing", 180, -160, 160, 28)
	addRoadH(roads, corridors, "WestCareerBoulevard", -900, -180, 0, 30)
	addRoadH(roads, corridors, "EastCareerBoulevard", 180, 900, 0, 30)
	addRoadV(roads, corridors, "NorthCareerAvenue", 0, 160, 950, 30)
	addRoadV(roads, corridors, "SouthCareerAvenue", 0, -1000, -160, 30)

	-- Origins closed grid.
	for _, z in ipairs({ -220, 0, 220 }) do addRoadH(roads, corridors, "OriginsH" .. z, -900, -400, z, 26) end
	for _, x in ipairs({ -900, -650, -400 }) do addRoadV(roads, corridors, "OriginsV" .. x, x, -220, 220, 26) end

	-- Riverstone closed grid and connection north toward town/Kingsview.
	for _, z in ipairs({ -220, 0, 220 }) do addRoadH(roads, corridors, "RiverstoneH" .. z, 400, 900, z, 26) end
	for _, x in ipairs({ 400, 650, 900 }) do addRoadV(roads, corridors, "RiverstoneV" .. x, x, -220, 220, 26) end
	addRoadV(roads, corridors, "EastOrbital", 900, -1000, 950, 30)
	addRoadV(roads, corridors, "RiverstoneNorthLink", 650, 220, 950, 26)

	-- Town centre / Kingsview grid.
	for _, z in ipairs({ 450, 700, 950 }) do addRoadH(roads, corridors, "TownH" .. z, -300, 900, z, 28) end
	for _, x in ipairs({ -300, 300 }) do addRoadV(roads, corridors, "TownV" .. x, x, 450, 950, 28) end

	-- Northbridge stadium loop and east connections.
	for _, z in ipairs({ -500, -1000 }) do addRoadH(roads, corridors, "StadiumH" .. z, -300, 900, z, 30) end
	for _, x in ipairs({ -300, 300 }) do addRoadV(roads, corridors, "StadiumV" .. x, x, -1000, -500, 30) end

	-- Kingsport future-club loop. Shares EastOrbital, so there are no dead ends.
	for _, z in ipairs({ -500, -1000 }) do addRoadH(roads, corridors, "KingsportH" .. z, 900, 1600, z, 32) end
	addRoadV(roads, corridors, "KingsportEast", 1600, -1000, -500, 32)

	for _, p in ipairs({
		Vector3.new(-400, 0, 0), Vector3.new(400, 0, 0), Vector3.new(0, 0, 160), Vector3.new(0, 0, -160),
		Vector3.new(-650, 0, 0), Vector3.new(650, 0, 0), Vector3.new(0, 0, 700), Vector3.new(0, 0, -500),
		Vector3.new(900, 0, -500), Vector3.new(900, 0, -1000),
	}) do crosswalk(roads, p.X, p.Z, true) end

	return roads, corridors
end

local function createModernHouse(parent, name, position, bodyColor, roofColor, price, propertyId)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local yard = part(model, "LandscapedYard", Vector3.new(52, 0.25, 46), position + Vector3.new(0, 0.1, 0), Color3.fromRGB(78, 116, 66), 0, true)
	yard.Material = Enum.Material.Grass
	part(model, "MainWing", Vector3.new(30, 10, 24), position + Vector3.new(-7, 5.1, 0), bodyColor, 0, true)
	part(model, "SideWing", Vector3.new(16, 7, 16), position + Vector3.new(16, 3.6, 3), bodyColor:Lerp(C.White, 0.12), 0, true)
	part(model, "RoofMain", Vector3.new(33, 1.2, 27), position + Vector3.new(-7, 10.6, 0), roofColor, 0, true)
	part(model, "RoofSide", Vector3.new(18, 1.0, 18), position + Vector3.new(16, 7.6, 3), roofColor, 0, true)
	part(model, "Porch", Vector3.new(12, 0.45, 5), position + Vector3.new(-8, 0.5, -14), C.Concrete, 0, true)
	part(model, "FrontDoor", Vector3.new(3.4, 6.4, 0.35), position + Vector3.new(-8, 3.5, -12.2), Color3.fromRGB(83, 56, 39), 0, true)
	for _, x in ipairs({ -18, -12, 1, 7 }) do
		part(model, "FrontWindow", Vector3.new(4.6, 3.2, 0.22), position + Vector3.new(x, 6.1, -12.15), C.Glass, 0.18, false)
	end
	part(model, "GarageDoor", Vector3.new(11, 5.3, 0.3), position + Vector3.new(16, 2.9, -5.1), Color3.fromRGB(216, 218, 219), 0, true)
	local drive = part(model, "Driveway", Vector3.new(14, 0.18, 18), position + Vector3.new(16, 0.19, -13), C.Concrete, 0, true)
	drive.Material = Enum.Material.Concrete
	for _, x in ipairs({ -24, 24 }) do hedge(model, position + Vector3.new(x, 1.2, 0), Vector3.new(2.2, 2.4, 43)) end
	if propertyId and price then propertyNode(model, propertyId, name, price, position + Vector3.new(-8, 2, -16)) end
	return model
end

local function createStarterHouse(parent, name, position, color, price, id)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local yard = part(model, "Yard", Vector3.new(42, 0.22, 38), position + Vector3.new(0, 0.08, 0), Color3.fromRGB(102, 126, 78), 0, true)
	yard.Material = Enum.Material.Grass
	part(model, "House", Vector3.new(24, 7.5, 18), position + Vector3.new(0, 3.9, 0), color, 0, true)
	part(model, "Roof", Vector3.new(27, 1.1, 21), position + Vector3.new(0, 8.2, 0), Color3.fromRGB(93, 74, 61), 0, true)
	part(model, "Porch", Vector3.new(12, 0.4, 4), position + Vector3.new(0, 0.45, -11), C.Concrete, 0, true)
	part(model, "Door", Vector3.new(3.2, 5.4, 0.28), position + Vector3.new(-5.5, 3, -9.15), Color3.fromRGB(88, 58, 40), 0, true)
	for _, x in ipairs({ 1, 6 }) do part(model, "Window", Vector3.new(3.6, 2.6, 0.2), position + Vector3.new(x, 4.5, -9.13), C.Glass, 0.2, false) end
	propertyNode(model, id, name, price, position + Vector3.new(-5, 2, -12.5))
	return model
end

local function createMansion(parent, name, position, color, price, id)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local plot = part(model, "EstateLawn", Vector3.new(112, 0.25, 94), position, Color3.fromRGB(65, 112, 61), 0, true)
	plot.Material = Enum.Material.Grass
	part(model, "MainResidence", Vector3.new(58, 16, 36), position + Vector3.new(0, 8.2, 5), color, 0, true)
	part(model, "WestWing", Vector3.new(28, 11, 28), position + Vector3.new(-39, 5.7, 7), color:Lerp(C.White, 0.08), 0, true)
	part(model, "EastWing", Vector3.new(28, 11, 28), position + Vector3.new(39, 5.7, 7), color:Lerp(C.White, 0.08), 0, true)
	part(model, "Roof", Vector3.new(62, 1.4, 40), position + Vector3.new(0, 16.8, 5), C.Navy, 0, true)
	for _, x in ipairs({ -20, -10, 0, 10, 20 }) do
		part(model, "UpperWindow", Vector3.new(5.5, 4, 0.24), position + Vector3.new(x, 11.5, -13.1), C.Glass, 0.15, false)
		part(model, "LowerWindow", Vector3.new(5.5, 4, 0.24), position + Vector3.new(x, 5.2, -13.1), C.Glass, 0.15, false)
	end
	part(model, "GrandDoor", Vector3.new(5.5, 8, 0.3), position + Vector3.new(0, 4.5, -13.2), Color3.fromRGB(82, 54, 38), 0, true)
	for _, x in ipairs({ -9, 9 }) do part(model, "EntranceColumn", Vector3.new(1.5, 10, 1.5), position + Vector3.new(x, 5.2, -16), C.White, 0, true) end
	part(model, "Balcony", Vector3.new(26, 0.6, 6), position + Vector3.new(0, 9.2, -16), C.Concrete, 0, true)
	local pool = part(model, "Pool", Vector3.new(36, 0.5, 18), position + Vector3.new(24, 0.25, 34), Color3.fromRGB(69, 157, 205), 0.18, false)
	pool.Material = Enum.Material.Glass
	local drive = part(model, "CircularDrive", Vector3.new(52, 0.18, 20), position + Vector3.new(0, 0.19, -34), C.Concrete, 0, true)
	drive.Material = Enum.Material.Concrete
	for _, offset in ipairs({ Vector3.new(-50, 0, -40), Vector3.new(50, 0, -40), Vector3.new(-50, 0, 38), Vector3.new(50, 0, 38) }) do tree(model, position + offset, 0.85) end
	propertyNode(model, id, name, price, position + Vector3.new(0, 2, -25))
	return model
end

local function createShop(parent, name, position, size, color, signName)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	part(model, "Building", size, position + Vector3.new(0, size.Y / 2, 0), color, 0, true)
	part(model, "RoofTrim", Vector3.new(size.X + 2, 1, size.Z + 2), position + Vector3.new(0, size.Y + 0.5, 0), C.Navy, 0, true)
	part(model, "ShopGlass", Vector3.new(size.X * 0.68, size.Y * 0.55, 0.25), position + Vector3.new(0, size.Y * 0.48, -(size.Z / 2 + 0.13)), C.Glass, 0.16, false)
	local sign = part(model, "Sign", Vector3.new(size.X * 0.72, 2.7, 0.3), position + Vector3.new(0, size.Y - 1.8, -(size.Z / 2 + 0.32)), C.Navy, 0, false)
	signText(sign, signName, Enum.NormalId.Front)
	part(model, "Awning", Vector3.new(size.X * 0.65, 0.4, 4), position + Vector3.new(0, size.Y * 0.62, -(size.Z / 2 + 2)), color:Lerp(C.White, 0.2), 0, true)
	return model
end

local function createOfficeBlock(parent, name, position, size, color, label)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	part(model, "Tower", size, position + Vector3.new(0, size.Y / 2, 0), color, 0, true)
	for floor = 1, math.floor(size.Y / 8) do
		local y = floor * 8 - 3
		for _, side in ipairs({ -1, 1 }) do
			part(model, "WindowBand", Vector3.new(size.X * 0.8, 3.5, 0.22), position + Vector3.new(0, y, side * (size.Z / 2 + 0.12)), C.Glass, 0.2, false)
		end
	end
	local sign = part(model, "BuildingSign", Vector3.new(size.X * 0.65, 3, 0.25), position + Vector3.new(0, size.Y - 2.2, -(size.Z / 2 + 0.15)), C.Navy, 0, false)
	signText(sign, label, Enum.NormalId.Front)
	return model
end

local function createGoal(parent, name, centreX, frontZ, backSign, baseY, width, height)
	width = width or 27
	height = height or 9
	local depth, rearHeight = 6.5, height * 0.7
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent
	local left, right = centreX - width / 2, centreX + width / 2
	local backZ = frontZ + backSign * depth
	for _, x in ipairs({ left, right }) do
		tubeBetween(goal, "FrontPost", Vector3.new(x, baseY, frontZ), Vector3.new(x, baseY + height, frontZ), 0.2, C.White, 0, true)
		tubeBetween(goal, "RearPost", Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.11, C.White, 0.03, false)
		tubeBetween(goal, "RoofSupport", Vector3.new(x, baseY + height, frontZ), Vector3.new(x, baseY + rearHeight, backZ), 0.11, C.White, 0.03, false)
	end
	tubeBetween(goal, "Crossbar", Vector3.new(left, baseY + height, frontZ), Vector3.new(right, baseY + height, frontZ), 0.2, C.White, 0, true)
	tubeBetween(goal, "RearBar", Vector3.new(left, baseY + rearHeight, backZ), Vector3.new(right, baseY + rearHeight, backZ), 0.11, C.White, 0.03, false)
	local netColor = Color3.fromRGB(231, 237, 239)
	for i = 0, 10 do
		local x = left + width * i / 10
		tubeBetween(goal, "RearNet", Vector3.new(x, baseY + 0.05, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.018, netColor, 0.82, false)
		tubeBetween(goal, "RoofNet", Vector3.new(x, baseY + height, frontZ), Vector3.new(x, baseY + rearHeight, backZ), 0.018, netColor, 0.84, false)
	end
	for i = 0, 6 do
		local y = baseY + rearHeight * i / 6
		tubeBetween(goal, "RearNetH", Vector3.new(left, y, backZ), Vector3.new(right, y, backZ), 0.018, netColor, 0.82, false)
	end
end

local function createPitch(parent, name, centre, width, length, grassColor)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local pitch = part(model, "MatchPitch", Vector3.new(width, 0.45, length), centre, grassColor or C.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	local y = centre.Y + 0.26
	for i = -4, 4 do
		local stripe = part(model, "MowingStripe", Vector3.new(width / 9, 0.03, length), Vector3.new(centre.X + i * width / 9, y, centre.Z), i % 2 == 0 and Color3.fromRGB(43, 111, 52) or Color3.fromRGB(48, 121, 57), 0, false)
		stripe.Material = Enum.Material.Grass
	end
	local line = Color3.fromRGB(239, 241, 238)
	local t = 0.16
	part(model, "LeftTouchline", Vector3.new(t, 0.05, length - 1), Vector3.new(centre.X - width / 2 + 0.5, y + 0.03, centre.Z), line, 0, false)
	part(model, "RightTouchline", Vector3.new(t, 0.05, length - 1), Vector3.new(centre.X + width / 2 - 0.5, y + 0.03, centre.Z), line, 0, false)
	part(model, "NorthGoalLine", Vector3.new(width - 1, 0.05, t), Vector3.new(centre.X, y + 0.03, centre.Z + length / 2 - 0.5), line, 0, false)
	part(model, "SouthGoalLine", Vector3.new(width - 1, 0.05, t), Vector3.new(centre.X, y + 0.03, centre.Z - length / 2 + 0.5), line, 0, false)
	part(model, "Halfway", Vector3.new(width - 1, 0.05, t), Vector3.new(centre.X, y + 0.03, centre.Z), line, 0, false)
	return model, pitch
end

local function makeCar(parent, name, position, yaw, color, vehicleType)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("RTGVehicle", true)
	model:SetAttribute("VehicleName", name)
	model:SetAttribute("VehicleType", vehicleType or "Car")
	model.Parent = parent
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local chassis = cfPart(model, "Chassis", Vector3.new(7.5, 1.1, 13), cf * CFrame.new(0, 1.3, 0), Color3.fromRGB(47, 49, 52), 0, true)
	model.PrimaryPart = chassis
	cfPart(model, "LowerBody", Vector3.new(7.2, 2.2, 12.4), cf * CFrame.new(0, 2.3, 0), color, 0, true)
	cfPart(model, "Cabin", Vector3.new(6.2, 2.6, 6.4), cf * CFrame.new(0, 4.2, 0.6), color:Lerp(C.White, 0.08), 0, true)
	cfPart(model, "Windshield", Vector3.new(5.5, 2.0, 0.25), cf * CFrame.new(0, 4.3, -2.7) * CFrame.Angles(math.rad(-12), 0, 0), C.Glass, 0.16, false)
	cfPart(model, "RearGlass", Vector3.new(5.5, 1.8, 0.25), cf * CFrame.new(0, 4.3, 3.7) * CFrame.Angles(math.rad(12), 0, 0), C.Glass, 0.16, false)
	for _, x in ipairs({ -3.7, 3.7 }) do
		for _, z in ipairs({ -4.2, 4.2 }) do
			local wheel = cfPart(model, "Wheel", Vector3.new(1.1, 2.6, 2.6), cf * CFrame.new(x, 1.3, z) * CFrame.Angles(0, 0, math.rad(90)), C.Black, 0, true)
			wheel.Shape = Enum.PartType.Cylinder
		end
	end
	for _, x in ipairs({ -2.2, 2.2 }) do
		cfPart(model, "Headlight", Vector3.new(1.5, 0.65, 0.18), cf * CFrame.new(x, 2.5, -6.25), Color3.fromRGB(246, 239, 194), 0, false).Material = Enum.Material.Neon
		cfPart(model, "TailLight", Vector3.new(1.5, 0.6, 0.18), cf * CFrame.new(x, 2.5, 6.25), C.Red, 0, false).Material = Enum.Material.Neon
	end
	local seat = Instance.new("VehicleSeat")
	seat.Name = "DriverSeat"
	seat.Anchored = true
	seat.CanCollide = true
	seat.Size = Vector3.new(2.2, 0.6, 2.3)
	seat.CFrame = cf * CFrame.new(-1.4, 3.2, 0.6)
	seat.Transparency = 0.35
	seat:SetAttribute("RTGVehicleSeat", true)
	seat.Parent = model
	return model
end

local function makeBike(parent, name, position, yaw, color)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("RTGVehicle", true)
	model:SetAttribute("VehicleName", name)
	model:SetAttribute("VehicleType", "Bike")
	model.Parent = parent
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	local chassis = cfPart(model, "BikeChassis", Vector3.new(1.2, 1.0, 5.8), cf * CFrame.new(0, 1.7, 0), C.Black, 0, true)
	chassis.Transparency = 0.65
	model.PrimaryPart = chassis
	for _, z in ipairs({ -2.6, 2.6 }) do
		local wheel = cfPart(model, "BikeWheel", Vector3.new(0.55, 3.1, 3.1), cf * CFrame.new(0, 1.55, z) * CFrame.Angles(0, 0, math.rad(90)), C.Black, 0, true)
		wheel.Shape = Enum.PartType.Cylinder
	end
	tubeBetween(model, "FrameA", (cf * CFrame.new(0, 1.5, 2.2)).Position, (cf * CFrame.new(0, 3.2, 0)).Position, 0.14, color, 0, false)
	tubeBetween(model, "FrameB", (cf * CFrame.new(0, 3.2, 0)).Position, (cf * CFrame.new(0, 1.5, -2.2)).Position, 0.14, color, 0, false)
	cfPart(model, "FuelTank", Vector3.new(1.6, 1.2, 2.2), cf * CFrame.new(0, 3.0, -0.4), color, 0, true)
	cfPart(model, "BikeSeatPad", Vector3.new(1.4, 0.45, 2.1), cf * CFrame.new(0, 3.15, 1.25), C.Black, 0, true)
	tubeBetween(model, "Handlebar", (cf * CFrame.new(-1.2, 3.7, -2.0)).Position, (cf * CFrame.new(1.2, 3.7, -2.0)).Position, 0.1, C.Steel, 0, false)
	local seat = Instance.new("VehicleSeat")
	seat.Name = "RiderSeat"
	seat.Anchored = true
	seat.CanCollide = true
	seat.Size = Vector3.new(1.4, 0.55, 1.8)
	seat.CFrame = cf * CFrame.new(0, 3.5, 1.1)
	seat.Transparency = 0.45
	seat:SetAttribute("RTGVehicleSeat", true)
	seat.Parent = model
	return model
end

local function createOrigins(root, vehicles)
	local district = Instance.new("Model")
	district.Name = "OriginsDistrict"
	district.Parent = root
	part(district, "OriginsGround", Vector3.new(560, 1, 520), Vector3.new(-650, -0.6, 0), Color3.fromRGB(103, 116, 78), 0, true).Material = Enum.Material.Grass

	createStarterHouse(district, "Childhood Home", Vector3.new(-525, 0, -110), Color3.fromRGB(188, 170, 143), 250, "starter_room")
	createStarterHouse(district, "Tin Roof Cottage", Vector3.new(-775, 0, -110), Color3.fromRGB(176, 184, 172), 500, "tin_cottage")
	createStarterHouse(district, "Blue Starter House", Vector3.new(-525, 0, 110), Color3.fromRGB(125, 157, 178), 850, "blue_starter")
	createStarterHouse(district, "Brick Starter House", Vector3.new(-775, 0, 110), Color3.fromRGB(179, 119, 94), 1300, "brick_starter")
	createShop(district, "OriginsMiniMarket", Vector3.new(-445, 0, -110), Vector3.new(42, 10, 28), Color3.fromRGB(78, 96, 111), "ORIGINS MINI MARKET")
	createShop(district, "OriginsClinic", Vector3.new(-445, 0, 110), Vector3.new(42, 10, 28), Color3.fromRGB(209, 211, 204), "COMMUNITY CLINIC")
	createShop(district, "OriginsCommunityHall", Vector3.new(-850, 0, -110), Vector3.new(48, 11, 32), Color3.fromRGB(202, 191, 166), "COMMUNITY HALL")

	local pitchCentre = Vector3.new(-775, 0.2, 110)
	local oldHouse = district:FindFirstChild("Brick Starter House")
	if oldHouse then oldHouse:Destroy() end
	local dust = part(district, "ChildhoodDustPitch", Vector3.new(120, 0.35, 160), pitchCentre, C.Dirt, 0, true)
	dust.Material = Enum.Material.Sand
	createGoal(district, "DustNorthGoal", pitchCentre.X, pitchCentre.Z + 76, 1, 0.38, 22, 7)
	createGoal(district, "DustSouthGoal", pitchCentre.X, pitchCentre.Z - 76, -1, 0.38, 22, 7)
	for _, p in ipairs({ Vector3.new(-842, 0, 28), Vector3.new(-708, 0, 28), Vector3.new(-842, 0, 192), Vector3.new(-708, 0, 192) }) do tree(district, p, 0.8) end

	-- Dedicated off-road bus bay on the pavement side of the west boulevard.
	local bay = part(district, "BusLayby", Vector3.new(58, 0.25, 16), Vector3.new(-365, 0.18, -30), C.Road, 0, true)
	bay.Material = Enum.Material.Asphalt
	local shelter = part(district, "BusShelterRoof", Vector3.new(18, 0.45, 6), Vector3.new(-365, 6.5, -44), C.Navy, 0, true)
	for _, x in ipairs({ -373, -357 }) do part(district, "BusShelterPost", Vector3.new(0.4, 6.4, 0.4), Vector3.new(x, 3.2, -44), C.Steel, 0, true) end
	cfPart(district, "BusBench", Vector3.new(11, 0.55, 2), CFrame.new(-365, 1.2, -43) * CFrame.Angles(0, math.rad(180), 0), C.Wood, 0, true)
	local busSign = part(district, "BusStopSign", Vector3.new(7, 2.4, 0.3), Vector3.new(-365, 5.1, -47), C.Navy, 0, false)
	signText(busSign, "ACADEMY BUS", Enum.NormalId.Front)

	npcAnchor(district, "Mum", "Family", Vector3.new(-525, 0.5, -134), Vector3.new(-525, 0.5, -110), "FamilyTalk", "Talk")
	npcAnchor(district, "Coach Samuel", "Coach", Vector3.new(-720, 0.5, 110), pitchCentre, "CoachTalk", "Talk")
	npcAnchor(district, "Timo", "Resident", Vector3.new(-470, 0.5, -98), Vector3.new(-445, 0.5, -110), nil, nil)
	local timo = exploreNode(district, "TimoV5", "Neighbour Timo", Vector3.new(-470, 2, -98), "Timo", "Everyone here knows this is your big day. Don't forget us when the stadiums get bigger.", "Talk")
	timo:SetAttribute("NPCAnchorLink", "Timo")
	storyNode(district, "ChildhoodPractice", "Old Childhood Pitch", pitchCentre + Vector3.new(0, 2, 0), "Practice")
	storyNode(district, "TravelAcademy", "Bus to Northbridge Academy", Vector3.new(-365, 2, -42), "Travel")
	exploreNode(district, "OriginsV5", "Origins Neighbourhood", Vector3.new(-600, 2, -15), "Narrator", "Working-class streets, family homes, a clinic, mini market and the sandy pitch where the career began.", "Look around")

	makeBike(vehicles, "Starter Motorbike", Vector3.new(-500, 0, -150), 90, C.Red)
	makeCar(vehicles, "Family Hatchback", Vector3.new(-475, 0, -145), 90, Color3.fromRGB(124, 139, 151), "Car")
	return district, pitchCentre
end

local function createRiverstone(root, vehicles)
	local district = Instance.new("Model")
	district.Name = "RiverstoneSuburb"
	district.Parent = root
	part(district, "RiverstoneGround", Vector3.new(540, 1, 500), Vector3.new(650, -0.6, 0), Color3.fromRGB(74, 111, 65), 0, true).Material = Enum.Material.Grass
	local positions = {
		Vector3.new(525, 0, -110), Vector3.new(775, 0, -110), Vector3.new(525, 0, 110), Vector3.new(775, 0, 110),
	}
	for i, p in ipairs(positions) do
		createModernHouse(district, "Riverstone Home " .. i, p, i % 2 == 0 and Color3.fromRGB(211, 207, 194) or Color3.fromRGB(176, 192, 197), Color3.fromRGB(65, 70, 76), 4500 + i * 900, "riverstone_" .. i)
	end
	local park = part(district, "RiverstonePark", Vector3.new(140, 0.25, 80), Vector3.new(650, 0.12, 110), Color3.fromRGB(52, 116, 58), 0, true)
	park.Material = Enum.Material.Grass
	for _, x in ipairs({ 595, 625, 675, 705 }) do tree(district, Vector3.new(x, 0, 110), 0.9) end
	exploreNode(district, "RiverstoneV5", "Riverstone", Vector3.new(650, 2, -90), "Resident", "A comfortable suburb for the stage when appearance fees and the first real salary begin changing life.", "Explore")
	makeCar(vehicles, "Riverstone Sedan", Vector3.new(560, 0, -145), 90, Color3.fromRGB(36, 66, 104), "Car")
	return district
end

local function createTown(root, vehicles)
	local district = Instance.new("Model")
	district.Name = "NorthbridgeTownCentre"
	district.Parent = root
	part(district, "TownGround", Vector3.new(1180, 1, 520), Vector3.new(300, -0.62, 700), Color3.fromRGB(139, 143, 145), 0, true).Material = Enum.Material.Concrete

	createOfficeBlock(district, "CivicTower", Vector3.new(-180, 0, 575), Vector3.new(90, 54, 70), Color3.fromRGB(91, 101, 112), "NORTHBRIDGE CIVIC")
	createOfficeBlock(district, "MediaHouse", Vector3.new(180, 0, 575), Vector3.new(80, 46, 64), Color3.fromRGB(77, 88, 101), "NORTHBRIDGE MEDIA")
	createShop(district, "SportsStore", Vector3.new(-180, 0, 825), Vector3.new(72, 16, 50), Color3.fromRGB(62, 90, 132), "MATCHDAY SPORTS")
	createShop(district, "Cafe", Vector3.new(0, 0, 825), Vector3.new(62, 14, 46), Color3.fromRGB(133, 88, 67), "THE HALF-TIME CAFE")
	createShop(district, "CarDealer", Vector3.new(180, 0, 825), Vector3.new(84, 16, 54), Color3.fromRGB(66, 72, 78), "NORTHBRIDGE MOTORS")
	createOfficeBlock(district, "Apartments", Vector3.new(520, 0, 575), Vector3.new(100, 62, 70), Color3.fromRGB(174, 166, 154), "RIVER VIEW APARTMENTS")
	createShop(district, "Bank", Vector3.new(520, 0, 825), Vector3.new(72, 18, 52), Color3.fromRGB(70, 91, 112), "NORTHBRIDGE BANK")

	local plaza = part(district, "TownSquare", Vector3.new(130, 0.3, 95), Vector3.new(0, 0.15, 575), Color3.fromRGB(183, 185, 183), 0, true)
	plaza.Material = Enum.Material.Concrete
	local fountain = part(district, "FountainBasin", Vector3.new(26, 1.2, 26), Vector3.new(0, 0.7, 575), Color3.fromRGB(91, 126, 143), 0, true)
	fountain.Shape = Enum.PartType.Cylinder
	for _, p in ipairs({ Vector3.new(-50, 0, 545), Vector3.new(50, 0, 545), Vector3.new(-50, 0, 605), Vector3.new(50, 0, 605) }) do tree(district, p, 0.75) end
	exploreNode(district, "TownCentreV5", "Northbridge Town Centre", Vector3.new(30, 2, 610), "Narrator", "Shops, apartments, media, a bank, cafe and car dealership connect career progression to a real town instead of isolated football venues.", "Explore")

	makeCar(vehicles, "Town Coupe", Vector3.new(145, 0, 790), 0, Color3.fromRGB(182, 52, 49), "Car")
	makeCar(vehicles, "Executive SUV", Vector3.new(205, 0, 790), 0, Color3.fromRGB(36, 40, 45), "SUV")
	return district
end

local function createKingsview(root, vehicles)
	local district = Instance.new("Model")
	district.Name = "KingsviewHeights"
	district.Parent = root
	part(district, "KingsviewGround", Vector3.new(560, 1, 500), Vector3.new(650, -0.6, 700), Color3.fromRGB(55, 102, 57), 0, true).Material = Enum.Material.Grass
	createMansion(district, "Kingsview Glass House", Vector3.new(515, 0, 575), Color3.fromRGB(210, 211, 207), 35000, "kingsview_glass")
	createMansion(district, "Kingsview Villa", Vector3.new(785, 0, 575), Color3.fromRGB(198, 185, 166), 52000, "kingsview_villa")
	createMansion(district, "Captain's Estate", Vector3.new(515, 0, 825), Color3.fromRGB(183, 194, 201), 85000, "captain_estate")
	createMansion(district, "Legend Residence", Vector3.new(785, 0, 825), Color3.fromRGB(220, 217, 207), 150000, "legend_residence")
	exploreNode(district, "KingsviewV5", "Kingsview Heights", Vector3.new(650, 2, 700), "Estate Agent", "The wealthy side of the career world: gated plots, pools, garages and homes that should feel earned rather than available on day one.", "Explore")
	makeCar(vehicles, "Kingsview Sports Car", Vector3.new(550, 0, 515), 90, Color3.fromRGB(200, 44, 44), "Car")
	makeCar(vehicles, "Kingsview SUV", Vector3.new(820, 0, 515), 90, Color3.fromRGB(25, 28, 31), "SUV")
	return district
end

local function createAcademy(root, worldBuilder, vehicles)
	local academy = Instance.new("Model")
	academy.Name = "NorthbridgeAcademyCampus"
	academy.Parent = root
	part(academy, "CampusGround", Vector3.new(350, 0.45, 310), Vector3.new(0, 0, 0), Color3.fromRGB(67, 105, 61), 0, true).Material = Enum.Material.Grass

	-- Buildings stay outside the existing playable/training pitch in the centre.
	local main = part(academy, "AcademyMainBuilding", Vector3.new(62, 16, 100), Vector3.new(-130, 8, 0), Color3.fromRGB(57, 68, 82), 0, true)
	part(academy, "AcademyGlassFront", Vector3.new(0.3, 10, 70), Vector3.new(-98.8, 8, 0), C.Glass, 0.18, false)
	local academySign = part(academy, "AcademySign", Vector3.new(0.35, 6, 52), Vector3.new(-98.6, 13, 0), C.Navy, 0, false)
	signText(academySign, "NORTHBRIDGE FC ACADEMY", Enum.NormalId.Right)

	part(academy, "PerformanceCentre", Vector3.new(64, 14, 72), Vector3.new(130, 7, 24), Color3.fromRGB(218, 219, 216), 0, true)
	part(academy, "PerformanceGlass", Vector3.new(0.3, 9, 52), Vector3.new(97.8, 7.5, 24), C.Glass, 0.16, false)
	part(academy, "MedicalWing", Vector3.new(54, 11, 42), Vector3.new(130, 5.5, -72), Color3.fromRGB(194, 204, 205), 0, true)
	part(academy, "RecoveryPool", Vector3.new(24, 0.55, 12), Vector3.new(130, 0.35, -72), Color3.fromRGB(70, 157, 201), 0.2, false).Material = Enum.Material.Glass

	-- Two full additional training pitches north of the ring, separated from the roads by setbacks.
	local p1 = createPitch(academy, "FirstTeamPitch", Vector3.new(-210, 0.2, 315), 118, 180, Color3.fromRGB(42, 116, 52))
	local p2 = createPitch(academy, "DevelopmentPitch", Vector3.new(210, 0.2, 315), 118, 180, Color3.fromRGB(42, 116, 52))
	createGoal(academy, "FTNorthGoal", -210, 315 + 86, 1, 0.43, 26, 8.5)
	createGoal(academy, "FTSouthGoal", -210, 315 - 86, -1, 0.43, 26, 8.5)
	createGoal(academy, "DevNorthGoal", 210, 315 + 86, 1, 0.43, 26, 8.5)
	createGoal(academy, "DevSouthGoal", 210, 315 - 86, -1, 0.43, 26, 8.5)

	local indoor = part(academy, "IndoorTrainingHall", Vector3.new(126, 22, 78), Vector3.new(-210, 11, 430), Color3.fromRGB(65, 72, 80), 0, true)
	local indoorSign = part(academy, "IndoorHallSign", Vector3.new(70, 4, 0.3), Vector3.new(-210, 17, 390.8), C.Navy, 0, false)
	signText(indoorSign, "INDOOR PERFORMANCE HALL", Enum.NormalId.Front)
	part(academy, "Gym", Vector3.new(78, 18, 64), Vector3.new(210, 9, 430), Color3.fromRGB(85, 94, 104), 0, true)
	for _, x in ipairs({ 184, 198, 212, 226, 240 }) do part(academy, "GymWindow", Vector3.new(8, 7, 0.24), Vector3.new(x, 10, 397.8), C.Glass, 0.18, false) end

	local busBay = part(academy, "TeamBusBay", Vector3.new(54, 0.25, 18), Vector3.new(135, 0.18, -130), C.Road, 0, true)
	busBay.Material = Enum.Material.Asphalt
	storyNode(academy, "TravelStadium", "Northbridge Team Bus", Vector3.new(135, 2, -130), "Travel")
	npcAnchor(academy, "Coach Daniels", "Coach", Vector3.new(-100, 0.5, -80), Vector3.new(0, 0.5, 0), nil, nil)
	npcAnchor(academy, "Scout Meyer", "Staff", Vector3.new(-100, 0.5, 65), Vector3.new(0, 0.5, 20), nil, nil)
	npcAnchor(academy, "Physio Amina", "Staff", Vector3.new(105, 0.5, -72), Vector3.new(130, 0.5, -72), nil, nil)
	npcAnchor(academy, "Kai Williams", "Player", Vector3.new(105, 0.5, 24), Vector3.new(0, 0.5, 20), nil, nil)
	exploreNode(academy, "AcademyV5", "Northbridge Academy", Vector3.new(-102, 2, 0), "Receptionist", "A real club campus: academy pitch, first-team pitch, development pitch, indoor hall, gym, medical and recovery facilities.", "Explore")

	makeCar(vehicles, "Academy Staff SUV", Vector3.new(142, 0, -112), 0, Color3.fromRGB(53, 62, 73), "SUV")
	worldBuilder.Campus = academy
	return academy
end

local function stadiumStand(parent, name, centre, side, length, rows, direction)
	local stand = Instance.new("Model")
	stand.Name = name
	stand.Parent = parent
	for row = 1, rows do
		local rise = row * 1.35
		local setback = row * 2.1
		local pos
		local size
		if side == "X" then
			pos = centre + Vector3.new(direction * setback, rise, 0)
			size = Vector3.new(4.4, 1.1, length)
		else
			pos = centre + Vector3.new(0, rise, direction * setback)
			size = Vector3.new(length, 1.1, 4.4)
		end
		part(stand, "Terrace", size, pos, row % 2 == 0 and Color3.fromRGB(58, 65, 74) or Color3.fromRGB(49, 56, 64), 0, true)
		local crowdStep = math.max(7, math.floor(length / 18))
		for n = -math.floor(length / (2 * crowdStep)), math.floor(length / (2 * crowdStep)) do
			local crowdPos
			if side == "X" then crowdPos = pos + Vector3.new(-direction * 1.1, 1.45, n * crowdStep) else crowdPos = pos + Vector3.new(n * crowdStep, 1.45, -direction * 1.1) end
			local spectator = part(stand, "Crowd", Vector3.new(1.3, 2.3, 1.1), crowdPos, (n + row) % 3 == 0 and C.Blue or ((n + row) % 3 == 1 and C.White or Color3.fromRGB(95, 100, 106)), 0, false)
			spectator.CanQuery = false
		end
	end
	return stand
end

local function createStadium(parent, name, centre, scale, clubName, accent, capacityLabel)
	local stadium = Instance.new("Model")
	stadium.Name = name
	stadium.Parent = parent
	local width = 122 * scale
	local length = 194 * scale
	local pitchModel, pitch = createPitch(stadium, "StadiumPitch", Vector3.new(centre.X, 0.2, centre.Z), width, length, Color3.fromRGB(42, 116, 52))
	pitch.Name = "MatchPitch"
	local baseY = 0.43
	createGoal(stadium, "NorthGoal", centre.X, centre.Z + length / 2 - 3, 1, baseY, 27 * scale, 9 * scale)
	createGoal(stadium, "SouthGoal", centre.X, centre.Z - length / 2 + 3, -1, baseY, 27 * scale, 9 * scale)

	local sideDistance = width / 2 + 13
	local endDistance = length / 2 + 13
	stadiumStand(stadium, "WestStand", Vector3.new(centre.X - sideDistance, 0, centre.Z), "X", length + 42, math.floor(10 * scale), -1)
	stadiumStand(stadium, "EastStand", Vector3.new(centre.X + sideDistance, 0, centre.Z), "X", length + 42, math.floor(10 * scale), 1)
	stadiumStand(stadium, "NorthStand", Vector3.new(centre.X, 0, centre.Z + endDistance), "Z", width + 60, math.floor(8 * scale), 1)
	stadiumStand(stadium, "SouthStand", Vector3.new(centre.X, 0, centre.Z - endDistance), "Z", width + 60, math.floor(8 * scale), -1)

	-- Continuous outer facade and roof canopy make the stadium read as one venue rather than four blocks.
	part(stadium, "WestFacade", Vector3.new(12, 28 * scale, length + 80), Vector3.new(centre.X - sideDistance - 28 * scale, 14 * scale, centre.Z), C.Navy, 0, true)
	part(stadium, "EastFacade", Vector3.new(12, 28 * scale, length + 80), Vector3.new(centre.X + sideDistance + 28 * scale, 14 * scale, centre.Z), C.Navy, 0, true)
	part(stadium, "NorthFacade", Vector3.new(width + 105, 24 * scale, 12), Vector3.new(centre.X, 12 * scale, centre.Z + endDistance + 24 * scale), C.Navy, 0, true)
	part(stadium, "SouthFacade", Vector3.new(width + 105, 24 * scale, 12), Vector3.new(centre.X, 12 * scale, centre.Z - endDistance - 24 * scale), C.Navy, 0, true)
	part(stadium, "WestRoof", Vector3.new(44 * scale, 1.3, length + 74), Vector3.new(centre.X - sideDistance - 10 * scale, 27 * scale, centre.Z), accent, 0, true)
	part(stadium, "EastRoof", Vector3.new(44 * scale, 1.3, length + 74), Vector3.new(centre.X + sideDistance + 10 * scale, 27 * scale, centre.Z), accent, 0, true)
	part(stadium, "NorthRoof", Vector3.new(width + 80, 1.3, 38 * scale), Vector3.new(centre.X, 24 * scale, centre.Z + endDistance + 9 * scale), accent, 0, true)
	part(stadium, "SouthRoof", Vector3.new(width + 80, 1.3, 38 * scale), Vector3.new(centre.X, 24 * scale, centre.Z - endDistance - 9 * scale), accent, 0, true)

	local press = part(stadium, "PressBox", Vector3.new(54, 12, 32), Vector3.new(centre.X + sideDistance + 35, 23, centre.Z), Color3.fromRGB(46, 52, 60), 0, true)
	part(stadium, "PressGlass", Vector3.new(0.25, 8, 24), press.Position + Vector3.new(-27.1, 0, 0), C.Glass, 0.12, false)
	local vip = part(stadium, "VIPSuite", Vector3.new(50, 11, 34), Vector3.new(centre.X - sideDistance - 35, 21, centre.Z), Color3.fromRGB(62, 67, 73), 0, true)
	part(stadium, "VIPGlass", Vector3.new(0.25, 7, 26), vip.Position + Vector3.new(25.1, 0, 0), C.Glass, 0.12, false)

	local board = part(stadium, "Scoreboard", Vector3.new(46, 17, 1.2), Vector3.new(centre.X, 35, centre.Z + endDistance + 15), C.Black, 0, false)
	signText(board, clubName .. "\n" .. capacityLabel, Enum.NormalId.Front)
	for _, offset in ipairs({ Vector3.new(-width / 2 - 55, 0, -length / 2 - 45), Vector3.new(width / 2 + 55, 0, -length / 2 - 45), Vector3.new(-width / 2 - 55, 0, length / 2 + 45), Vector3.new(width / 2 + 55, 0, length / 2 + 45) }) do
		local base = Vector3.new(centre.X + offset.X, 0, centre.Z + offset.Z)
		part(stadium, "FloodlightMast", Vector3.new(1.5, 48 * scale, 1.5), base + Vector3.new(0, 24 * scale, 0), C.Steel, 0, true)
		local lights = part(stadium, "FloodlightArray", Vector3.new(18, 3, 1), base + Vector3.new(0, 47 * scale, 0), C.White, 0, false)
		lights.Material = Enum.Material.Neon
	end

	-- Dugouts face the pitch.
	for _, data in ipairs({ { -1, accent }, { 1, C.Red } }) do
		local x = centre.X + data[1] * (width / 2 + 5)
		local cf = CFrame.lookAt(Vector3.new(x, 1, centre.Z - 20), Vector3.new(centre.X, 1, centre.Z - 20))
		local dug = Instance.new("Model")
		dug.Name = data[1] < 0 and "HomeDugout" or "AwayDugout"
		dug.Parent = stadium
		cfPart(dug, "Roof", Vector3.new(18, 0.4, 6), cf * CFrame.new(0, 6, 0), C.Navy, 0, true)
		cfPart(dug, "BackGlass", Vector3.new(18, 5.5, 0.25), cf * CFrame.new(0, 3, 2.8), C.Glass, 0.42, false)
		for i = -3, 3 do
			local seat = Instance.new("Seat")
			seat.Name = "DugoutSeat"
			seat.Anchored = true
			seat.Size = Vector3.new(2, 0.5, 2)
			seat.Color = data[2]
			seat.CFrame = cf * CFrame.new(i * 2.3, 1.0, 1.4)
			seat.Parent = dug
		end
	end
	return stadium, pitch
end

local function createNorthbridgeStadium(root, worldBuilder, vehicles)
	local centre = Vector3.new(0, 0, -750)
	local stadium, pitch = createStadium(root, "NorthbridgeCityStadium", centre, 1.0, "NORTHBRIDGE FC", C.Blue, "COMMUNITY STADIUM")

	local plaza = part(stadium, "MatchdayPlaza", Vector3.new(240, 0.35, 70), Vector3.new(0, 0.2, -535), C.Concrete, 0, true)
	plaza.Material = Enum.Material.Concrete
	for _, x in ipairs({ -58, 58 }) do
		part(stadium, "GatewayPylon", Vector3.new(7, 34, 7), Vector3.new(x, 17, -552), C.Navy, 0, true)
		cfPart(stadium, "GatewayBlade", Vector3.new(4, 27, 10), CFrame.new(x + (x < 0 and -6 or 6), 20, -552) * CFrame.Angles(0, 0, math.rad(x < 0 and -13 or 13)), C.Blue, 0, true)
	end
	local arch = part(stadium, "MainGatewayArch", Vector3.new(124, 6, 8), Vector3.new(0, 30, -552), C.Navy, 0, true)
	signText(arch, "NORTHBRIDGE FC • MATCHDAY", Enum.NormalId.Front)
	for _, x in ipairs({ -85, -70, 70, 85 }) do
		part(stadium, "TurnstileHousing", Vector3.new(10, 8, 10), Vector3.new(x, 4, -545), Color3.fromRGB(69, 75, 82), 0, true)
	end
	local tunnel = part(stadium, "PlayersTunnel", Vector3.new(24, 10, 30), Vector3.new(0, 5, -626), C.Navy, 0, true)
	part(stadium, "TunnelOpening", Vector3.new(14, 7.5, 0.3), Vector3.new(0, 4, -610.8), C.Black, 0, false)
	storyNode(stadium, "StartTrialMatch", "First Trial Match", Vector3.new(0, 2, -610), "Start Match")
	exploreNode(stadium, "NorthbridgeStadiumV5", "Northbridge City Stadium", Vector3.new(90, 2, -540), "Steward", "Covered stands, concourses, VIP and press areas, proper floodlights and a dedicated player arrival make the first stadium feel like a real destination.", "Explore")

	makeCar(vehicles, "Club Team SUV", Vector3.new(105, 0, -525), 90, C.Navy, "SUV")
	makeCar(vehicles, "Media Van", Vector3.new(-105, 0, -525), 90, Color3.fromRGB(228, 229, 226), "Car")
	worldBuilder.FirstMatchStadium = stadium
	worldBuilder.StoryMarkers.StadiumArrival = Vector3.new(0, 3, -540)
	worldBuilder.StoryMarkers.StadiumTunnel = Vector3.new(0, 3, -610)
	return stadium, pitch
end

local function createKingsportClub(root, vehicles)
	local club = Instance.new("Model")
	club.Name = "KingsportAthleticComplex"
	club.Parent = root
	local centre = Vector3.new(1275, 0, -750)
	local stadium = createStadium(club, "KingsportMetropolitanArena", centre, 1.32, "KINGSPORT ATHLETIC", Color3.fromRGB(121, 58, 151), "METROPOLITAN ARENA")
	local entrance = part(club, "KingsportEntrance", Vector3.new(160, 8, 12), Vector3.new(1275, 28, -515), Color3.fromRGB(62, 39, 83), 0, true)
	signText(entrance, "KINGSPORT ATHLETIC • METROPOLITAN ARENA", Enum.NormalId.Front)
	createPitch(club, "KingsportTrainingA", Vector3.new(1120, 0.2, -250), 120, 185, Color3.fromRGB(39, 108, 50))
	createPitch(club, "KingsportTrainingB", Vector3.new(1420, 0.2, -250), 120, 185, Color3.fromRGB(39, 108, 50))
	createOfficeBlock(club, "KingsportPerformanceCentre", Vector3.new(1275, 0, -250), Vector3.new(120, 28, 75), Color3.fromRGB(60, 55, 70), "KINGSPORT PERFORMANCE")
	exploreNode(club, "KingsportV5", "Kingsport Athletic", Vector3.new(1275, 2, -505), "Narrator", "A later-career rival club with a larger arena and elite training campus. It is visible now, but meant to become relevant as your career grows.", "Explore")
	makeCar(vehicles, "Kingsport Executive Car", Vector3.new(1370, 0, -520), 90, Color3.fromRGB(40, 32, 48), "Car")
	return club
end

local function pointInsideRoad(corridors, position)
	for _, c in ipairs(corridors) do
		if c.Axis == "H" then
			if position.X >= c.Min and position.X <= c.Max and math.abs(position.Z - c.Centre) <= c.HalfWidth - 0.8 then return true end
		else
			if position.Z >= c.Min and position.Z <= c.Max and math.abs(position.X - c.Centre) <= c.HalfWidth - 0.8 then return true end
		end
	end
	return false
end

local function auditRoadClearance(root, corridors)
	local removed = 0
	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.CanCollide and descendant:GetAttribute("RoadInfrastructure") ~= true and descendant.Position.Y < 5.5 then
			if pointInsideRoad(corridors, descendant.Position) then
				local vehicleModel = descendant:FindFirstAncestorWhichIsA("Model")
				if not (vehicleModel and vehicleModel:GetAttribute("RTGVehicle") == true) then
					descendant:Destroy()
					removed += 1
				end
			end
		end
	end
	root:SetAttribute("RoadObstacleAuditRemoved", removed)
end

function WorldMapV5Service:Init(worldBuilder)
	local old = worldBuilder.Model:FindFirstChild("CareerWorldV5")
	if old then old:Destroy() end

	local root = Instance.new("Model")
	root.Name = "CareerWorldV5"
	root.Parent = worldBuilder.Model
	worldBuilder.CareerWorldV5 = root
	worldBuilder.StoryMarkers = {}

	local worldGround = part(root, "WorldGround", Vector3.new(3700, 1.2, 2400), Vector3.new(300, -1.0, -80), Color3.fromRGB(72, 99, 64), 0, true)
	worldGround.Material = Enum.Material.Grass

	local roads, corridors = createRoadNetwork(root)
	worldBuilder.RoadNetworkV5 = roads
	worldBuilder.RoadCorridorsV5 = corridors

	local vehicles = Instance.new("Folder")
	vehicles.Name = "CareerVehicles"
	vehicles.Parent = root

	local origins, childhoodPitch = createOrigins(root, vehicles)
	createRiverstone(root, vehicles)
	createTown(root, vehicles)
	createKingsview(root, vehicles)
	createAcademy(root, worldBuilder, vehicles)
	createNorthbridgeStadium(root, worldBuilder, vehicles)
	createKingsportClub(root, vehicles)

	-- Career progression markers used by StoryService.
	worldBuilder.OriginsVillage = origins
	worldBuilder.StoryMarkers.HomeSpawn = Vector3.new(-525, 3, -134)
	worldBuilder.StoryMarkers.ChildhoodPitch = childhoodPitch + Vector3.new(0, 3, 0)
	worldBuilder.StoryMarkers.BusStop = Vector3.new(-365, 3, -42)
	worldBuilder.StoryMarkers.AcademyArrival = Vector3.new(0, 3, -125)

	local careerSpawn = worldBuilder.Model:FindFirstChild("CareerSpawn")
	if careerSpawn and careerSpawn:IsA("BasePart") then careerSpawn.Position = worldBuilder.StoryMarkers.HomeSpawn end

	auditRoadClearance(root, corridors)
	root:SetAttribute("WorldVersion", "V5")
	root:SetAttribute("RoadNetworkConnected", true)
end

return WorldMapV5Service
