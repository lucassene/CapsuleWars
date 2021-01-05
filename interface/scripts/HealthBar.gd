extends MarginContainer

onready var life_bar = $LifeBar
onready var tween = $Tween

var WIDTH = 500

var max_health
var current

func set_max_health(health):
	max_health = health
	current = max_health

func on_health_changed(current_health):
	current = current_health
	var new_health = (WIDTH * current) / max_health
	new_health = min(new_health,WIDTH)
	tween.interpolate_property(life_bar,"rect_size",life_bar.rect_size,Vector2(new_health,life_bar.rect_size.y),0.1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
