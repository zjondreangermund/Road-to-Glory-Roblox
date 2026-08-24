local Players = game:GetService("Players")

local ExplorationService = {
	Visited = {},
	TotalLocations = 0,
}

local function initialisePlayer(player, total)
	player:SetAttribute("ExplorationLocation", "Academy Entrance")
	player:SetAttribute("ExplorationCount", 0)
	player:SetAttribute("ExplorationTotal", total)
end

function ExplorationService:Init(worldBuilder)
	self.WorldBuilder = worldBuilder
	local nodes = {}
	for _, descendant in ipairs(worldBuilder.Model:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant:GetAttribute("ExplorationId") then
			table.insert(nodes, descendant)
		end
	end
	self.TotalLocations = #nodes

	for _, player in ipairs(Players:GetPlayers()) do
		initialisePlayer(player, self.TotalLocations)
	end
	Players.PlayerAdded:Connect(function(player)
		initialisePlayer(player, self.TotalLocations)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self.Visited[player] = nil
	end)

	for _, node in ipairs(nodes) do
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "ExplorePrompt"
		prompt.ActionText = node:GetAttribute("ExplorationPrompt") or "Explore"
		prompt.ObjectText = node:GetAttribute("ExplorationTitle") or "Academy"
		prompt.HoldDuration = 0
		prompt.MaxActivationDistance = 10
		prompt.RequiresLineOfSight = false
		prompt.Parent = node

		prompt.Triggered:Connect(function(player)
			local id = node:GetAttribute("ExplorationId")
			local title = node:GetAttribute("ExplorationTitle") or "Academy"
			player:SetAttribute("ExplorationLocation", title)
			player:SetAttribute("StorySpeaker", node:GetAttribute("ExplorationSpeaker") or "Academy")
			player:SetAttribute("StoryText", node:GetAttribute("ExplorationText") or "")

			local visited = self.Visited[player]
			if not visited then
				visited = {}
				self.Visited[player] = visited
			end
			if id and not visited[id] then
				visited[id] = true
				local count = 0
				for _ in pairs(visited) do count += 1 end
				player:SetAttribute("ExplorationCount", count)
			end
		end)
	end
end

return ExplorationService
