local ReplicatedStorage = game:GetService("ReplicatedStorage")

local servicesFolder = script.Parent.Services
local WorldBuilder = require(servicesFolder.WorldBuilder)
local EnvironmentExpansionService = require(servicesFolder.EnvironmentExpansionService)
local CareerWorldV2Service = require(servicesFolder.CareerWorldV2Service)
local PlayerDataService = require(servicesFolder.PlayerDataService)
local PropertyService = require(servicesFolder.PropertyService)
local RatingService = require(servicesFolder.RatingService)
local BallService = require(servicesFolder.BallService)
local MatchService = require(servicesFolder.MatchService)
local StoryService = require(servicesFolder.StoryService)
local AIService = require(servicesFolder.AIService)
local TrainingService = require(servicesFolder.TrainingService)
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
-- Build all world geometry before goal, exploration and property services scan the map.
EnvironmentExpansionService:Init(WorldBuilder)
CareerWorldV2Service:Init(WorldBuilder)
PlayerDataService:Init()
PropertyService:Init(WorldBuilder, PlayerDataService)
RatingService:Init()
BallService:Init(WorldBuilder.Ball, footballAction)
MatchService:Init(WorldBuilder, RatingService)
StoryService:Init()
AIService:Init()
TrainingService:Init(WorldBuilder, BallService, trainingAction, footballAction)
ExplorationService:Init(WorldBuilder)

print("Road to Glory V0.2 rural origins + career world initialized")
