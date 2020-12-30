extends State

var player_controller

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Menu")

func handle_input(event):
	pass
	#if player_controller.check_input_pressed(event,"escape","show_menu"): return

func exit(_actor):
	player_controller.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
