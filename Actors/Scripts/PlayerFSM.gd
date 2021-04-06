extends StateMachine

func enter_air_state():
	if actor.get_velocity().y > 0:
		set_state("Falling")
	else:
		set_state("Jumping")
