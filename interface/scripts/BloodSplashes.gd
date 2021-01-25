extends Control

onready var tween = $Tween

var max_health setget set_max_health
var current_health

func set_max_health(health):
	max_health = health
	tween.stop(self)
	tween.interpolate_property(self,"modulate:a",modulate.a,0.0,0.1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	
func on_player_health_changed(health):
	current_health = health
	var new_alpha = abs((float(current_health) - float(max_health)) / 100)
	if new_alpha < 0: new_alpha = 0.0
	if new_alpha > 1.0: new_alpha = 1.0
	tween.interpolate_property(self,"modulate:a",modulate.a,new_alpha,0.1,Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
