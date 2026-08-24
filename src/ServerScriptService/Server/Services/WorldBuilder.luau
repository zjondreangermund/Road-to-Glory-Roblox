local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local WorldBuilder = {}

local COLORS = {
	White = Color3.fromRGB(244, 246, 247),
	Dark = Color3.fromRGB(28, 34, 42),
	Navy = Color3.fromRGB(24, 39, 61),
	Steel = Color3.fromRGB(75, 84, 94),
	Concrete = Color3.fromRGB(176, 181, 184),
	Grass = Color3.fromRGB(42, 118, 55),
	DarkGrass = Color3.fromRGB(34, 88, 46),
	Wood = Color3.fromRGB(112, 78, 49),
	Gold = Color3.fromRGB(226, 181, 48),
	Glass = Color3.fromRGB(126, 176, 198),
}

local function makePart(parent, name, size, position, color, transparency, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color or COLORS.White
	part.Transparency = transparency or 0
	part.CanCollide = canCollide ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeCFramePart(parent, name, size, cframe, color, transparency, canCollide)
	local part = makePart(parent, name, size, cframe.Position, color, transparency, canCollide)
	part.CFrame = cframe
	return part
end

local function addBillboard(part, text, studsOffset, maxDistance, textSize)
	local gui = Instance.new("BillboardGui")
	gui.Name = "WorldLabel"
	gui.Size = UDim2.fromOffset(150, 30)
	gui.StudsOffset = studsOffset or Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 38
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.White
	label.TextStrokeTransparency = 0.3
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize or 16
	label.TextWrapped = true
	label.Parent = gui
	return gui
end

local function addSurfaceSign(part, text, face, textSize)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SurfaceSign"
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(800, 220)
	gui.LightInfluence = 0
	gui.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.White
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize or 58
	label.TextScaled = false
	label.TextWrapped = true
	label.Parent = gui
	return gui
end

local function setupLighting()
	Lighting.ClockTime = 15.2
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(120, 125, 130)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.35
	Lighting.GlobalShadows = true

	local old = Lighting:FindFirstChild("RTGAtmosphere")
	if old then old:Destroy() end
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "RTGAtmosphere"
	atmosphere.Density = 0.18
	atmosphere.Haze = 0.35
	atmosphere.Glare = 0.05
	atmosphere.Color = Color3.fromRGB(214, 227, 235)
	atmosphere.Decay = Color3.fromRGB(118, 135, 151)
	atmosphere.Parent = Lighting
end

local function setupBallBoundaryGroups()
	pcall(function() PhysicsService:RegisterCollisionGroup("RTGBall") end)
	pcall(function() PhysicsService:RegisterCollisionGroup("RTGBallBoundary") end)
	PhysicsService:CollisionGroupSetCollidable("RTGBall", "RTGBallBoundary", true)
	PhysicsService:CollisionGroupSetCollidable("Default", "RTGBallBoundary", false)
end

local function createInteraction(parent, id, title, position, speaker, text, promptText)
	local node = makePart(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, COLORS.White, 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", promptText or "Explore")
	return node
end

local function createGoal(model, name, z, goalFor)
	local width = GameConfig.Prototype.GoalWidth
	local height = 9.5
	local depth = 6
	local direction = z > 0 and 1 or -1
	local backZ = z + (depth * direction)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = model

	local postThickness = 0.55
	makePart(goal, "LeftPost", Vector3.new(postThickness, height, postThickness), Vector3.new(-width / 2, height / 2, z), COLORS.White, 0, true)
	makePart(goal, "RightPost", Vector3.new(postThickness, height, postThickness), Vector3.new(width / 2, height / 2, z), COLORS.White, 0, true)
	makePart(goal, "Crossbar", Vector3.new(width + postThickness, postThickness, postThickness), Vector3.new(0, height, z), COLORS.White, 0, true)

	-- Rear goal frame gives the goal visible depth instead of looking like three blocks.
	makePart(goal, "BackLeft", Vector3.new(postThickness, height * 0.7, postThickness), Vector3.new(-width / 2, (height * 0.7) / 2, backZ), COLORS.White, 0.05, false)
	makePart(goal, "BackRight", Vector3.new(postThickness, height * 0.7, postThickness), Vector3.new(width / 2, (height * 0.7) / 2, backZ), COLORS.White, 0.05, false)
	makePart(goal, "BackBar", Vector3.new(width + postThickness, postThickness, postThickness), Vector3.new(0, height * 0.7, backZ), COLORS.White, 0.05, false)
	for _, x in ipairs({ -width / 2, width / 2 }) do
		makeCFramePart(goal, "RoofSupport", Vector3.new(postThickness, postThickness, depth), CFrame.new(x, height, z + ((depth / 2) * direction)), COLORS.White, 0.05, false)
	end

	-- Lightweight net grid. It is visual only; the invisible ball boundary catches hard shots.
	local netColor = Color3.fromRGB(226, 232, 235)
	for i = 0, 8 do
		local x = (-width / 2) + (width * i / 8)
		makePart(goal, "BackNetV" .. i, Vector3.new(0.07, height * 0.7, 0.07), Vector3.new(x, (height * 0.7) / 2, backZ), netColor, 0.42, false)
	end
	for i = 0, 5 do
		local y = (height * 0.7) * i / 5
		makePart(goal, "BackNetH" .. i, Vector3.new(width, 0.07, 0.07), Vector3.new(0, y, backZ), netColor, 0.42, false)
	end
	for _, x in ipairs({ -width / 2, width / 2 }) do
		for i = 0, 4 do
			local y = (height * 0.7) * i / 4
			makePart(goal, "SideNetH", Vector3.new(0.07, 0.07, depth), Vector3.new(x, y, z + ((depth / 2) * direction)), netColor, 0.46, false)
		end
		for i = 0, 4 do
			local netZ = z + ((depth * i / 4) * direction)
			local netHeight = height - ((height * 0.3) * (i / 4))
			makePart(goal, "SideNetV", Vector3.new(0.07, netHeight, 0.07), Vector3.new(x, netHeight / 2, netZ), netColor, 0.46, false)
		end
	end

	local trigger = makePart(goal, "GoalTrigger", Vector3.new(width - 1, height - 0.8, 4.8), Vector3.new(0, (height - 0.8) / 2, z + (2.4 * direction)), COLORS.White, 1, false)
	trigger.CanTouch = true
	trigger:SetAttribute("GoalFor", goalFor)
	return trigger
end

local function createPitchMarkings(model)
	local markings = Instance.new("Model")
	markings.Name = "PitchMarkings"
	markings.Parent = model

	local w = GameConfig.Prototype.PitchWidth
	local l = GameConfig.Prototype.PitchLength
	local y = 0.54
	local thickness = 0.16
	local lineColor = Color3.fromRGB(236, 239, 235)

	makePart(markings, "WestTouchline", Vector3.new(thickness, 0.06, l - 1), Vector3.new(-(w / 2) + 0.55, y, 0), lineColor, 0, false)
	makePart(markings, "EastTouchline", Vector3.new(thickness, 0.06, l - 1), Vector3.new((w / 2) - 0.55, y, 0), lineColor, 0, false)
	makePart(markings, "NorthGoalLine", Vector3.new(w - 1, 0.06, thickness), Vector3.new(0, y, (l / 2) - 0.55), lineColor, 0, false)
	makePart(markings, "SouthGoalLine", Vector3.new(w - 1, 0.06, thickness), Vector3.new(0, y, -(l / 2) + 0.55), lineColor, 0, false)
	makePart(markings, "Halfway", Vector3.new(w - 1, 0.06, thickness), Vector3.new(0, y, 0), lineColor, 0, false)

	-- Centre circle drawn from small tangential strips.
	local radius = 14
	local segments = 28
	for i = 1, segments do
		local a1 = ((i - 1) / segments) * math.pi * 2
		local a2 = (i / segments) * math.pi * 2
		local p1 = Vector3.new(math.cos(a1) * radius, y, math.sin(a1) * radius)
		local p2 = Vector3.new(math.cos(a2) * radius, y, math.sin(a2) * radius)
		local midpoint = (p1 + p2) / 2
		local length = (p2 - p1).Magnitude
		makeCFramePart(markings, "CentreCircle" .. i, Vector3.new(thickness, 0.06, length), CFrame.lookAt(midpoint, p2), lineColor, 0, false)
	end
	local centreSpot = makePart(markings, "CentreSpot", Vector3.new(0.8, 0.07, 0.8), Vector3.new(0, y + 0.01, 0), lineColor, 0, false)
	centreSpot.Shape = Enum.PartType.Ball

	local boxWidth = 48
	local boxDepth = 22
	for _, direction in ipairs({ -1, 1 }) do
		local endZ = direction * ((l / 2) - 0.65)
		local insideZ = endZ - (direction * boxDepth)
		makePart(markings, "PenaltyTop", Vector3.new(boxWidth, 0.06, thickness), Vector3.new(0, y, insideZ), lineColor, 0, false)
		makePart(markings, "PenaltyLeft", Vector3.new(thickness, 0.06, boxDepth), Vector3.new(-(boxWidth / 2), y, endZ - (direction * boxDepth / 2)), lineColor, 0, false)
		makePart(markings, "PenaltyRight", Vector3.new(thickness, 0.06, boxDepth), Vector3.new(boxWidth / 2, y, endZ - (direction * boxDepth / 2)), lineColor, 0, false)
		local spot = makePart(markings, "PenaltySpot", Vector3.new(0.65, 0.07, 0.65), Vector3.new(0, y + 0.01, endZ - (direction * 12)), lineColor, 0, false)
		spot.Shape = Enum.PartType.Ball
	end
end

local function createBoundaries(model)
	local width = GameConfig.Prototype.PitchWidth
	local length = GameConfig.Prototype.PitchLength
	local padding = GameConfig.Prototype.BoundaryPadding
	local height = GameConfig.Prototype.BoundaryHeight
	local thickness = GameConfig.Prototype.BoundaryThickness
	local halfWidth = width / 2
	local halfLength = length / 2
	local wallY = 0.5 + (height / 2)

	local boundary = Instance.new("Model")
	boundary.Name = "BallBoundary"
	boundary.Parent = model
	local sideLength = length + ((padding + thickness) * 2)
	local endWidth = width + ((padding + thickness) * 2)
	local walls = {
		makePart(boundary, "WestWall", Vector3.new(thickness, height, sideLength), Vector3.new(-(halfWidth + padding), wallY, 0), COLORS.White, 1, true),
		makePart(boundary, "EastWall", Vector3.new(thickness, height, sideLength), Vector3.new(halfWidth + padding, wallY, 0), COLORS.White, 1, true),
		makePart(boundary, "NorthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, halfLength + padding), COLORS.White, 1, true),
		makePart(boundary, "SouthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, -(halfLength + padding)), COLORS.White, 1, true),
	}
	for _, wall in ipairs(walls) do wall.CollisionGroup = "RTGBallBoundary" end
end

local function createBench(parent, position, yaw)
	local model = Instance.new("Model")
	model.Name = "Bench"
	model.Parent = parent
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	makeCFramePart(model, "Seat", Vector3.new(6, 0.35, 1.4), cf * CFrame.new(0, 1.2, 0), COLORS.Wood, 0, true)
	makeCFramePart(model, "Back", Vector3.new(6, 1.5, 0.3), cf * CFrame.new(0, 2.0, 0.6), COLORS.Wood, 0, true)
	for _, x in ipairs({ -2.2, 2.2 }) do
		makeCFramePart(model, "Leg", Vector3.new(0.3, 1.2, 0.3), cf * CFrame.new(x, 0.6, 0), Color3.fromRGB(66, 67, 69), 0, true)
	end
	return model
end

local function createTree(parent, position, scale)
	scale = scale or 1
	local tree = Instance.new("Model")
	tree.Name = "Tree"
	tree.Parent = parent
	local trunk = makePart(tree, "Trunk", Vector3.new(1.3 * scale, 7 * scale, 1.3 * scale), position + Vector3.new(0, 3.5 * scale, 0), Color3.fromRGB(92, 67, 44), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 8, 0), Vector3.new(-2.2, 7.5, 0), Vector3.new(2.2, 7.2, 0), Vector3.new(0, 7.6, 2) }) do
		local leaf = makePart(tree, "Leaves", Vector3.new(6.2, 6.2, 6.2) * scale, position + (offset * scale), Color3.fromRGB(45, 108, 54), 0, false)
		leaf.Shape = Enum.PartType.Ball
		leaf.Material = Enum.Material.Grass
	end
	return tree
end

local function createLamp(parent, position, height)
	height = height or 12
	local post = makePart(parent, "PathLamp", Vector3.new(0.45, height, 0.45), position + Vector3.new(0, height / 2, 0), Color3.fromRGB(65, 69, 72), 0, true)
	post.Material = Enum.Material.Metal
	local lightHead = makePart(parent, "LampHead", Vector3.new(2.6, 0.5, 1.3), position + Vector3.new(0, height, 0), Color3.fromRGB(220, 224, 215), 0, false)
	lightHead.Material = Enum.Material.Neon
	local light = Instance.new("PointLight")
	light.Brightness = 1.2
	light.Range = 20
	light.Color = Color3.fromRGB(244, 237, 213)
	light.Parent = lightHead
end

local function createFloodlight(parent, position, facePitchX)
	local model = Instance.new("Model")
	model.Name = "Floodlight"
	model.Parent = parent
	local pole = makePart(model, "Pole", Vector3.new(1, 30, 1), position + Vector3.new(0, 15, 0), Color3.fromRGB(65, 71, 77), 0, true)
	pole.Material = Enum.Material.Metal
	local bar = makePart(model, "LightBar", Vector3.new(1.2, 2, 12), position + Vector3.new(0, 29, 0), Color3.fromRGB(56, 61, 66), 0, false)
	for i = -2, 2 do
		local lamp = makePart(model, "FloodLamp", Vector3.new(0.8, 1.2, 1.5), position + Vector3.new(facePitchX and -0.6 or 0.6, 29, i * 2.2), Color3.fromRGB(244, 244, 226), 0, false)
		lamp.Material = Enum.Material.Neon
	end
end

local function createCar(parent, name, position, color)
	local car = Instance.new("Model")
	car.Name = name
	car.Parent = parent
	makePart(car, "Body", Vector3.new(8.5, 1.8, 4.2), position + Vector3.new(0, 1.4, 0), color, 0, true)
	makePart(car, "Roof", Vector3.new(4.6, 1.4, 3.7), position + Vector3.new(0.3, 2.8, 0), color:Lerp(COLORS.White, 0.08), 0, true)
	makePart(car, "Windshield", Vector3.new(0.2, 1.1, 3.3), position + Vector3.new(-2.1, 2.8, 0), COLORS.Glass, 0.25, false)
	for _, x in ipairs({ -2.7, 2.7 }) do
		for _, z in ipairs({ -2.05, 2.05 }) do
			local wheel = makePart(car, "Wheel", Vector3.new(1.4, 1.4, 0.65), position + Vector3.new(x, 0.8, z), Color3.fromRGB(28, 29, 30), 0, false)
			wheel.Shape = Enum.PartType.Cylinder
		end
	end
	return car
end

local function createRoomSign(room, center, text)
	local sign = makePart(room, "RoomSign", Vector3.new(0.35, 2.6, 11), Vector3.new(center.X - 16.8, 7.6, center.Z), COLORS.Navy, 0, false)
	addSurfaceSign(sign, text, Enum.NormalId.Left, 54)
end

local function createRoomShell(parent, name, labelText, center, wallColor)
	local room = Instance.new("Model")
	room.Name = name
	room.Parent = parent
	local sx, sz = 34, 17
	makePart(room, "Floor", Vector3.new(sx, 0.5, sz), Vector3.new(center.X, 0.25, center.Z), Color3.fromRGB(207, 210, 212), 0, true)
	makePart(room, "BackWall", Vector3.new(1, 10, sz), Vector3.new(center.X + (sx / 2), 5, center.Z), wallColor, 0, true)
	makePart(room, "NorthWall", Vector3.new(sx, 10, 1), Vector3.new(center.X, 5, center.Z - (sz / 2)), wallColor, 0, true)
	makePart(room, "SouthWall", Vector3.new(sx, 10, 1), Vector3.new(center.X, 5, center.Z + (sz / 2)), wallColor, 0, true)
	makePart(room, "Roof", Vector3.new(sx, 0.5, sz), Vector3.new(center.X, 10, center.Z), Color3.fromRGB(42, 47, 54), 0, true)
	createRoomSign(room, center, labelText)
	return room
end

local function addTableAndChairs(room, centre)
	makePart(room, "Table", Vector3.new(5, 0.45, 3), centre + Vector3.new(0, 2, 0), Color3.fromRGB(136, 109, 76), 0, true)
	makePart(room, "TableLeg", Vector3.new(0.7, 2, 0.7), centre + Vector3.new(0, 1, 0), Color3.fromRGB(68, 69, 70), 0, true)
	for _, dx in ipairs({ -3.3, 3.3 }) do
		local seat = Instance.new("Seat")
		seat.Anchored = true
		seat.Size = Vector3.new(1.8, 0.5, 1.8)
		seat.Position = centre + Vector3.new(dx, 1.2, 0)
		seat.Color = Color3.fromRGB(68, 79, 91)
		seat.Parent = room
	end
end

local function decorateRoom(room, name, center)
	if name == "Reception" then
		makePart(room, "ReceptionDesk", Vector3.new(3, 3, 10), center + Vector3.new(7, 1.5, 0), Color3.fromRGB(91, 72, 56), 0, true)
		makePart(room, "Monitor", Vector3.new(0.5, 2.2, 3), center + Vector3.new(5.2, 3.4, 0), Color3.fromRGB(30, 35, 40), 0, false)
		createBench(room, center + Vector3.new(-3, 0, 4), 0)
		createBench(room, center + Vector3.new(-3, 0, -4), 0)
	elseif name == "ChangingRoom" then
		for i = -3, 3 do
			makePart(room, "Locker" .. i, Vector3.new(2.2, 7, 1.4), center + Vector3.new(10, 3.5, i * 2.1), Color3.fromRGB(55, 68, 86), 0, true)
		end
		createBench(room, center + Vector3.new(1, 0, -3.5), 90)
		createBench(room, center + Vector3.new(1, 0, 3.5), 90)
	elseif name == "KitRoom" then
		for row = -2, 2 do
			makePart(room, "Shelf" .. row, Vector3.new(1.2, 0.35, 12), center + Vector3.new(9, 2 + row * 1.3, 0), Color3.fromRGB(93, 96, 99), 0, true)
		end
		for i = -3, 3 do
			makePart(room, "KitStack" .. i, Vector3.new(2, 0.8, 2), center + Vector3.new(6, 1, i * 2), Color3.fromRGB(35, 70 + ((i + 3) * 8), 105), 0, true)
		end
	elseif name == "Gym" then
		for i = -2, 2 do
			local station = makePart(room, "BenchPress" .. i, Vector3.new(5, 0.7, 2), center + Vector3.new(5, 0.8, i * 2.7), Color3.fromRGB(45, 47, 50), 0, true)
			station.Material = Enum.Material.Metal
		end
		for i = -3, 3 do
			local weight = makePart(room, "Weight" .. i, Vector3.new(1.2, 1.2, 1.2), center + Vector3.new(10, 1.2, i * 2), Color3.fromRGB(28, 29, 31), 0, false)
			weight.Shape = Enum.PartType.Ball
		end
	elseif name == "Physio" then
		makePart(room, "PhysioBed", Vector3.new(7, 1.2, 3), center + Vector3.new(4, 1.2, 0), Color3.fromRGB(225, 231, 233), 0, true)
		makePart(room, "Cabinet", Vector3.new(2.5, 6, 6), center + Vector3.new(11, 3, 3.5), Color3.fromRGB(208, 211, 212), 0, true)
		makePart(room, "MedicalScreen", Vector3.new(0.4, 3.5, 5), center + Vector3.new(11, 5.5, -3), Color3.fromRGB(132, 183, 198), 0.2, false)
	elseif name == "CoachOffice" then
		makePart(room, "CoachDesk", Vector3.new(5, 2.6, 8), center + Vector3.new(7, 1.3, 0), Color3.fromRGB(104, 79, 58), 0, true)
		makePart(room, "TacticsBoard", Vector3.new(0.4, 5, 9), center + Vector3.new(15.8, 5.2, 0), COLORS.White, 0, false)
		addTableAndChairs(room, center + Vector3.new(-3, 0, 0))
	elseif name == "PlayerLounge" then
		for z = -4, 4, 4 do
			makePart(room, "Sofa", Vector3.new(6, 1.5, 2.5), center + Vector3.new(4, 1.1, z), Color3.fromRGB(52, 66, 82), 0, true)
		end
		makePart(room, "TV", Vector3.new(0.4, 5, 9), center + Vector3.new(15.8, 5, 0), Color3.fromRGB(18, 20, 22), 0, false)
	elseif name == "Cafeteria" then
		for z = -5, 5, 5 do addTableAndChairs(room, center + Vector3.new(3, 0, z)) end
		makePart(room, "ServingCounter", Vector3.new(3, 3, 13), center + Vector3.new(11, 1.5, 0), Color3.fromRGB(121, 126, 128), 0, true)
	elseif name == "TrophyHall" then
		for i = -3, 3 do
			local pedestal = makePart(room, "Pedestal" .. i, Vector3.new(2, 2.7, 2), center + Vector3.new(8, 1.35, i * 2), Color3.fromRGB(88, 92, 96), 0, true)
			local cup = makePart(room, "Trophy" .. i, Vector3.new(1.25, 1.6, 1.25), pedestal.Position + Vector3.new(0, 2.1, 0), COLORS.Gold, 0, false)
			cup.Shape = Enum.PartType.Ball
		end
		makePart(room, "DisplayGlass", Vector3.new(1, 7.5, 15), center + Vector3.new(11, 4, 0), COLORS.Glass, 0.62, false)
	end
end

local function createOpenRoom(parent, name, labelText, center, roomColor, interactionData)
	local room = createRoomShell(parent, name, labelText, center, roomColor or Color3.fromRGB(50, 60, 72))
	decorateRoom(room, name, center)
	if interactionData then
		createInteraction(room, interactionData.Id, labelText, Vector3.new(center.X - 5, 2, center.Z), interactionData.Speaker, interactionData.Text, interactionData.Prompt)
	end
	return room
end

local function createAcademyCampus(model)
	local campus = Instance.new("Model")
	campus.Name = "AcademyCampus"
	campus.Parent = model

	local ground = makePart(campus, "CampusGround", Vector3.new(330, 1, 330), Vector3.new(0, -0.55, 0), Color3.fromRGB(57, 105, 61), 0, true)
	ground.Material = Enum.Material.Grass

	-- Arrival road, paths and parking.
	local pathColor = Color3.fromRGB(152, 156, 159)
	local road = makePart(campus, "AcademyRoad", Vector3.new(84, 0.28, 90), Vector3.new(-100, 0.06, -96), Color3.fromRGB(65, 69, 72), 0, true)
	road.Material = Enum.Material.Asphalt
	makePart(campus, "SouthWalkway", Vector3.new(205, 0.25, 12), Vector3.new(-4, 0.08, -108), pathColor, 0, true)
	makePart(campus, "EastWalkway", Vector3.new(12, 0.25, 220), Vector3.new(67, 0.08, 0), pathColor, 0, true)
	makePart(campus, "EntrancePlaza", Vector3.new(60, 0.25, 30), Vector3.new(-88, 0.08, -123), Color3.fromRGB(178, 180, 181), 0, true)

	local entranceFacade = makePart(campus, "AcademyEntrance", Vector3.new(50, 12, 3), Vector3.new(-88, 6, -137), COLORS.Navy, 0, true)
	addSurfaceSign(entranceFacade, "NORTHBRIDGE FC\nACADEMY", Enum.NormalId.Front, 66)
	makePart(campus, "EntranceCanopy", Vector3.new(28, 0.8, 8), Vector3.new(-88, 9.2, -131.5), Color3.fromRGB(44, 52, 64), 0, true)
	for _, x in ipairs({ -100, -76 }) do makePart(campus, "CanopyPost", Vector3.new(0.8, 9, 0.8), Vector3.new(x, 4.5, -131), Color3.fromRGB(85, 91, 98), 0, true) end
	createInteraction(campus, "Entrance", "Academy Entrance", Vector3.new(-88, 2, -127), "Academy Staff", "Welcome to Northbridge FC Academy. The training pitch is ahead, with the development facilities around the campus.", "Look around")

	local parking = makePart(campus, "Parking", Vector3.new(78, 0.3, 48), Vector3.new(-98, 0.08, -84), Color3.fromRGB(67, 70, 73), 0, true)
	parking.Material = Enum.Material.Asphalt
	for i = 1, 6 do
		local x = -127 + ((i - 1) * 12)
		makePart(campus, "ParkingLine" .. i, Vector3.new(0.18, 0.04, 17), Vector3.new(x, 0.26, -80), COLORS.White, 0.1, false)
	end
	local carColors = {
		Color3.fromRGB(52, 79, 112), Color3.fromRGB(120, 48, 48), Color3.fromRGB(50, 53, 56), Color3.fromRGB(190, 193, 196), Color3.fromRGB(69, 95, 70),
	}
	for i, color in ipairs(carColors) do createCar(campus, "AcademyCar" .. i, Vector3.new(-124 + ((i - 1) * 14), 0, -79), color) end
	createInteraction(campus, "Parking", "Academy Car Park", Vector3.new(-98, 2, -58), "Kai Williams", "One day we'll be parking something better than academy lifts out here. First we need contracts.", "Talk")

	-- Landscaping fills the previously empty edges of the campus.
	for _, p in ipairs({
		Vector3.new(-145, 0, -130), Vector3.new(-145, 0, -100), Vector3.new(-145, 0, -45), Vector3.new(-145, 0, 5),
		Vector3.new(-142, 0, 70), Vector3.new(-125, 0, 125), Vector3.new(-85, 0, 132), Vector3.new(-35, 0, 135),
		Vector3.new(25, 0, 136), Vector3.new(135, 0, 125), Vector3.new(145, 0, 65), Vector3.new(145, 0, 10),
		Vector3.new(145, 0, -55), Vector3.new(140, 0, -120),
	}) do createTree(campus, p, 0.9 + ((math.abs(p.X + p.Z) % 3) * 0.08)) end

	for z = -90, 90, 30 do
		makePart(campus, "Hedge", Vector3.new(5, 3.5, 22), Vector3.new(131, 1.75, z), Color3.fromRGB(36, 92, 42), 0, true).Material = Enum.Material.Grass
	end
	for _, p in ipairs({ Vector3.new(-55, 0, -108), Vector3.new(25, 0, -108), Vector3.new(67, 0, -65), Vector3.new(67, 0, 5), Vector3.new(67, 0, 75) }) do createLamp(campus, p, 11) end

	-- Pitch-side benches, hydration area and floodlights.
	createBench(campus, Vector3.new(-66, 0, -38), 90)
	createBench(campus, Vector3.new(-66, 0, -28), 90)
	makePart(campus, "WaterCooler", Vector3.new(2, 4, 2), Vector3.new(-68, 2, -17), Color3.fromRGB(99, 169, 190), 0, true)
	makePart(campus, "EquipmentRack", Vector3.new(2, 4, 8), Vector3.new(-69, 2, 0), Color3.fromRGB(60, 64, 68), 0, true)
	for _, p in ipairs({ Vector3.new(-63, 0, -82), Vector3.new(-63, 0, 82), Vector3.new(63, 0, -82), Vector3.new(63, 0, 82) }) do createFloodlight(campus, p, p.X > 0) end

	local building = Instance.new("Model")
	building.Name = "AcademyBuilding"
	building.Parent = campus
	makePart(building, "BuildingWalkway", Vector3.new(18, 0.25, 196), Vector3.new(71, 0.08, 0), Color3.fromRGB(187, 189, 190), 0, true)
	makePart(building, "FacadeSpine", Vector3.new(3, 12, 196), Vector3.new(123, 6, 0), Color3.fromRGB(38, 49, 63), 0, true)

	local rooms = {
		{ "Reception", "RECEPTION", -80, { Id = "Reception", Speaker = "Receptionist", Text = "Your trial registration is confirmed. Coach Daniels is expecting you on the training ground." } },
		{ "ChangingRoom", "CHANGING ROOM", -60, { Id = "ChangingRoom", Speaker = "Kai Williams", Text = "This is our locker for today. If we make the cut, maybe our names stay on these doors." } },
		{ "KitRoom", "KIT ROOM", -40, { Id = "KitRoom", Speaker = "Kit Manager", Text = "Trial bib, boots and training kit. Keep your number visible — the scouts are taking notes." } },
		{ "Gym", "ACADEMY GYM", -20, { Id = "Gym", Speaker = "Fitness Coach", Text = "Acceleration, balance and strength all matter. The quickest player is not always the best athlete." } },
		{ "Physio", "PHYSIO ROOM", 0, { Id = "Physio", Speaker = "Club Physio", Text = "Any tightness or knock gets checked here. Availability is part of a professional career too." } },
		{ "CoachOffice", "COACH DANIELS' OFFICE", 20, { Id = "CoachOffice", Speaker = "Coach Daniels", Text = "I don't just judge goals. Movement, attitude and decisions will decide whether you get a contract." } },
		{ "PlayerLounge", "PLAYER LOUNGE", 40, { Id = "PlayerLounge", Speaker = "Marco Santos", Text = "Enjoy the seats while you can. On the pitch, I'm taking that contract spot." } },
		{ "Cafeteria", "CAFETERIA", 60, { Id = "Cafeteria", Speaker = "Nutritionist", Text = "Training is only half the job. Recovery, hydration and food affect how you perform tomorrow." } },
		{ "TrophyHall", "TROPHY HALL", 80, { Id = "TrophyHall", Speaker = "Academy Guide", Text = "Every trophy here started with players trying to earn a first contract. Your career could begin here too." } },
	}
	for _, room in ipairs(rooms) do createOpenRoom(building, room[1], room[2], Vector3.new(100, 0, room[3]), Color3.fromRGB(50, 60, 72), room[4]) end

	local stand = Instance.new("Model")
	stand.Name = "ScoutStand"
	stand.Parent = campus
	for row = 1, 5 do
		makePart(stand, "StandRow" .. row, Vector3.new(42, 1.1, 5), Vector3.new(-88, row * 1.1, 50 + (row * 4.2)), Color3.fromRGB(78, 87, 98), 0, true)
	end
	makePart(stand, "StandRoof", Vector3.new(48, 0.8, 24), Vector3.new(-88, 10, 61), Color3.fromRGB(35, 43, 53), 0, true)
	for _, x in ipairs({ -109, -67 }) do makePart(stand, "RoofPost", Vector3.new(0.7, 10, 0.7), Vector3.new(x, 5, 53), Color3.fromRGB(70, 75, 80), 0, true) end
	createInteraction(stand, "ScoutStand", "Scout Viewing Stand", Vector3.new(-88, 2, 45), "Scout", "From here we watch what players do when the ball is nowhere near them. That's often what separates prospects.", "Listen")

	return campus
end

local function createVisibleGate(parent, baseName, position, width, height, color, labelText, labelDistance)
	local trigger = makePart(parent, baseName, Vector3.new(width, height, 1.2), position, color, 1, false)
	trigger.CanTouch = true
	local left = makePart(parent, baseName .. "Left", Vector3.new(0.45, height, 0.45), position + Vector3.new(-(width / 2), 0, 0), color, 0, false)
	makePart(parent, baseName .. "Right", Vector3.new(0.45, height, 0.45), position + Vector3.new(width / 2, 0, 0), color, 0, false)
	makePart(parent, baseName .. "Top", Vector3.new(width, 0.35, 0.35), position + Vector3.new(0, height / 2, 0), color, 0.15, false)
	if labelText then addBillboard(left, labelText, Vector3.new(width / 2, height / 2 + 1.3, 0), labelDistance or 32, 15) end
	return trigger
end

local function createTrainingCourse(model)
	local training = Instance.new("Model")
	training.Name = "AcademyTraining"
	training.Parent = model
	local refs = {}

	local yellow = Color3.fromRGB(255, 205, 40)
	refs.SprintSpawn = makePart(training, "SprintSpawn", Vector3.new(4, 0.3, 4), Vector3.new(-40, 0.7, -76), yellow, 0.7, false)
	refs.SprintStart = createVisibleGate(training, "SprintStart", Vector3.new(-40, 2, -66), 12, 4, yellow, "START", 28)
	refs.SprintFinish = createVisibleGate(training, "SprintFinish", Vector3.new(-40, 2, -22), 12, 4, yellow, "FINISH", 28)

	local purple = Color3.fromRGB(145, 80, 220)
	refs.AgilitySpawn = makePart(training, "AgilitySpawn", Vector3.new(4, 0.3, 4), Vector3.new(36, 0.7, -74), purple, 0.7, false)
	refs.AgilityCheckpoints = {}
	local agilityPositions = {
		Vector3.new(36, 2.5, -64), Vector3.new(22, 2.5, -54), Vector3.new(42, 2.5, -44), Vector3.new(20, 2.5, -34),
		Vector3.new(42, 2.5, -24), Vector3.new(24, 2.5, -14), Vector3.new(40, 2.5, -4), Vector3.new(28, 2.5, 6),
	}
	for index, position in ipairs(agilityPositions) do
		local checkpoint = createVisibleGate(training, "AgilityCheckpoint" .. index, position, 6, 5, purple, tostring(index), 24)
		checkpoint:SetAttribute("TrainingIndex", index)
		table.insert(refs.AgilityCheckpoints, checkpoint)
	end

	refs.ShootingPlayerSpot = makePart(training, "ShootingPlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(0, 0.7, 35), Color3.fromRGB(220, 65, 65), 0.75, false)
	refs.ShootingBallSpot = makePart(training, "ShootingBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(0, 1.6, 42), Color3.fromRGB(220, 65, 65), 1, false)
	refs.ShootingTargetLook = makePart(training, "ShootingTargetLook", Vector3.new(1, 1, 1), Vector3.new(0, 5, 86), COLORS.White, 1, false)
	refs.ShootingTargets = {}
	local targetPositions = {
		Vector3.new(-10, 3.5, 86.5), Vector3.new(-5, 7.2, 86.5), Vector3.new(0, 5.2, 86.5), Vector3.new(5, 7.2, 86.5), Vector3.new(10, 3.5, 86.5),
	}
	for index, position in ipairs(targetPositions) do
		local target = makePart(training, "ShootingTarget" .. index, Vector3.new(4.5, 4.5, 0.55), position, Color3.fromRGB(214, 55, 55), 0.18, false)
		target.CanTouch = true
		target:SetAttribute("TrainingIndex", index)
		addBillboard(target, "TARGET " .. index, Vector3.new(0, 3.1, 0), 34, 14)
		table.insert(refs.ShootingTargets, target)
	end

	refs.PassingPlayerSpot = makePart(training, "PassingPlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(0, 0.7, -30), Color3.fromRGB(55, 130, 235), 0.75, false)
	refs.PassingBallSpot = makePart(training, "PassingBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(0, 1.6, -23), Color3.fromRGB(55, 130, 235), 1, false)
	refs.PassingTargetLook = makePart(training, "PassingTargetLook", Vector3.new(1, 1, 1), Vector3.new(0, 2, 18), COLORS.White, 1, false)
	refs.PassingTargets = {}
	for index, x in ipairs({ -32, -16, 0, 16, 32 }) do
		local target = createVisibleGate(training, "PassingTarget" .. index, Vector3.new(x, 3.2, 18), 7, 5.5, Color3.fromRGB(55, 130, 235), "PASS " .. index, 30)
		target:SetAttribute("TrainingIndex", index)
		table.insert(refs.PassingTargets, target)
	end

	refs.DribblePlayerSpot = makePart(training, "DribblePlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(-18, 0.7, -50), Color3.fromRGB(255, 135, 35), 0.75, false)
	refs.DribbleBallSpot = makePart(training, "DribbleBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(-18, 1.6, -44), Color3.fromRGB(255, 135, 35), 1, false)
	refs.DribbleGates = {}
	local gatePositions = {
		Vector3.new(-18, 2.5, -36), Vector3.new(4, 2.5, -27), Vector3.new(-12, 2.5, -18), Vector3.new(14, 2.5, -9), Vector3.new(-8, 2.5, 0),
		Vector3.new(18, 2.5, 9), Vector3.new(-6, 2.5, 18), Vector3.new(18, 2.5, 27), Vector3.new(-4, 2.5, 36), Vector3.new(16, 2.5, 48),
	}
	for index, position in ipairs(gatePositions) do
		local gate = createVisibleGate(training, "DribbleGate" .. index, position, 7, 4.5, Color3.fromRGB(255, 135, 35), tostring(index), 22)
		gate:SetAttribute("TrainingIndex", index)
		table.insert(refs.DribbleGates, gate)
	end

	-- Training props make the pitch look active even before a drill begins.
	for i = 1, 8 do
		local cone = makePart(training, "Cone" .. i, Vector3.new(0.7, 1.1, 0.7), Vector3.new(-52 + (i * 3), 1.05, -55), Color3.fromRGB(245, 116, 35), 0, false)
		cone.Shape = Enum.PartType.Ball
	end
	makePart(training, "BallRack", Vector3.new(5, 1.5, 2), Vector3.new(-51, 1.25, 18), Color3.fromRGB(64, 69, 73), 0, true)
	for i = 1, 4 do
		local spare = makePart(training, "SpareBall" .. i, Vector3.new(1.8, 1.8, 1.8), Vector3.new(-53 + (i * 1.8), 2.4, 18), COLORS.White, 0, false)
		spare.Shape = Enum.PartType.Ball
		spare.CanTouch = false
	end

	return refs
end

function WorldBuilder:Init()
	local old = Workspace:FindFirstChild("RoadToGloryPrototype")
	if old then old:Destroy() end
	setupLighting()
	setupBallBoundaryGroups()

	local model = Instance.new("Model")
	model.Name = "RoadToGloryPrototype"
	model.Parent = Workspace

	self.Campus = createAcademyCampus(model)
	local pitch = makePart(model, "Pitch", Vector3.new(GameConfig.Prototype.PitchWidth, 1, GameConfig.Prototype.PitchLength), Vector3.new(0, 0, 0), COLORS.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	createPitchMarkings(model)
	local halfLength = GameConfig.Prototype.PitchLength / 2
	createGoal(model, "NorthGoal", halfLength - 2, "Home")
	createGoal(model, "SouthGoal", -halfLength + 2, "Away")
	createBoundaries(model)
	self.Training = createTrainingCourse(model)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "CareerSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(-88, 1, -124)
	spawn.Neutral = true
	spawn.Transparency = 1
	spawn.CanCollide = true
	spawn.Parent = model

	local ball = Instance.new("Part")
	ball.Name = "Football"
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.new(2.2, 2.2, 2.2)
	ball.Position = Vector3.new(0, 3, 0)
	ball.Color = Color3.fromRGB(245, 245, 245)
	ball.Material = Enum.Material.SmoothPlastic
	ball.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.35, 0.55, 1, 1)
	ball.CollisionGroup = "RTGBall"
	ball:SetAttribute("LastTouchUserId", 0)
	ball:SetAttribute("TrainingMode", false)
	ball:SetAttribute("TrainingOwnerUserId", 0)
	ball.Parent = model

	self.Model = model
	self.Ball = ball
	return model
end

function WorldBuilder:SetBallPosition(position)
	if not self.Ball or not self.Ball.Parent then return end
	self.Ball.AssemblyLinearVelocity = Vector3.zero
	self.Ball.AssemblyAngularVelocity = Vector3.zero
	self.Ball.CFrame = CFrame.new(position)
	self.Ball:SetAttribute("LastTouchUserId", 0)
	pcall(function() self.Ball:SetNetworkOwner(nil) end)
end

function WorldBuilder:ResetBall()
	self:SetBallPosition(Vector3.new(0, 3, 0))
end

return WorldBuilder
