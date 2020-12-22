extends "res://Utils/scripts/State.gd"

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	print("Falling")

func update(actor,delta):
	if !actor.is_on_floor():
		player_controller.actor_in_air(delta)
	else:
		state_machine.set_state("Idle")
		return
	actor.move(delta)
