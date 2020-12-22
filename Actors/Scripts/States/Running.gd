extends State

export var SPEED = 10

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_speed(SPEED)
	print("Running")

func handle_input(event):
	if player_controller.check_input_pressed(event,"jump","jump"): return

func update(actor,delta):
	player_controller.actor_on_floor()
	var velocity = actor.move(delta)
	if velocity == Vector3.ZERO:
		state_machine.set_state("Idle")
