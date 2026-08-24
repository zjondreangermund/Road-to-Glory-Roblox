local ReplicatedStorage = game:GetService("ReplicatedStorage")

local servicesFolder = script.Parent.Services
local WorldBuilder = require(servicesFolder.WorldBuilder)
local EnvironmentExpansionService = require(servicesFolder.EnvironmentExpansionService)
local CareerWorldV2Service = require(servicesFolder.CareerWorldV2Service)
local CareerWorldPolishService = require(servicesFolder.CareerWorldPolishService)
local WorldLayoutV3Service = require(servicesFolder.WorldLayoutV3Service)
local PlayerDataService = require(servicesFolder.PlayerDataService)
local PropertyService = require(servicesFolder.PropertyService)
local RatingService = require(servicesFolder.RatingService)
local BallService = require(servicesFolder.BallService)
local MatchService = require(servicesFolder.MatchService)
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

WorldBuilder:Init()
-- Build the original academy/stadium, retain trophy polish, then replace the rural layout with the clean V3 district.
EnvironmentExpansionService:Init(WorldBuilder)
CareerWorldV2Service:Init(WorldBuilder)
CareerWorldPolishService:Init(WorldBuilder)
WorldLayoutV3Service:Init(WorldBuilder)

PlayerDataService:Init()
PropertyService:Init(WorldBuilder, PlayerDataService)
RatingService:Init()
BallService:Init(WorldBuilder.Ball, footballAction)
MatchService:Init(WorldBuilder, RatingService)
TrainingService:Init(WorldBuilder, BallService, trainingAction, footballAction)
StoryService:Init(WorldBuilder)
TrialMatchService:Init(WorldBuilder, BallService, RatingService, MatchService, PlayerDataService)
AIService:Init()
ExplorationService:Init(WorldBuilder)

print("Road to Glory V0.3 childhood opening + trial match initialized")
