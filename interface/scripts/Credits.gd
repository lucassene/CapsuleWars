extends Control

onready var back_button : Button = $MarginContainer/HBoxContainer/BackButton
onready var color_rect : ColorRect = $ColorRect
onready var main_container = $MainContainer
onready var tween : Tween = $Tween

func _unhandled_input(event):
	if event.is_action_pressed("escape"):
		hide()
		tween.stop_all()

func start_credits():
	main_container.rect_position.y = get_viewport_rect().size.y
	tween.reset_all()
	show()
	tween.interpolate_property(color_rect,"modulate:a",0.0,0.9,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func _on_BackButton_pressed():
	hide()
	tween.stop_all()

func _on_Tween_tween_completed(object, _key):
	if object == color_rect:
		if color_rect.modulate.a >= 0.5:
			tween.interpolate_property(main_container,"rect_position",main_container.rect_position,Vector2(0.0,-1500),25.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
			tween.start()
		else:
			hide()
		return
	elif object == main_container:
		tween.interpolate_property(color_rect,"modulate:a",0.9,0.0,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		tween.start()
