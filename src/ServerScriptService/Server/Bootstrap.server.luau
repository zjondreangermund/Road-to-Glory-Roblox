local ReplicatedStorage = game:GetService("ReplicatedStorage")

local servicesFolder = script.Parent.Services
local WorldBuilder = require(servicesFolder.WorldBuilder)
local WorldMapV5Service = require(servicesFolder.WorldMapV5Service)
local WorldMapV5PolishService = require(servicesFolder.WorldMapV5PolishService)
local CareerNPCPopulationV5Service = require(servicesFolder.CareerNPCPopulationV5Service)
local AvatarNPCV5Service = require(servicesFolder.AvatarNPCV5Service)
local VehicleServiceV5 = require(servicesFolder.VehicleServiceV5)
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

-- V5 deliberately uses one world plan instead of stacking V2/V3/V4 geometry.
-- This prevents duplicate districts, overlapping stadiums and road furniture from older runtime passes.
WorldBuilder:Init()
WorldMapV5Service:Init(WorldBuilder)
WorldMapV5PolishService:Init(WorldBuilder)
CareerNPCPopulationV5Service:Init(WorldBuilder)

-- Gameplay scans only after the final road/building/NPC-anchor map exists.
PlayerDataService:Init()
PropertyService:Init(WorldBuilder, PlayerDataService)
RatingService:Init()
BallService:Init(WorldBuilder.Ball, footballAction)
MatchService:Init(WorldBuilder, RatingService)
TrainingService:Init(WorldBuilder, BallService, trainingAction, footballAction)
StoryService:Init(WorldBuilder)
TrialMatchService:Init(WorldBuilder, BallService, RatingService, MatchService, PlayerDataService)
ExplorationService:Init(WorldBuilder)
VehicleServiceV5:Init(WorldBuilder)
AvatarNPCV5Service:Init(WorldBuilder)
AIService:Init()

print("Road to Glory V0.5 unified career world + vehicles + avatar NPCs initialized")
