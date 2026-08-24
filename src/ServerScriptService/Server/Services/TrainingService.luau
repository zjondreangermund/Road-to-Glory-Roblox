local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local TrainingService = {
	States = {},
}

local function clampScore(value)
	return math.clamp(math.floor(value + 0.5), 50, 100)
end

local function playerFromHit(hit)
	if not hit then
		return nil
	end
	local character = hit:FindFirstAncestorOfClass("Model")
	return character and Players:GetPlayerFromCharacter(character) or nil
end

local function countEntries(map)
	local count = 0
	for _ in pairs(map) do
		count += 1
	end
	return count
end

function TrainingService:SetStatus(player, stage, instruction, progress, score)
	player:SetAttribute("TrainingStage", stage)
	player:SetAttribute("TrainingInstruction", instruction or "")
	player:SetAttribute("TrainingProgress", progress or "")
	player:SetAttribute("TrainingScore", score or 0)
end

function TrainingService:TeleportPlayer(player, position, lookAt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local target = position + Vector3.new(0, 3, 0)
	if lookAt then
		root.CFrame = CFrame.lookAt(target, Vector3.new(lookAt.X, target.Y, lookAt.Z))
	else
		root.CFrame = CFrame.new(target)
	end
end

function TrainingService:PlaceBall(position)
	self.BallService:ReleaseAllDribblers()
	self.WorldBuilder:SetBallPosition(position)
	self.WorldBuilder.Ball:SetAttribute("TrainingMode", true)
end

function TrainingService:UpdateAverage(player, state)
	local total = 0
	local count = 0
	for _, score in pairs(state.Scores) do
		total += score
		count += 1
	end
	local average = count > 0 and math.floor((total / count) + 0.5) or 0
	player:SetAttribute("TrainingScore", average)
	return average
end

function TrainingService:BeginSprint(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Sprint"
	state.SprintStartedAt = nil
	self.BallService:ReleaseAllDribblers()
	self.WorldBuilder.Ball:SetAttribute("TrainingMode", true)
	self:SetStatus(player, "1/5  SPRINT TEST", "Run through the YELLOW START line, then race to the FINISH line.", "Waiting for start", self:UpdateAverage(player, state))
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "First test: pace. Get through the start line and explode to the finish.")
	self:TeleportPlayer(player, self.WorldBuilder.Training.SprintSpawn.Position, self.WorldBuilder.Training.SprintFinish.Position)
end

function TrainingService:BeginAgility(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Agility"
	state.AgilityNext = 1
	state.AgilityStartedAt = nil
	self.BallService:ReleaseAllDribblers()
	local total = #self.WorldBuilder.Training.AgilityCheckpoints
	self:SetStatus(player, "2/5  AGILITY TEST", "Run through the PURPLE checkpoints in order. Cut sharply and do not skip a gate.", "Checkpoint 0 / " .. tostring(total), self:UpdateAverage(player, state))
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "Pace is one thing. Now show me how quickly you can change direction.")
	self:TeleportPlayer(player, self.WorldBuilder.Training.AgilitySpawn.Position, self.WorldBuilder.Training.AgilityCheckpoints[1].Position)
end

function TrainingService:BeginShooting(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Shooting"
	state.ShootingHits = {}
	state.ShootingAttempts = 0
	local total = #self.WorldBuilder.Training.ShootingTargets
	self:SetStatus(player, "3/5  SHOOTING TEST", "Hit all " .. total .. " RED targets. E = shoot. Fewer attempts = higher score.", "0 / " .. tostring(total) .. " targets", self:UpdateAverage(player, state))
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "Five finishes. Low corners, high corners and the centre. Pick your target before you strike it.")
	self:TeleportPlayer(player, self.WorldBuilder.Training.ShootingPlayerSpot.Position, self.WorldBuilder.Training.ShootingTargetLook.Position)
	self:PlaceBall(self.WorldBuilder.Training.ShootingBallSpot.Position)
end

function TrainingService:BeginPassing(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Passing"
	state.PassingHits = {}
	state.PassingAttempts = 0
	local total = #self.WorldBuilder.Training.PassingTargets
	self:SetStatus(player, "4/5  PASSING TEST", "Pass through all " .. total .. " BLUE gates. Q = pass. Fewer attempts = higher score.", "0 / " .. tostring(total) .. " gates", self:UpdateAverage(player, state))
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "Open your body and find every gate. Accuracy matters more than power here.")
	self:TeleportPlayer(player, self.WorldBuilder.Training.PassingPlayerSpot.Position, self.WorldBuilder.Training.PassingTargetLook.Position)
	self:PlaceBall(self.WorldBuilder.Training.PassingBallSpot.Position)
end

function TrainingService:BeginDribbling(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Dribbling"
	state.DribbleNext = 1
	state.DribbleStartedAt = nil
	local total = #self.WorldBuilder.Training.DribbleGates
	self:SetStatus(player, "5/5  DRIBBLING TEST", "Press F to control the ball, then take it through all ORANGE gates in order.", "Gate 0 / " .. tostring(total), self:UpdateAverage(player, state))
	player:SetAttribute("StorySpeaker", "Coach Daniels")
	player:SetAttribute("StoryText", "Final drill. Ten gates. Keep the ball close, change direction and finish the course under control.")
	self:TeleportPlayer(player, self.WorldBuilder.Training.DribblePlayerSpot.Position, self.WorldBuilder.Training.DribbleGates[1].Position)
	self:PlaceBall(self.WorldBuilder.Training.DribbleBallSpot.Position)
end

function TrainingService:CompleteTraining(player)
	local state = self.States[player]
	if not state then return end
	state.Stage = "Complete"
	local overall = self:UpdateAverage(player, state)
	local grade
	if overall >= 90 then
		grade = "ELITE"
	elseif overall >= 80 then
		grade = "STRONG"
	elseif overall >= 70 then
		grade = "PROMISING"
	else
		grade = "DEVELOPMENT"
	end

	player:SetAttribute("TrainingActive", false)
	player:SetAttribute("ScoutOverall", overall)
	player:SetAttribute("ScoutGrade", grade)
	player:SetAttribute("ScoutReport", string.format(
		"PACE %d  |  AGILITY %d  |  SHOOT %d  |  PASS %d  |  DRIBBLE %d",
		state.Scores.Sprint or 0,
		state.Scores.Agility or 0,
		state.Scores.Shooting or 0,
		state.Scores.Passing or 0,
		state.Scores.Dribbling or 0
	))
	self:SetStatus(player, "SCOUT REPORT", "Full academy assessment complete. Press T / TRAINING to run it again.", grade .. "  •  OVR " .. tostring(overall), overall)
	player:SetAttribute("StorySpeaker", "Scout")
	player:SetAttribute("StoryText", string.format("Five-part assessment complete: %s. Scout score %d/100.", grade, overall))
	self.BallService:SetDribbling(player, false)
	self.WorldBuilder.Ball:SetAttribute("TrainingMode", false)
end

function TrainingService:StartTraining(player)
	self.States[player] = {
		Stage = "Sprint",
		Scores = {},
		AgilityNext = 1,
		ShootingHits = {},
		PassingHits = {},
		DribbleNext = 1,
	}
	player:SetAttribute("TrainingActive", true)
	player:SetAttribute("ScoutOverall", 0)
	player:SetAttribute("ScoutGrade", "")
	player:SetAttribute("ScoutReport", "")
	self.WorldBuilder.Ball:SetAttribute("TrainingOwnerUserId", player.UserId)
	self:BeginSprint(player)
end

function TrainingService:ConnectSprint()
	self.WorldBuilder.Training.SprintStart.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		local state = player and self.States[player]
		if not state or state.Stage ~= "Sprint" or state.SprintStartedAt then return end
		state.SprintStartedAt = os.clock()
		self:SetStatus(player, "1/5  SPRINT TEST", "GO! Reach the finish as quickly as possible.", "Running...", self:UpdateAverage(player, state))
	end)

	self.WorldBuilder.Training.SprintFinish.Touched:Connect(function(hit)
		local player = playerFromHit(hit)
		local state = player and self.States[player]
		if not state or state.Stage ~= "Sprint" or not state.SprintStartedAt then return end
		local duration = os.clock() - state.SprintStartedAt
		state.Scores.Sprint = clampScore(100 - math.max(0, duration - GameConfig.Training.SprintGoldTime) * 12)
		state.Stage = "Transition"
		self:SetStatus(player, "SPRINT COMPLETE", string.format("Time %.2fs", duration), "Score " .. tostring(state.Scores.Sprint), self:UpdateAverage(player, state))
		task.delay(1.2, function()
			if self.States[player] == state then self:BeginAgility(player) end
		end)
	end)
end

function TrainingService:ConnectAgility()
	for index, checkpoint in ipairs(self.WorldBuilder.Training.AgilityCheckpoints) do
		checkpoint.Touched:Connect(function(hit)
			local player = playerFromHit(hit)
			local state = player and self.States[player]
			if not state or state.Stage ~= "Agility" or state.AgilityNext ~= index then return end

			if index == 1 then
				state.AgilityStartedAt = os.clock()
			end
			state.AgilityNext += 1
			local total = #self.WorldBuilder.Training.AgilityCheckpoints
			self:SetStatus(player, "2/5  AGILITY TEST", "Keep moving through the purple checkpoints in order.", string.format("Checkpoint %d / %d", index, total), self:UpdateAverage(player, state))

			if index == total then
				local duration = os.clock() - (state.AgilityStartedAt or os.clock())
				state.Scores.Agility = clampScore(100 - math.max(0, duration - GameConfig.Training.AgilityGoldTime) * 4)
				state.Stage = "Transition"
				self:SetStatus(player, "AGILITY COMPLETE", string.format("Time %.2fs", duration), "Score " .. tostring(state.Scores.Agility), self:UpdateAverage(player, state))
				task.delay(1.2, function()
					if self.States[player] == state then self:BeginShooting(player) end
				end)
			end
		end)
	end
end

function TrainingService:ConnectTargets()
	for _, target in ipairs(self.WorldBuilder.Training.ShootingTargets) do
		target.Touched:Connect(function(hit)
			if hit ~= self.WorldBuilder.Ball then return end
			local player = Players:GetPlayerByUserId(self.WorldBuilder.Ball:GetAttribute("TrainingOwnerUserId") or 0)
			local state = player and self.States[player]
			if not state or state.Stage ~= "Shooting" or self.WorldBuilder.Ball:GetAttribute("LastAction") ~= "Shoot" then return end
			local id = target:GetAttribute("TrainingIndex")
			if state.ShootingHits[id] then return end
			state.ShootingHits[id] = true
			local count = countEntries(state.ShootingHits)
			local total = #self.WorldBuilder.Training.ShootingTargets
			self:SetStatus(player, "3/5  SHOOTING TEST", "Hit every RED target.", string.format("%d / %d targets", count, total), self:UpdateAverage(player, state))
			if count >= total then
				state.Scores.Shooting = clampScore(100 - math.max(0, state.ShootingAttempts - total) * 6)
				state.Stage = "Transition"
				task.delay(1.0, function()
					if self.States[player] == state then self:BeginPassing(player) end
				end)
			else
				task.delay(0.5, function()
					if self.States[player] == state and state.Stage == "Shooting" then
						self:PlaceBall(self.WorldBuilder.Training.ShootingBallSpot.Position)
					end
				end)
			end
		end)
	end

	for _, target in ipairs(self.WorldBuilder.Training.PassingTargets) do
		target.Touched:Connect(function(hit)
			if hit ~= self.WorldBuilder.Ball then return end
			local player = Players:GetPlayerByUserId(self.WorldBuilder.Ball:GetAttribute("TrainingOwnerUserId") or 0)
			local state = player and self.States[player]
			if not state or state.Stage ~= "Passing" or self.WorldBuilder.Ball:GetAttribute("LastAction") ~= "Pass" then return end
			local id = target:GetAttribute("TrainingIndex")
			if state.PassingHits[id] then return end
			state.PassingHits[id] = true
			local count = countEntries(state.PassingHits)
			local total = #self.WorldBuilder.Training.PassingTargets
			self:SetStatus(player, "4/5  PASSING TEST", "Find every BLUE passing gate.", string.format("%d / %d gates", count, total), self:UpdateAverage(player, state))
			if count >= total then
				state.Scores.Passing = clampScore(100 - math.max(0, state.PassingAttempts - total) * 6)
				state.Stage = "Transition"
				task.delay(1.0, function()
					if self.States[player] == state then self:BeginDribbling(player) end
				end)
			else
				task.delay(0.5, function()
					if self.States[player] == state and state.Stage == "Passing" then
						self:PlaceBall(self.WorldBuilder.Training.PassingBallSpot.Position)
					end
				end)
			end
		end)
	end
end

function TrainingService:ConnectDribbleGates()
	for index, gate in ipairs(self.WorldBuilder.Training.DribbleGates) do
		gate.Touched:Connect(function(hit)
			local player = playerFromHit(hit)
			local state = player and self.States[player]
			if not state or state.Stage ~= "Dribbling" or state.DribbleNext ~= index then return end
			if self.WorldBuilder.Ball:GetAttribute("DribbleOwnerUserId") ~= player.UserId then return end
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - self.WorldBuilder.Ball.Position).Magnitude > 8 then return end

			if index == 1 then state.DribbleStartedAt = os.clock() end
			state.DribbleNext += 1
			local total = #self.WorldBuilder.Training.DribbleGates
			self:SetStatus(player, "5/5  DRIBBLING TEST", "Keep the ball in front and take the gates in order.", string.format("Gate %d / %d", index, total), self:UpdateAverage(player, state))

			if index == total then
				local duration = os.clock() - (state.DribbleStartedAt or os.clock())
				state.Scores.Dribbling = clampScore(100 - math.max(0, duration - GameConfig.Training.DribbleGoldTime) * 3)
				self:CompleteTraining(player)
			end
		end)
	end
end

function TrainingService:Init(worldBuilder, ballService, trainingRemote, footballRemote)
	self.WorldBuilder = worldBuilder
	self.BallService = ballService
	self.TrainingRemote = trainingRemote

	local function initialisePlayer(player)
		player:SetAttribute("TrainingActive", false)
		player:SetAttribute("TrainingStage", "ACADEMY TRAINING")
		player:SetAttribute("TrainingInstruction", "Press T or the TRAINING button to begin the five-part academy assessment.")
		player:SetAttribute("TrainingProgress", "Sprint • Agility • Shooting • Passing • Dribbling")
		player:SetAttribute("TrainingScore", 0)
		player:SetAttribute("ScoutOverall", 0)
		player:SetAttribute("ScoutGrade", "")
		player:SetAttribute("ScoutReport", "")
	end

	Players.PlayerAdded:Connect(initialisePlayer)
	for _, player in ipairs(Players:GetPlayers()) do initialisePlayer(player) end
	Players.PlayerRemoving:Connect(function(player) self.States[player] = nil end)

	trainingRemote.OnServerEvent:Connect(function(player, action)
		if action == "StartTraining" then self:StartTraining(player) end
	end)

	footballRemote.OnServerEvent:Connect(function(player, action)
		local state = self.States[player]
		if not state then return end
		if state.Stage == "Shooting" and action == "Shoot" then
			state.ShootingAttempts += 1
			task.delay(2.2, function()
				if self.States[player] == state and state.Stage == "Shooting" then self:PlaceBall(self.WorldBuilder.Training.ShootingBallSpot.Position) end
			end)
		elseif state.Stage == "Passing" and action == "Pass" then
			state.PassingAttempts += 1
			task.delay(1.8, function()
				if self.States[player] == state and state.Stage == "Passing" then self:PlaceBall(self.WorldBuilder.Training.PassingBallSpot.Position) end
			end)
		end
	end)

	self:ConnectSprint()
	self:ConnectAgility()
	self:ConnectTargets()
	self:ConnectDribbleGates()
end

return TrainingService
