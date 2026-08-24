local GameConfig = {
	Prototype = {
		PitchWidth = 110,
		PitchLength = 180,
		GoalWidth = 28,
		BoundaryPadding = 5,
		BoundaryHeight = 8,
		BoundaryThickness = 1.5,
		BoundaryTransparency = 0.45,
	},
	Football = {
		KickDistance = 11,
		ShootPower = 92,
		PassPower = 55,
		ShootLift = 16,
		PassLift = 5,
		DribbleDistance = 4.6,
		DribbleBreakDistance = 12,
		DribbleHeightOffset = -1.9,
	},
	Match = {
		DurationSeconds = 300,
		ResetDelaySeconds = 2,
		AutoRestart = false,
	},
	Training = {
		SprintGoldTime = 3.2,
		DribbleGoldTime = 14,
	},
	Rating = {
		Start = 6.0,
		Minimum = 1.0,
		Maximum = 10.0,
		GoalBonus = 0.7,
	},
	Career = {
		EnablePersistence = false,
		DataStoreName = "RoadToGloryCareer_v1",
	},
}

return GameConfig
