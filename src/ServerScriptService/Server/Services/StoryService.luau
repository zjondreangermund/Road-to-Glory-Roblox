local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StoryData = require(ReplicatedStorage.Shared.StoryData)

local StoryService = {}

local ORIGINS_ORDER = {
	WakeUp = 1,
	FamilyTalk = 2,
	CoachCall = 3,
	ChildhoodPracticeActive = 4,
	ChildhoodPractice = 5,
	BusRide = 6,
}

local ACADEMY_ORDER = {
	Arrival = 1,
	FirstTouch = 2,
	StadiumTravel = 3,
	TrialMatch = 4,
	ContractDecision = 5,
	ScoutReport = 6,
}

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

local function rankFor(chapter, stage)
	if chapter == "Origins" then return ORIGINS_ORDER[stage] or 0 end
	if chapter == "AcademyTrial" then return ACADEMY_ORDER[stage] or 0 end
	return 0
end

function StoryService:PersistStage(player, chapterName, stageName)
	if not self.PlayerDataService then return end
	local profile = self.PlayerDataService:Get(player)
	if not profile or not profile.Career then return end
	profile.Career.Chapter = chapterName
	profile.Career.Stage = stageName
end

function StoryService:SetStage(player, chapterName, stageName, allowRegression)
	local chapter = StoryData[chapterName]
	local stage = chapter and chapter.Stages[stageName]
	if not stage then return false end

	local currentChapter = player:GetAttribute("CareerChapter") or "Origins"
	local currentStage = player:GetAttribute("CareerStage") or "WakeUp"
	if not allowRegression and currentChapter == chapterName then
		local currentRank = rankFor(currentChapter, currentStage)
		local nextRank = rankFor(chapterName, stageName)
		if currentRank > 0 and nextRank > 0 and nextRank < currentRank then
			return false
		end
	end

	player:SetAttribute("CareerChapter", chapterName)
	player:SetAttribute("CareerStage", stageName)
	player:SetAttribute("StorySpeaker", stage.Speaker or "Narrator")
	player:SetAttribute("StoryText", stage.Text or "")
	player:SetAttribute("CareerObjective", stage.Objective or "")
	self:PersistStage(player, chapterName, stageName)
	return true
end

function StoryService:FindActionPosition(action)
	if not self.WorldBuilder or not self.WorldBuilder.Model then return nil end
	for _, node in ipairs(self.WorldBuilder.Model:GetDescendants()) do
		if node:IsA("BasePart") and node:GetAttribute("StoryAction") == action then
			return node.Position
		end
	end
	return nil
end

function StoryService:HandleAction(player, action)
	local chapter = player:GetAttribute("CareerChapter") or "Origins"
	local stage = player:GetAttribute("CareerStage") or "WakeUp"

	if action == "FamilyTalk" then
		if chapter ~= "Origins" then
			player:SetAttribute("StorySpeaker", "Mum")
			player:SetAttribute("StoryText", "I'm proud of you. Keep going — your football journey is already moving forward.")
		elseif stage == "WakeUp" then
			self:SetStage(player, "Origins", "FamilyTalk")
		elseif rankFor("Origins", stage) >= ORIGINS_ORDER.FamilyTalk then
			player:SetAttribute("StorySpeaker", "Mum")
			player:SetAttribute("StoryText", stage == "FamilyTalk" and "Coach Samuel is waiting at the old pitch. Go on — don't keep him waiting." or "You've already said goodbye. Finish what Coach Samuel asked and keep moving forward.")
		end
		return
	end

	if action == "CoachTalk" then
		if chapter ~= "Origins" then
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "You've moved beyond this old pitch now. Make every chance count.")
		elseif stage == "FamilyTalk" then
			self:SetStage(player, "Origins", "CoachCall")
		elseif stage == "CoachCall" then
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Use the Practice prompt on the dusty pitch. I want to see you on the ball, not just hear you talk about it.")
		elseif stage == "ChildhoodPracticeActive" then
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Keep going. Take the ball through all three PRACTICE gates in order.")
		elseif rankFor("Origins", stage) >= ORIGINS_ORDER.ChildhoodPractice then
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "You've done enough here. The academy bus is your next step.")
		else
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Talk to your family first. Big days should start at home.")
		end
		return
	end

	if action == "ChildhoodPractice" then
		if chapter ~= "Origins" then return end
		if stage == "CoachCall" then
			if self:SetStage(player, "Origins", "ChildhoodPracticeActive") then
				self.ChildhoodPracticeService:Start(player)
			end
		elseif stage == "ChildhoodPracticeActive" then
			self.ChildhoodPracticeService:Resume(player)
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Practice is still live. Continue from PRACTICE " .. tostring((player:GetAttribute("ChildhoodPracticeCheckpoint") or 0) + 1) .. ".")
		elseif rankFor("Origins", stage) >= ORIGINS_ORDER.ChildhoodPractice then
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Session finished. Head to the academy bus stop.")
		else
			player:SetAttribute("StorySpeaker", "Coach Samuel")
			player:SetAttribute("StoryText", "Come speak to me first before you start kicking a ball around.")
		end
		return
	end

	if action == "TravelAcademy" then
		if chapter ~= "Origins" or stage ~= "ChildhoodPractice" then
			player:SetAttribute("StorySpeaker", "Bus Driver")
			if stage == "ChildhoodPracticeActive" then
				player:SetAttribute("StoryText", "Coach says you're not finished. Complete all three practice checkpoints first.")
			else
				player:SetAttribute("StoryText", "Not yet. Finish your childhood story objective before we leave.")
			end
			return
		end
		self:SetStage(player, "Origins", "BusRide")
		local markers = self.WorldBuilder.StoryMarkers or {}
		task.delay(0.45, function()
			if player.Parent then
				teleportPlayer(player, markers.AcademyArrival or Vector3.new(-88, 3, -124), Vector3.new(0, 3, 0))
				self:SetStage(player, "AcademyTrial", "Arrival", true)
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
		if chapter == "AcademyTrial" and rankFor(chapter, stage) > ACADEMY_ORDER.TrialMatch then
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
				prompt.HoldDuration = (action == "TravelAcademy" or action == "TravelStadium") and 0.5 or 0
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
		local chapter = player:GetAttribute("CareerChapter")
		local stage = player:GetAttribute("CareerStage") or "Arrival"
		if overall > 0 and chapter == "AcademyTrial" and rankFor(chapter, stage) < ACADEMY_ORDER.StadiumTravel then
			self:SetStage(player, "AcademyTrial", "StadiumTravel")
		end
	end)
end

function StoryService:PlaceForCurrentStage(player)
	local markers = self.WorldBuilder.StoryMarkers or {}
	local chapter = player:GetAttribute("CareerChapter") or "Origins"
	local stage = player:GetAttribute("CareerStage") or "WakeUp"
	if chapter == "Origins" then
		if stage == "ChildhoodPracticeActive" and self.ChildhoodPracticeService then
			local spawn = self.ChildhoodPracticeService:GetPracticeSpawn()
			teleportPlayer(player, spawn, spawn + Vector3.new(0, 0, 20))
			player:SetAttribute("ExplorationLocation", "Childhood Pitch")
			self.ChildhoodPracticeService:Resume(player)
		elseif stage == "ChildhoodPractice" or stage == "BusRide" then
			local bus = self:FindActionPosition("TravelAcademy")
			teleportPlayer(player, (bus and bus + Vector3.new(0, 3, 5)) or markers.HomeSpawn or Vector3.new(-555, 3, -157), bus)
			player:SetAttribute("ExplorationLocation", "Origins Bus Stop")
		else
			teleportPlayer(player, markers.HomeSpawn or Vector3.new(-555, 3, -157), Vector3.new(-555, 3, -180))
			player:SetAttribute("ExplorationLocation", "Childhood Home")
			if stage == "WakeUp" or stage == "" then self:SetStage(player, "Origins", "WakeUp") end
		end
	elseif chapter == "AcademyTrial" and stage == "TrialMatch" then
		teleportPlayer(player, markers.StadiumArrival or Vector3.new(-88, 3, -421), markers.StadiumTunnel)
		player:SetAttribute("ExplorationLocation", "Stadium Approach")
	else
		teleportPlayer(player, markers.AcademyArrival or Vector3.new(-88, 3, -124), Vector3.new(0, 3, 0))
		player:SetAttribute("ExplorationLocation", "Academy Entrance")
	end
end

function StoryService:SetupPlayer(player)
	self:WatchTraining(player)
	local function place(character)
		local root = character:WaitForChild("HumanoidRootPart", 8)
		if not root then return end
		task.wait(0.15)
		self:PlaceForCurrentStage(player)
	end
	player.CharacterAdded:Connect(place)
	if player.Character then task.defer(place, player.Character) end
end

function StoryService:Init(worldBuilder, playerDataService, childhoodPracticeService)
	self.WorldBuilder = worldBuilder
	self.PlayerDataService = playerDataService
	self.ChildhoodPracticeService = childhoodPracticeService
	if childhoodPracticeService then
		childhoodPracticeService:SetCompletionHandler(function(player)
			self:SetStage(player, "Origins", "ChildhoodPractice")
		end)
	end
	self:ConnectWorldActions()
	Players.PlayerAdded:Connect(function(player) self:SetupPlayer(player) end)
	for _, player in ipairs(Players:GetPlayers()) do self:SetupPlayer(player) end
end

return StoryService
