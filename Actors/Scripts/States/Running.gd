extends State

export var SPEED = 11.5
export var FOOTSTEP_DELAY = 0.35

var player_controller
var timer = 0

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_speed(SPEED)
	actor.set_is_moving(true)
	actor.play_camera_anim(true)
	timer = 0
	print("Running")

func handle_input(event):
	if player_controller.check_input_pressed(event,"jump","jump"): return
	if player_controller.check_input_pressed(event,"fire","fire",true): return
	if player_controller.check_input_released(event,"fire","fire",false): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return
	if player_controller.check_input_pressed(event,"sprint","sprint",true): return
	if player_controller.check_input_pressed(event,"reload","reload"): return
	if player_controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if player_controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if player_controller.check_input_pressed(event,"swap","swap_equip"): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return

func update(actor,delta):
	timer += delta
	player_controller.actor_on_floor()
	var velocity = actor.move(delta)
	if velocity.length() <= 1.0:
		state_machine.set_state("Idle")
		return
	if timer >= FOOTSTEP_DELAY:
		actor.play_footsteps()
		timer = 0
