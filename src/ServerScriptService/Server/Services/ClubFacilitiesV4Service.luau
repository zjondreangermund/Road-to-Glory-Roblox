local Players = game:GetService("Players")

local ClubFacilitiesV4Service = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Dark = Color3.fromRGB(27, 31, 36),
	Navy = Color3.fromRGB(21, 36, 60),
	Blue = Color3.fromRGB(40, 91, 167),
	Red = Color3.fromRGB(186, 48, 52),
	Steel = Color3.fromRGB(75, 82, 88),
	Concrete = Color3.fromRGB(171, 175, 179),
	Road = Color3.fromRGB(51, 54, 57),
	Grass = Color3.fromRGB(43, 116, 54),
	DarkGrass = Color3.fromRGB(32, 87, 44),
	Glass = Color3.fromRGB(118, 174, 198),
	Gold = Color3.fromRGB(224, 180, 49),
	Wood = Color3.fromRGB(107, 75, 48),
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
	gui.CanvasSize = Vector2.new(1100, 300)
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

local function exploration(parent, id, title, position, speaker, text, prompt)
	local node = part(parent, "Explore_" .. id, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("ExplorationId", id)
	node:SetAttribute("ExplorationTitle", title)
	node:SetAttribute("ExplorationSpeaker", speaker)
	node:SetAttribute("ExplorationText", text)
	node:SetAttribute("ExplorationPrompt", prompt or "Explore")
	return node
end

local function storyNode(parent, action, title, position, prompt)
	local node = part(parent, "Story_" .. action, Vector3.new(2, 3, 2), position, C.White, 1, false)
	node:SetAttribute("StoryAction", action)
	node:SetAttribute("StoryTitle", title)
	node:SetAttribute("StoryPrompt", prompt or "Use")
	return node
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

local function netLine(parent, name, a, b, transparency)
	local delta = b - a
	if delta.Magnitude < 0.001 then return end
	local line = cfPart(parent, name, Vector3.new(0.028, 0.028, delta.Magnitude), CFrame.lookAt((a + b) / 2, b), Color3.fromRGB(232, 237, 239), transparency or 0.84, false)
	line.Material = Enum.Material.SmoothPlastic
end

local function createGoal(parent, name, centreX, z, sign, baseY, width, height)
	width = width or 27
	height = height or 8.8
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local depth, rearHeight = 6.2, height * 0.69
	local leftX, rightX = centreX - width / 2, centreX + width / 2
	local backZ = z + sign * depth
	for _, x in ipairs({ leftX, rightX }) do
		cylinderBetween(model, "FrontPost", Vector3.new(x, baseY, z), Vector3.new(x, baseY + height, z), 0.22, C.White, 0, true)
		cylinderBetween(model, "RearPost", Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.12, C.White, 0.05, false)
		cylinderBetween(model, "RoofSupport", Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ), 0.12, C.White, 0.05, false)
	end
	cylinderBetween(model, "Crossbar", Vector3.new(leftX, baseY + height, z), Vector3.new(rightX, baseY + height, z), 0.22, C.White, 0, true)
	cylinderBetween(model, "RearBar", Vector3.new(leftX, baseY + rearHeight, backZ), Vector3.new(rightX, baseY + rearHeight, backZ), 0.12, C.White, 0.05, false)
	for i = 0, 11 do
		local x = leftX + width * i / 11
		netLine(model, "RearV" .. i, Vector3.new(x, baseY, backZ), Vector3.new(x, baseY + rearHeight, backZ), 0.85)
		netLine(model, "RoofV" .. i, Vector3.new(x, baseY + height, z), Vector3.new(x, baseY + rearHeight, backZ), 0.87)
	end
	for i = 0, 7 do
		local y = baseY + rearHeight * i / 7
		netLine(model, "RearH" .. i, Vector3.new(leftX, y, backZ), Vector3.new(rightX, y, backZ), 0.85)
	end
	for _, x in ipairs({ leftX, rightX }) do
		for i = 0, 6 do
			local t = i / 6
			local zz = z + (backZ - z) * t
			local topY = baseY + height + (rearHeight - height) * t
			netLine(model, "SideV" .. i, Vector3.new(x, baseY, zz), Vector3.new(x, topY, zz), 0.87)
		end
	end
	return model
end

local function pitchMarkings(parent, centre, width, length)
	local model = Instance.new("Model")
	model.Name = "PitchMarkings"
	model.Parent = parent
	local y = centre.Y + 0.28
	local c = Color3.fromRGB(239, 242, 237)
	local t = 0.16
	part(model, "WestLine", Vector3.new(t, 0.05, length), Vector3.new(centre.X - width / 2, y, centre.Z), c, 0, false)
	part(model, "EastLine", Vector3.new(t, 0.05, length), Vector3.new(centre.X + width / 2, y, centre.Z), c, 0, false)
	part(model, "NorthLine", Vector3.new(width, 0.05, t), Vector3.new(centre.X, y, centre.Z + length / 2), c, 0, false)
	part(model, "SouthLine", Vector3.new(width, 0.05, t), Vector3.new(centre.X, y, centre.Z - length / 2), c, 0, false)
	part(model, "Halfway", Vector3.new(width, 0.05, t), Vector3.new(centre.X, y, centre.Z), c, 0, false)
	local radius = 14
	for i = 1, 32 do
		local a1 = (i - 1) / 32 * math.pi * 2
		local a2 = i / 32 * math.pi * 2
		local p1 = centre + Vector3.new(math.cos(a1) * radius, 0.3, math.sin(a1) * radius)
		local p2 = centre + Vector3.new(math.cos(a2) * radius, 0.3, math.sin(a2) * radius)
		cfPart(model, "CentreCircle", Vector3.new(t, 0.05, (p2 - p1).Magnitude), CFrame.lookAt((p1 + p2) / 2, p2), c, 0, false)
	end
	for _, sign in ipairs({ -1, 1 }) do
		local goalZ = centre.Z + sign * (length / 2)
		local boxZ = goalZ - sign * 22
		part(model, "PenaltyTop", Vector3.new(48, 0.05, t), Vector3.new(centre.X, y, boxZ), c, 0, false)
		part(model, "PenaltyLeft", Vector3.new(t, 0.05, 22), Vector3.new(centre.X - 24, y, goalZ - sign * 11), c, 0, false)
		part(model, "PenaltyRight", Vector3.new(t, 0.05, 22), Vector3.new(centre.X + 24, y, goalZ - sign * 11), c, 0, false)
	end
	return model
end

local function createFloodlight(parent, position, target)
	local model = Instance.new("Model")
	model.Name = "Floodlight"
	model.Parent = parent
	local mast = part(model, "Mast", Vector3.new(1.6, 55, 1.6), position + Vector3.new(0, 27.5, 0), C.Steel, 0, true)
	mast.Material = Enum.Material.Metal
	local rack = cfPart(model, "Rack", Vector3.new(18, 2, 2.4), CFrame.lookAt(position + Vector3.new(0, 55, 0), target + Vector3.new(0, 8, 0)), C.Steel, 0, false)
	for i = -4, 4 do
		local lamp = cfPart(model, "Lamp", Vector3.new(1.6, 1.2, 0.5), rack.CFrame * CFrame.new(i * 1.85, 0, -1.4), Color3.fromRGB(247, 246, 226), 0, false)
		lamp.Material = Enum.Material.Neon
		local light = Instance.new("SurfaceLight")
		light.Face = Enum.NormalId.Back
		light.Angle = 75
		light.Range = 70
		light.Brightness = 1.2
		light.Parent = lamp
	end
end

local function createAvatarNPC(parent, name, position, lookAt, shirtColor, pantsColor, skinColor, hairColor, text)
	local description = Instance.new("HumanoidDescription")
	description.HeadColor = skinColor
	description.LeftArmColor = skinColor
	description.RightArmColor = skinColor
	description.TorsoColor = shirtColor
	description.LeftLegColor = pantsColor
	description.RightLegColor = pantsColor
	description.HeightScale = 0.98
	description.WidthScale = 0.93
	description.DepthScale = 0.93
	description.BodyTypeScale = 0.22
	local ok, model = pcall(function() return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15) end)
	if not ok or not model then return nil end
	model.Name = name
	model.Parent = parent
	model:PivotTo(CFrame.lookAt(position + Vector3.new(0, 3, 0), Vector3.new(lookAt.X, position.Y + 3, lookAt.Z)))
	for _, d in ipairs(model:GetDescendants()) do
		if d:IsA("BasePart") then d.Anchored = true d.CanCollide = false end
	end
	local head = model:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChildWhichIsA("Decal") or Instance.new("Decal")
		face.Texture = "rbxasset://textures/face.png"
		face.Face = Enum.NormalId.Front
		face.Parent = head
		for _, offset in ipairs({ Vector3.new(-0.4, 0.65, 0), Vector3.new(0, 0.82, 0), Vector3.new(0.4, 0.65, 0), Vector3.new(0, 0.55, 0.45) }) do
			local tuft = part(model, "Hair", Vector3.new(0.9, 0.75, 0.9), (head.CFrame * CFrame.new(offset)).Position, hairColor, 0, false)
			tuft.Shape = Enum.PartType.Ball
			tuft.CFrame = head.CFrame * CFrame.new(offset)
		end
	end
	exploration(model, "NPC_" .. string.gsub(name, "%s", ""), name, position + Vector3.new(2, 2, 0), name, text, "Talk")
	return model
end

local function buildTrainingPitch(parent, name, centre, width, length, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local pitch = part(model, "Pitch", Vector3.new(width, 0.5, length), centre, C.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	pitchMarkings(model, centre, width - 2, length - 2)
	createGoal(model, "NorthGoal", centre.X, centre.Z + length / 2 - 1, 1, centre.Y + 0.25, 25, 8)
	createGoal(model, "SouthGoal", centre.X, centre.Z - length / 2 + 1, -1, centre.Y + 0.25, 25, 8)
	for _, z in ipairs({ centre.Z - length / 2 - 5, centre.Z + length / 2 + 5 }) do
		local board = part(model, "SponsorBoard", Vector3.new(width * 0.8, 2.2, 0.3), Vector3.new(centre.X, 1.2, z), accent, 0, true)
		surfaceText(board, "NORTHBRIDGE FC • PERFORMANCE CENTRE", z > centre.Z and Enum.NormalId.Back or Enum.NormalId.Front)
	end
	return model
end

local function buildFirstTeamCentre(worldBuilder, root)
	local centre = Instance.new("Model")
	centre.Name = "NorthbridgeFirstTeamCentre"
	centre.Parent = root
	local ground = part(centre, "TrainingCentreGround", Vector3.new(300, 1, 390), Vector3.new(150, -0.55, 370), Color3.fromRGB(63, 110, 60), 0, true)
	ground.Material = Enum.Material.Grass
	buildTrainingPitch(centre, "FirstTeamPitch", Vector3.new(155, 0.25, 345), 108, 176, C.Navy)
	buildTrainingPitch(centre, "AcademySecondPitch", Vector3.new(155, 0.25, 545), 100, 158, C.Blue)

	local building = Instance.new("Model")
	building.Name = "PerformanceBuilding"
	building.Parent = centre
	part(building, "MainBlock", Vector3.new(110, 16, 48), Vector3.new(15, 8, 405), Color3.fromRGB(55, 65, 78), 0, true)
	part(building, "GlassFront", Vector3.new(88, 9, 0.3), Vector3.new(15, 8.5, 380.8), C.Glass, 0.22, false)
	local sign = part(building, "MainSign", Vector3.new(74, 5, 0.35), Vector3.new(15, 14.2, 380.6), C.Navy, 0, false)
	surfaceText(sign, "NORTHBRIDGE FC\nPERFORMANCE CENTRE", Enum.NormalId.Front)
	part(building, "GymWing", Vector3.new(44, 11, 38), Vector3.new(-55, 5.5, 435), Color3.fromRGB(69, 77, 88), 0, true)
	part(building, "MedicalWing", Vector3.new(44, 11, 38), Vector3.new(85, 5.5, 435), Color3.fromRGB(204, 211, 213), 0, true)
	part(building, "IndoorHall", Vector3.new(86, 20, 62), Vector3.new(15, 10, 475), Color3.fromRGB(64, 73, 83), 0, true)
	part(building, "IndoorGlass", Vector3.new(70, 10, 0.3), Vector3.new(15, 9, 443.8), C.Glass, 0.28, false)

	local recovery = part(centre, "RecoveryPool", Vector3.new(26, 0.35, 12), Vector3.new(82, 0.2, 395), Color3.fromRGB(60, 154, 201), 0.12, true)
	recovery.Material = Enum.Material.Glass
	for _, x in ipairs({ -45, -25, -5, 15, 35, 55, 75 }) do
		local parking = part(centre, "ParkingBay", Vector3.new(10, 0.14, 18), Vector3.new(x, 0.15, 600), Color3.fromRGB(94, 97, 100), 0, true)
		parking.Material = Enum.Material.Asphalt
	end

	for _, p in ipairs({ Vector3.new(75, 0, 265), Vector3.new(115, 0, 265), Vector3.new(195, 0, 265), Vector3.new(235, 0, 265), Vector3.new(75, 0, 625), Vector3.new(235, 0, 625) }) do
		local trunk = part(centre, "TreeTrunk", Vector3.new(1, 6, 1), p + Vector3.new(0, 3, 0), C.Wood, 0, true)
		trunk.Material = Enum.Material.Wood
		local crown = part(centre, "TreeCrown", Vector3.new(6, 6, 6), p + Vector3.new(0, 8, 0), Color3.fromRGB(45, 100, 48), 0, false)
		crown.Shape = Enum.PartType.Ball
	end

	createAvatarNPC(centre, "Coach Daniels", Vector3.new(95, 0, 300), Vector3.new(155, 0, 345), C.Navy, Color3.fromRGB(34, 37, 40), Color3.fromRGB(186, 139, 104), Color3.fromRGB(50, 40, 32), "This is where the first team works. The academy pitch gets you noticed; the performance centre keeps you at the level.")
	createAvatarNPC(centre, "Scout Meyer", Vector3.new(72, 0, 325), Vector3.new(155, 0, 345), Color3.fromRGB(83, 88, 94), Color3.fromRGB(38, 40, 43), Color3.fromRGB(205, 163, 126), Color3.fromRGB(87, 70, 55), "The better the facilities become, the smaller the margins get. We watch decisions as much as technique.")
	createAvatarNPC(centre, "Physio Amina", Vector3.new(82, 0, 423), Vector3.new(85, 0, 435), Color3.fromRGB(226, 229, 231), Color3.fromRGB(49, 74, 96), Color3.fromRGB(133, 91, 67), Color3.fromRGB(34, 28, 25), "Recovery, strength and availability matter. A career is longer than one good match.")
	createAvatarNPC(centre, "Kai Williams", Vector3.new(120, 0, 300), Vector3.new(155, 0, 345), C.Blue, Color3.fromRGB(31, 34, 38), Color3.fromRGB(205, 165, 127), Color3.fromRGB(157, 79, 25), "One day we'll be training here every morning instead of trying to impress from outside the fence.")

	exploration(centre, "PerformanceCentreV4", "Northbridge Performance Centre", Vector3.new(15, 2, 375), "Coach Daniels", "Two full training pitches, indoor work, gym, medical, recovery and analysis facilities form the professional side of Northbridge FC.", "Explore")
	worldBuilder.FirstTeamCentre = centre
end

local function createDugout(parent, name, position, target, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local cf = CFrame.lookAt(position, Vector3.new(target.X, position.Y, target.Z))
	cfPart(model, "Floor", Vector3.new(20, 0.35, 6), cf * CFrame.new(0, 0.18, 0), Color3.fromRGB(89, 92, 94), 0, true)
	cfPart(model, "Roof", Vector3.new(20, 0.4, 6), cf * CFrame.new(0, 6.2, 0), C.Navy, 0, true)
	cfPart(model, "BackGlass", Vector3.new(20, 5.8, 0.25), cf * CFrame.new(0, 3.1, 2.75), C.Glass, 0.45, false)
	for i = -3, 3 do
		local seat = Instance.new("Seat")
		seat.Name = "BenchSeat"
		seat.Anchored = true
		seat.Size = Vector3.new(2.1, 0.5, 2)
		seat.Color = accent
		seat.CFrame = cf * CFrame.new(i * 2.5, 1.1, 1.1)
		seat.Parent = model
	end
	return model
end

local function crowdRow(parent, position, length, alongX, rowIndex)
	local colors = { C.Navy, C.Blue, C.Red, Color3.fromRGB(217, 219, 220), Color3.fromRGB(220, 166, 45), Color3.fromRGB(70, 74, 79) }
	local segments = math.max(6, math.floor(length / 8))
	for i = 1, segments do
		local offset = -length / 2 + (i - 0.5) * (length / segments)
		local pos = alongX and position + Vector3.new(offset, 0, 0) or position + Vector3.new(0, 0, offset)
		local crowd = part(parent, "Crowd", alongX and Vector3.new(length / segments - 0.3, 1.4, 1.4) or Vector3.new(1.4, 1.4, length / segments - 0.3), pos, colors[((i + rowIndex) % #colors) + 1], 0, false)
		crowd.Material = Enum.Material.SmoothPlastic
	end
end

local function standSide(parent, name, centre, pitchWidth, pitchLength, side, rows, accent)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	local eastWest = side == "West" or side == "East"
	for row = 1, rows do
		local rise = 0.82
		local depth = 2.55
		local y = row * rise
		local outward = (row - 1) * depth
		local p
		local size
		if eastWest then
			local sign = side == "East" and 1 or -1
			p = Vector3.new(centre.X + sign * (pitchWidth / 2 + 8 + outward), y / 2, centre.Z)
			size = Vector3.new(depth, y, pitchLength + 24)
		else
			local sign = side == "North" and 1 or -1
			p = Vector3.new(centre.X, y / 2, centre.Z + sign * (pitchLength / 2 + 8 + outward))
			size = Vector3.new(pitchWidth + 24, y, depth)
		end
		local terrace = part(model, "Terrace" .. row, size, p, row % 2 == 0 and Color3.fromRGB(72, 78, 84) or Color3.fromRGB(61, 67, 73), 0, true)
		terrace.Material = Enum.Material.Concrete
		local crowdPos = p + Vector3.new(0, y / 2 + 0.9, 0)
		crowdRow(model, crowdPos, eastWest and pitchLength + 14 or pitchWidth + 14, not eastWest, row)
	end
	local roofHeight = rows * 0.82 + 8
	local roofOut = rows * 2.55 * 0.65
	local roofPos
	local roofSize
	if eastWest then
		local sign = side == "East" and 1 or -1
		roofPos = Vector3.new(centre.X + sign * (pitchWidth / 2 + 13 + roofOut), roofHeight, centre.Z)
		roofSize = Vector3.new(rows * 2.55 + 16, 1.0, pitchLength + 34)
	else
		local sign = side == "North" and 1 or -1
		roofPos = Vector3.new(centre.X, roofHeight, centre.Z + sign * (pitchLength / 2 + 13 + roofOut))
		roofSize = Vector3.new(pitchWidth + 34, 1.0, rows * 2.55 + 16)
	end
	local roof = part(model, "Roof", roofSize, roofPos, C.Navy, 0, true)
	roof.Material = Enum.Material.Metal
	local trim = part(model, "RoofTrim", eastWest and Vector3.new(1.2, 2.5, pitchLength + 35) or Vector3.new(pitchWidth + 35, 2.5, 1.2), roofPos + Vector3.new(0, -1.1, 0), accent, 0, false)
	trim.Material = Enum.Material.Metal
	return model
end

local function advertisingBoards(parent, centre, width, length)
	local model = Instance.new("Model")
	model.Name = "AdvertisingBoards"
	model.Parent = parent
	local messages = { "NORTHBRIDGE FC", "ROAD TO GLORY", "ACADEMY TO FIRST TEAM", "MATCHDAY", "NFC PERFORMANCE" }
	for i = -5, 5 do
		for _, sign in ipairs({ -1, 1 }) do
			local board = part(model, "Board", Vector3.new(15, 2.1, 0.35), Vector3.new(centre.X + i * 15, 1.15, centre.Z + sign * (length / 2 + 3.2)), (i + sign) % 2 == 0 and C.Navy or C.Blue, 0, true)
			surfaceText(board, messages[((i + 10) % #messages) + 1], sign > 0 and Enum.NormalId.Back or Enum.NormalId.Front)
		end
	end
	for i = -7, 7 do
		for _, sign in ipairs({ -1, 1 }) do
			local board = part(model, "Board", Vector3.new(0.35, 2.1, 13), Vector3.new(centre.X + sign * (width / 2 + 3.2), 1.15, centre.Z + i * 13), (i + sign) % 2 == 0 and C.Navy or C.Blue, 0, true)
			surfaceText(board, "NFC", sign > 0 and Enum.NormalId.Left or Enum.NormalId.Right)
		end
	end
end

local function clearMainBoulevard(worldBuilder, centreX, z1, z2, width)
	local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)
	for _, obj in ipairs(worldBuilder.Model:GetDescendants()) do
		if obj:IsA("BasePart") and obj.CanCollide and obj.Position.Y < 4.5 and obj.Size.X < 75 and obj.Size.Z < 75 then
			if obj.Position.Z >= minZ and obj.Position.Z <= maxZ and math.abs(obj.Position.X - centreX) < width / 2 then
				local n = obj.Name
				if not string.find(n, "Road") and not string.find(n, "Sidewalk") and not string.find(n, "Line") and not string.find(n, "Ground") then
					obj:Destroy()
				end
			end
		end
	end
end

local function buildMainBoulevard(root, centreX, z1, z2, width)
	local length = math.abs(z2 - z1)
	local cz = (z1 + z2) / 2
	local road = part(root, "NorthbridgeBoulevard", Vector3.new(width, 0.42, length), Vector3.new(centreX, 0.12, cz), C.Road, 0, true)
	road.Material = Enum.Material.Asphalt
	for z = math.min(z1, z2) + 10, math.max(z1, z2) - 10, 18 do
		part(root, "BoulevardCentre", Vector3.new(0.25, 0.05, 8), Vector3.new(centreX, 0.35, z), Color3.fromRGB(236, 220, 150), 0, false)
	end
	for _, side in ipairs({ -1, 1 }) do
		part(root, "BoulevardEdge", Vector3.new(0.2, 0.05, length), Vector3.new(centreX + side * (width / 2 - 0.8), 0.35, cz), C.White, 0, false)
		local walk = part(root, "BoulevardSidewalk", Vector3.new(6, 0.35, length), Vector3.new(centreX + side * (width / 2 + 3.8), 0.22, cz), C.Concrete, 0, true)
		walk.Material = Enum.Material.Concrete
	end
end

local function buildFirstStadium(worldBuilder, root)
	local old = worldBuilder.FirstMatchStadium
	local oldPitch = old and old:FindFirstChild("MatchPitch")
	local centre = oldPitch and oldPitch.Position or Vector3.new(-88, 0.25, -585)
	if old and old.Parent then old:Destroy() end
	local v3 = worldBuilder.WorldLayoutV3
	if v3 then
		local gateway = v3:FindFirstChild("StadiumGatewayV3")
		if gateway then gateway:Destroy() end
	end

	local stadium = Instance.new("Model")
	stadium.Name = "NorthbridgeCommunityStadiumV4"
	stadium.Parent = root
	local pitchWidth, pitchLength = 112, 184
	local pitch = part(stadium, "MatchPitch", Vector3.new(pitchWidth, 0.5, pitchLength), centre, C.Grass, 0, true)
	pitch.Material = Enum.Material.Grass
	pitchMarkings(stadium, centre, pitchWidth - 2, pitchLength - 2)
	createGoal(stadium, "StadiumNorthGoal", centre.X, centre.Z + pitchLength / 2 - 1, 1, centre.Y + 0.25, 27, 8.8)
	createGoal(stadium, "StadiumSouthGoal", centre.X, centre.Z - pitchLength / 2 + 1, -1, centre.Y + 0.25, 27, 8.8)
	advertisingBoards(stadium, centre, pitchWidth, pitchLength)

	standSide(stadium, "WestStand", centre, pitchWidth, pitchLength, "West", 14, C.Blue)
	standSide(stadium, "EastStand", centre, pitchWidth, pitchLength, "East", 14, C.Red)
	standSide(stadium, "NorthStand", centre, pitchWidth, pitchLength, "North", 11, C.Blue)
	standSide(stadium, "SouthStand", centre, pitchWidth, pitchLength, "South", 11, C.Red)

	-- Lower concourse and exterior shell.
	local concourse = part(stadium, "Concourse", Vector3.new(230, 1.1, 305), Vector3.new(centre.X, -0.3, centre.Z), Color3.fromRGB(132, 136, 139), 0, true)
	concourse.Material = Enum.Material.Concrete
	part(stadium, "WestFacade", Vector3.new(8, 28, 235), Vector3.new(centre.X - 108, 14, centre.Z), Color3.fromRGB(57, 65, 76), 0, true)
	part(stadium, "EastFacade", Vector3.new(8, 28, 235), Vector3.new(centre.X + 108, 14, centre.Z), Color3.fromRGB(57, 65, 76), 0, true)
	part(stadium, "SouthFacade", Vector3.new(215, 25, 8), Vector3.new(centre.X, 12.5, centre.Z - 142), Color3.fromRGB(57, 65, 76), 0, true)

	-- Press and VIP facilities above west stand.
	local press = part(stadium, "PressBox", Vector3.new(15, 12, 68), Vector3.new(centre.X - 87, 28, centre.Z), C.Glass, 0.2, true)
	press.Material = Enum.Material.Glass
	local pressSign = part(stadium, "PressSign", Vector3.new(0.3, 4, 42), Vector3.new(centre.X - 78.9, 28, centre.Z), C.Navy, 0, false)
	surfaceText(pressSign, "MEDIA • ANALYSIS • VIP", Enum.NormalId.Left)
	for i = -2, 2 do
		part(stadium, "VIPSuite", Vector3.new(13, 8, 12), Vector3.new(centre.X - 87, 20, centre.Z + i * 15), C.Glass, 0.3, true)
	end

	-- Scoreboard and clocks.
	local board = part(stadium, "Scoreboard", Vector3.new(54, 16, 2.2), Vector3.new(centre.X, 34, centre.Z - 125), C.Dark, 0, true)
	surfaceText(board, "NORTHBRIDGE FC\nFIRST MATCH STADIUM", Enum.NormalId.Front)
	local clock = part(stadium, "StadiumClock", Vector3.new(10, 10, 1.2), Vector3.new(centre.X + 38, 34, centre.Z - 124.5), C.Navy, 0, false)
	clock.Shape = Enum.PartType.Ball
	surfaceText(clock, "NFC", Enum.NormalId.Front)

	for _, p in ipairs({
		centre + Vector3.new(-92, 0, -115), centre + Vector3.new(92, 0, -115),
		centre + Vector3.new(-92, 0, 115), centre + Vector3.new(92, 0, 115),
	}) do createFloodlight(stadium, p, centre) end

	createDugout(stadium, "HomeDugout", centre + Vector3.new(-63, 0, -20), centre, C.Blue)
	createDugout(stadium, "AwayDugout", centre + Vector3.new(-63, 0, 18), centre, C.Red)

	-- Distinctive north matchday entrance and tunnel procession.
	local entryZ = centre.Z + 158
	local plaza = part(stadium, "MatchdayPlaza", Vector3.new(170, 0.45, 64), Vector3.new(centre.X, 0.18, entryZ), Color3.fromRGB(165, 169, 172), 0, true)
	plaza.Material = Enum.Material.Concrete
	for _, side in ipairs({ -1, 1 }) do
		local x = centre.X + side * 37
		part(stadium, "EntryPylon", Vector3.new(6, 30, 6), Vector3.new(x, 15, entryZ - 10), C.Navy, 0, true)
		cfPart(stadium, "EntryBlade", Vector3.new(4, 22, 10), CFrame.new(x + side * 5, 18, entryZ - 10) * CFrame.Angles(0, 0, math.rad(side * 17)), side == -1 and C.Blue or C.Red, 0, true)
	end
	local arch = part(stadium, "StadiumArch", Vector3.new(80, 6, 7), Vector3.new(centre.X, 27, entryZ - 10), C.Navy, 0, true)
	surfaceText(arch, "NORTHBRIDGE FC • MATCHDAY", Enum.NormalId.Front)
	local crest = part(stadium, "StadiumCrest", Vector3.new(10, 10, 1.4), Vector3.new(centre.X, 18, entryZ - 6), C.Blue, 0, false)
	crest.Shape = Enum.PartType.Ball
	surfaceText(crest, "NFC", Enum.NormalId.Front)
	for _, side in ipairs({ -1, 1 }) do
		local boothX = centre.X + side * 60
		part(stadium, "TicketOffice", Vector3.new(18, 10, 14), Vector3.new(boothX, 5, entryZ + 4), Color3.fromRGB(66, 73, 82), 0, true)
		part(stadium, "TicketGlass", Vector3.new(11, 4, 0.25), Vector3.new(boothX, 6, entryZ - 3.1), C.Glass, 0.2, false)
		for i = -2, 2 do part(stadium, "Turnstile", Vector3.new(1.1, 4, 1.1), Vector3.new(centre.X + side * (16 + i * 4), 2, entryZ - 5), C.Steel, 0, true) end
	end
	part(stadium, "TeamBusBay", Vector3.new(48, 0.4, 15), Vector3.new(centre.X + 75, 0.15, entryZ + 28), C.Road, 0, true).Material = Enum.Material.Asphalt
	local tunnel = part(stadium, "PlayerTunnel", Vector3.new(24, 10, 38), Vector3.new(centre.X, 5, centre.Z + 113), Color3.fromRGB(45, 49, 54), 0, true)
	local tunnelSign = part(stadium, "TunnelSign", Vector3.new(18, 3, 0.3), Vector3.new(centre.X, 8, centre.Z + 132.2), C.Navy, 0, false)
	surfaceText(tunnelSign, "PLAYERS • HOME / AWAY", Enum.NormalId.Front)
	storyNode(stadium, "StartTrialMatch", "First Trial Match", Vector3.new(centre.X, 2, centre.Z + 132), "Start Match")
	exploration(stadium, "NorthbridgeStadiumV4", "Northbridge Community Stadium", Vector3.new(centre.X + 48, 2, entryZ + 20), "Steward", "A complete football venue with four covered stands, crowd sections, concourses, VIP and media areas, floodlights, tunnel and matchday entrance.", "Explore")

	worldBuilder.FirstMatchStadium = stadium
	worldBuilder.StoryMarkers = worldBuilder.StoryMarkers or {}
	worldBuilder.StoryMarkers.StadiumArrival = Vector3.new(centre.X, 3, entryZ + 22)
	worldBuilder.StoryMarkers.StadiumTunnel = Vector3.new(centre.X, 3, centre.Z + 132)
	return stadium, centre
end

local function buildFutureRivalClub(root)
	local club = Instance.new("Model")
	club.Name = "KingsportAthleticFutureClub"
	club.Parent = root
	local base = Vector3.new(720, 0.25, -650)
	local ground = part(club, "ClubDistrictGround", Vector3.new(400, 1, 420), base + Vector3.new(0, -0.8, 0), Color3.fromRGB(64, 108, 61), 0, true)
	ground.Material = Enum.Material.Grass

	-- Future large arena: more imposing than the early Northbridge venue, but not yet used for gameplay.
	local pitchWidth, pitchLength = 116, 190
	local pitch = part(club, "FuturePitch", Vector3.new(pitchWidth, 0.5, pitchLength), base, C.DarkGrass, 0, true)
	pitch.Material = Enum.Material.Grass
	pitchMarkings(club, base, pitchWidth - 2, pitchLength - 2)
	createGoal(club, "FutureNorthGoal", base.X, base.Z + pitchLength / 2 - 1, 1, base.Y + 0.25, 27, 8.8)
	createGoal(club, "FutureSouthGoal", base.X, base.Z - pitchLength / 2 + 1, -1, base.Y + 0.25, 27, 8.8)
	standSide(club, "ArenaWest", base, pitchWidth, pitchLength, "West", 18, Color3.fromRGB(91, 38, 130))
	standSide(club, "ArenaEast", base, pitchWidth, pitchLength, "East", 18, Color3.fromRGB(91, 38, 130))
	standSide(club, "ArenaNorth", base, pitchWidth, pitchLength, "North", 15, C.White)
	standSide(club, "ArenaSouth", base, pitchWidth, pitchLength, "South", 15, C.White)
	for _, p in ipairs({ base + Vector3.new(-105, 0, -120), base + Vector3.new(105, 0, -120), base + Vector3.new(-105, 0, 120), base + Vector3.new(105, 0, 120) }) do createFloodlight(club, p, base) end
	local facade = part(club, "ArenaFacade", Vector3.new(210, 28, 8), base + Vector3.new(0, 14, 155), Color3.fromRGB(47, 40, 58), 0, true)
	local sign = part(club, "ArenaName", Vector3.new(110, 7, 0.5), base + Vector3.new(0, 19, 150.8), Color3.fromRGB(91, 38, 130), 0, false)
	surfaceText(sign, "KINGSPORT ATHLETIC\nMETROPOLITAN ARENA", Enum.NormalId.Front)

	buildTrainingPitch(club, "KingsportTrainingPitchA", base + Vector3.new(200, 0, 40), 100, 155, Color3.fromRGB(91, 38, 130))
	buildTrainingPitch(club, "KingsportTrainingPitchB", base + Vector3.new(200, 0, -135), 96, 145, Color3.fromRGB(91, 38, 130))
	part(club, "KingsportPerformanceCentre", Vector3.new(100, 18, 60), base + Vector3.new(210, 9, 155), Color3.fromRGB(55, 48, 66), 0, true)
	exploration(club, "KingsportFutureV4", "Kingsport Athletic", base + Vector3.new(0, 2, 170), "Narrator", "A richer rival club with a larger arena and elite training campus. This is a future-career destination once your reputation grows.", "Look")
	return club
end

local function correctAllSeats(worldBuilder)
	for _, seat in ipairs(worldBuilder.Model:GetDescendants()) do
		if seat:IsA("Seat") then
			local pos = seat.Position
			local target
			if worldBuilder.FirstMatchStadium and seat:IsDescendantOf(worldBuilder.FirstMatchStadium) then
				local pitch = worldBuilder.FirstMatchStadium:FindFirstChild("MatchPitch")
				target = pitch and pitch.Position or Vector3.new(-88, pos.Y, -585)
			else
				target = Vector3.new(0, pos.Y, 0)
			end
			seat.CFrame = CFrame.lookAt(pos, Vector3.new(target.X, pos.Y, target.Z))
		end
	end
end

function ClubFacilitiesV4Service:Init(worldBuilder)
	local expansionRoot = worldBuilder.Model:FindFirstChild("CareerWorldExpansion") or worldBuilder.Model
	local old = expansionRoot:FindFirstChild("ClubFacilitiesV4")
	if old then old:Destroy() end
	local root = Instance.new("Model")
	root.Name = "ClubFacilitiesV4"
	root.Parent = expansionRoot

	buildFirstTeamCentre(worldBuilder, root)
	local oldStadium = worldBuilder.FirstMatchStadium
	local oldPitch = oldStadium and oldStadium:FindFirstChild("MatchPitch")
	local stadiumCentre = oldPitch and oldPitch.Position or Vector3.new(-88, 0.25, -585)
	clearMainBoulevard(worldBuilder, -88, -178, stadiumCentre.Z + 180, 34)
	buildMainBoulevard(root, -88, -178, stadiumCentre.Z + 180, 34)
	local stadium = buildFirstStadium(worldBuilder, root)
	buildFutureRivalClub(root)
	correctAllSeats(worldBuilder)

	worldBuilder.ClubFacilitiesV4 = root
	worldBuilder.RealisticFirstStadium = stadium
end

return ClubFacilitiesV4Service
