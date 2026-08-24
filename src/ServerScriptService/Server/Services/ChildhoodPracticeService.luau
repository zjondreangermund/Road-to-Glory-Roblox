local RunService = game:GetService("RunService")

local ChildhoodPracticeService = {
	ActivePlayer = nil,
	CurrentCheckpoint = 0,
	Connections = {},
}

local COLORS = {
	Orange = Color3.fromRGB(238, 143, 35),
	Blue = Color3.fromRGB(46, 118, 204),
	Green = Color3.fromRGB(61, 170, 83),
	White = Color3.fromRGB(244, 246, 247),
}

local function part(parent, name, size, position, color, transparency, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Transparency = transparency or 0
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function billboard(parent, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "PracticeLabel"
	gui.Size = UDim2.fromOffset(180, 42)
	gui.StudsOffset = Vector3.new(0, 4.8, 0)
	gui.MaxDistance = 55
	gui.AlwaysOnTop = false
	gui.Parent = parent
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.White
	label.TextStrokeTransparency = 0.15
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

local function createGate(parent, index, position, color)
	local model = Instance.new("Model")
	model.Name = "ChildhoodPracticeGate" .. index
	model.Parent = parent
	local width, height = 12, 5.5
	part(model, "LeftPost", Vector3.new(0.55, height, 0.55), position + Vector3.new(-width / 2, height / 2, 0), color, 0, false)
	part(model, "RightPost", Vector3.new(0.55, height, 0.55), position + Vector3.new(width / 2, height / 2, 0), color, 0, false)
	part(model, "Top", Vector3.new(width, 0.45, 0.45), position + Vector3.new(0, height, 0), color, 0, false)
	local trigger = part(model, "Trigger", Vector3.new(width - 1, height, 3), position + Vector3.new(0, height / 2, 0), color, 1, false)
	trigger.CanTouch = true
	trigger:SetAttribute("PracticeCheckpoint", index)
	billboard(model:FindFirstChild("Top"), "PRACTICE " .. index .. "/3")
	return model, trigger
end

function ChildhoodPracticeService:FindPitch()
	if self.Pitch and self.Pitch.Parent then return self.Pitch end
	local model = self.WorldBuilder and self.WorldBuilder.Model
	if not model then return nil end
	self.Pitch = model:FindFirstChild("ChildhoodDustPitch", true)
	return self.Pitch
end

function ChildhoodPracticeService:GetPracticeSpawn()
	local pitch = self:FindPitch()
	if not pitch then return Vector3.new(-775, 3, 110) end
	return pitch.Position + Vector3.new(0, 3, -45)
end

function ChildhoodPracticeService:BuildCourse()
	if self.Course and self.Course.Parent then return true end
	local pitch = self:FindPitch()
	if not pitch then return false end
	local parent = pitch.Parent
	local old = parent:FindFirstChild("ChildhoodPracticeCourse")
	if old then old:Destroy() end

	local course = Instance.new("Model")
	course.Name = "ChildhoodPracticeCourse"
	course.Parent = parent
	self.Course = course
	self.CheckpointModels = {}
	self.CheckpointTriggers = {}

	local y = pitch.Position.Y + pitch.Size.Y / 2 + 0.02
	local positions = {
		Vector3.new(pitch.Position.X - 24, y, pitch.Position.Z - 18),
		Vector3.new(pitch.Position.X + 24, y, pitch.Position.Z + 8),
		Vector3.new(pitch.Position.X, y, pitch.Position.Z + 48),
	}
	local colors = { COLORS.Orange, COLORS.Blue, COLORS.Orange }
	for index, position in ipairs(positions) do
		local gate, trigger = createGate(course, index, position, colors[index])
		self.CheckpointModels[index] = gate
		self.CheckpointTriggers[index] = trigger
		trigger.Touched:Connect(function(hit)
			if hit == self.BallService.Ball then
				self:HitCheckpoint(index)
			end
		end)
	end

	-- A few cones make the pitch feel like an actual last training session.
	for _, offset in ipairs({
		Vector3.new(-36, 0, -42), Vector3.new(-12, 0, -42), Vector3.new(12, 0, -42), Vector3.new(36, 0, -42),
		Vector3.new(-34, 0, 34), Vector3.new(34, 0, 34),
	}) do
		local cone = part(course, "Cone", Vector3.new(1.1, 1.6, 1.1), Vector3.new(pitch.Position.X, y + 0.8, pitch.Position.Z) + offset, COLORS.Orange, 0, false)
		cone.Shape = Enum.PartType.Cylinder
	end
	return true
end

function ChildhoodPracticeService:SetGateState(index, completed)
	local model = self.CheckpointModels and self.CheckpointModels[index]
	if not model then return end
	for _, child in ipairs(model:GetDescendants()) do
		if child:IsA("BasePart") and child.Name ~= "Trigger" then
			child.Color = completed and COLORS.Green or (index == 2 and COLORS.Blue or COLORS.Orange)
			child.Transparency = completed and 0.18 or 0
		end
	end
end

function ChildhoodPracticeService:ResetBall()
	local pitch = self:FindPitch()
	local ball = self.BallService and self.BallService.Ball
	if not pitch or not ball then return end
	self.BallService:ReleaseAllDribblers()
	ball:SetAttribute("TrainingMode", false)
	ball.CFrame = CFrame.new(pitch.Position + Vector3.new(0, 2.1, -38))
	ball.AssemblyLinearVelocity = Vector3.zero
	ball.AssemblyAngularVelocity = Vector3.zero
end

function ChildhoodPracticeService:Start(player)
	if self.ActivePlayer and self.ActivePlayer ~= player then
		player:SetAttribute("StorySpeaker", "Coach Samuel")
		player:SetAttribute("StoryText", "Give me a moment. Someone else is finishing the practice run.")
		return false
	end
	if not self:BuildCourse() then
		player:SetAttribute("StorySpeaker", "Coach Samuel")
		player:SetAttribute("StoryText", "The old pitch isn't ready yet. Try the practice prompt again.")
		return false
	end

	self.ActivePlayer = player
	self.CurrentCheckpoint = 0
	player:SetAttribute("ChildhoodPracticeActive", true)
	player:SetAttribute("ChildhoodPracticeCheckpoint", 0)
	for index = 1, 3 do self:SetGateState(index, false) end
	self:ResetBall()
	player:SetAttribute("StorySpeaker", "Coach Samuel")
	player:SetAttribute("StoryText", "Ball's out. Take it through the three coloured gates in order. Use F to dribble, Q to pass or E to strike it through.")
	player:SetAttribute("CareerObjective", "Childhood practice: move the ball through PRACTICE 1, 2 and 3 in order.")
	return true
end

function ChildhoodPracticeService:Resume(player)
	if player:GetAttribute("ChildhoodPracticeActive") == true then
		self.ActivePlayer = player
		self.CurrentCheckpoint = player:GetAttribute("ChildhoodPracticeCheckpoint") or 0
		if self:BuildCourse() then
			for index = 1, 3 do self:SetGateState(index, index <= self.CurrentCheckpoint) end
			self:ResetBall()
		end
	end
end

function ChildhoodPracticeService:HitCheckpoint(index)
	local player = self.ActivePlayer
	if not player or not player.Parent then return end
	if index ~= self.CurrentCheckpoint + 1 then
		player:SetAttribute("StorySpeaker", "Coach Samuel")
		player:SetAttribute("StoryText", "In order. Start with PRACTICE " .. tostring(self.CurrentCheckpoint + 1) .. ".")
		return
	end
	self.CurrentCheckpoint = index
	player:SetAttribute("ChildhoodPracticeCheckpoint", index)
	self:SetGateState(index, true)
	if index < 3 then
		player:SetAttribute("StorySpeaker", "Coach Samuel")
		player:SetAttribute("StoryText", "Good touch. Now take it through PRACTICE " .. tostring(index + 1) .. ".")
		player:SetAttribute("CareerObjective", "Childhood practice: checkpoint " .. tostring(index) .. "/3 complete.")
	else
		self:Complete(player)
	end
end

function ChildhoodPracticeService:Complete(player)
	player:SetAttribute("ChildhoodPracticeActive", false)
	player:SetAttribute("ChildhoodPracticeCheckpoint", 3)
	self.ActivePlayer = nil
	if self.OnComplete then self.OnComplete(player) end
end

function ChildhoodPracticeService:Update()
	local player = self.ActivePlayer
	local pitch = self:FindPitch()
	local ball = self.BallService and self.BallService.Ball
	if not player or not player.Parent or not pitch or not ball then return end
	local dx = math.abs(ball.Position.X - pitch.Position.X)
	local dz = math.abs(ball.Position.Z - pitch.Position.Z)
	if dx > pitch.Size.X / 2 + 8 or dz > pitch.Size.Z / 2 + 8 or ball.Position.Y < -5 then
		self:ResetBall()
		player:SetAttribute("StorySpeaker", "Coach Samuel")
		player:SetAttribute("StoryText", "Ball went out. I've put it back on the pitch — keep going from checkpoint " .. tostring(self.CurrentCheckpoint + 1) .. ".")
	end
end

function ChildhoodPracticeService:SetCompletionHandler(callback)
	self.OnComplete = callback
end

function ChildhoodPracticeService:Init(worldBuilder, ballService)
	self.WorldBuilder = worldBuilder
	self.BallService = ballService
	self:BuildCourse()
	RunService.Heartbeat:Connect(function() self:Update() end)
end

return ChildhoodPracticeService
