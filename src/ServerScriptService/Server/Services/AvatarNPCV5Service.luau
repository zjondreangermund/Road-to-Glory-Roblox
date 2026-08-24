local Players = game:GetService("Players")

local AvatarNPCV5Service = {
	Built = false,
}

local STYLE = {
	Family = { Scale = 0.96, Accent = Color3.fromRGB(142, 78, 125) },
	Coach = { Scale = 1.04, Accent = Color3.fromRGB(35, 79, 145) },
	Staff = { Scale = 1.00, Accent = Color3.fromRGB(28, 45, 70) },
	Player = { Scale = 1.02, Accent = Color3.fromRGB(42, 98, 177) },
	Resident = { Scale = 0.98, Accent = Color3.fromRGB(71, 119, 79) },
	Executive = { Scale = 1.03, Accent = Color3.fromRGB(52, 55, 61) },
}

local function labelNPC(model, name)
	local head = model:FindFirstChild("Head", true)
	if not head or not head:IsA("BasePart") then return end
	local gui = Instance.new("BillboardGui")
	gui.Name = "NPCNameplate"
	gui.Size = UDim2.fromOffset(180, 36)
	gui.StudsOffset = Vector3.new(0, 2.8, 0)
	gui.MaxDistance = 38
	gui.AlwaysOnTop = false
	gui.Parent = head
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Text = name
	text.TextColor3 = Color3.new(1, 1, 1)
	text.TextStrokeTransparency = 0.25
	text.Font = Enum.Font.GothamBold
	text.TextSize = 15
	text.Parent = gui
end

local function addCareerVest(model, accent, styleName)
	local torso = model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
	if not torso or not torso:IsA("BasePart") then return end
	local vest = Instance.new("Part")
	vest.Name = "CareerVest"
	vest.Anchored = true
	vest.CanCollide = false
	vest.CanTouch = false
	vest.CanQuery = false
	vest.Material = Enum.Material.SmoothPlastic
	vest.Color = accent
	vest.Transparency = styleName == "Family" or styleName == "Resident" and 0.72 or 0.18
	vest.Size = Vector3.new(torso.Size.X + 0.12, torso.Size.Y * 0.62, torso.Size.Z + 0.15)
	vest.CFrame = torso.CFrame * CFrame.new(0, -torso.Size.Y * 0.06, -0.03)
	vest.Parent = model
end

local function anchorCharacter(model)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		humanoid.AutoRotate = false
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		end
	end
end

local function fallbackNPC(anchor, name, accent)
	local model = Instance.new("Model")
	model.Name = "NPC_" .. name
	model.Parent = anchor.Parent
	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(1, 1, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CFrame = anchor.CFrame
	root.Parent = model
	model.PrimaryPart = root
	local torso = Instance.new("Part")
	torso.Name = "UpperTorso"
	torso.Size = Vector3.new(2.2, 2.7, 1.1)
	torso.Color = accent
	torso.Anchored = true
	torso.CanCollide = false
	torso.CFrame = anchor.CFrame * CFrame.new(0, 3.1, 0)
	torso.Parent = model
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.75, 1.75, 1.75)
	head.Color = Color3.fromRGB(195, 151, 113)
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = anchor.CFrame * CFrame.new(0, 5.45, 0)
	head.Parent = model
	for _, x in ipairs({ -0.52, 0.52 }) do
		local leg = Instance.new("Part")
		leg.Name = "Leg"
		leg.Size = Vector3.new(0.76, 2.7, 0.82)
		leg.Color = Color3.fromRGB(35, 37, 42)
		leg.Anchored = true
		leg.CanCollide = false
		leg.CFrame = anchor.CFrame * CFrame.new(x, 1.4, 0)
		leg.Parent = model
	end
	labelNPC(model, name)
	return model
end

function AvatarNPCV5Service:BuildForPlayer(player)
	if self.Built or not self.WorldBuilder then return end
	local root = self.WorldBuilder.CareerWorldV5
	if not root then return end

	local description
	local ok, result = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)
	if ok then description = result end

	local folder = Instance.new("Folder")
	folder.Name = "CareerNPCs"
	folder.Parent = root
	self.WorldBuilder.CareerNPCs = folder

	for _, anchor in ipairs(root:GetDescendants()) do
		if anchor:IsA("BasePart") and anchor:GetAttribute("NPCAnchor") == true then
			local name = anchor:GetAttribute("NPCName") or "Local"
			local styleName = anchor:GetAttribute("NPCStyle") or "Resident"
			local style = STYLE[styleName] or STYLE.Resident
			local npc
			if description then
				local desc = description:Clone()
				pcall(function()
					desc.HeightScale = math.clamp((desc.HeightScale or 1) * style.Scale, 0.9, 1.08)
					desc.WidthScale = math.clamp(desc.WidthScale or 1, 0.92, 1.04)
					desc.DepthScale = math.clamp(desc.DepthScale or 1, 0.92, 1.04)
					desc.BodyTypeScale = math.clamp(desc.BodyTypeScale or 0, 0, 0.8)
					desc.ProportionScale = math.clamp(desc.ProportionScale or 0, 0, 0.8)
					-- Keep the player's hair/face style so NPCs belong visually in the same Roblox world,
					-- but remove large accessories that make staff/family look like exact duplicates.
					desc.BackAccessory = ""
					desc.FrontAccessory = ""
					desc.WaistAccessory = ""
					desc.ShouldersAccessory = ""
					desc.HatAccessory = ""
				end)
				local made, character = pcall(function()
					return Players:CreateHumanoidModelFromDescription(desc, Enum.HumanoidRigType.R15)
				end)
				if made and character then
					npc = character
					npc.Name = "NPC_" .. name
					npc.Parent = folder
					anchorCharacter(npc)
					npc:PivotTo(anchor.CFrame)
					addCareerVest(npc, style.Accent, styleName)
					labelNPC(npc, name)
				end
			end
			if not npc then
				npc = fallbackNPC(anchor, name, style.Accent)
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
		task.spawn(function() self:BuildForPlayer(existing) end)
	else
		local connection
		connection = Players.PlayerAdded:Connect(function(player)
			if connection then connection:Disconnect() end
			task.spawn(function() self:BuildForPlayer(player) end)
		end)
	end
end

return AvatarNPCV5Service
