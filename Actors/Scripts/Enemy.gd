extends KinematicBody

onready var blood_emitter = preload("res://particles/scenes/BloodEmitter.tscn")
onready var death_emitter = preload("res://particles/scenes/DeathEmitter.tscn")

onready var timer = $Timer

var health = 100
var current_health = 100

func add_damage(point,damage):
	create_blood_splash(point)
	current_health -= damage
	if current_health <= 0:
		create_death_splash(point)
		return true
	else:
		return false

func _process(_delta):
	if current_health <= 0:
		set_collision_layer_bit(0,false)
		current_health = health
		timer.start()
		yield(get_tree().create_timer(1),"timeout")
		visible = false

func create_blood_splash(point):
	var blood = blood_emitter.instance()
	add_child(blood)
	blood.global_transform.origin = point
	blood.emitting = true

func create_death_splash(point):
	var death = death_emitter.instance()
	add_child(death)
	death.global_transform.origin = point
	death.emitting = true

func _on_Timer_timeout():
	set_collision_layer_bit(0,true)
	visible = true
