extends Control

onready var lobby_button = $Container/Margin/Menu/LobbyButton

signal on_pause_menu_exited()
signal on_exit_to_lobby()

func _ready():
	Network.connect("on_client_created",self,"_on_client_created")
	Network.connect("on_server_created",self,"_on_server_created")

func _unhandled_key_input(event):
	if visible == true and event.is_action_pressed("escape"):
		close_menu()

func close_menu():
	hide()
	emit_signal("on_pause_menu_exited")

func _on_client_created():
	lobby_button.hide()

func _on_server_created():
	lobby_button.show()

func _on_BackButton_pressed():
	close_menu()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_LobbyButton_pressed():
	if get_tree().is_network_server():
		emit_signal("on_exit_to_lobby")
