extends State

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	actor.play_camera_anim(false)
	print("Menu")

func handle_input(event):
	if player_controller.check_input_pressed(event,"escape","show_menu",false): return

func update(actor,delta):
	if !actor.is_on_floor():
		player_controller.actor_in_air(delta)
	actor.move(delta)

func exit(_actor):
	player_controller.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

