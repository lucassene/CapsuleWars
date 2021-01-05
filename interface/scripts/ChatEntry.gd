extends RichTextLabel

onready var timer = $Timer
onready var tween = $Tween

func _on_Timer_timeout():
	tween.interpolate_property(self,"modulate:a",1.0,0.0,0.5,tween.TRANS_LINEAR,tween.EASE_IN_OUT)
	tween.start()

func _on_tween_completed(_object, _key):
	queue_free()
