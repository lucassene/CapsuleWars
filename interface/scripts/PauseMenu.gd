extends Control

onready var lobby_button = $Container/Margin/Menu/LobbyButton
onready var back_button = $Container/Margin/Menu/BackButton
onready var exit_button = $Container/Margin/Menu/HBoxContainer/ExitButton
onready var settings_button = $Container/Margin/Menu/HBoxContainer/SettingsButton
onready var dialog_menu = $DialogMenu

signal on_pause_menu_exited()
signal on_exit_to_lobby()

enum {SETTINGS,EXIT}

var opened_dialog

func _unhandled_key_input(event):
	if visible and not dialog_menu.visible and event.is_action_pressed("escape"):
		close_menu()

func open_menu():
	back_button.grab_focus()
	show()

func close_menu():
	emit_signal("on_pause_menu_exited")

func show_dialog(dialog):
	dialog_menu.initialize(dialog)
	dialog_menu.show()

func _on_BackButton_pressed():
	close_menu()

func _on_ExitButton_pressed():
	show_dialog(dialog_menu.EXIT_DIALOG)
	opened_dialog = EXIT

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
	opened_dialog = SETTINGS

func _on_dialog_exited():
	if opened_dialog == SETTINGS:
		settings_button.grab_focus()
	else:
		exit_button.grab_focus()
