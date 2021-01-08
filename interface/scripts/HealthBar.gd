extends MarginContainer

onready var life_bar = $LifeBar
onready var tween = $Tween

var red_color = Color(0.79,0.20,0.20,1.0)
var green_color = Color(0.73,0.94,0.57,1.0)

var width

var max_health
var current

func _ready():
	width = rect_size.x

func set_max_health(health):
	max_health = health
	current = max_health

func on_health_changed(current_health):
	current = current_health
	var new_health = (width * current) / max_health
	new_health = min(new_health,width)
	tween.interpolate_property(life_bar,"rect_size",life_bar.rect_size,Vector2(new_health,life_bar.rect_size.y),0.1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	if current_health <= (max_health * 0.25):
		life_bar.color = red_color
	else:
		life_bar.color = green_color
