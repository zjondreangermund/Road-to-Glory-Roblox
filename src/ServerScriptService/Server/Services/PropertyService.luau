local Players = game:GetService("Players")

local PropertyService = {}

local function setStory(player, speaker, text)
	player:SetAttribute("StorySpeaker", speaker)
	player:SetAttribute("StoryText", text)
end

local function countOwned(ownedHomes)
	local total = 0
	for _, owned in pairs(ownedHomes or {}) do
		if owned then total += 1 end
	end
	return total
end

function PropertyService:RefreshPlayer(player, profile)
	local properties = profile.Properties or {}
	local currentHome = properties.CurrentHome or ""
	player:SetAttribute("CareerMoney", profile.Career.Money or 0)
	player:SetAttribute("CurrentHome", currentHome)
	player:SetAttribute("OwnedHomeCount", countOwned(properties.OwnedHomes))
end

function PropertyService:HandlePurchase(player, node)
	local profile = self.PlayerDataService:Get(player)
	if not profile then return end

	profile.Properties = profile.Properties or { OwnedHomes = {}, CurrentHome = "" }
	profile.Properties.OwnedHomes = profile.Properties.OwnedHomes or {}
	local id = node:GetAttribute("PropertyId")
	local name = node:GetAttribute("PropertyName") or "Starter Home"
	local price = tonumber(node:GetAttribute("PropertyPrice")) or 0
	if not id then return end

	if profile.Properties.OwnedHomes[id] then
		profile.Properties.CurrentHome = id
		self:RefreshPlayer(player, profile)
		setStory(player, "Estate Agent", name .. " is already yours. It is now set as your current home.")
		return
	end

	local money = tonumber(profile.Career.Money) or 0
	if money < price then
		local short = price - money
		setStory(player, "Estate Agent", string.format("%s costs N$%d. You currently have N$%d, so you still need N$%d.", name, price, money, short))
		return
	end

	profile.Career.Money = money - price
	profile.Properties.OwnedHomes[id] = true
	profile.Properties.CurrentHome = id
	self:RefreshPlayer(player, profile)
	setStory(player, "Estate Agent", string.format("You bought %s for N$%d. Balance: N$%d. As your career grows, better homes will unlock.", name, price, profile.Career.Money))
end

function PropertyService:Init(worldBuilder, playerDataService)
	self.WorldBuilder = worldBuilder
	self.PlayerDataService = playerDataService

	for _, player in ipairs(Players:GetPlayers()) do
		local profile = playerDataService:Get(player)
		if profile then self:RefreshPlayer(player, profile) end
	end
	Players.PlayerAdded:Connect(function(player)
		task.defer(function()
			local profile = playerDataService:Get(player)
			if profile then self:RefreshPlayer(player, profile) end
		end)
	end)

	for _, node in ipairs(worldBuilder.Model:GetDescendants()) do
		if node:IsA("BasePart") and node:GetAttribute("PropertyId") then
			local price = tonumber(node:GetAttribute("PropertyPrice")) or 0
			local name = node:GetAttribute("PropertyName") or "Starter Home"
			local prompt = Instance.new("ProximityPrompt")
			prompt.Name = "PropertyPrompt"
			prompt.ActionText = string.format("Buy N$%d", price)
			prompt.ObjectText = name
			prompt.HoldDuration = 0.5
			prompt.MaxActivationDistance = 10
			prompt.RequiresLineOfSight = false
			prompt.Parent = node
			prompt.Triggered:Connect(function(player)
				self:HandlePurchase(player, node)
			end)
		end
	end
end

return PropertyService
