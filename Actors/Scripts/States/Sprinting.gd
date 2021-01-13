extends State

export var SPEED = 20
export var FOOTSTEP_DELAY = 0.25

var timer = 0
var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_speed(SPEED)
	actor.set_is_moving(true)
	actor.play_camera_anim(true)
	timer = 0
	print("Sprinting")

func handle_input(event):
	if player_controller.check_input_pressed(event,"escape","show_menu",true): return
	if player_controller.check_input_pressed(event,"jump","jump"): return
	if player_controller.check_input_pressed(event,"fire","fire",true): return
	if player_controller.check_input_released(event,"fire","fire",false): return
	if player_controller.check_input_pressed(event,"melee","melee"): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return
	if player_controller.check_input_pressed(event,"reload","reload"): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return

func update(actor,delta):
	timer += delta
	if !player_controller.actor_on_floor():
		state_machine.set_state("Falling")
	var velocity = actor.move(delta)
	if velocity.length() <= 1.0:
		state_machine.set_state("Idle")
		return
	if timer >= FOOTSTEP_DELAY:
		actor.play_footsteps()
		timer = 0
