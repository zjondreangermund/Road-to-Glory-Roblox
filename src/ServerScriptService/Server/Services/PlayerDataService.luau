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

local function mergeMissing(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then
			target[key] = deepCopy(value)
		elseif type(value) == "table" and type(target[key]) == "table" then
			mergeMissing(target[key], value)
		end
	end
	return target
end

function PlayerDataService:Migrate(profile)
	profile = type(profile) == "table" and profile or deepCopy(Defaults)
	mergeMissing(profile, Defaults)
	profile.Version = Defaults.Version
	profile.Properties = profile.Properties or { OwnedHomes = {}, CurrentHome = "" }
	profile.Properties.OwnedHomes = profile.Properties.OwnedHomes or {}
	profile.Properties.CurrentHome = profile.Properties.CurrentHome or ""
	profile.Career.Money = tonumber(profile.Career.Money) or Defaults.Career.Money
	return profile
end

function PlayerDataService:ApplyAttributes(player, profile)
	player:SetAttribute("CareerChapter", profile.Career.Chapter)
	player:SetAttribute("CareerStage", profile.Career.Stage)
	player:SetAttribute("Overall", profile.Career.Overall)
	player:SetAttribute("ManagerTrust", profile.Career.ManagerTrust)
	player:SetAttribute("Position", profile.Identity.Position)
	player:SetAttribute("CareerMoney", profile.Career.Money or 0)
	player:SetAttribute("CurrentHome", profile.Properties and profile.Properties.CurrentHome or "")
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

	profile = self:Migrate(profile)
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
