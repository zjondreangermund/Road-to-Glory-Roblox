local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TrainingController = {}

function TrainingController:Init()
	local remotes = ReplicatedStorage:WaitForChild("RoadToGloryRemotes")
	local trainingRemote = remotes:WaitForChild("TrainingAction")

	ContextActionService:BindAction("RTG_Training", function(_, state)
		if state == Enum.UserInputState.Begin then
			trainingRemote:FireServer("StartTraining")
		end
	end, true, Enum.KeyCode.T)
	ContextActionService:SetTitle("RTG_Training", "TRAINING")
	ContextActionService:SetPosition("RTG_Training", UDim2.fromScale(0.12, 0.76))
end

return TrainingController
