extends State

export var H_ACCELERATION = 7

func enter(_delta = 0.0):
	controller.set_current_acceleration(H_ACCELERATION)
	if controller.is_sprinting():
		state_machine.set_state("Sprinting")
		return
	controller.reset_speed()
	actor.set_is_moving(false)
	actor.play_camera_anim(false)
	print("Idle")
	
func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",true): return
	if controller.check_input_pressed(event,"jump","jump"): return
	if controller.check_input_pressed(event,"melee","melee"): return
	if controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if controller.check_input_pressed(event,"swap","swap_equip"): return
	if controller.check_input_pressed(event,"sacrifice","sacrifice"): return
	if controller.check_input_released(event,"sprint","sprint",false): return

func update(_delta):
	if !controller.actor_on_floor():
		state_machine.set_state("Falling")
	if get_x_movement() != 0 or get_z_movement() != 0: state_machine.set_state("Running")

func get_x_movement():
	return Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

func get_z_movement():
	return Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
