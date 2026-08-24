return {
	AcademyTrial = {
		Title = "The Trial",
		Stages = {
			Arrival = {
				Speaker = "Coach Daniels",
				Text = "Welcome to the trial. Today is about showing us who you are when the pressure starts.",
				Next = "FirstTouch",
			},
			FirstTouch = {
				Speaker = "Coach Daniels",
				Text = "Get comfortable on the ball. Your first impression starts now.",
				Next = "TrialMatch",
			},
			TrialMatch = {
				Speaker = "Coach Daniels",
				Text = "Forget the scouts. Play your football.",
				Next = "ScoutReport",
			},
			ScoutReport = {
				Speaker = "Scout",
				Text = "We've seen enough to make a decision.",
				Next = nil,
			},
		},
	},
}
