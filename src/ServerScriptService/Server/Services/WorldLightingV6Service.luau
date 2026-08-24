local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local WorldLightingV6Service = {}

local function ensure(className, name, parent)
	local existing = parent:FindFirstChild(name)
	if existing and existing.ClassName == className then return existing end
	if existing then existing:Destroy() end
	local object = Instance.new(className)
	object.Name = name
	object.Parent = parent
	return object
end

function WorldLightingV6Service:Init()
	pcall(function() Lighting.Technology = Enum.Technology.Future end)
	Lighting.GlobalShadows = true
	Lighting.ShadowSoftness = 0.28
	Lighting.Brightness = 2.15
	Lighting.ClockTime = 15.4
	Lighting.GeographicLatitude = -22.5
	Lighting.EnvironmentDiffuseScale = 0.42
	Lighting.EnvironmentSpecularScale = 0.62
	Lighting.ExposureCompensation = 0.05
	Lighting.Ambient = Color3.fromRGB(112, 119, 126)
	Lighting.OutdoorAmbient = Color3.fromRGB(142, 147, 151)

	local atmosphere = ensure("Atmosphere", "RTGWorldAtmosphere", Lighting)
	atmosphere.Density = 0.21
	atmosphere.Offset = 0.08
	atmosphere.Color = Color3.fromRGB(211, 225, 235)
	atmosphere.Decay = Color3.fromRGB(123, 137, 151)
	atmosphere.Glare = 0.08
	atmosphere.Haze = 1.15

	local correction = ensure("ColorCorrectionEffect", "RTGWorldColor", Lighting)
	correction.Brightness = 0.01
	correction.Contrast = 0.06
	correction.Saturation = 0.04
	correction.TintColor = Color3.fromRGB(255, 250, 244)

	local rays = ensure("SunRaysEffect", "RTGWorldSunRays", Lighting)
	rays.Intensity = 0.045
	rays.Spread = 0.62

	local bloom = ensure("BloomEffect", "RTGWorldBloom", Lighting)
	bloom.Intensity = 0.12
	bloom.Size = 20
	bloom.Threshold = 1.8

	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		local clouds = ensure("Clouds", "RTGWorldClouds", terrain)
		clouds.Cover = 0.28
		clouds.Density = 0.18
		clouds.Color = Color3.fromRGB(244, 246, 248)
	end
end

return WorldLightingV6Service
