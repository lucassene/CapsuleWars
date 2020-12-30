extends State

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	actor.set_dead_state(true)
	print("Dead")
