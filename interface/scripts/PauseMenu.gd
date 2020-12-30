extends Control

signal on_pause_menu_exited()

func _unhandled_key_input(event):
	if visible == true and event.is_action_pressed("escape"):
		close_menu()

func close_menu():
	hide()
	emit_signal("on_pause_menu_exited")

func _on_BackButton_pressed():
	close_menu()

func _on_ExitButton_pressed():
	get_tree().quit()
