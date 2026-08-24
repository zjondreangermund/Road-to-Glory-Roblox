local Players = game:GetService("Players")

local WorldRealismV4Service = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Dark = Color3.fromRGB(29, 33, 38),
	Navy = Color3.fromRGB(24, 40, 64),
	Steel = Color3.fromRGB(74, 82, 89),
	Concrete = Color3.fromRGB(177, 180, 182),
	Road = Color3.fromRGB(52, 55, 58),
	Grass = Color3.fromRGB(62, 112, 60),
	Dirt = Color3.fromRGB(143, 113, 79),
	Glass = Color3.fromRGB(127, 180, 202),
	Blue = Color3.fromRGB(48, 103, 181),
	Red = Color3.fromRGB(191, 55, 57),
	Amber = Color3.fromRGB(237, 178, 50),
	Green = Color3.fromRGB(61, 179, 84),
	Wood = Color3.fromRGB(111, 77, 49),
	SkinA = Color3.fromRGB(207, 166, 127),
	SkinB = Color3.fromRGB(152, 104, 73),
	SkinC = Color3.fromRGB(104, 70, 52),
}

local function part(parent, name, size, position, color, transparency, canCollide)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = position
	p.Color = color or C.White
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

local function surfaceText(target, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face or Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 260)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or C.White
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
	return label
end

local function storyNode(parent, action, title, position, prompt)
	local node = part(parent, "Story_" .. action, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("StoryAction", action)
	node:SetAttribute("StoryTitle", title)
	node:SetAttribute("StoryPrompt", prompt or "Talk")
	return node
end

local function explorationNode(parent, id, title, position, speaker, text, prompt)
	local node = part(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", prompt or "Explore")
	return node
end

local function propertyNode(parent, id, displayName, price, position)
	local node = part(parent, "PropertyNode", Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("PropertyId", id)
	node:SetAttribute("PropertyName", displayName)
	node:SetAttribute("PropertyPrice", price)
	return node
end

local function markRoadSafe(p)
	p:SetAttribute("RoadSafe", true)
	return p
end

local function roadEW(parent, roads, name, x1, x2, z, width)
	width = width or 26
	local length = math.abs(x2 - x1)
	local cx = (x1 + x2) / 2
	local road = markRoadSafe(part(parent, name, Vector3.new(length, 0.38, width), Vector3.new(cx, 0.08, z), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	road:SetAttribute("RoadSurface", true)
	for x = math.min(x1, x2) + 10, math.max(x1, x2) - 10, 18 do
		local line = markRoadSafe(part(parent, name .. "CentreLine", Vector3.new(8, 0.05, 0.24), Vector3.new(x, 0.3, z), Color3.fromRGB(235, 220, 151), 0, false))
		line:SetAttribute("RoadMarking", true)
	end
	for _, side in ipairs({ -1, 1 }) do
		local edge = markRoadSafe(part(parent, name .. "EdgeLine", Vector3.new(length, 0.05, 0.18), Vector3.new(cx, 0.3, z + side * (width / 2 - 0.7)), C.White, 0, false))
		edge:SetAttribute("RoadMarking", true)
		local curb = markRoadSafe(part(parent, name .. "Curb", Vector3.new(length, 0.42, 0.7), Vector3.new(cx, 0.34, z + side * (width / 2 + 0.45)), C.Concrete, 0, true))
		curb.Material = Enum.Material.Concrete
		local walk = markRoadSafe(part(parent, name .. "Sidewalk", Vector3.new(length, 0.32, 5.5), Vector3.new(cx, 0.2, z + side * (width / 2 + 3.5)), C.Concrete, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	table.insert(roads, { Axis = "X", Min = math.min(x1, x2), Max = math.max(x1, x2), Centre = z, Width = width })
	return road
end

local function roadNS(parent, roads, name, x, z1, z2, width)
	width = width or 26
	local length = math.abs(z2 - z1)
	local cz = (z1 + z2) / 2
	local road = markRoadSafe(part(parent, name, Vector3.new(width, 0.38, length), Vector3.new(x, 0.08, cz), C.Road, 0, true))
	road.Material = Enum.Material.Asphalt
	road:SetAttribute("RoadSurface", true)
	for z = math.min(z1, z2) + 10, math.max(z1, z2) - 10, 18 do
		local line = markRoadSafe(part(parent, name .. "CentreLine", Vector3.new(0.24, 0.05, 8), Vector3.new(x, 0.3, z), Color3.fromRGB(235, 220, 151), 0, false))
		line:SetAttribute("RoadMarking", true)
	end
	for _, side in ipairs({ -1, 1 }) do
		local edge = markRoadSafe(part(parent, name .. "EdgeLine", Vector3.new(0.18, 0.05, length), Vector3.new(x + side * (width / 2 - 0.7), 0.3, cz), C.White, 0, false))
		edge:SetAttribute("RoadMarking", true)
		local curb = markRoadSafe(part(parent, name .. "Curb", Vector3.new(0.7, 0.42, length), Vector3.new(x + side * (width / 2 + 0.45), 0.34, cz), C.Concrete, 0, true))
		curb.Material = Enum.Material.Concrete
		local walk = markRoadSafe(part(parent, name .. "Sidewalk", Vector3.new(5.5, 0.32, length), Vector3.new(x + side * (width / 2 + 3.5), 0.2, cz), C.Concrete, 0, true))
		walk.Material = Enum.Material.Concrete
	end
	table.insert(roads, { Axis = "Z", Min = math.min(z1, z2), Max = math.max(z1, z2), Centre = x, Width = width })
	return road
end

local function crosswalkEW(parent, x, z, width)
	for i = -4, 4 do
		local stripe = markRoadSafe(part(parent, "CrosswalkStripe", Vector3.new(1.2, 0.05, width - 2), Vector3.new(x + i * 2.3, 0.32, z), C.White, 0, false))
		stripe:SetAttribute("RoadMarking", true)
	end
end

local function streetLight(parent, position, facePoint)
	local model = Instance.new("Model")
	model.Name = "StreetLight"
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
	local pole = cfPart(model, "Pole", Vector3.new(0.45, 10, 0.45), base * CFrame.new(0, 5, 0), C.Steel, 0, true)
	pole.Material = Enum.Material.Metal
	local arm = cfPart(model, "Arm", Vector3.new(0.36, 0.36, 3.8), base * CFrame.new(0, 9.5, -1.7), C.Steel, 0, false)
	arm.Material = Enum.Material.Metal
	local lamp = cfPart(model, "Lamp", Vector3.new(1.4, 0.35, 0.85), base * CFrame.new(0, 9.35, -3.6), Color3.fromRGB(240, 239, 221), 0, false)
	lamp.Material = Enum.Material.Neon
end

local function tree(parent, position, scale)
	scale = scale or 1
	local trunk = part(parent, "TreeTrunk", Vector3.new(1.1 * scale, 6 * scale, 1.1 * scale), position + Vector3.new(0, 3 * scale, 0), Color3.fromRGB(92, 66, 43), 0, true)
	trunk.Material = Enum.Material.Wood
	for _, offset in ipairs({ Vector3.new(0, 7, 0), Vector3.new(-1.8, 6.5, 0), Vector3.new(1.8, 6.4, 0), Vector3.new(0, 6.4, 1.8) }) do
		local leaf = part(parent, "TreeLeaves", Vector3.new(5.3, 5.3, 5.3) * scale, position + offset * scale, Color3.fromRGB(47, 103, 49), 0, false)
		leaf.Shape = Enum.PartType.Ball
		leaf.Material = Enum.Material.Grass
	end
end

local function hedge(parent, position, size)
	local h = part(parent, "Hedge", size, position, Color3.fromRGB(49, 102, 55), 0, true)
	h.Material = Enum.Material.Grass
	return h
end

local function createCar(parent, name, position, yaw, bodyColor, suv)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local cf = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw or 0), 0)
	cfPart(model, "LowerBody", Vector3.new(suv and 7.4 or 7, suv and 2.0 or 1.65, 14), cf * CFrame.new(0, suv and 1.7 or 1.5, 0), bodyColor, 0, true)
	cfPart(model, "Bonnet", Vector3.new(suv and 7.1 or 6.7, 1.0, 4.2), cf * CFrame.new(0, suv and 2.55 or 2.25, -4.5), bodyColor, 0, false)
	cfPart(model, "Cabin", Vector3.new(suv and 6.8 or 6.3, suv and 3.0 or 2.5, 6.4), cf * CFrame.new(0, suv and 3.6 or 3.25, 1), C.Glass, 0.18, false)
	for _, x in ipairs({ -3.55, 3.55 }) do
		for _, z in ipairs({ -4.4, 4.4 }) do
			local wheel = cfPart(model, "Wheel", Vector3.new(1.2, 2.25, 2.25), cf * CFrame.new(x, 1.05, z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(25, 26, 27), 0, false)
			wheel.Shape = Enum.PartType.Cylinder
		end
	end
	for _, side in ipairs({ -1, 1 }) do
		cfPart(model, "Light", Vector3.new(1.2, 0.45, 0.18), cf * CFrame.new(side * 2.2, 2.0, -7.05), Color3.fromRGB(244, 235, 196), 0, false).Material = Enum.Material.Neon
		cfPart(model, "TailLight", Vector3.new(1.2, 0.45, 0.18), cf * CFrame.new(side * 2.2, 2.0, 7.05), Color3.fromRGB(203, 48, 48), 0, false).Material = Enum.Material.Neon
	end
	return model
end

local function addHair(model, head, hairColor, style)
	if not head then return end
	local root = Instance.new("Model")
	root.Name = "Hair"
	root.Parent = model
	local base = head.CFrame
	local offsets
	if style == "long" then
		offsets = { Vector3.new(0, 0.85, 0), Vector3.new(-0.55, 0.6, 0), Vector3.new(0.55, 0.6, 0), Vector3.new(0, 0.45, 0.62), Vector3.new(0, 0.2, 0.75) }
	elseif style == "curly" then
		offsets = { Vector3.new(-0.55, 0.65, 0), Vector3.new(0, 0.82, 0), Vector3.new(0.55, 0.65, 0), Vector3.new(-0.35, 0.6, 0.55), Vector3.new(0.35, 0.6, 0.55) }
	else
		offsets = { Vector3.new(-0.45, 0.65, 0), Vector3.new(0, 0.78, 0), Vector3.new(0.45, 0.65, 0), Vector3.new(0, 0.55, 0.45) }
	end
	for _, offset in ipairs(offsets) do
		local tuft = part(root, "HairTuft", Vector3.new(0.95, 0.8, 0.95), (base * CFrame.new(offset)).Position, hairColor, 0, false)
		tuft.Shape = Enum.PartType.Ball
		tuft.CFrame = base * CFrame.new(offset)
	end
end

local function fallbackAvatar(parent, name, position, lookAt, shirtColor, pantsColor, skinColor, hairColor, hairStyle)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local base = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	local root = cfPart(model, "HumanoidRootPart", Vector3.new(1.4, 2, 1), base * CFrame.new(0, 2.8, 0), C.Dark, 1, false)
	model.PrimaryPart = root
	cfPart(model, "UpperTorso", Vector3.new(2.5, 2.1, 1.2), base * CFrame.new(0, 4.2, 0), shirtColor, 0, false)
	cfPart(model, "LowerTorso", Vector3.new(2.1, 1.4, 1.1), base * CFrame.new(0, 2.55, 0), shirtColor, 0, false)
	local head = cfPart(model, "Head", Vector3.new(1.75, 1.75, 1.75), base * CFrame.new(0, 6.2, 0), skinColor, 0, false)
	head.Shape = Enum.PartType.Ball
	for _, side in ipairs({ -1, 1 }) do
		cfPart(model, "UpperArm", Vector3.new(0.75, 1.8, 0.75), base * CFrame.new(side * 1.65, 4.25, 0), shirtColor, 0, false)
		cfPart(model, "LowerArm", Vector3.new(0.65, 1.7, 0.65), base * CFrame.new(side * 1.65, 2.7, 0), skinColor, 0, false)
		local hand = cfPart(model, "Hand", Vector3.new(0.7, 0.7, 0.7), base * CFrame.new(side * 1.65, 1.65, 0), skinColor, 0, false)
		hand.Shape = Enum.PartType.Ball
		cfPart(model, "UpperLeg", Vector3.new(0.9, 1.9, 0.9), base * CFrame.new(side * 0.58, 1.25, 0), pantsColor, 0, false)
		cfPart(model, "LowerLeg", Vector3.new(0.78, 1.8, 0.78), base * CFrame.new(side * 0.58, -0.25, 0), pantsColor, 0, false)
	end
	local face = Instance.new("Decal")
	face.Name = "face"
	face.Texture = "rbxasset://textures/face.png"
	face.Face = Enum.NormalId.Front
	face.Parent = head
	addHair(model, head, hairColor, hairStyle)
	return model
end

local function createAvatarNPC(parent, name, position, lookAt, shirtColor, pantsColor, skinColor, hairColor, hairStyle, storyAction, storyPrompt, exploreId, exploreText)
	local model
	local description = Instance.new("HumanoidDescription")
	description.HeadColor = skinColor
	description.LeftArmColor = skinColor
	description.RightArmColor = skinColor
	description.TorsoColor = shirtColor
	description.LeftLegColor = pantsColor
	description.RightLegColor = pantsColor
	description.HeightScale = 0.96
	description.WidthScale = 0.92
	description.DepthScale = 0.92
	description.HeadScale = 1
	description.BodyTypeScale = 0.2
	description.ProportionScale = 0.15
	local ok, generated = pcall(function()
		return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
	end)
	if ok and generated then
		model = generated
		model.Name = name
		model.Parent = parent
		local root = model:FindFirstChild("HumanoidRootPart")
		if root then
			model:PivotTo(CFrame.lookAt(position + Vector3.new(0, 3, 0), Vector3.new(lookAt.X, position.Y + 3, lookAt.Z)))
		end
		for _, d in ipairs(model:GetDescendants()) do
			if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
		end
		local head = model:FindFirstChild("Head")
		if head then
			local face = head:FindFirstChildWhichIsA("Decal") or Instance.new("Decal")
			face.Name = "face"
			face.Texture = "rbxasset://textures/face.png"
			face.Face = Enum.NormalId.Front
			face.Parent = head
			addHair(model, head, hairColor, hairStyle)
		end
	else
		model = fallbackAvatar(parent, name, position, lookAt, shirtColor, pantsColor, skinColor, hairColor, hairStyle)
	end

	local head = model:FindFirstChild("Head") or model.PrimaryPart
	if head then
		local gui = Instance.new("BillboardGui")
		gui.Name = "NameTag"
		gui.Size = UDim2.fromOffset(180, 34)
		gui.StudsOffset = Vector3.new(0, 3.1, 0)
		gui.MaxDistance = 35
		gui.AlwaysOnTop = false
		gui.Parent = head
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = C.White
		label.TextStrokeTransparency = 0.35
		label.Font = Enum.Font.GothamBold
		label.TextSize = 15
		label.Parent = gui
	end

	local rootPosition = position + Vector3.new(0, 2, 0)
	if storyAction then storyNode(model, storyAction, name, rootPosition, storyPrompt or "Talk") end
	if exploreId then explorationNode(model, exploreId, name, rootPosition + Vector3.new(2, 0, 0), name, exploreText or "", "Talk") end
	return model
end

local function createHouse(parent, id, displayName, position, price, style, frontSign)
	frontSign = frontSign or -1
	style = style or "starter"
	local model = Instance.new("Model")
	model.Name = id
	model.Parent = parent
	local width = style == "luxury" and 30 or style == "suburb" and 24 or 20
	local depth = style == "luxury" and 23 or style == "suburb" and 19 or 16
	local height = style == "luxury" and 12 or style == "suburb" and 9.5 or 7.5
	local bodyColor = style == "luxury" and Color3.fromRGB(224, 222, 214) or style == "suburb" and Color3.fromRGB(193, 200, 202) or Color3.fromRGB(179, 160, 135)
	local roofColor = style == "luxury" and Color3.fromRGB(61, 65, 70) or Color3.fromRGB(91, 73, 58)
	local foundation = part(model, "Foundation", Vector3.new(width + 3, 0.5, depth + 3), position + Vector3.new(0, 0.25, 0), Color3.fromRGB(169, 165, 156), 0, true)
	foundation:SetAttribute("RoadSafe", true)
	part(model, "Body", Vector3.new(width, height, depth), position + Vector3.new(0, height / 2 + 0.5, 0), bodyColor, 0, true)
	part(model, "Roof", Vector3.new(width + 2, 1.3, depth + 2), position + Vector3.new(0, height + 1.1, 0), roofColor, 0, true)
	local frontZ = position.Z + frontSign * (depth / 2 + 0.15)
	part(model, "Door", Vector3.new(3.1, 5.5, 0.25), Vector3.new(position.X - width * 0.25, 3.3, frontZ), Color3.fromRGB(89, 61, 42), 0, true)
	for _, offset in ipairs({ -0.02, 0.28 }) do
		part(model, "Window", Vector3.new(3.2, 2.6, 0.18), Vector3.new(position.X + width * offset, 5.2, frontZ + frontSign * 0.04), C.Glass, 0.18, false)
	end
	local yard = part(model, "Yard", Vector3.new(width + 16, 0.16, depth + 18), position + Vector3.new(0, 0.1, frontSign * 5), Color3.fromRGB(93, 132, 75), 0, true)
	yard.Material = Enum.Material.Grass
	yard:SetAttribute("RoadSafe", true)
	local driveway = part(model, "Driveway", Vector3.new(7, 0.18, depth + 14), position + Vector3.new(width * 0.33, 0.2, frontSign * 7), Color3.fromRGB(128, 130, 132), 0, true)
	driveway.Material = Enum.Material.Concrete
	driveway:SetAttribute("RoadSafe", true)
	if style ~= "starter" then
		part(model, "GarageDoor", Vector3.new(7.2, 5.6, 0.3), Vector3.new(position.X + width * 0.32, 3.3, frontZ), Color3.fromRGB(79, 84, 89), 0, true)
	end
	if style == "luxury" then
		local pool = part(model, "Pool", Vector3.new(13, 0.35, 6.5), position + Vector3.new(-width * 0.2, 0.18, -frontSign * (depth / 2 + 5)), Color3.fromRGB(65, 157, 203), 0.18, true)
		pool.Material = Enum.Material.Glass
		headge(model, position + Vector3.new(-width / 2 - 4, 2, 0), Vector3.new(2, 4, depth + 18))
	end
	propertyNode(model, id, displayName, price, Vector3.new(position.X - width * 0.25, 2, frontZ + frontSign * 2.6))
	local sign = part(model, "PropertySign", Vector3.new(5.8, 2.8, 0.22), Vector3.new(position.X - width / 2 - 2, 1.8, frontZ + frontSign * 1.4), C.Navy, 0, false)
	surfaceText(sign, displayName .. "\nN$" .. tostring(price), frontSign < 0 and Enum.NormalId.Front or Enum.NormalId.Back)
	return model
end

local function cylinderBetween(parent, name, a, b, radius, color, transparency, collide)
	local delta = b - a
	if delta.Magnitude < 0.001 then return nil end
	local right = delta.Unit
	local seedUp = math.abs(right:Dot(Vector3.yAxis)) > 0.95 and Vector3.zAxis or Vector3.yAxis
	local back = right:Cross(seedUp).Unit
	local up = back:Cross(right).Unit
	local p = cfPart(parent, name, Vector3.new(delta.Magnitude, radius * 2, radius * 2), CFrame.fromMatrix((a + b) / 2, right, up, back), color, transparency or 0, collide)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function netLine(parent, name, a, b)
	local delta = b - a
	if delta.Magnitude < 0.001 then return end
	local line = cfPart(parent, name, Vector3.new(0.026, 0.026, delta.Magnitude), CFrame.lookAt((a + b) / 2, b), Color3.fromRGB(232, 237, 239), 0.84, false)
	line.Material = Enum.Material.SmoothPlastic
end

local function communityGoal(parent, name, centreX, z, sign, baseY)
	local goal = Instance.new("Model")
	goal.Name = name
	goal.Parent = parent
	local width, height, depth, rearHeight = 20, 7, 4.5, 5.2
	local leftX, rightX = centreX - width / 2, centreX + width / 2
	local backZ = z + sign * depth
	for _, x in ipairs({ leftX, rightX }) do
		cylinderBetween(goal, "FrontPost", Vector3.new(x, baseY, z), Vector3.new(x, baseY + height, z), 0.18, C.White, 0, true)
		cylinderBetween(goal, "RearPost", Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.10, C.White, 0.05, false)
		cylinderBetween(goal, "RoofSupport", Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ), 0.10, C.White, 0.05, false)
	end
	cylinderBetween(goal, "Crossbar", Vector3.new(leftX, baseY + height, z), Vector3.new(rightX, baseY + height, z), 0.18, C.White, 0, true)
	cylinderBetween(goal, "RearBar", Vector3.new(leftX, baseY + rearHeight, backZ), Vector3.new(rightX, baseY + rearHeight, backZ), 0.10, C.White, 0.05, false)
	for i = 0, 8 do
		local x = leftX + width * i / 8
		netLine(goal, "RearV" .. i, Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ))
		netLine(goal, "RoofV" .. i, Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ))
	end
	for i = 0, 5 do
		local y = baseY + rearHeight * i / 5
		netLine(goal, "RearH" .. i, Vector3.new(leftX, y, backZ), Vector3.new(rightX, y, backZ))
	end
end

local function createDustPitch(parent, centre)
	local pitch = part(parent, "ChildhoodDustPitch", Vector3.new(92, 0.42, 124), centre, C.Dirt, 0, true)
	pitch.Material = Enum.Material.Sand
	pitch:SetAttribute("RoadSafe", true)
	local baseY = centre.Y + pitch.Size.Y / 2
	communityGoal(parent, "ChildhoodNorthGoal", centre.X, centre.Z + 57, 1, baseY)
	communityGoal(parent, "ChildhoodSouthGoal", centre.X, centre.Z - 57, -1, baseY)
	local halfway = part(parent, "DustHalfway", Vector3.new(88, 0.04, 0.18), Vector3.new(centre.X, baseY + 0.03, centre.Z), Color3.fromRGB(221, 215, 195), 0.25, false)
	halfway:SetAttribute("RoadSafe", true)
	storyNode(parent, "ChildhoodPractice", "Childhood Pitch", centre + Vector3.new(0, 2, 0), "Practice")
	explorationNode(parent, "ChildhoodPitchV4", "Childhood Football Ground", centre + Vector3.new(13, 2, 0), "Coach Samuel", "The rough pitch where your first touch, confidence and football dream were built.", "Remember")
	return pitch
end

local function createBusBay(parent, position, roadZ)
	local model = Instance.new("Model")
	model.Name = "OriginsBusBay"
	model.Parent = parent
	local bay = markRoadSafe(part(model, "BusLayby", Vector3.new(34, 0.34, 10), Vector3.new(position.X, 0.09, position.Z), C.Road, 0, true))
	bay.Material = Enum.Material.Asphalt
	local walk = markRoadSafe(part(model, "BusPlatform", Vector3.new(32, 0.35, 6), Vector3.new(position.X, 0.2, position.Z + 8), C.Concrete, 0, true))
	walk.Material = Enum.Material.Concrete
	local shelterZ = position.Z + 11
	part(model, "Roof", Vector3.new(17, 0.42, 6), Vector3.new(position.X, 6.7, shelterZ), C.Navy, 0, true)
	for _, x in ipairs({ position.X - 7.5, position.X + 7.5 }) do
		part(model, "Post", Vector3.new(0.45, 6.4, 0.45), Vector3.new(x, 3.2, shelterZ), C.Steel, 0, true)
	end
	local bench = cfPart(model, "Bench", Vector3.new(10, 0.55, 2), CFrame.lookAt(Vector3.new(position.X, 1.2, shelterZ + 0.3), Vector3.new(position.X, 1.2, roadZ)), C.Wood, 0, true)
	bench:SetAttribute("RoadSafe", true)
	local sign = part(model, "BusStopSign", Vector3.new(0.45, 5.5, 0.45), Vector3.new(position.X - 11, 2.75, shelterZ), C.Steel, 0, true)
	local plate = part(model, "BusPlate", Vector3.new(4.5, 2.2, 0.22), sign.Position + Vector3.new(0, 2.5, 0), C.Navy, 0, false)
	surfaceText(plate, "BUS\nACADEMY", Enum.NormalId.Front)
	storyNode(model, "TravelAcademy", "Bus to Northbridge Academy", Vector3.new(position.X + 4, 2, shelterZ - 1), "Travel")
	return model
end

local function createTrafficSignals(parent, centre)
	local function signal(position, facePoint)
		local model = Instance.new("Model")
		model.Name = "TrafficRobot"
		model.Parent = parent
		local base = CFrame.lookAt(position, Vector3.new(facePoint.X, position.Y, facePoint.Z))
		part(model, "Base", Vector3.new(1.5, 0.35, 1.5), position + Vector3.new(0, 0.18, 0), C.Concrete, 0, true)
		local pole = cfPart(model, "Pole", Vector3.new(0.45, 9.5, 0.45), base * CFrame.new(0, 4.75, 0), C.Steel, 0, true)
		pole.Material = Enum.Material.Metal
		cfPart(model, "Arm", Vector3.new(0.35, 0.35, 5), base * CFrame.new(0, 8.8, -2.3), C.Steel, 0, false)
		local box = cfPart(model, "SignalBox", Vector3.new(2.0, 4.9, 1.2), base * CFrame.new(0, 8.1, -4.8), C.Dark, 0, false)
		local lamps = {}
		for i, color in ipairs({ C.Red, C.Amber, C.Green }) do
			local lamp = part(model, "Lamp" .. i, Vector3.new(0.95, 0.95, 0.25), Vector3.zero, color, i == 1 and 0 or 0.82, false)
			lamp.Shape = Enum.PartType.Ball
			lamp.Material = Enum.Material.Neon
			lamp.CFrame = box.CFrame * CFrame.new(0, 1.48 - (i - 1) * 1.48, -0.72)
			lamps[i] = lamp
		end
		return lamps
	end
	local ns = {
		signal(centre + Vector3.new(-18, 0, -18), centre + Vector3.new(-18, 0, 22)),
		signal(centre + Vector3.new(18, 0, 18), centre + Vector3.new(18, 0, -22)),
	}
	local ew = {
		signal(centre + Vector3.new(-18, 0, 18), centre + Vector3.new(22, 0, 18)),
		signal(centre + Vector3.new(18, 0, -18), centre + Vector3.new(-22, 0, -18)),
	}
	local function setGroup(group, state)
		for _, lamps in ipairs(group) do
			for i, lamp in ipairs(lamps) do lamp.Transparency = i == state and 0 or 0.82 end
		end
	end
	setGroup(ns, 3)
	setGroup(ew, 1)
	task.spawn(function()
		while parent.Parent do
			task.wait(9) setGroup(ns, 2)
			task.wait(2) setGroup(ns, 1) setGroup(ew, 3)
			task.wait(9) setGroup(ew, 2)
			task.wait(2) setGroup(ew, 1) setGroup(ns, 3)
		end
	end)
end

local function cleanRoadCorridors(root, roads)
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj.Position.Y < 4.6 and not obj:GetAttribute("RoadSafe") and not obj:GetAttribute("RoadSurface") and not obj:GetAttribute("RoadMarking") then
			local inLane = false
			for _, road in ipairs(roads) do
				if road.Axis == "X" then
					if obj.Position.X >= road.Min and obj.Position.X <= road.Max and math.abs(obj.Position.Z - road.Centre) < road.Width / 2 - 0.5 then inLane = true break end
				else
					if obj.Position.Z >= road.Min and obj.Position.Z <= road.Max and math.abs(obj.Position.X - road.Centre) < road.Width / 2 - 0.5 then inLane = true break end
				end
			end
			if inLane then obj:Destroy() end
		end
	end
end

local function buildOrigins(worldBuilder, root)
	if worldBuilder.OriginsVillage and worldBuilder.OriginsVillage.Parent then worldBuilder.OriginsVillage:Destroy() end
	local district = Instance.new("Model")
	district.Name = "OriginsVillage"
	district.Parent = root
	local roads = {}
	local ground = markRoadSafe(part(district, "OriginsGround", Vector3.new(520, 1, 360), Vector3.new(-620, -0.55, -70), C.Grass, 0, true))
	ground.Material = Enum.Material.Grass

	-- The neighbourhood is well away from the stadium and only connects to the wider map at one controlled junction.
	roadEW(district, roads, "OriginsConnector", -520, -88, -30, 28)
	roadEW(district, roads, "OriginsNorthRoad", -790, -480, 50, 24)
	roadEW(district, roads, "OriginsSouthRoad", -790, -480, -190, 24)
	roadNS(district, roads, "OriginsWestRoad", -705, 35, -205, 24)
	roadNS(district, roads, "OriginsEastRoad", -565, 35, -205, 24)
	roadNS(district, roads, "OriginsMarketRoad", -495, 10, -120, 22)
	crosswalkEW(district, -565, -30, 24)
	createTrafficSignals(district, Vector3.new(-565, 0, -30))

	for x = -780, -490, 58 do
		streetLight(district, Vector3.new(x, 0, 34), Vector3.new(x, 0, 50))
		streetLight(district, Vector3.new(x, 0, -174), Vector3.new(x, 0, -190))
	end

	local starter = createHouse(district, "Home_StarterRoom", "Starter Room", Vector3.new(-655, 0, 88), 250, "starter", -1)
	createHouse(district, "Home_TinRoof", "Tin-Roof Cottage", Vector3.new(-585, 0, 88), 450, "starter", -1)
	createHouse(district, "Home_BlueCottage", "Blue Village Cottage", Vector3.new(-655, 0, -228), 750, "starter", 1)
	createHouse(district, "Home_BrickHouse", "Small Brick House", Vector3.new(-585, 0, -228), 1200, "starter", 1)
	createHouse(district, "Home_FamilyHouse", "Family Starter House", Vector3.new(-505, 0, -165), 1800, "suburb", 1)
	createCar(starter, "OldHatchback", Vector3.new(-648, 0, 72), 0, Color3.fromRGB(126, 133, 137), false)

	local shop = part(district, "OriginsShop", Vector3.new(32, 9, 20), Vector3.new(-470, 4.5, 76), Color3.fromRGB(84, 102, 118), 0, true)
	local awning = part(district, "ShopAwning", Vector3.new(34, 0.55, 5), Vector3.new(-470, 7.2, 64.5), C.Navy, 0, true)
	local sign = part(district, "ShopSign", Vector3.new(20, 2.8, 0.25), Vector3.new(-470, 7.5, 65.2), C.Navy, 0, false)
	surfaceText(sign, "ORIGINS MINI MARKET", Enum.NormalId.Front)
	explorationNode(district, "OriginsMarketV4", "Origins Mini Market", Vector3.new(-470, 2, 63), "Mr. Petrus", "A small family shop where players buy snacks and airtime before taking the bus to training.", "Talk")

	local hall = part(district, "CommunityHall", Vector3.new(40, 10, 28), Vector3.new(-470, 5, -95), Color3.fromRGB(204, 196, 176), 0, true)
	local hallSign = part(district, "HallSign", Vector3.new(24, 3, 0.25), Vector3.new(-470, 8, -80.8), C.Navy, 0, false)
	surfaceText(hallSign, "ORIGINS COMMUNITY CENTRE", Enum.NormalId.Front)
	local clinic = part(district, "Clinic", Vector3.new(30, 9, 22), Vector3.new(-790, 4.5, -65), Color3.fromRGB(214, 219, 218), 0, true)
	local clinicSign = part(district, "ClinicSign", Vector3.new(18, 2.5, 0.25), Vector3.new(-790, 7.2, -53.8), C.Green, 0, false)
	surfaceText(clinicSign, "COMMUNITY CLINIC", Enum.NormalId.Front)

	local busPosition = Vector3.new(-438, 0, -44)
	createBusBay(district, busPosition, -30)
	local pitchCentre = Vector3.new(-835, 0.24, -70)
	createDustPitch(district, pitchCentre)

	-- Story and social NPCs use proper R15-style bodies rather than block mannequins.
	createAvatarNPC(district, "Mum", Vector3.new(-655, 0, 72), Vector3.new(-655, 0, 50), Color3.fromRGB(145, 76, 119), Color3.fromRGB(48, 48, 52), C.SkinB, Color3.fromRGB(42, 29, 24), "long", "FamilyTalk", "Talk", nil, nil)
	createAvatarNPC(district, "Coach Samuel", Vector3.new(-790, 0, -70), pitchCentre, Color3.fromRGB(45, 90, 150), Color3.fromRGB(35, 38, 42), C.SkinC, Color3.fromRGB(35, 28, 24), "short", "CoachTalk", "Talk", nil, nil)
	createAvatarNPC(district, "Timo", Vector3.new(-454, 0, -55), busPosition, Color3.fromRGB(66, 120, 78), Color3.fromRGB(39, 42, 45), C.SkinA, Color3.fromRGB(164, 87, 24), "curly", nil, nil, "NeighbourTimoV4", "Everyone around here knows the academy trial is today. Don't miss that bus.")
	createAvatarNPC(district, "Mr. Petrus", Vector3.new(-470, 0, 62), Vector3.new(-470, 0, 76), Color3.fromRGB(118, 85, 55), Color3.fromRGB(43, 45, 48), C.SkinC, Color3.fromRGB(33, 31, 29), "short", nil, nil, "ShopOwnerV4", "I remember when you used to kick a plastic ball outside this shop. Now you're off to an academy.")

	for _, p in ipairs({
		Vector3.new(-760, 0, 18), Vector3.new(-690, 0, 18), Vector3.new(-620, 0, 18), Vector3.new(-520, 0, 18),
		Vector3.new(-760, 0, -222), Vector3.new(-690, 0, -222), Vector3.new(-620, 0, -222), Vector3.new(-520, 0, -222),
		Vector3.new(-850, 0, 10), Vector3.new(-875, 0, -130), Vector3.new(-820, 0, -155),
	}) do tree(district, p, 0.9) end

	cleanRoadCorridors(district, roads)
	explorationNode(district, "OriginsDistrictV4", "Origins District", Vector3.new(-620, 2, -30), "Narrator", "A modest working-class neighbourhood separated from the professional football world by distance, money and one big opportunity.", "Look around")

	worldBuilder.OriginsVillage = district
	worldBuilder.OriginsStarterHouse = starter
	worldBuilder.StoryMarkers = worldBuilder.StoryMarkers or {}
	worldBuilder.StoryMarkers.HomeSpawn = Vector3.new(-655, 3, 72)
	worldBuilder.StoryMarkers.ChildhoodPitch = pitchCentre + Vector3.new(0, 3, 0)
	worldBuilder.StoryMarkers.BusStop = busPosition + Vector3.new(4, 3, 11)
	return district
end

local function buildRiverstone(root)
	local district = Instance.new("Model")
	district.Name = "RiverstoneSuburb"
	district.Parent = root
	local roads = {}
	local ground = markRoadSafe(part(district, "RiverstoneGround", Vector3.new(340, 1, 260), Vector3.new(275, -0.55, -120), Color3.fromRGB(75, 122, 68), 0, true))
	ground.Material = Enum.Material.Grass
	roadEW(district, roads, "RiverstoneBoulevard", 110, 440, -70, 30)
	roadEW(district, roads, "RiverstoneSouth", 125, 425, -195, 24)
	roadNS(district, roads, "RiverstoneWest", 165, -45, -215, 24)
	roadNS(district, roads, "RiverstoneEast", 380, -45, -215, 24)
	crosswalkEW(district, 275, -70, 30)
	for x = 125, 425, 50 do
		streetLight(district, Vector3.new(x, 0, -50), Vector3.new(x, 0, -70))
	end
	local h1 = createHouse(district, "Home_RiverstoneTownhouse", "Riverstone Townhouse", Vector3.new(220, 0, -115), 12000, "suburb", -1)
	local h2 = createHouse(district, "Home_RiverstoneFamily", "Riverstone Family Home", Vector3.new(330, 0, -115), 22000, "suburb", -1)
	createHouse(district, "Home_RiverstoneCorner", "Riverstone Corner House", Vector3.new(220, 0, -240), 28000, "suburb", 1)
	createCar(h1, "SilverSUV", Vector3.new(227, 0, -132), 0, Color3.fromRGB(160, 164, 168), true)
	createCar(h2, "BlueSedan", Vector3.new(337, 0, -132), 0, Color3.fromRGB(44, 87, 140), false)
	local park = markRoadSafe(part(district, "RiverstonePark", Vector3.new(70, 0.35, 55), Vector3.new(375, 0.05, -245), Color3.fromRGB(78, 137, 77), 0, true))
	park.Material = Enum.Material.Grass
	for _, p in ipairs({ Vector3.new(350, 0, -235), Vector3.new(375, 0, -235), Vector3.new(400, 0, -235), Vector3.new(350, 0, -260), Vector3.new(400, 0, -260) }) do tree(district, p, 0.85) end
	explorationNode(district, "RiverstoneV4", "Riverstone", Vector3.new(275, 2, -70), "Estate Agent", "A comfortable middle-class suburb. Homes here become realistic once football wages replace academy travel money.", "Explore")
	cleanRoadCorridors(district, roads)
	return district
end

local function buildKingsview(root)
	local district = Instance.new("Model")
	district.Name = "KingsviewHeights"
	district.Parent = root
	local roads = {}
	local ground = markRoadSafe(part(district, "KingsviewGround", Vector3.new(390, 1, 300), Vector3.new(445, -0.55, 170), Color3.fromRGB(67, 116, 66), 0, true))
	ground.Material = Enum.Material.Grass
	roadEW(district, roads, "KingsviewDrive", 255, 635, 120, 34)
	roadEW(district, roads, "KingsviewCrescent", 290, 605, 260, 26)
	roadNS(district, roads, "KingsviewWest", 325, 100, 280, 26)
	roadNS(district, roads, "KingsviewEast", 565, 100, 280, 26)
	for x = 275, 615, 52 do streetLight(district, Vector3.new(x, 0, 141), Vector3.new(x, 0, 120)) end
	local h1 = createHouse(district, "Home_KingsviewVilla", "Kingsview Villa", Vector3.new(395, 0, 190), 85000, "luxury", 1)
	local h2 = createHouse(district, "Home_KingsviewModern", "Modern Player Home", Vector3.new(520, 0, 190), 130000, "luxury", 1)
	createCar(h1, "PerformanceSUV", Vector3.new(405, 0, 210), 0, Color3.fromRGB(35, 38, 42), true)
	createCar(h2, "WhiteCoupe", Vector3.new(530, 0, 210), 0, Color3.fromRGB(232, 233, 234), false)
	local gateA = part(district, "EstatePillar", Vector3.new(4, 14, 4), Vector3.new(280, 7, 120), C.Navy, 0, true)
	local gateB = part(district, "EstatePillar", Vector3.new(4, 14, 4), Vector3.new(306, 7, 120), C.Navy, 0, true)
	local gateSign = part(district, "EstateSign", Vector3.new(30, 4, 2), Vector3.new(293, 13, 120), C.Navy, 0, true)
	surfaceText(gateSign, "KINGSVIEW HEIGHTS", Enum.NormalId.Front)
	explorationNode(district, "KingsviewV4", "Kingsview Heights", Vector3.new(315, 2, 145), "Estate Agent", "Luxury homes, private gardens and expensive cars. This is a late-career destination, not a starting shortcut.", "Explore")
	cleanRoadCorridors(district, roads)
	return district
end

function WorldRealismV4Service:Init(worldBuilder)
	local expansionRoot = worldBuilder.Model:FindFirstChild("CareerWorldExpansion") or worldBuilder.Model
	local old = expansionRoot:FindFirstChild("WorldRealismV4")
	if old then old:Destroy() end
	local root = Instance.new("Model")
	root.Name = "WorldRealismV4"
	root.Parent = expansionRoot

	local origins = buildOrigins(worldBuilder, root)
	local riverstone = buildRiverstone(root)
	local kingsview = buildKingsview(root)
	worldBuilder.Neighborhoods = { Origins = origins, Riverstone = riverstone, Kingsview = kingsview }
	worldBuilder.WorldRealismV4 = root
end

return WorldRealismV4Service
