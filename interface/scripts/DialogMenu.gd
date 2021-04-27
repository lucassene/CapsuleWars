extends Control

onready var content_container: Control = $CenterContainer/MarginContainer/Panel/MarginContainer/DialogContainer/ContentContainer
onready var title_label: Label = $CenterContainer/MarginContainer/Panel/MarginContainer/DialogContainer/TitleContainer/TitileLabel
onready var cancel_button: Button = $CenterContainer/MarginContainer/Panel/MarginContainer/DialogContainer/ButtonsContainer/CancelButton
onready var confirm_button: Button = $CenterContainer/MarginContainer/Panel/MarginContainer/DialogContainer/ButtonsContainer/ConfirmButton

onready var EXIT_DIALOG = preload("res://interface/scenes/ExitMessage.tscn")
onready var SETTINGS_DIALOG = preload("res://interface/scenes/SettingsDialog.tscn")

var current_body

func initialize(dialog):
	var scene = dialog.instance()
	content_container.add_child(scene)
	title_label.text = scene.get_title()
	confirm_button.text = scene.get_confirm_text()
	cancel_button.text = scene.get_cancel_text()
	current_body = scene
	scene.connect("exited",get_parent(),"_on_dialog_exited")
	scene.connect("no_focus_needed",self,"_on_dialog_focus_declined")
	scene.initialize()

func _unhandled_input(event):
	if visible and event.is_action_pressed("escape") or event.is_action_pressed("back"):
		if current_body:
			current_body.cancel_pressed()
			hide()
			current_body.queue_free()

func _on_CancelButton_pressed():
	current_body.cancel_pressed()
	hide()
	current_body.queue_free()

func _on_ConfirmButton_pressed():
	current_body.confirm_pressed()
	hide()
	current_body.queue_free()

func _on_dialog_focus_declined():
	cancel_button.grab_focus()
