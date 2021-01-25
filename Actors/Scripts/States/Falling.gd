extends State

var player_controller

func enter(actor,delta = 0.0):
	player_controller = actor.get_player_controller()
	actor.play_camera_anim(false)
	player_controller.actor_in_air(delta)
	print("Falling")

func handle_input(event):
	if player_controller.check_input_pressed(event,"escape","show_menu",true): return
	if player_controller.check_input_pressed(event,"fire","fire",true): return
	if player_controller.check_input_released(event,"fire","fire",false): return
	if player_controller.check_input_pressed(event,"melee","melee"): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return
	if player_controller.check_input_pressed(event,"reload","reload"): return
	if player_controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if player_controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if player_controller.check_input_pressed(event,"swap","swap_equip"): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return

func update(actor,delta):
	if !actor.is_on_floor():
		player_controller.actor_in_air(delta)
	elif actor.get_floor_contact():
		state_machine.exit_falling_state()
		return
	actor.move(delta)
