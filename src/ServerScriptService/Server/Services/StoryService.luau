local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryData = require(ReplicatedStorage.Shared.StoryData)

local StoryService = {}

function StoryService:SetStage(player, chapterName, stageName)
	local chapter = StoryData[chapterName]
	local stage = chapter and chapter.Stages[stageName]
	if not stage then
		return false
	end
	player:SetAttribute("CareerChapter", chapterName)
	player:SetAttribute("CareerStage", stageName)
	player:SetAttribute("StorySpeaker", stage.Speaker)
	player:SetAttribute("StoryText", stage.Text)
	return true
end

function StoryService:Init()
	local function setup(player)
		task.delay(1, function()
			if player.Parent then
				self:SetStage(player, "AcademyTrial", "Arrival")
			end
		end)
	end
	Players.PlayerAdded:Connect(setup)
	for _, player in ipairs(Players:GetPlayers()) do
		setup(player)
	end
end

return StoryService
