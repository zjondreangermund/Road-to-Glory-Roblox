local controllers = script.Parent.Controllers

local FootballController = require(controllers.FootballController)
local UIController = require(controllers.UIController)

UIController:Init()
FootballController:Init()

print("Road to Glory V0.1 client initialized")
