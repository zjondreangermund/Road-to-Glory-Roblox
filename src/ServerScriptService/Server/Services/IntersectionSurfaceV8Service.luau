local IntersectionSurfaceV8Service = {}

local ROAD = Color3.fromRGB(47, 50, 53)
local WHITE = Color3.fromRGB(242, 244, 246)

local function part(parent, name, size, position, color, transparency)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.Size = size
	p.Position = position
	p.Color = color
	p.Transparency = transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function collectRoads(root)
	local roads = {}
	for _, obj in ipairs(root:GetDescendants()) do
		if obj:IsA("BasePart")
			and obj:GetAttribute("RoadInfrastructure") == true
			and obj.Material == Enum.Material.Asphalt
			and obj.Size.Y <= 1
			and obj.Name ~= "IntersectionCap"
			and obj.Name ~= "JunctionAsphaltMask" then
			table.insert(roads, obj)
		end
	end
	return roads
end

local function overlaps(a, b)
	return math.abs(a.Position.X - b.Position.X) <= (a.Size.X + b.Size.X) / 2
		and math.abs(a.Position.Z - b.Position.Z) <= (a.Size.Z + b.Size.Z) / 2
end

local function zebraHorizontal(parent, x, z, roadWidth)
	for i = -3, 3 do
		part(parent, "CrosswalkStripe", Vector3.new(2.1, 0.035, roadWidth - 5), Vector3.new(x + i * 3.2, 0.475, z), WHITE, 0)
	end
end

local function zebraVertical(parent, x, z, roadWidth)
	for i = -3, 3 do
		part(parent, "CrosswalkStripe", Vector3.new(roadWidth - 5, 0.035, 2.1), Vector3.new(x, 0.475, z + i * 3.2), WHITE, 0)
	end
end

function IntersectionSurfaceV8Service:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root then return end
	local old = root:FindFirstChild("IntersectionSurfaceV8")
	if old then old:Destroy() end
	local layer = Instance.new("Model")
	layer.Name = "IntersectionSurfaceV8"
	layer.Parent = root

	local roads = collectRoads(root)
	local made = {}
	local count = 0
	for i = 1, #roads do
		local a = roads[i]
		local ah, av = a.Size.X > a.Size.Z * 1.5, a.Size.Z > a.Size.X * 1.5
		if ah or av then
			for j = i + 1, #roads do
				local b = roads[j]
				local bh, bv = b.Size.X > b.Size.Z * 1.5, b.Size.Z > b.Size.X * 1.5
				if ((ah and bv) or (av and bh)) and overlaps(a, b) then
					local h = ah and a or b
					local v = av and a or b
					local x, z = v.Position.X, h.Position.Z
					local key = tostring(math.floor(x + 0.5)) .. ":" .. tostring(math.floor(z + 0.5))
					if not made[key] then
						made[key] = true
						count += 1
						local mask = part(layer, "JunctionAsphaltMask", Vector3.new(v.Size.X + 16, 0.06, h.Size.Z + 16), Vector3.new(x, 0.425, z), ROAD, 0)
						mask.Material = Enum.Material.Asphalt
						mask:SetAttribute("RoadInfrastructure", true)
						mask:SetAttribute("IntersectionSurfaceV8", true)

						local northZ = z + h.Size.Z / 2 + 3.8
						local southZ = z - h.Size.Z / 2 - 3.8
						local eastX = x + v.Size.X / 2 + 3.8
						local westX = x - v.Size.X / 2 - 3.8
						zebraHorizontal(layer, x, northZ, h.Size.Z)
						zebraHorizontal(layer, x, southZ, h.Size.Z)
						zebraVertical(layer, eastX, z, v.Size.X)
						zebraVertical(layer, westX, z, v.Size.X)
					end
				end
			end
		end
	end
	root:SetAttribute("CleanIntersectionSurfaceCountV8", count)
end

return IntersectionSurfaceV8Service
