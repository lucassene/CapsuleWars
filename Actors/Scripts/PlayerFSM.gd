extends StateMachine

func exit_falling_state():
	if controller.is_sprinting():
		set_state("Sprinting")
	else:
		set_state("Idle")

func enter_air_state():
	if actor.get_velocity().y > 0:
		set_state("Falling")
	else:
		set_state("Jumping")
