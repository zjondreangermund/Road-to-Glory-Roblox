local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local RatingService = {}

function RatingService:Init()
	return self
end

function RatingService:Reset(player)
	player:SetAttribute("ManagerRating", GameConfig.Rating.Start)
	player:SetAttribute("LastRatingReason", "Match started")
end

function RatingService:Add(player, amount, reason)
	local current = player:GetAttribute("ManagerRating") or GameConfig.Rating.Start
	local updated = math.clamp(current + amount, GameConfig.Rating.Minimum, GameConfig.Rating.Maximum)
	player:SetAttribute("ManagerRating", math.round(updated * 10) / 10)
	player:SetAttribute("LastRatingReason", reason or "Performance")
end

return RatingService
