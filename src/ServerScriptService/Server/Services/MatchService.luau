local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local MatchService = {
	HomeScore = 0,
	AwayScore = 0,
	TimeLeft = 0,
	Active = false,
	GoalLock = false,
}

function MatchService:Broadcast()
	for _, player in ipairs(Players:GetPlayers()) do
		player:SetAttribute("HomeScore", self.HomeScore)
		player:SetAttribute("AwayScore", self.AwayScore)
		player:SetAttribute("MatchTime", self.TimeLeft)
		player:SetAttribute("MatchActive", self.Active)
	end
end

function MatchService:ResetPlayerRatings()
	for _, player in ipairs(Players:GetPlayers()) do
		self.RatingService:Reset(player)
	end
end

function MatchService:StartMatch(resetBall)
	self.HomeScore = 0
	self.AwayScore = 0
	self.TimeLeft = GameConfig.Match.DurationSeconds
	self.Active = true
	self:ResetPlayerRatings()
	if resetBall ~= false and not self.Ball:GetAttribute("TrainingMode") then
		self.WorldBuilder:ResetBall()
	end
	self:Broadcast()
end

function MatchService:AwardGoal(goalFor)
	if self.GoalLock or not self.Active then return end
	if self.Ball:GetAttribute("TrainingMode") then return end

	self.GoalLock = true
	if goalFor == "Home" then self.HomeScore += 1 else self.AwayScore += 1 end

	local lastTouch = self.Ball:GetAttribute("LastTouchUserId") or 0
	local scorer = Players:GetPlayerByUserId(lastTouch)
	if scorer then
		self.RatingService:Add(scorer, GameConfig.Rating.GoalBonus, "Goal scored")
		scorer:SetAttribute("LastMatchEvent", "GOAL! Ball reset for kickoff.")
	end
	self:Broadcast()

	task.delay(GameConfig.Match.ResetDelaySeconds, function()
		if not self.Ball:GetAttribute("TrainingMode") then
			self.WorldBuilder:ResetBall()
		end
		self.GoalLock = false
	end)
end

function MatchService:ConnectGoals(worldModel)
	for _, descendant in ipairs(worldModel:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "GoalTrigger" then
			descendant.Touched:Connect(function(hit)
				if hit == self.Ball then self:AwardGoal(descendant:GetAttribute("GoalFor")) end
			end)
		end
	end
end

function MatchService:Init(worldBuilder, ratingService)
	self.WorldBuilder = worldBuilder
	self.RatingService = ratingService
	self.Ball = worldBuilder.Ball
	self:ConnectGoals(worldBuilder.Model)

	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			self.RatingService:Reset(player)
			self:Broadcast()
		end)
	end)

	self:StartMatch(true)
	task.spawn(function()
		while true do
			task.wait(1)
			if self.Active then
				self.TimeLeft = math.max(self.TimeLeft - 1, 0)
				if self.TimeLeft == 0 then
					self.Active = false
					if GameConfig.Match.AutoRestart then
						task.delay(5, function() self:StartMatch(false) end)
					end
				end
				self:Broadcast()
			end
		end
	end)
end

return MatchService
