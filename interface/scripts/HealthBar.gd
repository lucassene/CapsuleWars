extends MarginContainer

onready var danger_sound = preload("res://assets/audio/danger-sound.wav")
onready var recovered_sound = preload("res://assets/audio/recovered-sound.wav")
onready var recovering_sound = preload("res://assets/audio/recovering-sound.wav")

onready var life_bar = $LifeBar
onready var tween = $Tween
onready var sound_player = $SoundPlayer

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
	life_bar.color = green_color

func on_health_changed(current_health):
	var old_health = current
	current = current_health
	var new_health = (width * current) / max_health
	new_health = min(new_health,width)
	tween.interpolate_property(life_bar,"rect_size",life_bar.rect_size,Vector2(new_health,life_bar.rect_size.y),0.1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()
	if current_health <= (max_health * 0.33):
		life_bar.color = red_color
		sound_player.set_stream(danger_sound)
		sound_player.play(0.0)
	else:
		life_bar.color = green_color
		if current_health > old_health:
			sound_player.set_stream(recovering_sound)
			sound_player.play(0.0)

func _on_Tween_tween_completed(_object, _key):
	if current >= max_health:
		current = max_health
		sound_player.set_stream(recovered_sound)
		sound_player.play()
