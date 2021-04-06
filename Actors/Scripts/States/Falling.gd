extends State

func enter(delta = 0.0):
	actor.play_camera_anim(false)
	controller.actor_in_air(delta)
	print("Falling")

func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",true): return
	if controller.check_input_pressed(event,"melee","melee"): return
	if controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if controller.check_input_pressed(event,"swap","swap_equip"): return
	if controller.check_input_pressed(event,"sacrifice","sacrifice"): return
	if controller.check_input_released(event,"sprint","sprint",false): return

func update(delta):
	if !actor.is_on_floor():
		controller.actor_in_air(delta)
		actor.falling_sway(delta)
	elif actor.get_floor_contact():
		state_machine.set_state("Idle")
		return
	actor.move(delta)
