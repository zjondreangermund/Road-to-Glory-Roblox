local ReplicatedStorage = game:GetService("ReplicatedStorage")

local servicesFolder = script.Parent.Services
local WorldBuilder = require(servicesFolder.WorldBuilder)
local WorldMapV5Service = require(servicesFolder.WorldMapV5Service)
local WorldMapV5PolishService = require(servicesFolder.WorldMapV5PolishService)
local WorldCompletionV6Service = require(servicesFolder.WorldCompletionV6Service)
local WorldLightingV6Service = require(servicesFolder.WorldLightingV6Service)
local ExternalWorldAssetsService = require(servicesFolder.ExternalWorldAssetsService)
local CareerNPCPopulationV5Service = require(servicesFolder.CareerNPCPopulationV5Service)
local AvatarNPCV5Service = require(servicesFolder.AvatarNPCV5Service)
local VehicleServiceV5 = require(servicesFolder.VehicleServiceV5)
local PlayerDataService = require(servicesFolder.PlayerDataService)
local PropertyService = require(servicesFolder.PropertyService)
local RatingService = require(servicesFolder.RatingService)
local BallService = require(servicesFolder.BallService)
local MatchService = require(servicesFolder.MatchService)
local ChildhoodPracticeService = require(servicesFolder.ChildhoodPracticeService)
local StoryService = require(servicesFolder.StoryService)
local AIService = require(servicesFolder.AIService)
local TrainingService = require(servicesFolder.TrainingService)
local TrialMatchService = require(servicesFolder.TrialMatchService)
local ExplorationService = require(servicesFolder.ExplorationService)

local remotes = ReplicatedStorage:FindFirstChild("RoadToGloryRemotes") or Instance.new("Folder")
remotes.Name = "RoadToGloryRemotes"
remotes.Parent = ReplicatedStorage

local footballAction = remotes:FindFirstChild("FootballAction") or Instance.new("RemoteEvent")
footballAction.Name = "FootballAction"
footballAction.Parent = remotes

local trainingAction = remotes:FindFirstChild("TrainingAction") or Instance.new("RemoteEvent")
trainingAction.Name = "TrainingAction"
trainingAction.Parent = remotes

local startupFailures = {}
local function safeInit(label, callback)
	local ok, err = pcall(callback)
	if not ok then
		table.insert(startupFailures, label)
		warn("Road to Glory startup failure [" .. label .. "]: " .. tostring(err))
	end
	return ok
end

-- World-first build: stable coordinate layout, procedural/detail pass, lighting,
-- then vetted Creator Store 3D replacements BEFORE NPC/property/gameplay systems scan the world.
safeInit("WorldBuilder", function() WorldBuilder:Init() end)
safeInit("WorldMapV5", function() WorldMapV5Service:Init(WorldBuilder) end)
safeInit("WorldMapV5Polish", function() WorldMapV5PolishService:Init(WorldBuilder) end)
safeInit("WorldCompletionV6", function() WorldCompletionV6Service:Init(WorldBuilder) end)
safeInit("WorldLightingV6", function() WorldLightingV6Service:Init() end)
safeInit("ExternalWorldAssets", function() ExternalWorldAssetsService:Init(WorldBuilder) end)
safeInit("CareerNPCPopulationV5", function() CareerNPCPopulationV5Service:Init(WorldBuilder) end)

-- Existing gameplay remains available for testing, but story development stays frozen while the world is completed.
safeInit("PlayerData", function() PlayerDataService:Init() end)
safeInit("Property", function() PropertyService:Init(WorldBuilder, PlayerDataService) end)
safeInit("Rating", function() RatingService:Init() end)
safeInit("Ball", function() BallService:Init(WorldBuilder.Ball, footballAction) end)
safeInit("Match", function() MatchService:Init(WorldBuilder, RatingService) end)
safeInit("ChildhoodPractice", function() ChildhoodPracticeService:Init(WorldBuilder, BallService) end)
safeInit("Training", function() TrainingService:Init(WorldBuilder, BallService, trainingAction, footballAction) end)
safeInit("Story", function() StoryService:Init(WorldBuilder, PlayerDataService, ChildhoodPracticeService) end)
safeInit("TrialMatch", function() TrialMatchService:Init(WorldBuilder, BallService, RatingService, MatchService, PlayerDataService) end)
safeInit("Exploration", function() ExplorationService:Init(WorldBuilder) end)
safeInit("Vehicles", function() VehicleServiceV5:Init(WorldBuilder) end)
safeInit("AvatarNPCs", function() AvatarNPCV5Service:Init(WorldBuilder) end)
safeInit("AI", function() AIService:Init() end)

if #startupFailures == 0 then
	print("Road to Glory V0.7 external 3D residential world build initialized")
else
	warn("Road to Glory V0.7 initialized with recoverable failures: " .. table.concat(startupFailures, ", "))
end
