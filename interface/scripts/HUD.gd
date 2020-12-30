extends Control

onready var health_bar = $Container/HBoxContainer/HealthBar
onready var ammo_counter = $Container/HBoxContainer/AmmoCounter
onready var respawn_hud = $Container/RespawnHUD
onready var warning_label = $Container/WarningLabel
onready var timer = $Container/Timer
onready var tween = $Container/Timer/Tween
onready var pause_menu = $PauseMenu

signal _on_player_can_spawn(actor)

func _ready():
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")

func _on_player_damage_suffered(current_health):
	print("player sofreu dano")
	health_bar.on_damage_suffered(current_health)

func _on_player_reload():
	ammo_counter.on_reload()

func _on_player_shot_fired():
	ammo_counter.on_shot_fired()

func _on_player_weapon_changed(current_ammo, clip_size):
	ammo_counter.on_weapon_changed(current_ammo,clip_size)

func _on_player_weapon_equipped(clip_size):
	ammo_counter.on_weapon_equipped(clip_size)

func _on_player_death(actor):
	health_bar.visible = false
	ammo_counter.visible = false
	yield(get_tree().create_timer(1.5),"timeout")
	respawn_hud.on_player_death(actor)

func _on_player_spawned():
	var health = Global.player.get_max_health()
	health_bar.set_max_health(health)
	show()

func _on_player_disconnected(player):
	warning_label.text = player.name + " has disconnected."
	warning_label.visible = true
	timer.start()

func _on_pause_menu_pressed(value):
	if value:
		pause_menu.show()
	else:
		pause_menu.hide()

func _on_spawn_time_reached(actor):
	health_bar.visible = true
	ammo_counter.visible = true
	emit_signal("_on_player_can_spawn",actor)

func _on_Timer_timeout():
	tween.interpolate_property(warning_label,"modulate:a",1.0,0.0,0.3,tween.TRANS_LINEAR,tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(_object, _key):
	warning_label.visible = false

func _on_pause_menu_exited():
	Global.player.show_menu(false)
