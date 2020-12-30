extends KinematicBody

onready var timer = $Timer

var health = 100
var current_health = 100

func add_damage(damage):
	current_health -= damage
	print(current_health)

func _process(_delta):
	if current_health <= 0:
		set_collision_layer_bit(0,false)
		current_health = health
		timer.start()
		visible = false

func _on_Timer_timeout():
	set_collision_layer_bit(0,true)
	visible = true
