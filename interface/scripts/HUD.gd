extends MarginContainer

onready var health_bar = $HBoxContainer/HealthBar
onready var ammo_counter = $HBoxContainer/AmmoCounter
onready var respawn_hud = $RespawnHUD
onready var warning_label = $WarningLabel
onready var timer = $Timer
onready var tween = $HBoxContainer/HealthBar/Tween

signal _on_player_can_spawn(actor)

func _ready():
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")

func _on_player_damage_suffered(current_health):
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

func _on_spawn_time_reached(actor):
	health_bar.visible = true
	ammo_counter.visible = true
	emit_signal("_on_player_can_spawn",actor)

func _on_Timer_timeout():
	tween.interpolate_property(warning_label,"modulate:a",1.0,0.0,0.3,tween.TRANS_LINEAR,tween.EASE_IN_OUT)
	tween.start()

func _on_Tween_tween_completed(_object, _key):
	warning_label.visible = false
