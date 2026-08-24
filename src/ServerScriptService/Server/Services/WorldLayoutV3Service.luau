local WorldLayoutV3Service = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Dark = Color3.fromRGB(28, 32, 37),
	Navy = Color3.fromRGB(24, 40, 64),
	Steel = Color3.fromRGB(73, 80, 86),
	Concrete = Color3.fromRGB(176, 180, 183),
	Road = Color3.fromRGB(57, 60, 63),
	Grass = Color3.fromRGB(58, 107, 57),
	Dirt = Color3.fromRGB(139, 111, 78),
	Glass = Color3.fromRGB(124, 178, 199),
	Blue = Color3.fromRGB(45, 99, 174),
	Red = Color3.fromRGB(188, 52, 52),
	Amber = Color3.fromRGB(234, 174, 48),
	Green = Color3.fromRGB(57, 181, 83),
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

local function cfPart(parent, name, size, cframe, color, transparency, canCollide)
	local p = part(parent, name, size, cframe.Position, color, transparency, canCollide)
	p.CFrame = cframe
	return p
end

local function surfaceText(target, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 260)
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

local function storyNode(parent, action, title, position, prompt)
	local node = part(parent, "Story_" .. action, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("StoryAction", action)
	node:SetAttribute("StoryTitle", title)
	node:SetAttribute("StoryPrompt", prompt or "Talk")
	return node
end

local function exploration(parent, id, title, position, speaker, text, prompt)
	local node = part(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", prompt or "Explore")
	return node
end

local function propertyNode(parent, id, displayName, price, position)
	local node = part(parent, "PropertyNode", Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("PropertyId", id)
	node:SetAttribute("PropertyName", displayName)
	node:SetAttribute("PropertyPrice", price)
	return node
end

local function roadEW(parent, name, x1, x2, z, width)
	width = width or 24
	local length = math.abs(x2 - x1)
	local centreX = (x1 + x2) / 2
	local road = part(parent, name, Vector3.new(length, 0.36, width), Vector3.new(centreX, 0.08, z), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for x = math.min(x1, x2) + 12, math.max(x1, x2) - 12, 20 do
		part(parent, name .. "CentreLine", Vector3.new(9, 0.05, 0.26), Vector3.new(x, 0.29, z), Color3.fromRGB(231, 219, 154), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, name .. "EdgeLine", Vector3.new(length, 0.05, 0.2), Vector3.new(centreX, 0.29, z + side * (width / 2 - 0.5)), C.White, 0, false)
		local walk = part(parent, name .. "Sidewalk", Vector3.new(length, 0.3, 5), Vector3.new(centreX, 0.16, z + side * (width / 2 + 3.0)), C.Concrete, 0, true)
		walk.Material = Enum.Material.Concrete
	end
	return road
end

local function roadNS(parent, name, x, z1, z2, width)
	width = width or 22
	local length = math.abs(z2 - z1)
	local centreZ = (z1 + z2) / 2
	local road = part(parent, name, Vector3.new(width, 0.36, length), Vector3.new(x, 0.08, centreZ), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for z = math.min(z1, z2) + 12, math.max(z1, z2) - 12, 20 do
		part(parent, name .. "CentreLine", Vector3.new(0.26, 0.05, 9), Vector3.new(x, 0.29, z), Color3.fromRGB(231, 219, 154), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, name .. "EdgeLine", Vector3.new(0.2, 0.05, length), Vector3.new(x + side * (width / 2 - 0.5), 0.29, centreZ), C.White, 0, false)
		local walk = part(parent, name .. "Sidewalk", Vector3.new(5, 0.3, length), Vector3.new(x + side * (width / 2 + 3.0), 0.16, centreZ), C.Concrete, 0, true)
		walk.Material = Enum.Material.Concrete
	end
	return road
end

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = part(parent, "TreeTrunk", Vector3.new(1.1 * scale, 6 * scale, 1.1 * scale), position + Vector3.new(0, 3 * scale, 0), Color3.fromRGB(91, 66, 43), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 7, 0), Vector3.new(-1.8, 6.5, 0), Vector3.new(1.8, 6.4, 0), Vector3.new(0, 6.5, 1.8) }) do
		local leaf = part(parent, "Leaves", Vector3.new(5.2, 5.2, 5.2) * scale, position + offset * scale, Color3.fromRGB(48, 104, 49), 0, false)
		leaf.Shape = Enum.PartType.Ball
		leaf.Material = Enum.Material.Grass
	end
end

local function createHouse(parent, id, displayName, position, price, bodyColor, roofColor, frontSign)
	frontSign = frontSign or -1
	local house = Instance.new("Model")
	house.Name = id
	house.Parent = parent
	part(house, "Foundation", Vector3.new(20, 0.5, 16), position + Vector3.new(0, 0.25, 0), Color3.fromRGB(169, 165, 156), 0, true)
	part(house, "Body", Vector3.new(18, 7.5, 14), position + Vector3.new(0, 4, 0), bodyColor, 0, true)
	part(house, "Roof", Vector3.new(20, 1.5, 16), position + Vector3.new(0, 8.5, 0), roofColor, 0, true)
	local frontZ = position.Z + (frontSign * 7.1)
	part(house, "Door", Vector3.new(3, 5.4, 0.3), Vector3.new(position.X - 4.5, 3, frontZ), Color3.fromRGB(88, 60, 42), 0, true)
	for _, x in ipairs({ position.X + 1.0, position.X + 5.2 }) do
		part(house, "Window", Vector3.new(2.5, 2.1, 0.2), Vector3.new(x, 4.8, frontZ), C.Glass, 0.24, false)
	end
	local yard = part(house, "Yard", Vector3.new(24, 0.18, 22), position + Vector3.new(0, 0.1, frontSign * 4), Color3.fromRGB(107, 128, 80), 0, true)
	yard.Material = Enum.Material.Grass
	local nodePos = Vector3.new(position.X - 5, 2, frontZ + frontSign * 2)
	propertyNode(house, id, displayName, price, nodePos)
	local sign = part(house, "ForSaleSign", Vector3.new(5.2, 2.6, 0.25), Vector3.new(position.X + 8.8, 1.8, frontZ + frontSign * 1.5), C.Navy, 0, false)
	surfaceText(sign, displayName .. "\nN$" .. tostring(price), frontSign < 0 and Enum.NormalId.Front or Enum.NormalId.Back)
	return house
end

local function createNPC(parent, name, position, lookAt, shirtColor, action, prompt)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	local torso = cfPart(model, "Torso", Vector3.new(2.1, 3.0, 1.2), base * CFrame.new(0, 3.2, 0), shirtColor, 0, false)
	local head = part(model, "Head", Vector3.new(1.7, 1.7, 1.7), position + Vector3.new(0, 5.5, 0), Color3.fromRGB(198, 158, 122), 0, false)
	head.Shape = Enum.PartType.Ball
	for _, side in ipairs({ -1, 1 }) do
		cfPart(model, "Leg", Vector3.new(0.75, 2.5, 0.8), base * CFrame.new(side * 0.55, 1.35, 0), Color3.fromRGB(50, 54, 58), 0, false)
	end
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(170, 34)
	billboard.StudsOffset = Vector3.new(0, 3.0, 0)
	billboard.MaxDistance = 35
	billboard.AlwaysOnTop = false
	billboard.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = C.White
	label.TextStrokeTransparency = 0.35
	label.TextSize = 16
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
	if action then
		local node = storyNode(model, action, name, torso.Position, prompt)
		node.CFrame = torso.CFrame
	end
	return model
end

local function createTrafficSignal(parent, position, facePoint)
	local model = Instance.new("Model")
	model.Name = "TrafficRobot"
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	local poleHeight = 10
	local pole = cfPart(model, "Pole", Vector3.new(0.55, poleHeight, 0.55), base * CFrame.new(0, poleHeight / 2, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	cfPart(model, "Arm", Vector3.new(5.4, 0.42, 0.42), base * CFrame.new(0, 9.2, -2.4), C.Steel, 0, false)
	local box = cfPart(model, "SignalBox", Vector3.new(2.0, 5.0, 1.3), base * CFrame.new(0, 8.3, -4.8), C.Dark, 0, false)
	local lamps = {}
	for index, color in ipairs({ C.Red, C.Amber, C.Green }) do
		local lamp = part(model, ({ "Red", "Amber", "Green" })[index], Vector3.new(1.0, 1.0, 0.35), Vector3.zero, color, index == 1 and 0 or 0.8, false)
		lamp.Shape = Enum.PartType.Ball
		lamp.CFrame = box.CFrame * CFrame.new(0, 1.55 - ((index - 1) * 1.55), -0.78)
		lamp.Material = Enum.Material.Neon
		lamps[index] = lamp
	end
	return lamps
end

local function trafficIntersection(parent, centre)
	local groups = { NS = {}, EW = {} }
	table.insert(groups.NS, createTrafficSignal(parent, centre + Vector3.new(-15, 0, -15), centre + Vector3.new(-15, 0, 20)))
	table.insert(groups.NS, createTrafficSignal(parent, centre + Vector3.new(15, 0, 15), centre + Vector3.new(15, 0, -20)))
	table.insert(groups.EW, createTrafficSignal(parent, centre + Vector3.new(-15, 0, 15), centre + Vector3.new(20, 0, 15)))
	table.insert(groups.EW, createTrafficSignal(parent, centre + Vector3.new(15, 0, -15), centre + Vector3.new(-20, 0, -15)))
	local function state(group, on)
		for _, signal in ipairs(group) do
			for index, lamp in ipairs(signal) do lamp.Transparency = index == on and 0 or 0.8 end
		end
	end
	state(groups.NS, 3)
	state(groups.EW, 1)
	task.spawn(function()
		while parent.Parent do
			task.wait(9)
			state(groups.NS, 2)
			task.wait(2)
			state(groups.NS, 1)
			state(groups.EW, 3)
			task.wait(9)
			state(groups.EW, 2)
			task.wait(2)
			state(groups.EW, 1)
			state(groups.NS, 3)
		end
	end)
end

local function createBusStop(parent, position, roadCentreZ)
	local stop = Instance.new("Model")
	stop.Name = "OriginsBusStop"
	stop.Parent = parent
	local shelterZ = position.Z
	local roof = part(stop, "Roof", Vector3.new(14, 0.45, 5.5), Vector3.new(position.X, 6.5, shelterZ), C.Navy, 0, true)
	for _, x in ipairs({ position.X - 6, position.X + 6 }) do
		part(stop, "Post", Vector3.new(0.45, 6.4, 0.45), Vector3.new(x, 3.2, shelterZ), C.Steel, 0, true)
	end
	local bench = cfPart(stop, "Bench", Vector3.new(9, 0.55, 2), CFrame.lookAt(Vector3.new(position.X, 1.25, shelterZ + 0.6), Vector3.new(position.X, 1.25, roadCentreZ)), Color3.fromRGB(108, 77, 49), 0, true)
	part(stop, "BackGlass", Vector3.new(11.5, 4.8, 0.22), Vector3.new(position.X, 3.2, shelterZ + 2.35), C.Glass, 0.5, false)
	local sign = part(stop, "StopSign", Vector3.new(3, 3, 0.25), Vector3.new(position.X + 8.5, 4, shelterZ), C.Navy, 0, false)
	surfaceText(sign, "BUS\nACADEMY", Enum.NormalId.Front)
	storyNode(stop, "TravelAcademy", "Bus to Academy", Vector3.new(position.X - 3.5, 2, shelterZ - 0.5), "Travel")
	exploration(stop, "OriginsBusStopV3", "Origins Bus Stop", Vector3.new(position.X + 3.5, 2, shelterZ - 0.5), "Neighbour", "The bus stop sits safely off the road and connects the childhood neighbourhood to the academy.", "Look")
	return stop
end

local function createDustPitch(parent, centre)
	local pitch = part(parent, "ChildhoodDustPitch", Vector3.new(82, 0.45, 112), centre, C.Dirt, 0, true)
	pitch.Material = Enum.Material.Sand
	local function goal(z, sign)
		local width, height = 20, 7
		local leftX, rightX = centre.X - width / 2, centre.X + width / 2
		for _, x in ipairs({ leftX, rightX }) do
			part(parent, "DustGoalPost", Vector3.new(0.35, height, 0.35), Vector3.new(x, height / 2, z), C.White, 0, true).Shape = Enum.PartType.Cylinder
		end
		part(parent, "DustCrossbar", Vector3.new(width, 0.35, 0.35), Vector3.new(centre.X, height, z), C.White, 0, true)
	end
	goal(centre.Z + 52, 1)
	goal(centre.Z - 52, -1)
	storyNode(parent, "ChildhoodPractice", "Childhood Pitch", centre + Vector3.new(0, 2, 0), "Practice")
	exploration(parent, "ChildhoodPitchV3", "Childhood Football Ground", centre + Vector3.new(10, 2, 0), "Local Coach", "A rough community pitch where the player learned to love football long before the academy.", "Remember")
end

local function createOriginsDistrict(worldBuilder, root)
	if worldBuilder.OriginsVillage and worldBuilder.OriginsVillage.Parent then worldBuilder.OriginsVillage:Destroy() end
	local district = Instance.new("Model")
	district.Name = "OriginsVillage"
	district.Parent = root

	local ground = part(district, "VillageGround", Vector3.new(470, 1, 290), Vector3.new(-545, -0.55, -195), C.Grass, 0, true)
	ground.Material = Enum.Material.Grass

	-- One clean connector branches from the academy/stadium road, then the neighbourhood sits well to the west.
	roadEW(district, "VillageConnector", -525, -88, -180, 24)
	roadEW(district, "VillageNorthStreet", -655, -385, -115, 22)
	roadEW(district, "VillageSouthStreet", -655, -385, -265, 22)
	roadNS(district, "VillageWestStreet", -585, -105, -275, 22)
	roadNS(district, "VillageEastStreet", -445, -105, -275, 22)
	trafficIntersection(district, Vector3.new(-445, 0, -180))

	-- Homes are deliberately 25+ studs away from lane centres, never in the street.
	local starter = createHouse(district, "Home_StarterRoom", "Starter Room", Vector3.new(-555, 0, -145), 250, Color3.fromRGB(177, 157, 132), Color3.fromRGB(94, 70, 54), -1)
	createHouse(district, "Home_TinRoof", "Tin-Roof Cottage", Vector3.new(-485, 0, -145), 450, Color3.fromRGB(188, 178, 151), Color3.fromRGB(112, 117, 118), -1)
	createHouse(district, "Home_BlueCottage", "Blue Village Cottage", Vector3.new(-555, 0, -225), 750, Color3.fromRGB(120, 154, 176), Color3.fromRGB(77, 83, 88), 1)
	createHouse(district, "Home_BrickHouse", "Small Brick House", Vector3.new(-485, 0, -225), 1200, Color3.fromRGB(176, 112, 87), Color3.fromRGB(89, 62, 49), 1)
	createHouse(district, "Home_FamilyHouse", "Family Starter House", Vector3.new(-405, 0, -225), 1800, Color3.fromRGB(193, 190, 173), Color3.fromRGB(63, 72, 82), 1)

	local shop = part(district, "OriginsShop", Vector3.new(26, 8, 17), Vector3.new(-395, 4, -145), Color3.fromRGB(80, 97, 113), 0, true)
	local shopSign = part(district, "ShopSign", Vector3.new(15, 2.4, 0.25), Vector3.new(-395, 7, -153.7), C.Navy, 0, false)
	surfaceText(shopSign, "ORIGINS SHOP", Enum.NormalId.Front)
	exploration(district, "OriginsShopV3", "Origins Shop", Vector3.new(-395, 2, -157), "Shop Owner", "A small neighbourhood shop serving families around the childhood district.", "Talk")

	part(district, "CommunityHall", Vector3.new(34, 9, 24), Vector3.new(-395, 4.5, -235), Color3.fromRGB(204, 196, 175), 0, true)
	local hallSign = part(district, "HallSign", Vector3.new(19, 2.4, 0.25), Vector3.new(-395, 7.3, -222.8), C.Navy, 0, false)
	surfaceText(hallSign, "COMMUNITY HALL", Enum.NormalId.Front)

	createBusStop(district, Vector3.new(-350, 0, -198), -180)
	local pitchCentre = Vector3.new(-700, 0.24, -190)
	createDustPitch(district, pitchCentre)

	-- Story NPCs.
	createNPC(district, "Mum", Vector3.new(-555, 0, -157), Vector3.new(-555, 0, -180), Color3.fromRGB(147, 77, 117), "FamilyTalk", "Talk")
	createNPC(district, "Coach Samuel", Vector3.new(-660, 0, -190), pitchCentre, Color3.fromRGB(51, 88, 143), "CoachTalk", "Talk")
	createNPC(district, "Neighbour Timo", Vector3.new(-365, 0, -198), Vector3.new(-350, 0, -198), Color3.fromRGB(68, 118, 78), nil, nil)

	for _, p in ipairs({
		Vector3.new(-620, 0, -85), Vector3.new(-540, 0, -88), Vector3.new(-465, 0, -88), Vector3.new(-390, 0, -90),
		Vector3.new(-625, 0, -295), Vector3.new(-540, 0, -300), Vector3.new(-465, 0, -300), Vector3.new(-390, 0, -298),
		Vector3.new(-735, 0, -125), Vector3.new(-740, 0, -245), Vector3.new(-675, 0, -280),
	}) do tree(district, p, 0.9) end

	exploration(district, "OriginsVillageV3", "Origins Village", Vector3.new(-520, 2, -180), "Narrator", "The player's childhood neighbourhood now sits away from the stadium, connected to the wider world by a proper road junction.", "Look around")

	worldBuilder.OriginsVillage = district
	worldBuilder.OriginsStarterHouse = starter
	worldBuilder.StoryMarkers = worldBuilder.StoryMarkers or {}
	worldBuilder.StoryMarkers.HomeSpawn = Vector3.new(-555, 3, -157)
	worldBuilder.StoryMarkers.ChildhoodPitch = pitchCentre + Vector3.new(0, 3, 0)
	worldBuilder.StoryMarkers.BusStop = Vector3.new(-350, 3, -198)
	return district
end

local function createStadiumGateway(worldBuilder, root)
	local stadium = worldBuilder.FirstMatchStadium
	if not stadium then return end
	local old = root:FindFirstChild("StadiumGatewayV3")
	if old then old:Destroy() end
	local pitch = stadium:FindFirstChild("MatchPitch")
	local centre = pitch and pitch.Position or Vector3.new(-88, 0, -585)
	local gate = Instance.new("Model")
	gate.Name = "StadiumGatewayV3"
	gate.Parent = root
	local entryZ = centre.Z + 164
	local plaza = part(gate, "ArrivalPlaza", Vector3.new(125, 0.42, 52), Vector3.new(centre.X, 0.16, entryZ), Color3.fromRGB(164, 168, 171), 0, true)
	plaza.Material = Enum.Material.Concrete

	-- Distinctive twin pylons and cantilevered matchday arch; clear lane remains underneath.
	for _, side in ipairs({ -1, 1 }) do
		local x = centre.X + side * 28
		part(gate, "EntryPylon", Vector3.new(5, 26, 5), Vector3.new(x, 13, entryZ - 10), C.Navy, 0, true)
		cfPart(gate, "EntryFin", Vector3.new(3, 19, 8), CFrame.new(x + side * 4, 17, entryZ - 10) * CFrame.Angles(0, 0, math.rad(side * 16)), C.Blue, 0, true)
		local banner = part(gate, "ClubBanner", Vector3.new(4, 10, 0.35), Vector3.new(x, 15, entryZ - 6.9), side == -1 and C.Blue or C.Red, 0, false)
		surfaceText(banner, side == -1 and "NFC" or "MATCHDAY", Enum.NormalId.Front)
	end
	local arch = part(gate, "MatchdayArch", Vector3.new(61, 4.5, 5), Vector3.new(centre.X, 24, entryZ - 10), C.Navy, 0, true)
	surfaceText(arch, "NORTHBRIDGE • FIRST MATCH", Enum.NormalId.Front)
	local crest = part(gate, "Crest", Vector3.new(8, 8, 1), Vector3.new(centre.X, 17.5, entryZ - 7.3), C.Blue, 0, false)
	crest.Shape = Enum.PartType.Ball
	surfaceText(crest, "N", Enum.NormalId.Front)

	for _, side in ipairs({ -1, 1 }) do
		local boothX = centre.X + side * 47
		part(gate, "TicketBooth", Vector3.new(13, 8, 10), Vector3.new(boothX, 4, entryZ - 2), Color3.fromRGB(62, 70, 80), 0, true)
		part(gate, "BoothGlass", Vector3.new(8, 3, 0.2), Vector3.new(boothX, 5, entryZ + 3.1), C.Glass, 0.25, false)
		for i = -1, 1 do
			part(gate, "Turnstile", Vector3.new(1, 4, 1), Vector3.new(centre.X + side * (14 + i * 4), 2, entryZ - 3), C.Steel, 0, true)
		end
	end

	local tunnelTarget = centre + Vector3.new(0, 3, 120)
	worldBuilder.StoryMarkers = worldBuilder.StoryMarkers or {}
	worldBuilder.StoryMarkers.StadiumArrival = Vector3.new(centre.X, 3, entryZ + 13)
	worldBuilder.StoryMarkers.StadiumTunnel = tunnelTarget
	storyNode(gate, "StartTrialMatch", "First Trial Match", tunnelTarget, "Start Match")
	exploration(gate, "StadiumGatewayV3", "Northbridge Matchday Gateway", Vector3.new(centre.X + 38, 2, entryZ + 10), "Steward", "The first-match entrance is designed as a destination, with club pylons, ticket booths and a clear procession toward the tunnel.", "Look")
end

local function addAcademyTravelNode(worldBuilder)
	local root = worldBuilder.Model:FindFirstChild("CareerWorldExpansion") or worldBuilder.Model
	local old = root:FindFirstChild("Story_TravelStadium")
	if old then old:Destroy() end
	storyNode(root, "TravelStadium", "Team Bus to Stadium", Vector3.new(-88, 2, -168), "Travel")
	worldBuilder.StoryMarkers = worldBuilder.StoryMarkers or {}
	worldBuilder.StoryMarkers.AcademyArrival = Vector3.new(-88, 3, -124)
end

local function correctSeats(worldBuilder)
	local campus = worldBuilder.Campus
	if not campus then return end
	for _, seat in ipairs(campus:GetDescendants()) do
		if seat:IsA("Seat") then
			local ancestor = seat.Parent
			local shouldFacePitch = false
			while ancestor and ancestor ~= campus do
				if ancestor.Name == "ScoutStand" or ancestor.Name == "HomeDugout" or ancestor.Name == "AwayDugout" then
					shouldFacePitch = true
					break
				end
				ancestor = ancestor.Parent
			end
			if shouldFacePitch then
				local pos = seat.Position
				seat.CFrame = CFrame.lookAt(pos, Vector3.new(0, pos.Y, pos.Z))
			end
		end
	end
end

function WorldLayoutV3Service:Init(worldBuilder)
	local expansionRoot = worldBuilder.Model:FindFirstChild("CareerWorldExpansion") or worldBuilder.Model
	local old = expansionRoot:FindFirstChild("WorldLayoutV3")
	if old then old:Destroy() end
	local root = Instance.new("Model")
	root.Name = "WorldLayoutV3"
	root.Parent = expansionRoot

	createOriginsDistrict(worldBuilder, root)
	createStadiumGateway(worldBuilder, root)
	addAcademyTravelNode(worldBuilder)
	correctSeats(worldBuilder)

	local spawn = worldBuilder.Model:FindFirstChild("CareerSpawn")
	if spawn then
		spawn.Position = worldBuilder.StoryMarkers.HomeSpawn
	end
	worldBuilder.WorldLayoutV3 = root
end

return WorldLayoutV3Service
