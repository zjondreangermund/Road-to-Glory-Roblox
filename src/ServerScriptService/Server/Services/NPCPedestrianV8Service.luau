local RunService = game:GetService("RunService")

local NPCPedestrianV8Service = {
	Walkers = {},
}

local function pointInsideRoad(position, road, margin)
	margin = margin or 0
	return math.abs(position.X - road.Position.X) <= road.Size.X / 2 + margin
		and math.abs(position.Z - road.Position.Z) <= road.Size.Z / 2 + margin
end

local function safePoint(position, roads)
	for _, road in ipairs(roads) do
		if pointInsideRoad(position, road, 2.5) then return false end
	end
	return true
end

local function nearestRoad(position, roads)
	local best, bestDistance
	for _, road in ipairs(roads) do
		local dx = math.max(math.abs(position.X - road.Position.X) - road.Size.X / 2, 0)
		local dz = math.max(math.abs(position.Z - road.Position.Z) - road.Size.Z / 2, 0)
		local d = math.sqrt(dx * dx + dz * dz)
		if not bestDistance or d < bestDistance then
			best = road
			bestDistance = d
		end
	end
	return best
end

local function anchorMap(root)
	local map = {}
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj:GetAttribute("NPCAnchor") == true then
			local name = obj:GetAttribute("NPCName")
			if name then map[name] = obj end
		end
	end
	return map
end

local function routeFor(anchor, roads)
	local road = nearestRoad(anchor.Position, roads)
	if not road then return nil end
	local horizontal = road.Size.X > road.Size.Z
	local direction = horizontal and Vector3.new(1, 0, 0) or Vector3.new(0, 0, 1)
	local origin = anchor.Position

	for _, distance in ipairs({ 16, 12, 8 }) do
		local a = origin - direction * distance
		local b = origin + direction * distance
		if safePoint(a, roads) and safePoint(b, roads) then return a, b end
		if safePoint(origin, roads) and safePoint(b, roads) then return origin, b end
		if safePoint(a, roads) and safePoint(origin, roads) then return a, origin end
	end
	return nil
end

function NPCPedestrianV8Service:Build(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root then return end
	local folder = root:FindFirstChild("CareerNPCs")
	if not folder then return end
	local roads = worldBuilder.NPCSidewalkRoadsV8 or {}
	local anchors = anchorMap(root)
	self.Walkers = {}

	for _, model in ipairs(folder:GetChildren()) do
		if model:IsA("Model") and string.sub(model.Name, 1, 4) == "NPC_" then
			local name = string.sub(model.Name, 5)
			local anchor = anchors[name]
			if anchor and not anchor:GetAttribute("StoryAction") then
				local style = anchor:GetAttribute("NPCStyle") or "Resident"
				if style == "Resident" or style == "Staff" or style == "Executive" then
					local a, b = routeFor(anchor, roads)
					if a and b and (b - a).Magnitude >= 5 then
						local pivot = model:GetPivot()
						table.insert(self.Walkers, {
							Model = model,
							A = a,
							B = b,
							PivotY = pivot.Position.Y,
							Distance = (b - a).Magnitude,
							Speed = 1.7 + ((#name % 4) * 0.18),
							Phase = (#name % 7) * 0.37,
						})
						anchor:SetAttribute("PedestrianPatrolV8", true)
					end
				end
			end
		end
	end
	root:SetAttribute("AmbientSidewalkWalkersV8", #self.Walkers)
end

function NPCPedestrianV8Service:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	task.spawn(function()
		local root = worldBuilder.CareerWorldV5
		if not root then return end
		for _ = 1, 40 do
			if root:FindFirstChild("CareerNPCs") then break end
			task.wait(0.25)
		end
		self:Build(worldBuilder)
	end)

	RunService.Heartbeat:Connect(function()
		local now = os.clock()
		for i = #self.Walkers, 1, -1 do
			local walker = self.Walkers[i]
			local model = walker.Model
			if not model or not model.Parent then
				table.remove(self.Walkers, i)
			else
				local cycle = math.max((walker.Distance * 2) / walker.Speed, 4)
				local t = ((now + walker.Phase) % cycle) / cycle
				local forward = t <= 0.5
				local alpha = forward and (t * 2) or ((1 - t) * 2)
				local p = walker.A:Lerp(walker.B, alpha)
				local target = forward and walker.B or walker.A
				local pos = Vector3.new(p.X, walker.PivotY, p.Z)
				local look = Vector3.new(target.X, walker.PivotY, target.Z)
				if (look - pos).Magnitude > 0.2 then
					model:PivotTo(CFrame.lookAt(pos, look))
				end
			end
		end
	end)
end

return NPCPedestrianV8Service
