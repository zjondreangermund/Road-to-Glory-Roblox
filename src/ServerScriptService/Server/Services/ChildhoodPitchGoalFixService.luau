local ChildhoodPitchGoalFixService = {}

local WHITE = Color3.fromRGB(244, 246, 247)
local NET = Color3.fromRGB(232, 237, 239)

local function part(parent, name, size, position, color, transparency, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color or WHITE
	p.Transparency = transparency or 0
	p.CanCollide = canCollide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function cfPart(parent, name, size, cframe, color, transparency, canCollide)
	local p = part(parent, name, size, cframe.Position, color, transparency, canCollide)
	p.CFrame = cframe
	return p
end

local function cylinderBetween(parent, name, a, b, radius, color, transparency, canCollide)
	local delta = b - a
	if delta.Magnitude < 0.001 then return nil end
	local right = delta.Unit
	local seedUp = math.abs(right:Dot(Vector3.yAxis)) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local back = right:Cross(seedUp).Unit
	local up = back:Cross(right).Unit
	local cf = CFrame.fromMatrix((a + b) / 2, right, up, back)
	local p = cfPart(parent, name, Vector3.new(delta.Magnitude, radius * 2, radius * 2), cf, color, transparency or 0, canCollide)
	p.Shape = Enum.PartType.Cylinder
	p.Material = Enum.Material.SmoothPlastic
	return p
end

local function netLine(parent, name, a, b)
	local delta = b - a
	if delta.Magnitude < 0.001 then return end
	local line = cfPart(parent, name, Vector3.new(0.028, 0.028, delta.Magnitude), CFrame.lookAt((a + b) / 2, b), NET, 0.82, false)
	line.Material = Enum.Material.SmoothPlastic
end

local function buildGoal(parent, name, centreX, frontZ, backSign, baseY)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent

	local width = 20
	local height = 7
	local depth = 4.8
	local rearHeight = 5.2
	local frontRadius = 0.18
	local rearRadius = 0.10
	local leftX = centreX - width / 2
	local rightX = centreX + width / 2
	local backZ = frontZ + (backSign * depth)

	-- Front frame: all round and planted on the pitch surface.
	cylinderBetween(goal, "LeftPost", Vector3.new(leftX, baseY, frontZ), Vector3.new(leftX, baseY + height, frontZ), frontRadius, WHITE, 0, true)
	cylinderBetween(goal, "RightPost", Vector3.new(rightX, baseY, frontZ), Vector3.new(rightX, baseY + height, frontZ), frontRadius, WHITE, 0, true)
	cylinderBetween(goal, "Crossbar", Vector3.new(leftX, baseY + height, frontZ), Vector3.new(rightX, baseY + height, frontZ), frontRadius, WHITE, 0, true)

	-- Thin rear supports, like the academy goals.
	cylinderBetween(goal, "RearLeft", Vector3.new(leftX, baseY, backZ), Vector3.new(leftX, baseY + rearHeight, backZ), rearRadius, WHITE, 0.05, false)
	cylinderBetween(goal, "RearRight", Vector3.new(rightX, baseY, backZ), Vector3.new(rightX, baseY + rearHeight, backZ), rearRadius, WHITE, 0.05, false)
	cylinderBetween(goal, "RearBar", Vector3.new(leftX, baseY + rearHeight, backZ), Vector3.new(rightX, baseY + rearHeight, backZ), rearRadius, WHITE, 0.05, false)
	cylinderBetween(goal, "LeftRoofSupport", Vector3.new(leftX, baseY + height, frontZ), Vector3.new(leftX, baseY + rearHeight, backZ), rearRadius, WHITE, 0.05, false)
	cylinderBetween(goal, "RightRoofSupport", Vector3.new(rightX, baseY + height, frontZ), Vector3.new(rightX, baseY + rearHeight, backZ), rearRadius, WHITE, 0.05, false)

	-- Light, soft-looking net rather than a rigid cage.
	for i = 0, 10 do
		local x = leftX + width * i / 10
		netLine(goal, "RearNetV" .. i, Vector3.new(x, baseY + 0.05, backZ), Vector3.new(x, baseY + rearHeight, backZ))
		netLine(goal, "RoofNetV" .. i, Vector3.new(x, baseY + height, frontZ), Vector3.new(x, baseY + rearHeight, backZ))
	end
	for i = 0, 6 do
		local y = baseY + rearHeight * i / 6
		netLine(goal, "RearNetH" .. i, Vector3.new(leftX, y, backZ), Vector3.new(rightX, y, backZ))
	end
	for i = 0, 5 do
		local t = i / 5
		local y = baseY + height + ((rearHeight - height) * t)
		local z = frontZ + ((backZ - frontZ) * t)
		netLine(goal, "RoofNetH" .. i, Vector3.new(leftX, y, z), Vector3.new(rightX, y, z))
	end
	for _, x in ipairs({ leftX, rightX }) do
		for i = 0, 5 do
			local t = i / 5
			local z = frontZ + ((backZ - frontZ) * t)
			local topY = baseY + height + ((rearHeight - height) * t)
			netLine(goal, "SideNetV" .. tostring(i), Vector3.new(x, baseY + 0.05, z), Vector3.new(x, topY, z))
		end
	end
end

function ChildhoodPitchGoalFixService:Init(worldBuilder)
	local village = worldBuilder.OriginsVillage
	if not village then return end
	local pitch = village:FindFirstChild("ChildhoodDustPitch", true)
	if not pitch or not pitch:IsA("BasePart") then return end

	-- Remove the old malformed cylinders/box crossbars from the V3 layout.
	for _, descendant in ipairs(village:GetDescendants()) do
		if descendant:IsA("BasePart") and (descendant.Name == "DustGoalPost" or descendant.Name == "DustCrossbar") then
			descendant:Destroy()
		end
	end
	local old = village:FindFirstChild("ChildhoodGoalsV4")
	if old then old:Destroy() end

	local goals = Instance.new("Model")
	goals.Name = "ChildhoodGoalsV4"
	goals.Parent = village
	local centre = pitch.Position
	local baseY = pitch.Position.Y + (pitch.Size.Y / 2)
	buildGoal(goals, "NorthChildhoodGoal", centre.X, centre.Z + 52, 1, baseY)
	buildGoal(goals, "SouthChildhoodGoal", centre.X, centre.Z - 52, -1, baseY)
end

return ChildhoodPitchGoalFixService
