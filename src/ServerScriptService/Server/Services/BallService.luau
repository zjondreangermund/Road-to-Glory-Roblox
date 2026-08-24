local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local BallService = {
	Dribblers = {},
}

local function flatUnit(vector)
	local flat = Vector3.new(vector.X, 0, vector.Z)
	if flat.Magnitude < 0.01 then
		return Vector3.new(0, 0, -1)
	end
	return flat.Unit
end

local function getControlDirection(player, root)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local move = Vector3.new(humanoid.MoveDirection.X, 0, humanoid.MoveDirection.Z)
		if move.Magnitude > 0.05 then
			return move.Unit
		end
	end
	return flatUnit(root.CFrame.LookVector)
end

function BallService:GetRoot(player)
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

function BallService:CanTouchBall(player)
	local root = self:GetRoot(player)
	if not root or not self.Ball or not self.Ball.Parent then
		return false
	end
	return (root.Position - self.Ball.Position).Magnitude <= GameConfig.Football.KickDistance
end

function BallService:ReleaseAllDribblers()
	for player in pairs(self.Dribblers) do
		self.Dribblers[player] = nil
	end
	if self.Ball then
		self.Ball:SetAttribute("DribbleOwnerUserId", 0)
	end
end

function BallService:Kick(player, direction, power, lift, actionName)
	if not self:CanTouchBall(player) or typeof(direction) ~= "Vector3" then
		return
	end
	self:SetDribbling(player, false)
	local kickDirection = flatUnit(direction)
	self.Ball:SetAttribute("LastTouchUserId", player.UserId)
	self.Ball:SetAttribute("LastAction", actionName or "Kick")
	pcall(function()
		self.Ball:SetNetworkOwner(nil)
	end)
	self.Ball.AssemblyLinearVelocity = (kickDirection * power) + Vector3.new(0, lift, 0)
end

function BallService:SetDribbling(player, enabled)
	if enabled and self:CanTouchBall(player) then
		self.Dribblers[player] = true
		self.Ball:SetAttribute("DribbleOwnerUserId", player.UserId)
		self.Ball:SetAttribute("LastAction", "Dribble")
		pcall(function()
			self.Ball:SetNetworkOwner(nil)
		end)
	else
		self.Dribblers[player] = nil
		if self.Ball and self.Ball:GetAttribute("DribbleOwnerUserId") == player.UserId then
			self.Ball:SetAttribute("DribbleOwnerUserId", 0)
		end
	end
end

function BallService:UpdateDribble(player)
	local root = self:GetRoot(player)
	if not root or not self.Ball or not self.Ball.Parent then
		self:SetDribbling(player, false)
		return
	end

	local distance = (root.Position - self.Ball.Position).Magnitude
	if distance > GameConfig.Football.DribbleBreakDistance then
		self:SetDribbling(player, false)
		return
	end

	local direction = getControlDirection(player, root)
	local targetY = math.max(1.6, root.Position.Y + GameConfig.Football.DribbleHeightOffset)
	local target = Vector3.new(
		root.Position.X + (direction.X * GameConfig.Football.DribbleDistance),
		targetY,
		root.Position.Z + (direction.Z * GameConfig.Football.DribbleDistance)
	)

	-- Prototype close control: keep the ball at the footballer's front foot every frame.
	-- This removes the physics lag that allowed the character to run ahead of the ball.
	self.Ball.CFrame = CFrame.new(target)
	self.Ball.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
	self.Ball.AssemblyAngularVelocity = Vector3.zero
	self.Ball:SetAttribute("LastTouchUserId", player.UserId)
	self.Ball:SetAttribute("DribbleOwnerUserId", player.UserId)
	self.Ball:SetAttribute("LastAction", "Dribble")
end

function BallService:Init(ball, actionRemote)
	self.Ball = ball
	self.Remote = actionRemote
	ball:SetAttribute("DribbleOwnerUserId", 0)
	ball:SetAttribute("LastAction", "None")
	ball:SetAttribute("TrainingMode", false)

	actionRemote.OnServerEvent:Connect(function(player, action, payload)
		if action == "Shoot" then
			local direction = typeof(payload) == "Vector3" and payload or Vector3.new(0, 0, -1)
			self:Kick(player, direction, GameConfig.Football.ShootPower, GameConfig.Football.ShootLift, "Shoot")
		elseif action == "Pass" then
			local direction = typeof(payload) == "Vector3" and payload or Vector3.new(0, 0, -1)
			self:Kick(player, direction, GameConfig.Football.PassPower, GameConfig.Football.PassLift, "Pass")
		elseif action == "Dribble" then
			self:SetDribbling(player, payload == true)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:SetDribbling(player, false)
	end)

	RunService.Heartbeat:Connect(function()
		for player in pairs(self.Dribblers) do
			self:UpdateDribble(player)
		end
	end)
end

return BallService
