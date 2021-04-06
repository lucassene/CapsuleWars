extends State

export var SPEED = 20
export var FOOTSTEP_DELAY = 0.25

var timer = 0

func enter(_delta = 0.0):
	controller.set_current_speed(SPEED)
	actor.set_is_moving(true)
	actor.play_camera_anim(true)
	actor.sprint(true)
	timer = 0
	print("Sprinting")

func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",true): return
	if controller.check_input_pressed(event,"jump","jump"): return
	if controller.check_input_pressed(event,"melee","melee"): return
	if controller.check_input_pressed(event,"sacrifice","sacrifice"): return
	if controller.check_input_released(event,"sprint","sprint",false): return

func update(delta):
	timer += delta
	if !controller.actor_on_floor():
		state_machine.set_state("Falling")
	var velocity = actor.move(delta)
	if velocity.length() <= 1.0:
		state_machine.set_state("Idle")
		return
	if timer >= FOOTSTEP_DELAY:
		actor.play_footsteps()
		timer = 0

func exit():
	actor.sprint(false)
