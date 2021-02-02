extends State

func enter(_delta = 0.0):
	controller.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	actor.play_camera_anim(false)
	print("Menu")

func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",false): return

func update(delta):
	if !actor.is_on_floor():
		controller.actor_in_air(delta)
	actor.move(delta)

func exit():
	controller.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

