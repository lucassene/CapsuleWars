extends State

export var AIR_ACCELERATION = 1

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_acceleration(AIR_ACCELERATION)
	print("Jumping")

func update(actor,delta):
	var movement = Vector3.ZERO
	if !actor.is_on_floor():
		movement = player_controller.actor_in_air(delta)
	if movement.y < 0.0:
		state_machine.set_state("Falling")
		return
	actor.move(delta)
