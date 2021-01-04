extends Control

onready var info_container = $Container/InfoContainer
onready var health_bar = $Container/InfoContainer/HealthBar
onready var ammo_counter = $Container/InfoContainer/AmmoCounter
onready var respawn_hud = $Container/RespawnHUD
onready var warning_label = $Container/WarningLabel
onready var timer = $Container/Timer
onready var tween = $Container/Timer/Tween
onready var pause_menu = $PauseMenu
onready var scoreboard_menu = $Scoreboard

signal _on_player_can_spawn(actor)

var is_dead = false

func _ready():
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")

func _unhandled_input(event):
	if !is_dead:
		if event.is_action_pressed("score_menu"):
			scoreboard_menu.show()
			return
		if event.is_action_released("score_menu"):
			scoreboard_menu.hide()
			return

func _on_player_health_changed(current_health):
	health_bar.on_health_changed(current_health)

func _on_player_reload():
	ammo_counter.on_reload()

func _on_player_shot_fired():
	ammo_counter.on_shot_fired()

func _on_player_weapon_changed(current_ammo, clip_size):
	ammo_counter.on_weapon_changed(current_ammo,clip_size)

func _on_player_weapon_equipped(clip_size):
	ammo_counter.on_weapon_equipped(clip_size)

func _on_player_death(actor):
	is_dead = true
	info_container.visible = false
	scoreboard_menu.show()
	respawn_hud.on_player_death(actor)

func _on_player_spawned():
	var health = Global.player.get_max_health()
	health_bar.set_max_health(health)
	show()

func _on_player_disconnected(player):
	warning_label.text = player.name + " has disconnected."
	warning_label.visible = true
	timer.start()

func _on_server_disconnected():
	info_container.visible = false

func _on_pause_menu_pressed(value):
	if value:
		pause_menu.show()
		scoreboard_menu.show()
	else:
		scoreboard_menu.hide()
		pause_menu.hide()

func _on_spawn_time_reached(actor):
	is_dead = false
	info_container.visible = true
	scoreboard_menu.hide()
	emit_signal("_on_player_can_spawn",actor)

func _on_Timer_timeout():
	tween.interpolate_property(warning_label,"modulate:a",1.0,0.0,0.3,tween.TRANS_LINEAR,tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(_object, _key):
	warning_label.visible = false

func _on_pause_menu_exited():
	Global.player.show_menu(false)
	scoreboard_menu.hide()

func _on_score_changed(id,item):
	scoreboard_menu.update_score(id,item)

func _on_game_begin():
	scoreboard_menu.initialize()
