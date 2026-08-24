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

function BallService:Kick(player, direction, power, lift)
	if not self:CanTouchBall(player) or typeof(direction) ~= "Vector3" then
		return
	end
	self.Dribblers[player] = nil
	local kickDirection = flatUnit(direction)
	self.Ball:SetAttribute("LastTouchUserId", player.UserId)
	pcall(function()
		self.Ball:SetNetworkOwner(nil)
	end)
	self.Ball.AssemblyLinearVelocity = (kickDirection * power) + Vector3.new(0, lift, 0)
end

function BallService:SetDribbling(player, enabled)
	if enabled and self:CanTouchBall(player) then
		self.Dribblers[player] = true
		pcall(function()
			self.Ball:SetNetworkOwner(nil)
		end)
	else
		self.Dribblers[player] = nil
	end
end

function BallService:UpdateDribble(player)
	local root = self:GetRoot(player)
	if not root or not self.Ball or not self.Ball.Parent then
		self.Dribblers[player] = nil
		return
	end

	local distance = (root.Position - self.Ball.Position).Magnitude
	if distance > GameConfig.Football.DribbleBreakDistance then
		self.Dribblers[player] = nil
		return
	end

	local direction = getControlDirection(player, root)
	local targetY = math.max(1.6, root.Position.Y - 1.9)
	local target = Vector3.new(
		root.Position.X + (direction.X * GameConfig.Football.DribbleDistance),
		targetY,
		root.Position.Z + (direction.Z * GameConfig.Football.DribbleDistance)
	)

	local relative = self.Ball.Position - root.Position
	local planarRelative = Vector3.new(relative.X, 0, relative.Z)
	local isBehind = planarRelative.Magnitude > 0.1 and planarRelative.Unit:Dot(direction) < -0.05

	-- If the player has run past the ball, recover it immediately to the front.
	-- This prevents the prototype dribble from trailing behind the character.
	if isBehind or distance > GameConfig.Football.DribbleCatchupDistance then
		self.Ball.CFrame = CFrame.new(target)
		self.Ball.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
		self.Ball.AssemblyAngularVelocity = Vector3.zero
	else
		local delta = target - self.Ball.Position
		local velocity = Vector3.new(
			(delta.X * GameConfig.Football.DribbleResponsiveness) + (root.AssemblyLinearVelocity.X * 0.45),
			self.Ball.AssemblyLinearVelocity.Y,
			(delta.Z * GameConfig.Football.DribbleResponsiveness) + (root.AssemblyLinearVelocity.Z * 0.45)
		)
		local flatVelocity = Vector3.new(velocity.X, 0, velocity.Z)
		if flatVelocity.Magnitude > GameConfig.Football.DribbleMaxSpeed then
			flatVelocity = flatVelocity.Unit * GameConfig.Football.DribbleMaxSpeed
			velocity = Vector3.new(flatVelocity.X, velocity.Y, flatVelocity.Z)
		end
		self.Ball.AssemblyLinearVelocity = velocity
	end

	self.Ball:SetAttribute("LastTouchUserId", player.UserId)
end

function BallService:Init(ball, actionRemote)
	self.Ball = ball
	self.Remote = actionRemote

	actionRemote.OnServerEvent:Connect(function(player, action, payload)
		if action == "Shoot" then
			local direction = typeof(payload) == "Vector3" and payload or Vector3.new(0, 0, -1)
			self:Kick(player, direction, GameConfig.Football.ShootPower, GameConfig.Football.ShootLift)
		elseif action == "Pass" then
			local direction = typeof(payload) == "Vector3" and payload or Vector3.new(0, 0, -1)
			self:Kick(player, direction, GameConfig.Football.PassPower, GameConfig.Football.PassLift)
		elseif action == "Dribble" then
			self:SetDribbling(player, payload == true)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.Dribblers[player] = nil
	end)

	RunService.Heartbeat:Connect(function()
		for player in pairs(self.Dribblers) do
			self:UpdateDribble(player)
		end
	end)
end

return BallService
