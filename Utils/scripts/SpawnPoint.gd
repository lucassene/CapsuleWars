extends Spatial

onready var area = $Area

var can_spawn = true setget set_can_spawn,get_can_spawn

func set_can_spawn(value):
	can_spawn = value

func get_can_spawn():
	if can_spawn:
		for actor in area.get_overlapping_bodies():
			if actor.is_in_group("Player"):
				return false
	return can_spawn

func get_spawn_rotation():
	return rotation

func _on_Area_body_entered(_body):
	can_spawn = false

func _on_Area_body_exited(_body):
	can_spawn = true
