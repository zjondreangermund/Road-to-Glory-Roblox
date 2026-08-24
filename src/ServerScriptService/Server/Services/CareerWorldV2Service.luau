local Workspace = game:GetService("Workspace")

local CareerWorldV2Service = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Dark = Color3.fromRGB(27, 31, 36),
	Navy = Color3.fromRGB(25, 40, 62),
	Steel = Color3.fromRGB(75, 82, 88),
	Concrete = Color3.fromRGB(174, 178, 181),
	Road = Color3.fromRGB(58, 61, 64),
	Grass = Color3.fromRGB(47, 111, 54),
	Dirt = Color3.fromRGB(132, 105, 76),
	Glass = Color3.fromRGB(123, 177, 198),
	Gold = Color3.fromRGB(223, 179, 50),
	Silver = Color3.fromRGB(210, 216, 220),
	Bronze = Color3.fromRGB(175, 110, 65),
	Red = Color3.fromRGB(205, 52, 52),
	Amber = Color3.fromRGB(235, 174, 47),
	Green = Color3.fromRGB(60, 181, 82),
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

local function surfaceText(target, text, face, textColor)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(850, 250)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = textColor or C.White
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
	return node
end

local function cylinderBetween(parent, name, a, b, radius, color, transparency, canCollide)
	local delta = b - a
	local length = delta.Magnitude
	if length < 0.001 then return nil end
	local right = delta.Unit
	local seedUp = math.abs(right:Dot(Vector3.yAxis)) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local back = right:Cross(seedUp).Unit
	local up = back:Cross(right).Unit
	local cf = CFrame.fromMatrix((a + b) / 2, right, up, back)
	local p = cfPart(parent, name, Vector3.new(length, radius * 2, radius * 2), cf, color, transparency or 0, canCollide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function netLine(parent, name, a, b)
	local delta = b - a
	if delta.Magnitude < 0.001 then return end
	local line = cfPart(parent, name, Vector3.new(0.035, 0.035, delta.Magnitude), CFrame.lookAt((a + b) / 2, b), Color3.fromRGB(229, 235, 237), 0.78, false)
	line.Material = Enum.Material.SmoothPlastic
end

local function createSoftGoal(parent, name, centreX, z, backSign, goalFor, functional)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent

	local width = 27
	local height = 8.8
	local depth = 6.2
	local rearHeight = 5.9
	local frontRadius = 0.22
	local rearRadius = 0.13
	local backZ = z + (backSign * depth)
	local leftX = centreX - width / 2
	local rightX = centreX + width / 2

	cylinderBetween(goal, "LeftPost", Vector3.new(leftX, 0, z), Vector3.new(leftX, height, z), frontRadius, C.White, 0, true)
	cylinderBetween(goal, "RightPost", Vector3.new(rightX, 0, z), Vector3.new(rightX, height, z), frontRadius, C.White, 0, true)
	cylinderBetween(goal, "Crossbar", Vector3.new(leftX, height, z), Vector3.new(rightX, height, z), frontRadius, C.White, 0, true)

	cylinderBetween(goal, "RearLeft", Vector3.new(leftX, 0, backZ), Vector3.new(leftX, rearHeight, backZ), rearRadius, C.White, 0.04, false)
	cylinderBetween(goal, "RearRight", Vector3.new(rightX, 0, backZ), Vector3.new(rightX, rearHeight, backZ), rearRadius, C.White, 0.04, false)
	cylinderBetween(goal, "RearBar", Vector3.new(leftX, rearHeight, backZ), Vector3.new(rightX, rearHeight, backZ), rearRadius, C.White, 0.04, false)
	cylinderBetween(goal, "LeftRoofSupport", Vector3.new(leftX, height, z), Vector3.new(leftX, rearHeight, backZ), rearRadius, C.White, 0.04, false)
	cylinderBetween(goal, "RightRoofSupport", Vector3.new(rightX, height, z), Vector3.new(rightX, rearHeight, backZ), rearRadius, C.White, 0.04, false)

	-- Very thin, highly transparent net strands so the net reads as soft instead of a rigid cage.
	for i = 0, 12 do
		local x = leftX + (width * i / 12)
		netLine(goal, "RearNetV" .. i, Vector3.new(x, 0.05, backZ), Vector3.new(x, rearHeight, backZ))
		netLine(goal, "RoofNetV" .. i, Vector3.new(x, height, z), Vector3.new(x, rearHeight, backZ))
	end
	for i = 0, 7 do
		local y = rearHeight * i / 7
		netLine(goal, "RearNetH" .. i, Vector3.new(leftX, y, backZ), Vector3.new(rightX, y, backZ))
	end
	for i = 0, 6 do
		local t = i / 6
		local yy = height + ((rearHeight - height) * t)
		local zz = z + ((backZ - z) * t)
		netLine(goal, "RoofNetH" .. i, Vector3.new(leftX, yy, zz), Vector3.new(rightX, yy, zz))
	end
	for _, x in ipairs({ leftX, rightX }) do
		for i = 0, 7 do
			local t = i / 7
			local zz = z + ((backZ - z) * t)
			local topY = height + ((rearHeight - height) * t)
			netLine(goal, "SideNetV" .. tostring(x) .. "_" .. i, Vector3.new(x, 0.05, zz), Vector3.new(x, topY, zz))
		end
		for i = 0, 6 do
			local y = rearHeight * i / 6
			netLine(goal, "SideNetH" .. tostring(x) .. "_" .. i, Vector3.new(x, y, z), Vector3.new(x, y, backZ))
		end
	end

	if functional then
		local trigger = part(goal, "GoalTrigger", Vector3.new(width - 1, height - 0.6, 4.5), Vector3.new(centreX, (height - 0.6) / 2, z + (backSign * 2.25)), C.White, 1, false)
		trigger.CanTouch = true
		trigger:SetAttribute("GoalFor", goalFor)
	end
	return goal
end

local function replaceGoals(worldBuilder)
	for _, name in ipairs({ "NorthGoal", "SouthGoal" }) do
		local old = worldBuilder.Model:FindFirstChild(name)
		if old then old:Destroy() end
	end
	createSoftGoal(worldBuilder.Model, "NorthGoal", 0, 88, 1, "Home", true)
	createSoftGoal(worldBuilder.Model, "SouthGoal", 0, -88, -1, "Away", true)

	local stadium = worldBuilder.FirstMatchStadium
	if stadium then
		for _, name in ipairs({ "StadiumNorthGoal", "StadiumSouthGoal" }) do
			local old = stadium:FindFirstChild(name)
			if old then old:Destroy() end
		end
		local pitch = stadium:FindFirstChild("MatchPitch")
		local centre = pitch and pitch.Position or Vector3.new(-88, 0, -585)
		-- North net goes away from the pitch toward +Z; south net toward -Z.
		createSoftGoal(stadium, "StadiumNorthGoal", centre.X, centre.Z + 91, 1, nil, false)
		createSoftGoal(stadium, "StadiumSouthGoal", centre.X, centre.Z - 91, -1, nil, false)
	end
end

local function roadEW(parent, name, x1, x2, z, width)
	width = width or 28
	local length = math.abs(x2 - x1)
	local centreX = (x1 + x2) / 2
	local road = part(parent, name, Vector3.new(length, 0.34, width), Vector3.new(centreX, 0.07, z), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for x = math.min(x1, x2) + 12, math.max(x1, x2) - 12, 20 do
		part(parent, name .. "CentreLine", Vector3.new(9, 0.05, 0.28), Vector3.new(x, 0.27, z), Color3.fromRGB(230, 218, 155), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, name .. "Edge", Vector3.new(length, 0.05, 0.2), Vector3.new(centreX, 0.27, z + side * (width / 2 - 0.5)), C.White, 0, false)
	end
	return road
end

local function roadNS(parent, name, x, z1, z2, width)
	width = width or 28
	local length = math.abs(z2 - z1)
	local centreZ = (z1 + z2) / 2
	local road = part(parent, name, Vector3.new(width, 0.34, length), Vector3.new(x, 0.07, centreZ), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for z = math.min(z1, z2) + 12, math.max(z1, z2) - 12, 20 do
		part(parent, name .. "CentreLine", Vector3.new(0.28, 0.05, 9), Vector3.new(x, 0.27, z), Color3.fromRGB(230, 218, 155), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(parent, name .. "Edge", Vector3.new(0.2, 0.05, length), Vector3.new(x + side * (width / 2 - 0.5), 0.27, centreZ), C.White, 0, false)
	end
	return road
end

local function makeTrafficRobot(parent, position, facePoint)
	local model = Instance.new("Model")
	model.Name = "TrafficRobot"
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	local pole = cfPart(model, "Pole", Vector3.new(0.6, 10, 0.6), base * CFrame.new(0, 5, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	cfPart(model, "Arm", Vector3.new(6, 0.45, 0.45), base * CFrame.new(0, 9.2, -2.7), C.Steel, 0, false)
	local box = cfPart(model, "SignalBox", Vector3.new(2.2, 5.4, 1.4), base * CFrame.new(0, 8.4, -5.3), C.Dark, 0, false)
	local lights = {}
	for index, color in ipairs({ C.Red, C.Amber, C.Green }) do
		local lamp = part(model, ({ "Red", "Amber", "Green" })[index], Vector3.new(1.15, 1.15, 0.35), Vector3.zero, color, index == 1 and 0 or 0.78, false)
		lamp.Shape = Enum.PartType.Ball
		lamp.CFrame = box.CFrame * CFrame.new(0, 1.7 - ((index - 1) * 1.7), -0.85)
		lamp.Material = Enum.Material.Neon
		lights[index] = lamp
	end
	return lights
end

local function createTrafficIntersection(parent, centre)
	local allSignals = {
		NS = {
			makeTrafficRobot(parent, centre + Vector3.new(-16, 0, -16), centre + Vector3.new(-16, 0, 20)),
			makeTrafficRobot(parent, centre + Vector3.new(16, 0, 16), centre + Vector3.new(16, 0, -20)),
		},
		EW = {
			makeTrafficRobot(parent, centre + Vector3.new(-16, 0, 16), centre + Vector3.new(20, 0, 16)),
			makeTrafficRobot(parent, centre + Vector3.new(16, 0, -16), centre + Vector3.new(-20, 0, -16)),
		},
	}

	local function setGroup(group, state)
		for _, signal in ipairs(group) do
			for index, lamp in ipairs(signal) do
				lamp.Transparency = index == state and 0 or 0.78
			end
		end
	end
	setGroup(allSignals.NS, 3)
	setGroup(allSignals.EW, 1)
	task.spawn(function()
		while parent.Parent do
			task.wait(8)
			setGroup(allSignals.NS, 2)
			task.wait(2)
			setGroup(allSignals.NS, 1)
			setGroup(allSignals.EW, 3)
			task.wait(8)
			setGroup(allSignals.EW, 2)
			task.wait(2)
			setGroup(allSignals.EW, 1)
			setGroup(allSignals.NS, 3)
		end
	end)
end

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = part(parent, "RuralTreeTrunk", Vector3.new(1.1 * scale, 6 * scale, 1.1 * scale), position + Vector3.new(0, 3 * scale, 0), Color3.fromRGB(92, 66, 43), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 7, 0), Vector3.new(-2, 6.5, 0), Vector3.new(2, 6.4, 0), Vector3.new(0, 6.5, 1.9) }) do
		local leaf = part(parent, "RuralTreeLeaves", Vector3.new(5.5, 5.5, 5.5) * scale, position + offset * scale, Color3.fromRGB(49, 105, 50), 0, false)
		leaf.Shape = Enum.PartType.Ball
		leaf.Material = Enum.Material.Grass
	end
end

local function propertyNode(house, id, displayName, price, position)
	local node = part(house, "PropertyNode", Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("PropertyId", id)
	node:SetAttribute("PropertyName", displayName)
	node:SetAttribute("PropertyPrice", price)
	return node
end

local function createStarterHouse(parent, id, displayName, position, wallColor, roofColor, price, width)
	width = width or 16
	local house = Instance.new("Model")
	house.Name = id
	house.Parent = parent
	part(house, "Foundation", Vector3.new(width + 2, 0.5, 15), position + Vector3.new(0, 0.25, 0), Color3.fromRGB(168, 164, 154), 0, true)
	part(house, "Body", Vector3.new(width, 7.5, 13), position + Vector3.new(0, 4, 0), wallColor, 0, true)
	part(house, "Roof", Vector3.new(width + 2, 1.4, 15), position + Vector3.new(0, 8.4, 0), roofColor, 0, true)
	part(house, "Door", Vector3.new(3, 5.5, 0.35), position + Vector3.new(-4, 3, 6.65), Color3.fromRGB(90, 61, 42), 0, true)
	for _, x in ipairs({ 1.5, 5.2 }) do
		part(house, "Window", Vector3.new(2.5, 2.1, 0.22), position + Vector3.new(x, 4.7, 6.7), C.Glass, 0.24, false)
	end
	local sign = part(house, "ForSaleSign", Vector3.new(6, 3, 0.25), position + Vector3.new(-(width / 2 + 2.5), 2.1, 7.2), C.Navy, 0, false)
	surfaceText(sign, displayName .. "\nN$" .. tostring(price), Enum.NormalId.Front)
	propertyNode(house, id, displayName, price, position + Vector3.new(-4, 2, 8.5))
	return house
end

local function createCommunityPitch(parent, centre)
	local pitch = part(parent, "DustFootballPitch", Vector3.new(78, 0.5, 112), centre, C.Dirt, 0, true)
	pitch.Material = Enum.Material.Sand
	createSoftGoal(parent, "VillageNorthGoal", centre.X, centre.Z + 52, 1, nil, false)
	createSoftGoal(parent, "VillageSouthGoal", centre.X, centre.Z - 52, -1, nil, false)
	interaction(parent, "ChildhoodPitch", "Childhood Football Ground", centre + Vector3.new(0, 2, 0), "Local Coach", "Before academies, contracts and crowds, this dusty pitch is where your football story began.", "Remember")
end

local function createOriginsVillage(expansion)
	local village = Instance.new("Model")
	village.Name = "OriginsVillage"
	village.Parent = expansion

	-- Main village intersection branches from the academy-stadium route.
	roadEW(village, "VillageMainRoad", -330, 65, -300, 28)
	roadNS(village, "VillageWestRoad", -245, -235, -500, 24)
	roadNS(village, "VillageEastRoad", -145, -245, -455, 22)
	roadEW(village, "VillageSouthRoad", -300, -115, -405, 22)
	createTrafficIntersection(village, Vector3.new(-88, 0, -300))

	local dirtRoad = part(village, "RuralDirtRoad", Vector3.new(24, 0.28, 180), Vector3.new(-305, 0.03, -385), C.Dirt, 0, true)
	dirtRoad.Material = Enum.Material.Ground

	-- Affordable homes provide a visible career ladder before luxury property exists.
	createStarterHouse(village, "Home_StarterRoom", "Starter Room", Vector3.new(-205, 0, -278), Color3.fromRGB(170, 155, 132), Color3.fromRGB(92, 70, 55), 250, 14)
	createStarterHouse(village, "Home_TinRoof", "Tin-Roof Cottage", Vector3.new(-258, 0, -278), Color3.fromRGB(184, 176, 153), Color3.fromRGB(112, 118, 119), 450, 15)
	createStarterHouse(village, "Home_BlueCottage", "Blue Village Cottage", Vector3.new(-205, 0, -365), Color3.fromRGB(122, 154, 174), Color3.fromRGB(79, 82, 84), 750, 17)
	createStarterHouse(village, "Home_BrickHouse", "Small Brick House", Vector3.new(-260, 0, -365), Color3.fromRGB(177, 112, 86), Color3.fromRGB(89, 61, 48), 1200, 18)
	createStarterHouse(village, "Home_FamilyHouse", "Family Starter House", Vector3.new(-190, 0, -430), Color3.fromRGB(190, 188, 172), Color3.fromRGB(63, 71, 80), 1800, 20)

	-- Village shop, bus stop and community hall make the area feel lived in.
	local shop = part(village, "VillageShop", Vector3.new(24, 8, 16), Vector3.new(-128, 4, -350), Color3.fromRGB(81, 96, 112), 0, true)
	local shopSign = part(village, "VillageShopSign", Vector3.new(14, 2.4, 0.3), Vector3.new(-128, 7, -341.8), C.Navy, 0, false)
	surfaceText(shopSign, "ORIGINS SHOP", Enum.NormalId.Front)
	interaction(village, "OriginsShop", "Origins Village Shop", Vector3.new(-128, 2, -340), "Shop Owner", "This is the kind of place you stop at before training when there is not much money in your pocket.", "Talk")

	part(village, "CommunityHall", Vector3.new(34, 9, 24), Vector3.new(-150, 4.5, -430), Color3.fromRGB(202, 194, 172), 0, true)
	local hallSign = part(village, "CommunityHallSign", Vector3.new(18, 2.5, 0.25), Vector3.new(-150, 7.5, -417.8), C.Navy, 0, false)
	surfaceText(hallSign, "COMMUNITY HALL", Enum.NormalId.Front)

	local shelter = part(village, "BusShelter", Vector3.new(12, 0.5, 5), Vector3.new(-105, 6.5, -334), C.Navy, 0, true)
	for _, x in ipairs({ -110, -100 }) do part(village, "BusPost", Vector3.new(0.5, 6, 0.5), Vector3.new(x, 3, -334), C.Steel, 0, true) end
	part(village, "BusBench", Vector3.new(8, 0.6, 2), Vector3.new(-105, 1.2, -333), Color3.fromRGB(105, 76, 49), 0, true)
	interaction(village, "VillageBusStop", "Origins Bus Stop", Vector3.new(-105, 2, -330), "Neighbour", "The academy is a long walk. Later this stop will connect to the travel system.", "Wait")

	createCommunityPitch(village, Vector3.new(-355, 0.25, -340))

	for _, p in ipairs({
		Vector3.new(-330, 0, -265), Vector3.new(-290, 0, -255), Vector3.new(-225, 0, -240), Vector3.new(-172, 0, -255),
		Vector3.new(-325, 0, -445), Vector3.new(-285, 0, -472), Vector3.new(-230, 0, -485), Vector3.new(-165, 0, -475),
		Vector3.new(-385, 0, -285), Vector3.new(-395, 0, -390), Vector3.new(-370, 0, -455),
	}) do tree(village, p, 0.85 + ((math.abs(p.X + p.Z) % 3) * 0.08)) end

	interaction(village, "OriginsVillage", "Origins Village", Vector3.new(-235, 2, -320), "Narrator", "A modest neighbourhood, cheap homes and a dusty football ground. This is the player's world before professional football changes everything.", "Look around")
	return village
end

local function trophyShape(parent, name, basePosition, style, color)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	part(model, "Base", Vector3.new(3.4, 1.2, 3.4), basePosition + Vector3.new(0, 0.6, 0), C.Navy, 0, true)
	local stem = cylinderBetween(model, "Stem", basePosition + Vector3.new(0, 1.2, 0), basePosition + Vector3.new(0, 3.5, 0), 0.22, color, 0, false)
	if stem then stem.Material = Enum.Material.Metal end

	if style == "world" then
		local globe = part(model, "Globe", Vector3.new(2.3, 2.3, 2.3), basePosition + Vector3.new(0, 4.5, 0), color, 0, false)
		globe.Shape = Enum.PartType.Ball
		globe.Material = Enum.Material.Metal
		for _, offset in ipairs({ -0.85, 0.85 }) do
			cylinderBetween(model, "Support", basePosition + Vector3.new(offset, 3.2, 0), basePosition + Vector3.new(offset * 0.55, 4.2, 0), 0.12, color, 0, false)
		end
	elseif style == "league" then
		local body = part(model, "CrownBody", Vector3.new(2.8, 2.8, 2.8), basePosition + Vector3.new(0, 4.4, 0), color, 0, false)
		body.Shape = Enum.PartType.Ball
		body.Material = Enum.Material.Metal
		for i = -2, 2 do
			part(model, "CrownPoint", Vector3.new(0.35, 1.4, 0.35), basePosition + Vector3.new(i * 0.55, 6.1 - math.abs(i) * 0.18, 0), color, 0, false)
		end
	else
		local bowl = part(model, "CupBowl", Vector3.new(style == "champions" and 3.2 or 2.7, style == "champions" and 3.0 or 2.5, 2.4), basePosition + Vector3.new(0, 4.7, 0), color, 0, false)
		bowl.Shape = Enum.PartType.Ball
		bowl.Material = Enum.Material.Metal
		for _, side in ipairs({ -1, 1 }) do
			cylinderBetween(model, "Handle", basePosition + Vector3.new(side * 1.1, 4.1, 0), basePosition + Vector3.new(side * 1.75, 5.6, 0), 0.12, color, 0, false)
		end
	end
	return model
end

local function rebuildTrophyHall(worldBuilder)
	local campus = worldBuilder.Campus
	if not campus then return end
	local building = campus:FindFirstChild("AcademyBuilding")
	local room = building and building:FindFirstChild("TrophyHall")
	if not room then return end

	for _, child in ipairs(room:GetChildren()) do
		if string.match(child.Name, "^Pedestal") or string.match(child.Name, "^Trophy") or child.Name == "DisplayGlass" or child.Name == "CareerTrophyDisplay" then
			child:Destroy()
		end
	end

	local display = Instance.new("Model")
	display.Name = "CareerTrophyDisplay"
	display.Parent = room
	local items = {
		{ "Copa America", "cup", C.Silver },
		{ "Champions League", "champions", C.Silver },
		{ "Premier League", "league", C.Silver },
		{ "World Cup", "world", C.Gold },
		{ "African Cup", "world", C.Gold },
		{ "Club Champions", "cup", C.Silver },
	}
	local zStart = 65
	for index, item in ipairs(items) do
		local z = zStart + ((index - 1) * 5.4)
		local basePos = Vector3.new(109, 0.5, z)
		trophyShape(display, "Trophy_" .. index, basePos, item[2], item[3])
		local plaque = part(display, "Plaque_" .. index, Vector3.new(0.25, 1.5, 4.2), Vector3.new(111.2, 1.5, z), C.Navy, 0, false)
		surfaceText(plaque, string.upper(item[1]), Enum.NormalId.Right)
	end
	local glass = part(display, "DisplayGlass", Vector3.new(0.28, 8.5, 35), Vector3.new(112, 4.4, 78.5), C.Glass, 0.72, false)
	glass.Material = Enum.Material.Glass
	interaction(display, "CareerTrophies", "Career Trophy Collection", Vector3.new(103, 2, 78), "Academy Guide", "These are the trophies every young player dreams about: continental cups, league titles, the World Cup and African glory.", "View")
end

function CareerWorldV2Service:Init(worldBuilder)
	local old = worldBuilder.Model:FindFirstChild("CareerWorldV2")
	if old then old:Destroy() end
	local expansionRoot = worldBuilder.Model:FindFirstChild("CareerWorldExpansion") or worldBuilder.Model
	local root = Instance.new("Model")
	root.Name = "CareerWorldV2"
	root.Parent = expansionRoot

	replaceGoals(worldBuilder)
	self.OriginsVillage = createOriginsVillage(root)
	rebuildTrophyHall(worldBuilder)
	worldBuilder.OriginsVillage = self.OriginsVillage
end

return CareerWorldV2Service
