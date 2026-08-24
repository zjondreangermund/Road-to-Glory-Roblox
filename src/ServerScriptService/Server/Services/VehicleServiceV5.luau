local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local VehicleServiceV5 = {
	States = {},
}

local function getModel(seat)
	local current = seat.Parent
	while current and not current:GetAttribute("RTGVehicle") do
		current = current.Parent
	end
	return current
end

local function getPlayerFromHumanoid(humanoid)
	local character = humanoid and humanoid.Parent
	return character and Players:GetPlayerFromCharacter(character) or nil
end

function VehicleServiceV5:RegisterSeat(seat)
	if not seat:IsA("VehicleSeat") or seat:GetAttribute("RTGVehicleSeat") ~= true then
		return
	end
	local model = getModel(seat)
	if not model or not model:IsA("Model") or not model.PrimaryPart then
		return
	end
	if self.States[seat] then
		return
	end

	local vehicleType = model:GetAttribute("VehicleType") or "Car"
	local state = {
		Seat = seat,
		Model = model,
		Speed = 0,
		MaxSpeed = vehicleType == "Bike" and 58 or 72,
		ReverseSpeed = vehicleType == "Bike" and 16 or 24,
		Acceleration = vehicleType == "Bike" and 42 or 34,
		Brake = 48,
		TurnRate = vehicleType == "Bike" and 1.8 or 1.35,
		VehicleType = vehicleType,
	}
	self.States[seat] = state

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "VehicleEnterPrompt"
	prompt.ActionText = vehicleType == "Bike" and "Ride" or "Drive"
	prompt.ObjectText = model:GetAttribute("VehicleName") or vehicleType
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0.15
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = seat

	prompt.Triggered:Connect(function(player)
		if seat.Occupant then
			return
		end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		seat:Sit(humanoid)
		player:SetAttribute("StorySpeaker", vehicleType == "Bike" and "Motorbike" or "Vehicle")
		player:SetAttribute("StoryText", "Use W/S to accelerate or reverse and A/D to steer. Press jump to get out.")
	end)

	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = seat.Occupant
		local driver = occupant and getPlayerFromHumanoid(occupant) or nil
		model:SetAttribute("DriverUserId", driver and driver.UserId or 0)
		prompt.Enabled = occupant == nil
		if not occupant then
			state.Speed = 0
		end
	end)
end

function VehicleServiceV5:UpdateState(state, dt)
	local seat = state.Seat
	local model = state.Model
	if not seat.Parent or not model.Parent or not seat.Occupant then
		return
	end

	local throttle = seat.ThrottleFloat
	local steer = seat.SteerFloat
	local targetSpeed = 0
	if throttle > 0.05 then
		targetSpeed = state.MaxSpeed * throttle
	elseif throttle < -0.05 then
		targetSpeed = state.ReverseSpeed * throttle
	end

	local delta = targetSpeed - state.Speed
	local rate = math.abs(targetSpeed) < math.abs(state.Speed) and state.Brake or state.Acceleration
	local step = math.clamp(delta, -rate * dt, rate * dt)
	state.Speed += step
	if math.abs(state.Speed) < 0.08 and math.abs(targetSpeed) < 0.08 then
		state.Speed = 0
	end

	local pivot = model:GetPivot()
	local turnScale = math.clamp(math.abs(state.Speed) / 12, 0.25, 1)
	local reverseSign = state.Speed < -0.1 and -1 or 1
	local yaw = -steer * state.TurnRate * turnScale * reverseSign * dt
	local rotated = pivot * CFrame.Angles(0, yaw, 0)
	local forward = rotated.LookVector
	local nextPosition = rotated.Position + (forward * state.Speed * dt)
	nextPosition = Vector3.new(
		math.clamp(nextPosition.X, -1850, 1850),
		rotated.Position.Y,
		math.clamp(nextPosition.Z, -1250, 1150)
	)
	model:PivotTo(CFrame.lookAt(nextPosition, nextPosition + forward))
end

function VehicleServiceV5:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	for _, descendant in ipairs(worldBuilder.Model:GetDescendants()) do
		if descendant:IsA("VehicleSeat") and descendant:GetAttribute("RTGVehicleSeat") == true then
			self:RegisterSeat(descendant)
		end
	end

	worldBuilder.Model.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("VehicleSeat") and descendant:GetAttribute("RTGVehicleSeat") == true then
			task.defer(function()
				if descendant.Parent then self:RegisterSeat(descendant) end
			end)
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for seat, state in pairs(self.States) do
			if not seat.Parent then
				self.States[seat] = nil
			else
				self:UpdateState(state, math.min(dt, 0.05))
			end
		end
	end)
end

return VehicleServiceV5
