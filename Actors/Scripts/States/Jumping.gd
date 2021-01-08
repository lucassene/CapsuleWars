extends State

export var AIR_ACCELERATION = 1

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_acceleration(AIR_ACCELERATION)
	actor.play_camera_anim(false)
	print("Jumping")

func handle_input(event):
	if player_controller.check_input_pressed(event,"escape","show_menu",true): return
	if player_controller.check_input_pressed(event,"fire","fire",true): return
	if player_controller.check_input_released(event,"fire","fire",false): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return
	if player_controller.check_input_pressed(event,"reload","reload"): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return

func update(actor,delta):
	var movement = Vector3.ZERO
	if !actor.is_on_floor():
		movement = player_controller.actor_in_air(delta)
	if movement.y < 0.0:
		state_machine.set_state("Falling")
		return
	actor.move(delta)
