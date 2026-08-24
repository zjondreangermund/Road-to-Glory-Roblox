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

local function addLabel(part, text)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(160, 40)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
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
	local transparency = GameConfig.Prototype.BoundaryTransparency
	local halfWidth = width / 2
	local halfLength = length / 2
	local wallY = 0.5 + (height / 2)
	local wallColor = Color3.fromRGB(25, 70, 45)
	local boundary = Instance.new("Model")
	boundary.Name = "PrototypeBoundary"
	boundary.Parent = model
	local sideLength = length + ((padding + thickness) * 2)
	local endWidth = width + ((padding + thickness) * 2)
	makePart(boundary, "WestWall", Vector3.new(thickness, height, sideLength), Vector3.new(-(halfWidth + padding), wallY, 0), wallColor, transparency, true)
	makePart(boundary, "EastWall", Vector3.new(thickness, height, sideLength), Vector3.new(halfWidth + padding, wallY, 0), wallColor, transparency, true)
	makePart(boundary, "NorthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, halfLength + padding), wallColor, transparency, true)
	makePart(boundary, "SouthWall", Vector3.new(endWidth, height, thickness), Vector3.new(0, wallY, -(halfLength + padding)), wallColor, transparency, true)
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
		Vector3.new(36, 2.5, -64),
		Vector3.new(22, 2.5, -54),
		Vector3.new(42, 2.5, -44),
		Vector3.new(20, 2.5, -34),
		Vector3.new(42, 2.5, -24),
		Vector3.new(24, 2.5, -14),
		Vector3.new(40, 2.5, -4),
		Vector3.new(28, 2.5, 6),
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
		Vector3.new(-10, 3.5, 86.5),
		Vector3.new(-5, 7.2, 86.5),
		Vector3.new(0, 5.2, 86.5),
		Vector3.new(5, 7.2, 86.5),
		Vector3.new(10, 3.5, 86.5),
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
		Vector3.new(-18, 2.5, -36),
		Vector3.new(4, 2.5, -27),
		Vector3.new(-12, 2.5, -18),
		Vector3.new(14, 2.5, -9),
		Vector3.new(-8, 2.5, 0),
		Vector3.new(18, 2.5, 9),
		Vector3.new(-6, 2.5, 18),
		Vector3.new(18, 2.5, 27),
		Vector3.new(-4, 2.5, 36),
		Vector3.new(16, 2.5, 48),
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
	local model = Instance.new("Model")
	model.Name = "RoadToGloryPrototype"
	model.Parent = Workspace

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
	spawn.Position = Vector3.new(0, 1, -35)
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
