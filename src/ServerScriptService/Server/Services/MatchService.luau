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

function MatchService:StartMatch()
	self.HomeScore = 0
	self.AwayScore = 0
	self.TimeLeft = GameConfig.Match.DurationSeconds
	self.Active = true
	self:ResetPlayerRatings()
	self.WorldBuilder:ResetBall()
	self:Broadcast()
end

function MatchService:AwardGoal(goalFor)
	if self.GoalLock or not self.Active then
		return
	end
	self.GoalLock = true
	if goalFor == "Home" then
		self.HomeScore += 1
	else
		self.AwayScore += 1
	end

	local lastTouch = self.Ball:GetAttribute("LastTouchUserId") or 0
	local scorer = Players:GetPlayerByUserId(lastTouch)
	if scorer then
		self.RatingService:Add(scorer, GameConfig.Rating.GoalBonus, "Goal scored")
	end
	self:Broadcast()

	task.delay(GameConfig.Match.ResetDelaySeconds, function()
		self.WorldBuilder:ResetBall()
		self.GoalLock = false
	end)
end

function MatchService:ConnectGoals(worldModel)
	for _, descendant in ipairs(worldModel:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "GoalTrigger" then
			descendant.Touched:Connect(function(hit)
				if hit == self.Ball then
					self:AwardGoal(descendant:GetAttribute("GoalFor"))
				end
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

	self:StartMatch()
	task.spawn(function()
		while true do
			task.wait(1)
			if self.Active then
				self.TimeLeft = math.max(self.TimeLeft - 1, 0)
				if self.TimeLeft == 0 then
					self.Active = false
					task.delay(5, function()
						self:StartMatch()
					end)
				end
				self:Broadcast()
			end
		end
	end)
end

return MatchService
