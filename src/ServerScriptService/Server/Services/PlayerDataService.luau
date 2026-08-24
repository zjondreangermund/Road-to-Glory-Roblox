local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Defaults = require(ReplicatedStorage.Shared.CareerDefaults)
local GameConfig = require(ReplicatedStorage.Shared.GameConfig)

local PlayerDataService = {
	Profiles = {},
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end
	local copy = {}
	for key, child in pairs(value) do
		copy[key] = deepCopy(child)
	end
	return copy
end

function PlayerDataService:ApplyAttributes(player, profile)
	player:SetAttribute("CareerChapter", profile.Career.Chapter)
	player:SetAttribute("CareerStage", profile.Career.Stage)
	player:SetAttribute("Overall", profile.Career.Overall)
	player:SetAttribute("ManagerTrust", profile.Career.ManagerTrust)
	player:SetAttribute("Position", profile.Identity.Position)
end

function PlayerDataService:Load(player)
	local profile = deepCopy(Defaults)

	if GameConfig.Career.EnablePersistence then
		local store = DataStoreService:GetDataStore(GameConfig.Career.DataStoreName)
		local success, saved = pcall(function()
			return store:GetAsync(tostring(player.UserId))
		end)
		if success and type(saved) == "table" then
			profile = saved
		elseif not success then
			warn("Road to Glory: career load failed for", player.UserId)
		end
	end

	self.Profiles[player] = profile
	self:ApplyAttributes(player, profile)
	return profile
end

function PlayerDataService:Get(player)
	return self.Profiles[player]
end

function PlayerDataService:Save(player)
	local profile = self.Profiles[player]
	if not profile or not GameConfig.Career.EnablePersistence then
		return
	end
	local store = DataStoreService:GetDataStore(GameConfig.Career.DataStoreName)
	local success = pcall(function()
		store:SetAsync(tostring(player.UserId), profile)
	end)
	if not success then
		warn("Road to Glory: career save failed for", player.UserId)
	end
end

function PlayerDataService:Init()
	Players.PlayerAdded:Connect(function(player)
		self:Load(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:Save(player)
		self.Profiles[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		self:Load(player)
	end
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			self:Save(player)
		end
	end)
end

return PlayerDataService
