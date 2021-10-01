extends ExplodingEnemy

func override_exploding_shot(shot):
	shot.bounces = 1
