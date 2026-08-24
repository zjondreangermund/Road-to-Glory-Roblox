local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TrialMatchService = {
	ActivePlayer = nil,
	Agents = {},
	HomeScore = 0,
	AwayScore = 0,
	TimeLeft = 0,
	GoalLock = false,
	PlayerGoals = 0,
}

local HOME = Color3.fromRGB(43, 101, 183)
local AWAY = Color3.fromRGB(196, 54, 54)
local SKIN = Color3.fromRGB(201, 161, 124)
local DARK = Color3.fromRGB(36, 39, 43)

local function part(parent, name, size, position, color, transparency, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color
	p.Transparency = transparency or 0
	p.CanCollide = canCollide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function teleportPlayer(player, position, lookAt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if lookAt then
		root.CFrame = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	else
		root.CFrame = CFrame.new(position)
	end
end

local function makeAgent(parent, name, position, team, role, homeOffset)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local root = part(model, "Root", Vector3.new(1, 1, 1), position, DARK, 1, false)
	model.PrimaryPart = root
	local shirt = team == "Home" and HOME or AWAY
	part(model, "Torso", Vector3.new(2.1, 3, 1.1), position + Vector3.new(0, 2.8, 0), shirt, 0, false)
	local head = part(model, "Head", Vector3.new(1.6, 1.6, 1.6), position + Vector3.new(0, 5.0, 0), SKIN, 0, false)
	head.Shape = Enum.PartType.Ball
	for _, side in ipairs({ -1, 1 }) do
		part(model, "Leg", Vector3.new(0.72, 2.4, 0.75), position + Vector3.new(side * 0.5, 1.25, 0), DARK, 0, false)
	end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(130, 28)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 45
	gui.AlwaysOnTop = false
	gui.Parent = head
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.35
	label.TextSize = 13
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	return {
		Model = model,
		Root = root,
		Team = team,
		Role = role,
		HomeOffset = homeOffset,
		LastKick = 0,
	}
end

local function moveAgent(agent, target, dt, facePoint)
	if not agent.Model.Parent then return end
	local pos = agent.Root.Position
	local flatTarget = Vector3.new(target.X, pos.Y, target.Z)
	local delta = flatTarget - pos
	local speed = agent.Role == "GK" and 13 or 17
	local nextPos = pos
	if delta.Magnitude > 0.15 then
		nextPos = pos + delta.Unit * math.min(delta.Magnitude, speed * dt)
	end
	local look = facePoint or target
	local lookFlat = Vector3.new(look.X, nextPos.Y, look.Z)
	if (lookFlat - nextPos).Magnitude < 0.05 then lookFlat = nextPos + Vector3.new(0, 0, -1) end
	agent.Model:PivotTo(CFrame.lookAt(nextPos, lookFlat))
end

function TrialMatchService:CreateAgents()
	if self.AgentFolder then self.AgentFolder:Destroy() end
	local stadium = self.WorldBuilder.FirstMatchStadium
	if not stadium then return end
	local folder = Instance.new("Folder")
	folder.Name = "TrialMatchPlayers"
	folder.Parent = stadium
	self.AgentFolder = folder
	self.Agents = {}
	local c = self.PitchCentre
	local homeData = {
		{ "Kai", "OUT", Vector3.new(-25, 0, -18) },
		{ "Mason", "OUT", Vector3.new(24, 0, -15) },
		{ "Theo", "OUT", Vector3.new(-15, 0, 24) },
		{ "Luca", "OUT", Vector3.new(17, 0, 28) },
		{ "Home GK", "GK", Vector3.new(0, 0, -78) },
	}
	local awayData = {
		{ "Marco", "OUT", Vector3.new(0, 0, 12) },
		{ "Rival 7", "OUT", Vector3.new(-28, 0, 18) },
		{ "Rival 8", "OUT", Vector3.new(27, 0, 20) },
		{ "Rival 10", "OUT", Vector3.new(-14, 0, -12) },
		{ "Away GK", "GK", Vector3.new(0, 0, 78) },
	}
	for _, data in ipairs(homeData) do
		table.insert(self.Agents, makeAgent(folder, data[1], c + data[3] + Vector3.new(0, 0.5, 0), "Home", data[2], data[3]))
	end
	for _, data in ipairs(awayData) do
		table.insert(self.Agents, makeAgent(folder, data[1], c + data[3] + Vector3.new(0, 0.5, 0), "Away", data[2], data[3]))
	end
end

function TrialMatchService:ResetAgents()
	for _, agent in ipairs(self.Agents) do
		local p = self.PitchCentre + agent.HomeOffset + Vector3.new(0, 0.5, 0)
		agent.Model:PivotTo(CFrame.lookAt(p, self.PitchCentre + Vector3.new(0, 0.5, 0)))
	end
end

function TrialMatchService:ResetKickoff()
	self.BallService:ReleaseAllDribblers()
	self.WorldBuilder.Ball:SetAttribute("TrainingMode", false)
	self.WorldBuilder:SetBallPosition(self.PitchCentre + Vector3.new(0, 2.2, 0))
	self:ResetAgents()
	if self.ActivePlayer and self.ActivePlayer.Parent then
		teleportPlayer(self.ActivePlayer, self.PitchCentre + Vector3.new(0, 3, -8), self.PitchCentre + Vector3.new(0, 3, 25))
	end
end

function TrialMatchService:Broadcast()
	local player = self.ActivePlayer
	if not player then return end
	player:SetAttribute("HomeScore", self.HomeScore)
	player:SetAttribute("AwayScore", self.AwayScore)
	player:SetAttribute("MatchTime", self.TimeLeft)
	player:SetAttribute("TrialMatchActive", self.TimeLeft > 0)
	player:SetAttribute("TrialMatchProgress", string.format("HOME %d-%d AWAY  •  %ds", self.HomeScore, self.AwayScore, self.TimeLeft))
end

function TrialMatchService:AwardGoal(goalFor)
	if self.GoalLock or not self.ActivePlayer or self.TimeLeft <= 0 then return end
	self.GoalLock = true
	if goalFor == "Home" then
		self.HomeScore += 1
		if self.WorldBuilder.Ball:GetAttribute("LastTouchUserId") == self.ActivePlayer.UserId then
			self.PlayerGoals += 1
			self.RatingService:Add(self.ActivePlayer, 0.7, "Trial match goal")
			self.ActivePlayer:SetAttribute("StorySpeaker", "Commentator")
			self.ActivePlayer:SetAttribute("StoryText", "GOAL! That's exactly the kind of moment the scouts remember.")
		else
			self.RatingService:Add(self.ActivePlayer, 0.15, "Team goal contribution")
		end
	else
		self.AwayScore += 1
		self.RatingService:Add(self.ActivePlayer, -0.15, "Team conceded")
	end
	self:Broadcast()
	task.delay(1.4, function()
		if self.ActivePlayer and self.TimeLeft > 0 then self:ResetKickoff() end
		self.GoalLock = false
	end)
end

function TrialMatchService:ConnectGoals()
	local stadium = self.WorldBuilder.FirstMatchStadium
	if not stadium then return end
	local old = stadium:FindFirstChild("TrialGoalTriggers")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "TrialGoalTriggers"
	folder.Parent = stadium
	local c = self.PitchCentre
	local north = part(folder, "HomeGoalTrigger", Vector3.new(26, 8.2, 4.2), c + Vector3.new(0, 4.1, 93), Color3.new(1, 1, 1), 1, false)
	local south = part(folder, "AwayGoalTrigger", Vector3.new(26, 8.2, 4.2), c + Vector3.new(0, 4.1, -93), Color3.new(1, 1, 1), 1, false)
	north.CanTouch = true
	south.CanTouch = true
	north.Touched:Connect(function(hit) if hit == self.WorldBuilder.Ball then self:AwardGoal("Home") end end)
	south.Touched:Connect(function(hit) if hit == self.WorldBuilder.Ball then self:AwardGoal("Away") end end)
end

function TrialMatchService:AIKick(agent)
	local ball = self.WorldBuilder.Ball
	if os.clock() - agent.LastKick < 1.1 then return end
	if ball:GetAttribute("DribbleOwnerUserId") ~= 0 then return end
	if (agent.Root.Position - ball.Position).Magnitude > 4.8 then return end
	agent.LastKick = os.clock()
	ball:SetAttribute("LastTouchUserId", 0)
	ball:SetAttribute("LastAction", "AIKick")
	local targetZ = self.PitchCentre.Z + (agent.Team == "Home" and 91 or -91)
	local target = Vector3.new(self.PitchCentre.X + math.random(-8, 8), 1.5, targetZ)
	local delta = target - ball.Position
	local flat = Vector3.new(delta.X, 0, delta.Z)
	if flat.Magnitude > 0 then
		ball.AssemblyLinearVelocity = flat.Unit * (agent.Role == "GK" and 65 or 54) + Vector3.new(0, 7, 0)
	end
end

function TrialMatchService:UpdateAI(dt)
	if not self.ActivePlayer or self.TimeLeft <= 0 then return end
	local ball = self.WorldBuilder.Ball
	local ballPos = ball.Position
	local playerRoot = self.ActivePlayer.Character and self.ActivePlayer.Character:FindFirstChild("HumanoidRootPart")
	local playerPos = playerRoot and playerRoot.Position or self.PitchCentre

	local closestHome, closestHomeDistance = nil, math.huge
	local closestAway, closestAwayDistance = nil, math.huge
	for _, agent in ipairs(self.Agents) do
		if agent.Role ~= "GK" then
			local d = (agent.Root.Position - ballPos).Magnitude
			if agent.Team == "Home" and d < closestHomeDistance then closestHome, closestHomeDistance = agent, d end
			if agent.Team == "Away" and d < closestAwayDistance then closestAway, closestAwayDistance = agent, d end
		end
	end

	for _, agent in ipairs(self.Agents) do
		local target
		if agent.Role == "GK" then
			local goalZ = self.PitchCentre.Z + (agent.Team == "Home" and -82 or 82)
			local x = math.clamp(ballPos.X, self.PitchCentre.X - 10, self.PitchCentre.X + 10)
			target = Vector3.new(x, agent.Root.Position.Y, goalZ)
		elseif agent.Team == "Away" and agent == closestAway then
			target = ballPos
		elseif agent.Team == "Home" and agent == closestHome and (playerPos - ballPos).Magnitude > 11 then
			target = ballPos
		else
			local shift = Vector3.new((ballPos.X - self.PitchCentre.X) * 0.18, 0, (ballPos.Z - self.PitchCentre.Z) * 0.12)
			target = self.PitchCentre + agent.HomeOffset + shift
		end
		moveAgent(agent, target, dt, ballPos)
		self:AIKick(agent)
	end
end

function TrialMatchService:FinishMatch()
	local player = self.ActivePlayer
	if not player then return end
	self.TimeLeft = 0
	self:Broadcast()
	player:SetAttribute("TrialMatchActive", false)
	player:SetAttribute("CareerStage", "ContractDecision")
	player:SetAttribute("CareerObjective", "Receive the scout's decision.")

	local trainingScore = player:GetAttribute("ScoutOverall") or 60
	local rating = player:GetAttribute("ManagerRating") or 6.0
	local combined = math.floor((trainingScore * 0.55) + (rating * 10 * 0.45) + 0.5)
	local success = combined >= 70 or self.PlayerGoals >= 2 or rating >= 7.4
	local profile = self.PlayerDataService:Get(player)
	if profile then
		profile.Stats.Matches = (profile.Stats.Matches or 0) + 1
		profile.Stats.Goals = (profile.Stats.Goals or 0) + self.PlayerGoals
		profile.Career.Money = (profile.Career.Money or 0) + 250
		if success then
			profile.Career.Club = "Northbridge FC"
			profile.Career.Money += 500
			profile.Career.Stage = "FirstContract"
		else
			profile.Career.Stage = "SecondChance"
		end
		player:SetAttribute("CareerMoney", profile.Career.Money)
	end

	if success then
		player:SetAttribute("ContractOffer", "NORTHBRIDGE FC DEVELOPMENT CONTRACT")
		player:SetAttribute("StorySpeaker", "Scout")
		player:SetAttribute("StoryText", string.format("Training %d. Match rating %.1f. Final score %d. Congratulations — Northbridge FC wants to offer you your first contract.", trainingScore, rating, combined))
		player:SetAttribute("CareerObjective", "First contract earned. Explore the world while we build Chapter 2.")
	else
		player:SetAttribute("ContractOffer", "SECOND TRIAL INVITE")
		player:SetAttribute("StorySpeaker", "Coach Daniels")
		player:SetAttribute("StoryText", string.format("Training %d. Match rating %.1f. Final score %d. You're not out — we've invited you back for a second trial.", trainingScore, rating, combined))
		player:SetAttribute("CareerObjective", "Second trial unlocked. Improve and try again.")
	end

	self.WorldBuilder.Ball.AssemblyLinearVelocity = Vector3.zero
	self.ActivePlayer = nil
	if self.AgentFolder then self.AgentFolder:Destroy() self.AgentFolder = nil end
end

function TrialMatchService:StartMatch(player)
	if self.ActivePlayer then
		player:SetAttribute("StorySpeaker", "Steward")
		player:SetAttribute("StoryText", "A trial match is already active.")
		return
	end
	local scout = player:GetAttribute("ScoutOverall") or 0
	if scout <= 0 then
		player:SetAttribute("StorySpeaker", "Coach Daniels")
		player:SetAttribute("StoryText", "Complete the academy assessment before the final trial match.")
		return
	end

	self.ActivePlayer = player
	self.HomeScore = 0
	self.AwayScore = 0
	self.PlayerGoals = 0
	self.TimeLeft = 180
	self.GoalLock = false
	self.MatchService.Active = false
	self.RatingService:Reset(player)
	player:SetAttribute("ContractOffer", "")
	player:SetAttribute("TrialMatchActive", true)
	player:SetAttribute("CareerChapter", "AcademyTrial")
	player:SetAttribute("CareerStage", "TrialMatch")
	player:SetAttribute("CareerObjective", "Trial Match: reach 7.0+ manager rating and make a decisive contribution.")
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "This is it. Three minutes. Blue team. Play your football and make the scouts remember you.")
	self:CreateAgents()
	self:ResetKickoff()
	self:Broadcast()

	task.spawn(function()
		while self.ActivePlayer == player and self.TimeLeft > 0 do
			task.wait(1)
			if self.ActivePlayer ~= player then break end
			self.TimeLeft -= 1
			self:Broadcast()
		end
		if self.ActivePlayer == player then self:FinishMatch() end
	end)
end

function TrialMatchService:ConnectStartPrompt()
	for _, node in ipairs(self.WorldBuilder.Model:GetDescendants()) do
		if node:IsA("BasePart") and node:GetAttribute("StoryAction") == "StartTrialMatch" then
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "TrialMatchPrompt"
			prompt.ActionText = "Start Match"
			prompt.ObjectText = "First Trial Match"
			prompt.HoldDuration = 0.6
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = node
			prompt.Triggered:Connect(function(player) self:StartMatch(player) end)
		end
	end
end

function TrialMatchService:Init(worldBuilder, ballService, ratingService, matchService, playerDataService)
	self.WorldBuilder = worldBuilder
	self.BallService = ballService
	self.RatingService = ratingService
	self.MatchService = matchService
	self.PlayerDataService = playerDataService
	local stadium = worldBuilder.FirstMatchStadium
	local pitch = stadium and stadium:FindFirstChild("MatchPitch")
	self.PitchCentre = pitch and pitch.Position or Vector3.new(-88, 0, -585)
	self:ConnectGoals()
	self:ConnectStartPrompt()
	RunService.Heartbeat:Connect(function(dt) self:UpdateAI(dt) end)
	Players.PlayerRemoving:Connect(function(player)
		if self.ActivePlayer == player then
			self.ActivePlayer = nil
			if self.AgentFolder then self.AgentFolder:Destroy() self.AgentFolder = nil end
		end
	end)
end

return TrialMatchService
