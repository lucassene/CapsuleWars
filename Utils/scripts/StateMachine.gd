extends Node
class_name StateMachine

onready var actor = owner
onready var controller

var states = {}

var current_state setget ,get_current_state
var previous_state setget ,get_previous_state
var next_state setget ,get_next_state

func get_current_state():
	return current_state

func get_previous_state():
	return previous_state

func get_next_state():
	return next_state

func initialize(first_state,actor_controller):
	controller = actor_controller
	actor_controller.initialize(self)
	for child in get_children():
		states[child.get_name()] = child
		child.initialize(actor,actor_controller)
	current_state = first_state
	states[current_state].enter(actor)

func set_state(new_state):
	if current_state and current_state != new_state:
		next_state = new_state
		previous_state = current_state
		exit_state(current_state)
		current_state = new_state
		enter_state(current_state)
	
func enter_state(state):
	states[state].enter()
	
func exit_state(state):
	states[state].exit()

func handle_input(event):
	states[current_state].handle_input(event)

func update(delta):
	if current_state: states[current_state].update(delta)

