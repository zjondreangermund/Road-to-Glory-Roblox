local CareerWorldPolishService = {}

local C = {
	White = Color3.fromRGB(244, 246, 247),
	Navy = Color3.fromRGB(25, 40, 62),
	Glass = Color3.fromRGB(123, 177, 198),
	Gold = Color3.fromRGB(223, 179, 50),
	Silver = Color3.fromRGB(210, 216, 220),
	Grass = Color3.fromRGB(61, 109, 57),
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

local function surfaceText(target, text, face)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.CanvasSize = Vector2.new(700, 240)
	gui.LightInfluence = 0
	gui.Parent = target
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = C.White
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function roundPart(parent, name, size, position, color)
	local p = part(parent, name, size, position, color, 0, false)
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Metal
	return p
end

local function trophy(parent, index, label, position, kind, color)
	local model = Instance.new("Model")
	model.Name = "DisplayTrophy" .. index
	model.Parent = parent
	part(model, "Base", Vector3.new(2.35, 0.9, 2.35), position + Vector3.new(0, 0.45, 0), C.Navy, 0, true)
	part(model, "Stem", Vector3.new(0.28, 1.8, 0.28), position + Vector3.new(0, 1.8, 0), color, 0, false).Material = Enum.Material.Metal

	if kind == "world" then
		roundPart(model, "Globe", Vector3.new(1.6, 1.6, 1.6), position + Vector3.new(0, 3.2, 0), color)
		for _, x in ipairs({ -0.58, 0.58 }) do
			part(model, "GlobeSupport", Vector3.new(0.2, 1.25, 0.2), position + Vector3.new(x, 2.6, 0), color, 0, false).Material = Enum.Material.Metal
		end
	elseif kind == "league" then
		roundPart(model, "LeagueBody", Vector3.new(1.8, 1.8, 1.8), position + Vector3.new(0, 3.15, 0), color)
		for point = -2, 2 do
			part(model, "CrownPoint", Vector3.new(0.22, 1.0, 0.22), position + Vector3.new(point * 0.36, 4.25 - math.abs(point) * 0.12, 0), color, 0, false).Material = Enum.Material.Metal
		end
	else
		roundPart(model, "Cup", Vector3.new(kind == "champions" and 2.05 or 1.75, kind == "champions" and 1.9 or 1.65, 1.55), position + Vector3.new(0, 3.25, 0), color)
		for _, x in ipairs({ -1.0, 1.0 }) do
			part(model, "Handle", Vector3.new(0.2, 1.35, 0.2), position + Vector3.new(x, 3.25, 0), color, 0, false).Material = Enum.Material.Metal
		end
	end

	local plaque = part(model, "Plaque", Vector3.new(0.22, 1.15, 2.45), position + Vector3.new(-1.4, 0.85, 0), C.Navy, 0, false)
	surfaceText(plaque, string.upper(label), Enum.NormalId.Left)
end

local function fixTrophyHall(worldBuilder)
	local campus = worldBuilder.Campus
	local building = campus and campus:FindFirstChild("AcademyBuilding")
	local room = building and building:FindFirstChild("TrophyHall")
	if not room then return end
	local old = room:FindFirstChild("CareerTrophyDisplay")
	if old then old:Destroy() end
	local oldPolish = room:FindFirstChild("CompactTrophyDisplay")
	if oldPolish then oldPolish:Destroy() end

	local floor = room:FindFirstChild("Floor")
	local centre = floor and floor.Position or Vector3.new(100, 0.25, 80)
	local display = Instance.new("Model")
	display.Name = "CompactTrophyDisplay"
	display.Parent = room

	local items = {
		{ "Copa America", "cup", C.Silver },
		{ "Champions League", "champions", C.Silver },
		{ "Premier League", "league", C.Silver },
		{ "World Cup", "world", C.Gold },
		{ "African Cup", "world", C.Gold },
		{ "Club Champions", "cup", C.Silver },
	}
	local startZ = centre.Z - 6.3
	for i, item in ipairs(items) do
		trophy(display, i, item[1], Vector3.new(centre.X + 10.2, 0.5, startZ + ((i - 1) * 2.5)), item[2], item[3])
	end
	local glass = part(display, "DisplayGlass", Vector3.new(0.22, 6.7, 16), Vector3.new(centre.X + 8.65, 3.7, centre.Z), C.Glass, 0.76, false)
	glass.Material = Enum.Material.Glass
end

local function groundOriginsVillage(worldBuilder)
	local village = worldBuilder.OriginsVillage
	if not village then return end
	local old = village:FindFirstChild("VillageGround")
	if old then old:Destroy() end
	local ground = part(village, "VillageGround", Vector3.new(370, 1, 310), Vector3.new(-235, -0.55, -365), C.Grass, 0, true)
	ground.Material = Enum.Material.Grass
	-- Keep roads, buildings and football pitch visually above the rural base.
	ground:SetAttribute("EnvironmentGround", true)
end

function CareerWorldPolishService:Init(worldBuilder)
	groundOriginsVillage(worldBuilder)
	fixTrophyHall(worldBuilder)
end

return CareerWorldPolishService
