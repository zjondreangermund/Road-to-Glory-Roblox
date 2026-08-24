local controllers = script.Parent.Controllers

local FootballController = require(controllers.FootballController)
local TrainingController = require(controllers.TrainingController)
local UIController = require(controllers.UIController)

UIController:Init()
FootballController:Init()
TrainingController:Init()

print("Road to Glory V0.2 client initialized")
