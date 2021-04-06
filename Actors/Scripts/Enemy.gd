extends KinematicBody

onready var blood_emitter = preload("res://particles/scenes/BloodEmitter.tscn")
onready var death_emitter = preload("res://particles/scenes/DeathEmitter.tscn")

onready var timer = $Timer

var health = 100
var current_health = 100
var ttk = 0.0
var shot = false

func add_damage(point,damage):
	shot = true
	create_blood_splash(point)
	current_health -= damage
	print("inimigo com: " + str(current_health))
	if current_health <= 0:
		create_death_splash(point)
		return true
	else:
		return false

func _process(delta):
	if shot:
		ttk += delta
	if current_health <= 0:
		shot = false
		print("Enemy killed in: " + str(ttk) + " seconds.")
		ttk = 0.0
		set_collision_layer_bit(0,false)
		current_health = health
		timer.start()
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
