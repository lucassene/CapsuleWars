extends KinematicBody

onready var blood_emitter = preload("res://particles/scenes/BloodEmitter.tscn")
onready var death_emitter = preload("res://particles/scenes/DeathEmitter.tscn")
onready var floating_damage = preload("res://interface/scenes/FloatingDamage.tscn")

onready var timer = $Timer
onready var float_dmg_container = $FloatDmgContainer

var health = 100
var current_health = 100
var ttk = 0.0
var shot = false
var counter = 0

func add_damage(point,damage):
	counter += 1
	shot = true
	show_floating_damage(damage,Scores.TAILSHOT)
	create_blood_splash(point)
	current_health -= damage
	print("inimigo com: " + str(current_health))
	if current_health <= 0:
		create_death_splash(point)
		return true
	else:
		return false

func show_floating_damage(damage,shot_type):
	var label = floating_damage.instance()
	float_dmg_container.add_child(label)
	label.initialize(damage,shot_type)

func _process(delta):
	if shot:
		ttk += delta
	if current_health <= 0:
		shot = false
		print("Enemy killed in " + str(ttk) + " seconds, with " + str(counter) + " shots.")
		counter = 0
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
