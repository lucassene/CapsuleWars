extends State

func enter(_delta = 0.0):
	print("Dead")

func handle_input(event):
	if controller.check_input_pressed(event,"escape","show_menu",true): return
