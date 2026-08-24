local Players = game:GetService("Players")

local UIController = {}

local function makeLabel(parent, name, size, position, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.GothamBold
	label.TextSize = textSize
	label.Parent = parent
	return label
end

local function formatTime(seconds)
	seconds = tonumber(seconds) or 0
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

function UIController:Refresh()
	local player = Players.LocalPlayer
	self.Score.Text = string.format("HOME %d  -  %d AWAY", player:GetAttribute("HomeScore") or 0, player:GetAttribute("AwayScore") or 0)
	self.Clock.Text = formatTime(player:GetAttribute("MatchTime"))
	self.Rating.Text = string.format("MANAGER RATING  %.1f", player:GetAttribute("ManagerRating") or 6.0)
	self.Cash.Text = string.format("CASH  N$%d", player:GetAttribute("CareerMoney") or 0)
	self.Story.Text = string.format("%s\n%s", player:GetAttribute("StorySpeaker") or "Coach", player:GetAttribute("StoryText") or "Welcome to Road to Glory")

	local location = player:GetAttribute("ExplorationLocation") or "Academy Entrance"
	local explored = player:GetAttribute("ExplorationCount") or 0
	local total = player:GetAttribute("ExplorationTotal") or 0
	self.Exploration.Text = string.format("CAREER WORLD  •  %s  •  %d/%d EXPLORED", location, explored, total)

	local stage = player:GetAttribute("TrainingStage") or "ACADEMY TRAINING"
	local instruction = player:GetAttribute("TrainingInstruction") or "Press T to begin."
	local progress = player:GetAttribute("TrainingProgress") or ""
	local score = player:GetAttribute("TrainingScore") or 0
	self.Training.Text = string.format("%s\n%s\n%s\nCURRENT SCORE: %d", stage, instruction, progress, score)

	local report = player:GetAttribute("ScoutReport") or ""
	local grade = player:GetAttribute("ScoutGrade") or ""
	local overall = player:GetAttribute("ScoutOverall") or 0
	self.Scout.Visible = report ~= ""
	if report ~= "" then
		self.Scout.Text = string.format("SCOUT REPORT  •  %s  •  %d/100\n%s", grade, overall, report)
	end
end

function UIController:Init()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "RoadToGloryHUD"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	self.Score = makeLabel(gui, "Score", UDim2.fromOffset(260, 42), UDim2.new(0.5, -130, 0, 18), 18)
	self.Clock = makeLabel(gui, "Clock", UDim2.fromOffset(100, 34), UDim2.new(0.5, -50, 0, 64), 16)
	self.Rating = makeLabel(gui, "Rating", UDim2.fromOffset(210, 40), UDim2.new(0, 18, 0, 18), 16)
	self.Cash = makeLabel(gui, "Cash", UDim2.fromOffset(145, 40), UDim2.new(0, 238, 0, 18), 15)
	self.Exploration = makeLabel(gui, "Exploration", UDim2.fromOffset(470, 34), UDim2.new(0, 18, 0, 66), 13)
	self.Exploration.TextXAlignment = Enum.TextXAlignment.Left
	self.Story = makeLabel(gui, "Story", UDim2.new(0.6, 0, 0, 92), UDim2.new(0.2, 0, 1, -120), 15)
	self.Story.TextWrapped = true

	self.Training = makeLabel(gui, "Training", UDim2.fromOffset(390, 126), UDim2.new(1, -410, 0, 105), 14)
	self.Training.TextWrapped = true
	self.Training.TextXAlignment = Enum.TextXAlignment.Left
	self.Training.TextYAlignment = Enum.TextYAlignment.Center

	self.Scout = makeLabel(gui, "Scout", UDim2.new(0.82, 0, 0, 84), UDim2.new(0.09, 0, 0, 112), 14)
	self.Scout.TextWrapped = true
	self.Scout.Visible = false

	for _, attribute in ipairs({
		"HomeScore", "AwayScore", "MatchTime", "ManagerRating", "CareerMoney", "CurrentHome", "StorySpeaker", "StoryText",
		"TrainingStage", "TrainingInstruction", "TrainingProgress", "TrainingScore",
		"ScoutReport", "ScoutGrade", "ScoutOverall", "ExplorationLocation", "ExplorationCount", "ExplorationTotal",
	}) do
		player:GetAttributeChangedSignal(attribute):Connect(function()
			self:Refresh()
		end)
	end
	self:Refresh()
end

return UIController
