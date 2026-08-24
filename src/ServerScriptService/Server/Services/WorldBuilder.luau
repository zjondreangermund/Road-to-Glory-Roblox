local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local WorldBuilder = {}

local function makePart(parent, name, size, position, color, transparency, canCollide)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.Position = position
	part.Color = color
	part.Transparency = transparency or 0
	part.CanCollide = canCollide ~= false
	part.Parent = parent
	return part
end

local function addLabel(part, text, studsOffset)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(190, 44)
	gui.StudsOffset = studsOffset or Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.25
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

local function setupBallBoundaryGroups()
	pcall(function() PhysicsService:RegisterCollisionGroup("RTGBall") end)
	pcall(function() PhysicsService:RegisterCollisionGroup("RTGBallBoundary") end)
	PhysicsService:CollisionGroupSetCollidable("RTGBall", "RTGBallBoundary", true)
	PhysicsService:CollisionGroupSetCollidable("Default", "RTGBallBoundary", false)
end

local function createGoal(model, name, z, goalFor)
	local width = GameConfig.Prototype.GoalWidth
	local direction = z > 0 and 1 or -1
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = model

	makePart(goal, "LeftPost", Vector3.new(1, 10, 1), Vector3.new(-width / 2, 5, z), Color3.fromRGB(240, 240, 240), 0, true)
	makePart(goal, "RightPost", Vector3.new(1, 10, 1), Vector3.new(width / 2, 5, z), Color3.fromRGB(240, 240, 240), 0, true)
	makePart(goal, "Crossbar", Vector3.new(width + 1, 1, 1), Vector3.new(0, 10, z), Color3.fromRGB(240, 240, 240), 0, true)

	local trigger = makePart(goal, "GoalTrigger", Vector3.new(width - 1, 9, 5), Vector3.new(0, 4.5, z + (2.5 * direction)), Color3.new(1, 1, 1), 1, false)
	trigger.CanTouch = true
	trigger:SetAttribute("GoalFor", goalFor)
	return trigger
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
		makePart(boundary, "WestWall", Vector3.new(thickness, height, sideLength), Vector3.new(-(halfWidth + padding), wallY, 0), Color3.new(1, 1, 1), 1, true),
		makePart(boundary, "EastWall", Vector3.new(thickness, height, sideLength), Vector3.new(halfWidth + padding, wallY, 0), Color3.new(1, 1, 1), 1, true),
		makePart(boundary, "NorthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, halfLength + padding), Color3.new(1, 1, 1), 1, true),
		makePart(boundary, "SouthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, -(halfLength + padding)), Color3.new(1, 1, 1), 1, true),
	}
	for _, wall in ipairs(walls) do
		wall.CollisionGroup = "RTGBallBoundary"
	end
end

local function createInteraction(parent, id, title, position, speaker, text, promptText)
	local node = makePart(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, Color3.new(1, 1, 1), 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", promptText or "Explore")
	return node
end

local function createBench(parent, position, facingX)
	local seat = Instance.new("Seat")
	seat.Name = "AcademyBench"
	seat.Anchored = true
	seat.Size = Vector3.new(6, 0.7, 2)
	seat.Position = position
	seat.Color = Color3.fromRGB(95, 65, 42)
	if facingX then
		seat.CFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(90), 0)
	end
	seat.Parent = parent
	return seat
end

local function createOpenRoom(parent, name, labelText, center, roomColor, interactionData)
	local room = Instance.new("Model")
	room.Name = name
	room.Parent = parent
	local sx, sz = 34, 17
	local wallColor = roomColor or Color3.fromRGB(55, 62, 72)
	local floorColor = Color3.fromRGB(205, 208, 210)

	makePart(room, "Floor", Vector3.new(sx, 0.5, sz), Vector3.new(center.X, 0.25, center.Z), floorColor, 0, true)
	makePart(room, "BackWall", Vector3.new(1, 10, sz), Vector3.new(center.X + (sx / 2), 5, center.Z), wallColor, 0, true)
	makePart(room, "NorthWall", Vector3.new(sx, 10, 1), Vector3.new(center.X, 5, center.Z - (sz / 2)), wallColor, 0, true)
	makePart(room, "SouthWall", Vector3.new(sx, 10, 1), Vector3.new(center.X, 5, center.Z + (sz / 2)), wallColor, 0, true)
	makePart(room, "Roof", Vector3.new(sx, 0.5, sz), Vector3.new(center.X, 10, center.Z), Color3.fromRGB(42, 47, 54), 0, true)
	local sign = makePart(room, "RoomSign", Vector3.new(1, 2, 8), Vector3.new(center.X - (sx / 2) + 0.6, 7, center.Z), Color3.fromRGB(28, 34, 42), 0.15, false)
	addLabel(sign, labelText, Vector3.new(0, 2.5, 0))

	-- Simple furniture so each room reads differently while we are still prototyping.
	if name == "ChangingRoom" then
		for i = -2, 2 do createBench(room, Vector3.new(center.X + 2, 1.05, center.Z + (i * 2.4)), true) end
	elseif name == "Gym" then
		for i = -2, 2 do
			local pad = makePart(room, "GymStation" .. i, Vector3.new(4, 1, 2), Vector3.new(center.X + 4, 0.75, center.Z + (i * 2.5)), Color3.fromRGB(45, 45, 48), 0, true)
			pad.Material = Enum.Material.Metal
		end
	elseif name == "Cafeteria" or name == "PlayerLounge" then
		for i = -1, 1 do createBench(room, Vector3.new(center.X + 4, 1.05, center.Z + (i * 4)), true) end
	elseif name == "TrophyHall" then
		for i = -2, 2 do
			local pedestal = makePart(room, "Pedestal" .. i, Vector3.new(2, 3, 2), Vector3.new(center.X + 7, 1.5, center.Z + (i * 2.8)), Color3.fromRGB(125, 110, 75), 0, true)
			local trophy = makePart(room, "Trophy" .. i, Vector3.new(1.2, 1.8, 1.2), pedestal.Position + Vector3.new(0, 2.4, 0), Color3.fromRGB(235, 195, 55), 0, false)
			trophy.Shape = Enum.PartType.Ball
		end
	end

	if interactionData then
		createInteraction(room, interactionData.Id, labelText, Vector3.new(center.X - 5, 2, center.Z), interactionData.Speaker, interactionData.Text, interactionData.Prompt)
	end
	return room
end

local function createAcademyCampus(model)
	local campus = Instance.new("Model")
	campus.Name = "AcademyCampus"
	campus.Parent = model

	local ground = makePart(campus, "CampusGround", Vector3.new(300, 1, 310), Vector3.new(0, -0.55, 0), Color3.fromRGB(56, 104, 60), 0, true)
	ground.Material = Enum.Material.Grass

	-- Walkway from the academy entrance around the training pitch.
	local pathColor = Color3.fromRGB(145, 149, 151)
	makePart(campus, "SouthWalkway", Vector3.new(190, 0.25, 12), Vector3.new(-5, 0.08, -108), pathColor, 0, true)
	makePart(campus, "EastWalkway", Vector3.new(12, 0.25, 220), Vector3.new(67, 0.08, 0), pathColor, 0, true)

	local entranceSign = makePart(campus, "AcademyEntranceSign", Vector3.new(34, 9, 2), Vector3.new(-90, 5, -118), Color3.fromRGB(25, 38, 55), 0, true)
	addLabel(entranceSign, "NORTHBRIDGE FC ACADEMY", Vector3.new(0, 6, 0))
	createInteraction(campus, "Entrance", "Academy Entrance", Vector3.new(-90, 2, -112), "Academy Staff", "Welcome to Northbridge FC Academy. The training pitch is ahead, with the first-team development facilities around the campus.", "Look around")

	-- Prototype car park and arrival area.
	local parking = makePart(campus, "Parking", Vector3.new(78, 0.3, 55), Vector3.new(-92, 0.08, -72), Color3.fromRGB(67, 70, 73), 0, true)
	parking.Material = Enum.Material.Asphalt
	for i = 1, 5 do
		local x = -118 + ((i - 1) * 13)
		local car = makePart(campus, "AcademyCar" .. i, Vector3.new(8, 2.5, 4), Vector3.new(x, 1.4, -76), Color3.fromRGB(60 + (i * 20), 70, 95 + (i * 10)), 0, true)
		car.Material = Enum.Material.Metal
	end
	createInteraction(campus, "Parking", "Academy Car Park", Vector3.new(-90, 2, -58), "Kai Williams", "One day we'll be parking something better than academy lifts out here. First we need contracts.", "Talk")

	local building = Instance.new("Model")
	building.Name = "AcademyBuilding"
	building.Parent = campus
	makePart(building, "BuildingWalkway", Vector3.new(16, 0.25, 190), Vector3.new(70, 0.08, 0), Color3.fromRGB(185, 187, 188), 0, true)

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

	for _, room in ipairs(rooms) do
		createOpenRoom(building, room[1], room[2], Vector3.new(91, 0, room[3]), Color3.fromRGB(50, 60, 72), room[4])
	end

	-- A small viewing stand gives the pitch another place to explore.
	local stand = Instance.new("Model")
	stand.Name = "ScoutStand"
	stand.Parent = campus
	for row = 1, 4 do
		makePart(stand, "StandRow" .. row, Vector3.new(38, 1.2, 5), Vector3.new(-84, row * 1.2, 48 + (row * 4)), Color3.fromRGB(80, 87, 95), 0, true)
	end
	createInteraction(stand, "ScoutStand", "Scout Viewing Stand", Vector3.new(-84, 2, 45), "Scout", "From here we watch what players do when the ball is nowhere near them. That's often what separates prospects.", "Listen")

	return campus
end

local function createTrainingCourse(model)
	local training = Instance.new("Model")
	training.Name = "AcademyTraining"
	training.Parent = model
	local refs = {}

	local yellow = Color3.fromRGB(255, 205, 40)
	refs.SprintSpawn = makePart(training, "SprintSpawn", Vector3.new(4, 0.3, 4), Vector3.new(-40, 0.7, -76), yellow, 0.55, false)
	refs.SprintStart = makePart(training, "SprintStart", Vector3.new(14, 3, 2), Vector3.new(-40, 2, -66), yellow, 0.45, false)
	refs.SprintFinish = makePart(training, "SprintFinish", Vector3.new(14, 3, 2), Vector3.new(-40, 2, -22), yellow, 0.45, false)
	refs.SprintStart.CanTouch = true
	refs.SprintFinish.CanTouch = true
	addLabel(refs.SprintStart, "SPRINT START")
	addLabel(refs.SprintFinish, "SPRINT FINISH")

	local purple = Color3.fromRGB(145, 80, 220)
	refs.AgilitySpawn = makePart(training, "AgilitySpawn", Vector3.new(4, 0.3, 4), Vector3.new(36, 0.7, -74), purple, 0.55, false)
	refs.AgilityCheckpoints = {}
	local agilityPositions = {
		Vector3.new(36, 2.5, -64), Vector3.new(22, 2.5, -54), Vector3.new(42, 2.5, -44), Vector3.new(20, 2.5, -34),
		Vector3.new(42, 2.5, -24), Vector3.new(24, 2.5, -14), Vector3.new(40, 2.5, -4), Vector3.new(28, 2.5, 6),
	}
	for index, position in ipairs(agilityPositions) do
		local checkpoint = makePart(training, "AgilityCheckpoint" .. index, Vector3.new(8, 5, 2), position, purple, 0.58, false)
		checkpoint.CanTouch = true
		checkpoint:SetAttribute("TrainingIndex", index)
		addLabel(checkpoint, "AGILITY " .. index)
		table.insert(refs.AgilityCheckpoints, checkpoint)
	end

	refs.ShootingPlayerSpot = makePart(training, "ShootingPlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(0, 0.7, 35), Color3.fromRGB(220, 65, 65), 0.55, false)
	refs.ShootingBallSpot = makePart(training, "ShootingBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(0, 1.6, 42), Color3.fromRGB(220, 65, 65), 1, false)
	refs.ShootingTargetLook = makePart(training, "ShootingTargetLook", Vector3.new(1, 1, 1), Vector3.new(0, 5, 86), Color3.new(1, 1, 1), 1, false)
	refs.ShootingTargets = {}
	local targetPositions = {
		Vector3.new(-10, 3.5, 86.5), Vector3.new(-5, 7.2, 86.5), Vector3.new(0, 5.2, 86.5), Vector3.new(5, 7.2, 86.5), Vector3.new(10, 3.5, 86.5),
	}
	for index, position in ipairs(targetPositions) do
		local target = makePart(training, "ShootingTarget" .. index, Vector3.new(5, 5, 1), position, Color3.fromRGB(220, 55, 55), 0.2, false)
		target.CanTouch = true
		target:SetAttribute("TrainingIndex", index)
		addLabel(target, "SHOOT " .. index)
		table.insert(refs.ShootingTargets, target)
	end

	refs.PassingPlayerSpot = makePart(training, "PassingPlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(0, 0.7, -30), Color3.fromRGB(55, 130, 235), 0.55, false)
	refs.PassingBallSpot = makePart(training, "PassingBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(0, 1.6, -23), Color3.fromRGB(55, 130, 235), 1, false)
	refs.PassingTargetLook = makePart(training, "PassingTargetLook", Vector3.new(1, 1, 1), Vector3.new(0, 2, 18), Color3.new(1, 1, 1), 1, false)
	refs.PassingTargets = {}
	for index, x in ipairs({ -32, -16, 0, 16, 32 }) do
		local target = makePart(training, "PassingTarget" .. index, Vector3.new(8, 6, 1), Vector3.new(x, 3.5, 18), Color3.fromRGB(55, 130, 235), 0.35, false)
		target.CanTouch = true
		target:SetAttribute("TrainingIndex", index)
		addLabel(target, "PASS " .. index)
		table.insert(refs.PassingTargets, target)
	end

	refs.DribblePlayerSpot = makePart(training, "DribblePlayerSpot", Vector3.new(5, 0.3, 5), Vector3.new(-18, 0.7, -50), Color3.fromRGB(255, 135, 35), 0.55, false)
	refs.DribbleBallSpot = makePart(training, "DribbleBallSpot", Vector3.new(2, 0.2, 2), Vector3.new(-18, 1.6, -44), Color3.fromRGB(255, 135, 35), 1, false)
	refs.DribbleGates = {}
	local gatePositions = {
		Vector3.new(-18, 2.5, -36), Vector3.new(4, 2.5, -27), Vector3.new(-12, 2.5, -18), Vector3.new(14, 2.5, -9), Vector3.new(-8, 2.5, 0),
		Vector3.new(18, 2.5, 9), Vector3.new(-6, 2.5, 18), Vector3.new(18, 2.5, 27), Vector3.new(-4, 2.5, 36), Vector3.new(16, 2.5, 48),
	}
	for index, position in ipairs(gatePositions) do
		local gate = makePart(training, "DribbleGate" .. index, Vector3.new(9, 5, 2), position, Color3.fromRGB(255, 135, 35), 0.58, false)
		gate.CanTouch = true
		gate:SetAttribute("TrainingIndex", index)
		addLabel(gate, "GATE " .. index)
		table.insert(refs.DribbleGates, gate)
	end

	return refs
end

function WorldBuilder:Init()
	local old = Workspace:FindFirstChild("RoadToGloryPrototype")
	if old then old:Destroy() end
	setupBallBoundaryGroups()

	local model = Instance.new("Model")
	model.Name = "RoadToGloryPrototype"
	model.Parent = Workspace

	self.Campus = createAcademyCampus(model)
	local pitch = makePart(model, "Pitch", Vector3.new(GameConfig.Prototype.PitchWidth, 1, GameConfig.Prototype.PitchLength), Vector3.new(0, 0, 0), Color3.fromRGB(46, 125, 50), 0, true)
	pitch.Material = Enum.Material.Grass
	local halfLength = GameConfig.Prototype.PitchLength / 2
	createGoal(model, "NorthGoal", halfLength - 2, "Home")
	createGoal(model, "SouthGoal", -halfLength + 2, "Away")
	createBoundaries(model)
	self.Training = createTrainingCourse(model)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "CareerSpawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(-90, 1, -105)
	spawn.Neutral = true
	spawn.Transparency = 0.35
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
