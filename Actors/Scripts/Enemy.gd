extends KinematicBody

var health = 100
var current_health = 100

func add_damage(damage):
	current_health -= damage
	print(current_health)

func _process(_delta):
	if current_health <= 0:
		queue_free()
