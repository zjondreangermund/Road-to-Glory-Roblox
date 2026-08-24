local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryData = require(ReplicatedStorage.Shared.StoryData)

local StoryService = {}

local function teleportPlayer(player, position, lookAt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not position then return end
	local target = position
	if lookAt then
		root.CFrame = CFrame.lookAt(target, Vector3.new(lookAt.X, target.Y, lookAt.Z))
	else
		root.CFrame = CFrame.new(target)
	end
end

function StoryService:SetStage(player, chapterName, stageName)
	local chapter = StoryData[chapterName]
	local stage = chapter and chapter.Stages[stageName]
	if not stage then return false end
	player:SetAttribute("CareerChapter", chapterName)
	player:SetAttribute("CareerStage", stageName)
	player:SetAttribute("StorySpeaker", stage.Speaker or "Narrator")
	player:SetAttribute("StoryText", stage.Text or "")
	player:SetAttribute("CareerObjective", stage.Objective or "")
	return true
end

function StoryService:HandleAction(player, action)
	local chapter = player:GetAttribute("CareerChapter") or "Origins"
	local stage = player:GetAttribute("CareerStage") or "WakeUp"

	if action == "FamilyTalk" then
		if chapter == "Origins" and (stage == "WakeUp" or stage == "FamilyTalk") then
			self:SetStage(player, "Origins", "FamilyTalk")
		else
			player:SetAttribute("StorySpeaker", "Mum")
			player:SetAttribute("StoryText", "You know where I am. Go make the most of your chance.")
		end
		return
	end

	if action == "CoachTalk" then
		if chapter == "Origins" and (stage == "FamilyTalk" or stage == "CoachCall") then
			self:SetStage(player, "Origins", "CoachCall")
		else
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Talk to your family first. Big days should start at home.")
		end
		return
	end

	if action == "ChildhoodPractice" then
		if chapter == "Origins" and (stage == "CoachCall" or stage == "ChildhoodPractice") then
			self:SetStage(player, "Origins", "ChildhoodPractice")
		else
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Come see me before you leave. I want one last look at you on this pitch.")
		end
		return
	end

	if action == "TravelAcademy" then
		if chapter ~= "Origins" or stage ~= "ChildhoodPractice" then
			player:SetAttribute("StorySpeaker", "Bus Driver")
			player:SetAttribute("StoryText", "You're early. Finish what you need to do in the neighbourhood before we leave.")
			return
		end
		self:SetStage(player, "Origins", "BusRide")
		local markers = self.WorldBuilder.StoryMarkers or {}
		task.delay(0.45, function()
			if player.Parent then
				teleportPlayer(player, markers.AcademyArrival or Vector3.new(-88, 3, -124), Vector3.new(0, 3, 0))
				self:SetStage(player, "AcademyTrial", "Arrival")
				player:SetAttribute("ExplorationLocation", "Academy Entrance")
			end
		end)
		return
	end

	if action == "TravelStadium" then
		local scoutOverall = player:GetAttribute("ScoutOverall") or 0
		if scoutOverall <= 0 then
			player:SetAttribute("StorySpeaker", "Coach Daniels")
			player:SetAttribute("StoryText", "Not yet. Complete the academy assessment first, then we'll take the team bus to the stadium.")
			player:SetAttribute("CareerObjective", "Complete the Academy Training assessment.")
			return
		end
		self:SetStage(player, "AcademyTrial", "TrialMatch")
		local markers = self.WorldBuilder.StoryMarkers or {}
		task.delay(0.35, function()
			if player.Parent then
				teleportPlayer(player, markers.StadiumArrival or Vector3.new(-88, 3, -421), markers.StadiumTunnel)
				player:SetAttribute("ExplorationLocation", "Stadium Approach")
			end
		end)
		return
	end
end

function StoryService:ConnectWorldActions()
	for _, node in ipairs(self.WorldBuilder.Model:GetDescendants()) do
		if node:IsA("BasePart") and node:GetAttribute("StoryAction") then
			local action = node:GetAttribute("StoryAction")
			if action ~= "StartTrialMatch" then
				local prompt = node:FindFirstChild("StoryPrompt") or Instance.new("ProximityPrompt")
				prompt.Name = "StoryPrompt"
				prompt.ActionText = node:GetAttribute("StoryPrompt") or "Talk"
				prompt.ObjectText = node:GetAttribute("StoryTitle") or "Story"
				prompt.HoldDuration = action == "TravelAcademy" or action == "TravelStadium" and 0.5 or 0
				prompt.MaxActivationDistance = 10
				prompt.RequiresLineOfSight = false
				prompt.Parent = node
				prompt.Triggered:Connect(function(player)
					self:HandleAction(player, action)
				end)
			end
		end
	end
end

function StoryService:WatchTraining(player)
	player:GetAttributeChangedSignal("ScoutOverall"):Connect(function()
		local overall = player:GetAttribute("ScoutOverall") or 0
		if overall > 0 and player:GetAttribute("CareerChapter") == "AcademyTrial" then
			self:SetStage(player, "AcademyTrial", "StadiumTravel")
		end
	end)
end

function StoryService:SetupPlayer(player)
	player:SetAttribute("CareerObjective", "")
	self:WatchTraining(player)
	local function placeAtOrigins(character)
		local root = character:WaitForChild("HumanoidRootPart", 8)
		if not root then return end
		task.wait(0.15)
		local markers = self.WorldBuilder.StoryMarkers or {}
		teleportPlayer(player, markers.HomeSpawn or Vector3.new(-555, 3, -157), Vector3.new(-555, 3, -180))
		self:SetStage(player, "Origins", "WakeUp")
		player:SetAttribute("ExplorationLocation", "Childhood Home")
	end
	player.CharacterAdded:Connect(placeAtOrigins)
	if player.Character then task.defer(placeAtOrigins, player.Character) end
end

function StoryService:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	self:ConnectWorldActions()
	Players.PlayerAdded:Connect(function(player) self:SetupPlayer(player) end)
	for _, player in ipairs(Players:GetPlayers()) do self:SetupPlayer(player) end
end

return StoryService
