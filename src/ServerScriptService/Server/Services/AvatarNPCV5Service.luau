local Players = game:GetService("Players")

local AvatarNPCV5Service = {
	Built = false,
}

local PRESETS = {
	Family = {
		Height = 0.98, Width = 0.97, Depth = 0.97, BodyType = 0.28, Proportion = 0.35,
		Skin = Color3.fromRGB(205, 158, 116), Shirt = Color3.fromRGB(144, 83, 126),
		Pants = Color3.fromRGB(52, 55, 66), Shoes = Color3.fromRGB(230, 230, 232), Hair = Color3.fromRGB(62, 39, 24),
	},
	Coach = {
		Height = 1.04, Width = 1.02, Depth = 1.01, BodyType = 0.42, Proportion = 0.48,
		Skin = Color3.fromRGB(151, 104, 73), Shirt = Color3.fromRGB(31, 71, 135),
		Pants = Color3.fromRGB(28, 31, 37), Shoes = Color3.fromRGB(238, 238, 238), Hair = Color3.fromRGB(31, 24, 20),
	},
	Staff = {
		Height = 1.00, Width = 0.98, Depth = 0.98, BodyType = 0.32, Proportion = 0.42,
		Skin = Color3.fromRGB(189, 139, 102), Shirt = Color3.fromRGB(25, 42, 67),
		Pants = Color3.fromRGB(40, 43, 48), Shoes = Color3.fromRGB(225, 225, 227), Hair = Color3.fromRGB(76, 48, 29),
	},
	Player = {
		Height = 1.03, Width = 1.00, Depth = 1.00, BodyType = 0.50, Proportion = 0.58,
		Skin = Color3.fromRGB(177, 125, 88), Shirt = Color3.fromRGB(39, 93, 174),
		Pants = Color3.fromRGB(24, 29, 38), Shoes = Color3.fromRGB(242, 242, 242), Hair = Color3.fromRGB(42, 29, 21),
	},
	Resident = {
		Height = 0.99, Width = 0.98, Depth = 0.98, BodyType = 0.28, Proportion = 0.38,
		Skin = Color3.fromRGB(111, 75, 54), Shirt = Color3.fromRGB(72, 116, 78),
		Pants = Color3.fromRGB(49, 53, 60), Shoes = Color3.fromRGB(218, 218, 220), Hair = Color3.fromRGB(27, 22, 19),
	},
	Executive = {
		Height = 1.02, Width = 0.98, Depth = 0.98, BodyType = 0.35, Proportion = 0.48,
		Skin = Color3.fromRGB(220, 174, 131), Shirt = Color3.fromRGB(48, 51, 58),
		Pants = Color3.fromRGB(22, 24, 28), Shoes = Color3.fromRGB(24, 24, 25), Hair = Color3.fromRGB(86, 60, 37),
	},
}

local function stableVariant(name)
	local total = 0
	for i = 1, #name do total += string.byte(name, i) end
	return total
end

local function labelNPC(model, name)
	local head = model:FindFirstChild("Head", true)
	if not head or not head:IsA("BasePart") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "NPCNameplate"
	gui.Size = UDim2.fromOffset(180, 34)
	gui.StudsOffset = Vector3.new(0, 2.7, 0)
	gui.MaxDistance = 34
	gui.AlwaysOnTop = false
	gui.Parent = head
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = name
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.32
	text.Font = Enum.Font.GothamBold
	text.TextSize = 14
	text.Parent = gui
end

local function anchorCharacter(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.AutoRotate = false
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.BreakJointsOnDeath = false
	end
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
		end
	end
end

local function applyOutfit(model, preset, variant)
	local brighten = ((variant % 5) - 2) * 0.025
	local function tint(color)
		return Color3.new(
			math.clamp(color.R + brighten, 0, 1),
			math.clamp(color.G + brighten, 0, 1),
			math.clamp(color.B + brighten, 0, 1)
		)
	end
	local shirt = tint(preset.Shirt)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			local n = item.Name
			if n == "Head" or string.find(n, "Arm") or string.find(n, "Hand") then
				item.Color = preset.Skin
			elseif n == "UpperTorso" then
				item.Color = shirt
			elseif n == "LowerTorso" or string.find(n, "UpperLeg") or string.find(n, "LowerLeg") then
				item.Color = preset.Pants
			elseif string.find(n, "Foot") then
				item.Color = preset.Shoes
			end
		end
	end
end

local function addSimpleHair(model, color, variant)
	local head = model:FindFirstChild("Head", true)
	if not head or not head:IsA("BasePart") then return end
	local hair = Instance.new("Part")
	hair.Name = "RTGHair"
	hair.Anchored = true
	hair.CanCollide = false
	hair.CanTouch = false
	hair.CanQuery = false
	hair.Shape = Enum.PartType.Ball
	hair.Material = Enum.Material.SmoothPlastic
	hair.Color = color
	hair.Size = Vector3.new(head.Size.X * 1.04, head.Size.Y * 0.52, head.Size.Z * 1.04)
	hair.CFrame = head.CFrame * CFrame.new(0, head.Size.Y * 0.39, 0)
	hair.Parent = model
	if variant % 3 == 0 then
		local fringe = Instance.new("Part")
		fringe.Name = "RTGHairFringe"
		fringe.Anchored = true
		fringe.CanCollide = false
		fringe.CanTouch = false
		fringe.CanQuery = false
		fringe.Material = Enum.Material.SmoothPlastic
		fringe.Color = color
		fringe.Size = Vector3.new(head.Size.X * 0.75, head.Size.Y * 0.22, head.Size.Z * 0.22)
		fringe.CFrame = head.CFrame * CFrame.new(0, head.Size.Y * 0.29, -head.Size.Z * 0.47) * CFrame.Angles(math.rad(-12), 0, 0)
		fringe.Parent = model
	end
end

local function placeOnGround(model, anchor)
	model:PivotTo(anchor.CFrame)
	local boxCF, boxSize = model:GetBoundingBox()
	local currentBottom = boxCF.Position.Y - (boxSize.Y / 2)
	local lift = anchor.Position.Y - currentBottom + 0.04
	model:PivotTo(model:GetPivot() + Vector3.new(0, lift, 0))
end

local function makeDescription(preset, variant)
	local desc = Instance.new("HumanoidDescription")
	desc.HeightScale = math.clamp(preset.Height + (((variant % 5) - 2) * 0.012), 0.92, 1.08)
	desc.WidthScale = math.clamp(preset.Width + (((variant % 3) - 1) * 0.01), 0.92, 1.05)
	desc.DepthScale = preset.Depth
	desc.HeadScale = 1
	desc.BodyTypeScale = preset.BodyType
	desc.ProportionScale = preset.Proportion

	-- Standard R15 human structure only. No player face, hair, body package,
	-- accessories or clothing is copied from the user's avatar.
	desc.Head = 0
	desc.Torso = 0
	desc.LeftArm = 0
	desc.RightArm = 0
	desc.LeftLeg = 0
	desc.RightLeg = 0
	desc.Face = 0
	desc.GraphicTShirt = 0
	desc.Shirt = 0
	desc.Pants = 0
	desc.HatAccessory = ""
	desc.HairAccessory = ""
	desc.FaceAccessory = ""
	desc.NeckAccessory = ""
	desc.ShouldersAccessory = ""
	desc.FrontAccessory = ""
	desc.BackAccessory = ""
	desc.WaistAccessory = ""
	desc.HeadColor = preset.Skin
	desc.LeftArmColor = preset.Skin
	desc.RightArmColor = preset.Skin
	desc.LeftLegColor = preset.Pants
	desc.RightLegColor = preset.Pants
	desc.TorsoColor = preset.Shirt
	return desc
end

local function buildFallback(anchor, name, preset, variant)
	local model = Instance.new("Model")
	model.Name = "NPC_" .. name
	model.Parent = anchor.Parent
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CFrame = anchor.CFrame * CFrame.new(0, 3, 0)
	root.Parent = model
	model.PrimaryPart = root
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.Parent = model

	local torso = Instance.new("Part")
	torso.Name = "UpperTorso"
	torso.Size = Vector3.new(2.1, 2.4, 1.05)
	torso.Color = preset.Shirt
	torso.Anchored = true
	torso.CanCollide = false
	torso.CFrame = root.CFrame
	torso.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.7, 1.7, 1.7)
	head.Color = preset.Skin
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = root.CFrame * CFrame.new(0, 2.05, 0)
	head.Parent = model
	for _, x in ipairs({ -0.48, 0.48 }) do
		local leg = Instance.new("Part")
		leg.Name = "LowerLeg"
		leg.Size = Vector3.new(0.72, 2.5, 0.8)
		leg.Color = preset.Pants
		leg.Anchored = true
		leg.CanCollide = false
		leg.CFrame = root.CFrame * CFrame.new(x, -2.35, 0)
		leg.Parent = model
	end
	for _, x in ipairs({ -1.35, 1.35 }) do
		local arm = Instance.new("Part")
		arm.Name = "LowerArm"
		arm.Size = Vector3.new(0.65, 2.25, 0.65)
		arm.Color = preset.Skin
		arm.Anchored = true
		arm.CanCollide = false
		arm.CFrame = root.CFrame * CFrame.new(x, -0.05, 0)
		arm.Parent = model
	end
	addSimpleHair(model, preset.Hair, variant)
	labelNPC(model, name)
	placeOnGround(model, anchor)
	return model
end

function AvatarNPCV5Service:BuildForPlayer(_player)
	if self.Built or not self.WorldBuilder then return end
	local root = self.WorldBuilder.CareerWorldV5
	if not root then return end

	local old = root:FindFirstChild("CareerNPCs")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "CareerNPCs"
	folder.Parent = root
	self.WorldBuilder.CareerNPCs = folder

	for _, anchor in ipairs(root:GetDescendants()) do
		if anchor:IsA("BasePart") and anchor:GetAttribute("NPCAnchor") == true then
			local name = anchor:GetAttribute("NPCName") or "Local"
			local styleName = anchor:GetAttribute("NPCStyle") or "Resident"
			local preset = PRESETS[styleName] or PRESETS.Resident
			local variant = stableVariant(name)
			local npc
			local description = makeDescription(preset, variant)
			local made, character = pcall(function()
				return Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R15)
			end)
			description:Destroy()
			if made and character then
				npc = character
				npc.Name = "NPC_" .. name
				npc.Parent = folder
				anchorCharacter(npc)
				applyOutfit(npc, preset, variant)
				addSimpleHair(npc, preset.Hair, variant)
				labelNPC(npc, name)
				placeOnGround(npc, anchor)
			else
				npc = buildFallback(anchor, name, preset, variant)
				npc.Parent = folder
			end
			anchor:SetAttribute("NPCBuilt", true)
		end
	end
	self.Built = true
end

function AvatarNPCV5Service:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	local existing = Players:GetPlayers()[1]
	if existing then
		task.defer(function() self:BuildForPlayer(existing) end)
	else
		local connection
		connection = Players.PlayerAdded:Connect(function(player)
			if connection then connection:Disconnect() end
			task.defer(function() self:BuildForPlayer(player) end)
		end)
	end
end

return AvatarNPCV5Service
