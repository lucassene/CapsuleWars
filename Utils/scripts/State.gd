extends Node
class_name State

onready var state_machine = get_parent()
var controller
var actor

func initialize(owner_actor,actor_controller):
	actor = owner_actor
	controller = actor_controller

func enter(_delta = 0.0):
	pass

func update(_delta):
	pass

func handle_input(_event):
	pass

func exit():
	pass

