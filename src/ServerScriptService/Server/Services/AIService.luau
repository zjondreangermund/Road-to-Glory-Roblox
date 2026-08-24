local AIService = {}

function AIService:Init()
	-- V0.1 reserves the service boundary for teammate, opponent and goalkeeper AI.
	-- V0.2 will add academy drill targets first, followed by match agents.
	self.Ready = true
end

return AIService
