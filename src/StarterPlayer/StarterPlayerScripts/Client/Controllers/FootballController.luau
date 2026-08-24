local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FootballController = {
	Dribbling = false,
}

local function flatUnit(vector)
	local flat = Vector3.new(vector.X, 0, vector.Z)
	if flat.Magnitude < 0.01 then return nil end
	return flat.Unit
end

local function getKickDirection()
	local character = Players.LocalPlayer.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local moveDirection = flatUnit(humanoid.MoveDirection)
		if moveDirection then return moveDirection end
	end
	if root then
		local facingDirection = flatUnit(root.CFrame.LookVector)
		if facingDirection then return facingDirection end
	end
	return Vector3.new(0, 0, -1)
end

function FootballController:BindAction(name, title, keyCode, position, callback)
	ContextActionService:BindAction(name, callback, true, keyCode)
	ContextActionService:SetTitle(name, title)
	ContextActionService:SetPosition(name, position)
end

function FootballController:SetLocalDribbling(enabled, notifyServer)
	self.Dribbling = enabled
	if notifyServer and self.Remote then
		self.Remote:FireServer("Dribble", enabled)
	end
end

function FootballController:Init()
	local remotes = ReplicatedStorage:WaitForChild("RoadToGloryRemotes")
	self.Remote = remotes:WaitForChild("FootballAction")
	local player = Players.LocalPlayer

	self:BindAction("RTG_Shoot", "SHOOT", Enum.KeyCode.E, UDim2.fromScale(0.86, 0.72), function(_, state)
		if state == Enum.UserInputState.Begin then
			self:SetLocalDribbling(false, false)
			self.Remote:FireServer("Shoot", getKickDirection())
		end
	end)

	self:BindAction("RTG_Pass", "PASS", Enum.KeyCode.Q, UDim2.fromScale(0.73, 0.79), function(_, state)
		if state == Enum.UserInputState.Begin then
			self:SetLocalDribbling(false, false)
			self.Remote:FireServer("Pass", getKickDirection())
		end
	end)

	self:BindAction("RTG_Dribble", "DRIBBLE", Enum.KeyCode.F, UDim2.fromScale(0.86, 0.84), function(_, state)
		if state == Enum.UserInputState.Begin then
			self:SetLocalDribbling(not self.Dribbling, true)
		end
	end)

	player:GetAttributeChangedSignal("TrainingStage"):Connect(function()
		-- Each drill transition begins with a clean local possession state.
		self:SetLocalDribbling(false, false)
	end)
end

return FootballController
