extends State

export var AIR_ACCELERATION = 1

func enter(_delta = 0.0):
	controller.set_current_acceleration(AIR_ACCELERATION)
	actor.play_camera_anim(false)
	print("Jumping")

func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",true): return
	if controller.check_input_pressed(event,"melee","melee"): return
	if controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if controller.check_input_pressed(event,"swap","swap_equip"): return
	if controller.check_input_pressed(event,"sacrifice","sacrifice"): return
	if controller.check_input_released(event,"sprint","sprint",false): return

func update(delta):
	var movement = Vector3.ZERO
	if !actor.is_on_floor():
		movement = controller.actor_in_air(delta)
		actor.jump_sway(delta)
	if movement.y < 0.0:
		state_machine.set_state("Falling")
		return
	actor.move(delta)
