local CareerNPCPopulationV5Service = {}

local function anchor(parent, name, style, position, lookAt, dialogue)
	local p = Instance.new("Part")
	p.Name = "NPCAnchor_" .. string.gsub(name, " ", "")
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Transparency = 1
	p.Size = Vector3.new(2, 3, 2)
	p.CFrame = CFrame.lookAt(position, Vector3.new(lookAt.X, position.Y, lookAt.Z))
	p:SetAttribute("NPCAnchor", true)
	p:SetAttribute("NPCName", name)
	p:SetAttribute("NPCStyle", style)
	p:SetAttribute("ExplorationId", "NPCV5_" .. string.gsub(name, " ", ""))
	p:SetAttribute("ExplorationTitle", name)
	p:SetAttribute("ExplorationSpeaker", name)
	p:SetAttribute("ExplorationText", dialogue)
	p:SetAttribute("ExplorationPrompt", "Talk")
	p.Parent = parent
	return p
end

local DIALOGUE = {
	["Coach Daniels"] = "Talent gets you through the gate. Decisions, discipline and consistency decide whether you stay.",
	["Scout Meyer"] = "I am not counting stepovers. I am watching what you see before the ball reaches you.",
	["Physio Amina"] = "A career is only as strong as the body carrying it. Recovery is part of training, not time away from training.",
	["Kai Williams"] = "The first day feels massive. It gets bigger. Enjoy it, then earn the next one.",
}

function CareerNPCPopulationV5Service:Init(worldBuilder)
	local root = worldBuilder.CareerWorldV5
	if not root then return end

	-- Existing academy anchors become fully talkable without duplicating their visual NPCs.
	for _, p in ipairs(root:GetDescendants()) do
		if p:IsA("BasePart") and p:GetAttribute("NPCAnchor") == true then
			local name = p:GetAttribute("NPCName")
			if DIALOGUE[name] and not p:GetAttribute("StoryAction") then
				p:SetAttribute("ExplorationId", "NPCV5_" .. string.gsub(name, " ", ""))
				p:SetAttribute("ExplorationTitle", name)
				p:SetAttribute("ExplorationSpeaker", name)
				p:SetAttribute("ExplorationText", DIALOGUE[name])
				p:SetAttribute("ExplorationPrompt", "Talk")
			end
		end
	end

	local origins = root:FindFirstChild("OriginsDistrict")
	if origins then
		anchor(origins, "Nandi", "Resident", Vector3.new(-446, 0.5, -132), Vector3.new(-445, 0.5, -110), "Your mum has been talking about this trial all week. Take some water before you go.")
		anchor(origins, "Uncle Ben", "Resident", Vector3.new(-845, 0.5, -90), Vector3.new(-820, 0.5, -90), "We used to watch you kick a flat ball against that wall. Now there is an academy bus waiting.")
		anchor(origins, "Jay", "Player", Vector3.new(-820, 0.5, 155), Vector3.new(-775, 0.5, 110), "When you make it, bring boots back for the kids here. Mine are nearly finished.")
	end

	local riverstone = root:FindFirstChild("RiverstoneSuburb")
	if riverstone then
		anchor(riverstone, "Levi", "Player", Vector3.new(610, 0.5, -85), Vector3.new(650, 0.5, 0), "I got my first semi-pro deal last season. Riverstone felt impossible when I was still catching the bus from Origins.")
		anchor(riverstone, "Mrs Jacobs", "Resident", Vector3.new(705, 0.5, 95), Vector3.new(650, 0.5, 110), "The footballers move in, then suddenly every child in the park wants a number ten shirt.")
	end

	local town = root:FindFirstChild("NorthbridgeTownCentre")
	if town then
		anchor(town, "Mara", "Resident", Vector3.new(-150, 0.5, 790), Vector3.new(-180, 0.5, 825), "New boots do not improve bad decisions, but the right pair certainly feels quicker.")
		anchor(town, "Daniel Reed", "Staff", Vector3.new(150, 0.5, 540), Vector3.new(180, 0.5, 575), "Northbridge Daily. One good trial and people want a story. Two good matches and they want an interview.")
		anchor(town, "Mr Cole", "Executive", Vector3.new(220, 0.5, 790), Vector3.new(180, 0.5, 825), "Come back when the signing bonus lands. The sports coupe will still be here.")
		anchor(town, "Lina", "Resident", Vector3.new(55, 0.5, 795), Vector3.new(100, 0.5, 825), "Players, coaches and journalists all end up here after training. Coffee keeps half the league functioning.")
	end

	local kingsview = root:FindFirstChild("KingsviewHeights")
	if kingsview then
		anchor(kingsview, "Estate Agent Nadia", "Executive", Vector3.new(650, 0.5, 690), Vector3.new(650, 0.5, 700), "These homes are not starter properties. They are milestones. Win enough, save enough, then choose carefully.")
		anchor(kingsview, "Veteran Musa", "Player", Vector3.new(745, 0.5, 545), Vector3.new(785, 0.5, 575), "The expensive house is easy. Staying good enough to keep it is the difficult part.")
	end

	local stadium = root:FindFirstChild("NorthbridgeCityStadium")
	if stadium then
		anchor(stadium, "Steward Paul", "Staff", Vector3.new(82, 0.5, -560), Vector3.new(0, 0.5, -610), "Players use the centre route. Supporters enter through the outer turnstiles. Matchday gets busy quickly.")
		anchor(stadium, "Groundsman Eli", "Staff", Vector3.new(-76, 0.5, -655), Vector3.new(0, 0.5, -750), "A good pitch should disappear under the football. If players are talking about the grass, I have done something wrong.")
	end

	local kingsport = root:FindFirstChild("KingsportAthleticComplex")
	if kingsport then
		anchor(kingsport, "Kingsport Scout", "Staff", Vector3.new(1190, 0.5, -520), Vector3.new(1275, 0.5, -750), "Northbridge develops players. Kingsport buys players who prove they can decide matches.")
		anchor(kingsport, "Rival Fan", "Resident", Vector3.new(1400, 0.5, -520), Vector3.new(1275, 0.5, -750), "Come back here in a Northbridge shirt and you will find out what an away day sounds like.")
	end
end

return CareerNPCPopulationV5Service
