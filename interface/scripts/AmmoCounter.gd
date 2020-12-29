extends MarginContainer

onready var current_label = $VBoxContainer/current
onready var total_label = $VBoxContainer/total

var current_ammo
var clip_size

func on_weapon_equipped(magazine_size):
	current_ammo = magazine_size
	clip_size = magazine_size
	update_labels()

func on_shot_fired():
	current_ammo -= 1
	current_label.text = String(current_ammo)

func on_reload():
	current_ammo = clip_size
	current_label.text = String(clip_size)

func on_weapon_changed(ammo,magazine_size):
	current_ammo = ammo
	clip_size = magazine_size
	update_labels()

func update_labels():
	current_label.text = String(current_ammo)
	total_label.text = String(clip_size)
