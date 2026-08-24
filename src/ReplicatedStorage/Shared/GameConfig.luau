local GameConfig = {
	Prototype = {
		PitchWidth = 110,
		PitchLength = 180,
		GoalWidth = 28,
	},
	Football = {
		KickDistance = 11,
		ShootPower = 92,
		PassPower = 55,
		ShootLift = 16,
		PassLift = 5,
		DribbleDistance = 4.5,
		DribbleBreakDistance = 15,
	},
	Match = {
		DurationSeconds = 300,
		ResetDelaySeconds = 2,
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
