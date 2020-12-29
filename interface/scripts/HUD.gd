extends MarginContainer

onready var health_bar = $HBoxContainer/HealthBar
onready var ammo_counter = $HBoxContainer/AmmoCounter
onready var player: Player = get_node(player_path)

export var player_path = NodePath()

func _ready():
	var health = player.get_max_health()
	health_bar.set_max_health(health)

func _on_Player_on_damage_suffered(current_health):
	health_bar.on_damage_suffered(current_health)

func _on_Player_on_reload():
	ammo_counter.on_reload()

func _on_Player_on_shot_fired():
	ammo_counter.on_shot_fired()

func _on_Player_on_weapon_changed(current_ammo, clip_size):
	ammo_counter.on_weapon_changed(current_ammo,clip_size)

func _on_Player_on_weapon_equipped(clip_size):
	ammo_counter.on_weapon_equipped(clip_size)
