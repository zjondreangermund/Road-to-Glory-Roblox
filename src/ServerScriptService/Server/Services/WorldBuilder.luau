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

local function createGoal(model, name, z, goalFor)
	local width = GameConfig.Prototype.GoalWidth
	local direction = z > 0 and 1 or -1
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = model

	makePart(goal, "LeftPost", Vector3.new(1, 10, 1), Vector3.new(-width / 2, 5, z), Color3.fromRGB(240, 240, 240), 0, true)
	makePart(goal, "RightPost", Vector3.new(1, 10, 1), Vector3.new(width / 2, 5, z), Color3.fromRGB(240, 240, 240), 0, true)
	makePart(goal, "Crossbar", Vector3.new(width + 1, 1, 1), Vector3.new(0, 10, z), Color3.fromRGB(240, 240, 240), 0, true)

	local trigger = makePart(
		goal,
		"GoalTrigger",
		Vector3.new(width - 1, 9, 5),
		Vector3.new(0, 4.5, z + (2.5 * direction)),
		Color3.new(1, 1, 1),
		1,
		false
	)
	trigger.CanTouch = true
	trigger:SetAttribute("GoalFor", goalFor)
	return trigger
end

function WorldBuilder:Init()
	local old = Workspace:FindFirstChild("RoadToGloryPrototype")
	if old then
		old:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "RoadToGloryPrototype"
	model.Parent = Workspace

	local pitch = makePart(
		model,
		"Pitch",
		Vector3.new(GameConfig.Prototype.PitchWidth, 1, GameConfig.Prototype.PitchLength),
		Vector3.new(0, 0, 0),
		Color3.fromRGB(46, 125, 50),
		0,
		true
	)
	pitch.Material = Enum.Material.Grass

	local halfLength = GameConfig.Prototype.PitchLength / 2
	createGoal(model, "NorthGoal", halfLength - 2, "Home")
	createGoal(model, "SouthGoal", -halfLength + 2, "Away")

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
	ball.Parent = model

	self.Model = model
	self.Ball = ball
	return model
end

function WorldBuilder:ResetBall()
	if not self.Ball or not self.Ball.Parent then
		return
	end
	self.Ball.AssemblyLinearVelocity = Vector3.zero
	self.Ball.AssemblyAngularVelocity = Vector3.zero
	self.Ball.CFrame = CFrame.new(0, 3, 0)
	self.Ball:SetAttribute("LastTouchUserId", 0)
	pcall(function()
		self.Ball:SetNetworkOwner(nil)
	end)
end

return WorldBuilder
