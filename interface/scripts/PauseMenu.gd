extends Control

onready var lobby_button = $Container/Margin/Menu/LobbyButton
onready var dialog_menu = $DialogMenu

signal on_pause_menu_exited()
signal on_exit_to_lobby()

func _unhandled_key_input(event):
	if visible == true and event.is_action_pressed("escape"):
		close_menu()

func close_menu():
	dialog_menu.close()
	dialog_menu.hide()
	emit_signal("on_pause_menu_exited")

func show_dialog(dialog):
	dialog_menu.initialize(dialog)
	dialog_menu.show()

func hide_dialog():
	dialog_menu.hide()

func _on_BackButton_pressed():
	close_menu()

func _on_ExitButton_pressed():
	show_dialog(dialog_menu.EXIT_DIALOG)

func _on_LobbyButton_pressed():
	if get_tree().is_network_server() and Network.has_mapped_port:
		lobby_button.text = "Leaving"
		lobby_button.pressed = false
		yield(get_tree().create_timer(0.1),"timeout")
		Network.clear_mapped_ports()
	emit_signal("on_exit_to_lobby")
	lobby_button.text = "Back to Lobby"

func _on_SettingsButton_pressed():
	show_dialog(dialog_menu.SETTINGS_DIALOG)
