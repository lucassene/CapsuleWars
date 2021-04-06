extends Control

onready var texture = $Texture
onready var tween = $Tween

export var SHOW_TIME = 1.5

var attacker
var victim

func _physics_process(_delta):
	if attacker and victim:
		texture.set_rotation(get_angle())

func show_hit_marker(victim_scene,attacker_scene):
	attacker = attacker_scene
	victim = victim_scene
	print(attacker.name)
	print(victim.name)
	texture.show()
	texture.set_rotation(get_angle())
	tween.reset(texture)
	tween.interpolate_property(texture,"modulate:a",1.0,0.0,SHOW_TIME,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	tween.start()

func get_angle():
	var dir = victim.global_transform.origin.direction_to(attacker.global_transform.origin)
	var right_basis = victim.global_transform.basis.z * -1
	var left_basis = victim.global_transform.basis.z
	var angle
	var angle_to_side = victim.global_transform.basis.x.dot(dir)
	if angle_to_side >= 0:
		angle = right_basis.angle_to(dir)
	else:
		angle = left_basis.angle_to(dir) + deg2rad(180)
	return angle

func _on_Tween_tween_completed(_object, _key):
	texture.hide()
	attacker = null
	victim = null
