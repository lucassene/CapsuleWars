extends StateMachine

var player_controller

func initialize(first_state):
	player_controller = actor.get_player_controller()
	.initialize(first_state)

func exit_falling_state():
	if player_controller.is_sprinting():
		set_state("Sprinting")
	else:
		set_state("Idle")

func enter_air_state():
	if actor.get_velocity().y > 0:
		set_state("Falling")
	else:
		set_state("Jumping")
