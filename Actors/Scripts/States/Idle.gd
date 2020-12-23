extends State

export var H_ACCELERATION = 7

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_acceleration(H_ACCELERATION)
	print("Idle")
	
func handle_input(event):
	if player_controller.check_input_pressed(event,"jump","jump"): return
	if player_controller.check_input_pressed(event,"fire","fire"): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return

func update(_actor,_delta):
	player_controller.actor_on_floor()
	if get_x_movement() != 0 or get_z_movement() != 0: state_machine.set_state("Running")

func get_x_movement():
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

func get_z_movement():
	return Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
