local AssetService = game:GetService("AssetService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Catalog = require(ReplicatedStorage.Shared.WorldAssetCatalog)

local ExternalWorldAssetsService = {}

local SCRIPT_OR_INTERACTION_CLASSES = {
	Script = true,
	LocalScript = true,
	ModuleScript = true,
	ProximityPrompt = true,
	ClickDetector = true,
	TouchTransmitter = true,
	RemoteEvent = true,
	RemoteFunction = true,
	BindableEvent = true,
	BindableFunction = true,
	SpawnLocation = true,
}

local function sanitizeAsset(model)
	for _, descendant in ipairs(model:GetDescendants()) do
		if SCRIPT_OR_INTERACTION_CLASSES[descendant.ClassName] then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			-- Remove invisible non-collidable helper/trigger parts so they do not distort scaling.
			if descendant.Transparency >= 0.99 and descendant.CanCollide == false then
				descendant:Destroy()
			end
		elseif descendant:IsA("Humanoid") or descendant:IsA("AnimationController") then
			descendant:Destroy()
		end
	end
	model:SetAttribute("RTGExternalAssetSanitized", true)
end

local function fitAndGround(model, targetPosition, yaw, maxFootprint)
	local size = model:GetExtentsSize()
	if size.X < 0.05 or size.Y < 0.05 or size.Z < 0.05 then
		return false, "asset has no usable 3D bounds"
	end

	local scale = math.min(
		maxFootprint.X / math.max(size.X, 0.01),
		maxFootprint.Y / math.max(size.Y, 0.01),
		maxFootprint.Z / math.max(size.Z, 0.01)
	)
	scale = math.clamp(scale, 0.03, 6)
	model:ScaleTo(model:GetScale() * scale)

	-- First orient the model, then use its real bounding box to centre and ground it.
	model:PivotTo(CFrame.new(targetPosition + Vector3.new(0, maxFootprint.Y * 0.5, 0)) * CFrame.Angles(0, math.rad(yaw or 0), 0))
	local boxCf, boxSize = model:GetBoundingBox()
	local bottom = boxCf.Position.Y - boxSize.Y / 2
	local desiredBottom = targetPosition.Y + 0.12
	local correction = Vector3.new(
		targetPosition.X - boxCf.Position.X,
		desiredBottom - bottom,
		targetPosition.Z - boxCf.Position.Z
	)
	model:PivotTo(model:GetPivot() + correction)
	return true
end

local function makePlotBase(parent, entry)
	local oldPlot = parent:FindFirstChild("ExternalPlot_" .. entry.PropertyId)
	if oldPlot then oldPlot:Destroy() end
	local plot = Instance.new("Model")
	plot.Name = "ExternalPlot_" .. entry.PropertyId
	plot.Parent = parent

	local isLuxury = string.find(entry.TargetDistrict, "Kingsview") ~= nil
	local lawnSize = isLuxury and Vector3.new(112, 0.18, 94) or Vector3.new(54, 0.18, 48)
	local lawn = Instance.new("Part")
	lawn.Name = "Lawn"
	lawn.Anchored = true
	lawn.CanCollide = true
	lawn.Size = lawnSize
	lawn.Position = entry.Position + Vector3.new(0, 0.08, 0)
	lawn.Color = isLuxury and Color3.fromRGB(59, 111, 61) or Color3.fromRGB(77, 119, 68)
	lawn.Material = Enum.Material.Grass
	lawn.Parent = plot

	local drive = Instance.new("Part")
	drive.Name = "Driveway"
	drive.Anchored = true
	drive.CanCollide = true
	drive.Size = isLuxury and Vector3.new(30, 0.16, 16) or Vector3.new(14, 0.16, 14)
	drive.Position = entry.Position + Vector3.new(0, 0.17, -(lawnSize.Z / 2 - drive.Size.Z / 2))
	drive.Color = Color3.fromRGB(170, 173, 176)
	drive.Material = Enum.Material.Concrete
	drive.Parent = plot
	return plot
end

local function makePropertyNode(parent, entry)
	local node = Instance.new("Part")
	node.Name = "Property_" .. entry.PropertyId
	node.Anchored = true
	node.CanCollide = false
	node.CanTouch = false
	node.Transparency = 1
	node.Size = Vector3.new(2, 3, 2)
	node.Position = entry.Position + Vector3.new(0, 2, -(entry.MaxFootprint.Z / 2 + 3))
	node:SetAttribute("PropertyId", entry.PropertyId)
	node:SetAttribute("PropertyName", entry.DisplayName)
	node:SetAttribute("PropertyPrice", entry.Price)
	node:SetAttribute("ExternalAssetId", entry.AssetId)
	node.Parent = parent
	return node
end

local function loadExternalAsset(assetId)
	local ok, loaded = pcall(AssetService.LoadAssetAsync, AssetService, assetId)
	if not ok or not loaded then
		return nil, tostring(loaded)
	end
	return loaded
end

function ExternalWorldAssetsService:ReplaceResidential(root, entry)
	local district = root:FindFirstChild(entry.TargetDistrict)
	if not district then
		warn(string.format("RTG 3D asset %d skipped: district %s not found", entry.AssetId, entry.TargetDistrict))
		return false
	end

	local oldModel = district:FindFirstChild(entry.TargetModel)
	local loaded, loadError = loadExternalAsset(entry.AssetId)
	if not loaded then
		warn(string.format("RTG 3D asset %d failed to load for %s: %s", entry.AssetId, entry.DisplayName, loadError or "unknown error"))
		return false
	end

	sanitizeAsset(loaded)
	loaded.Name = "3D_" .. entry.PropertyId
	loaded:SetAttribute("ExternalAssetId", entry.AssetId)
	loaded:SetAttribute("ExternalAssetRole", "ResidentialModern")
	loaded:SetAttribute("PropertyDisplayName", entry.DisplayName)

	local fitted, fitError = fitAndGround(loaded, entry.Position, entry.Yaw, entry.MaxFootprint)
	if not fitted then
		loaded:Destroy()
		warn(string.format("RTG 3D asset %d could not be fitted: %s", entry.AssetId, fitError or "unknown error"))
		return false
	end

	-- Only remove the procedural placeholder after the real model is confirmed usable.
	if oldModel then oldModel:Destroy() end
	makePlotBase(district, entry)
	makePropertyNode(loaded, entry)
	loaded.Parent = district
	return true
end

function ExternalWorldAssetsService:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root or not root.Parent then
		warn("RTG ExternalWorldAssets: CareerWorldV5 is not ready")
		return
	end

	local allowCheckOk, allowThirdParty = pcall(function()
		return AssetService.AllowInsertFreeAssets
	end)
	if allowCheckOk and allowThirdParty == false then
		warn("RTG ExternalWorldAssets: third-party Creator Store loading is OFF. In Roblox Studio enable Experience/Game Settings > Security > Allow Loading Third Party Assets, then restart Play.")
	end

	local loadedCount = 0
	local total = #(Catalog.ResidentialModern or {})
	for _, entry in ipairs(Catalog.ResidentialModern or {}) do
		if self:ReplaceResidential(root, entry) then
			loadedCount += 1
		end
		task.wait(0.05)
	end

	root:SetAttribute("ExternalResidentialAssetCount", loadedCount)
	root:SetAttribute("ExternalResidentialAssetTargetCount", total)
	root:SetAttribute("ExternalResidentialAssetsVersion", "V7")
	worldBuilder.ExternalWorldAssets = self
	print(string.format("Road to Glory external 3D residential assets: %d/%d loaded", loadedCount, total))
end

return ExternalWorldAssetsService
