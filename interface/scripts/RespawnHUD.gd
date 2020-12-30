extends HBoxContainer

onready var countdown_label = $CountdownLabel

export var SPAWN_TIME = 3.0

var timer = 0
var actor

signal on_spawn_time_reached(actor)

func _ready():
	set_process(false)

func _process(delta):
	if visible == true:
		timer -= delta
		countdown_label.text = String(timer)
		if timer <= 0:
			emit_signal("on_spawn_time_reached",actor)
			visible = false
			set_process(false)

func on_player_death(player):
	actor = player
	visible = true
	set_process(true)
	timer = SPAWN_TIME
