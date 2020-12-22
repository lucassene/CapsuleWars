extends KinematicBody

onready var head: Spatial = $Head
onready var player_controller = $PlayerController
onready var state_machine = $StateMachine
onready var ground_check = $GroundCheck

var velocity = Vector3.ZERO
var floor_contact = true setget ,get_floor_contact

func get_floor_contact():
	return floor_contact

func _ready():
	player_controller._initialize(state_machine)
	state_machine.initialize("Idle")

func _unhandled_input(event):
	state_machine.handle_input(event)
	player_controller.handle_input(event)

func _physics_process(delta):
	check_floor()
	state_machine.update(delta)

func move(delta):
	var movement = player_controller.calculate_movement(delta)
	velocity = move_and_slide(movement,Vector3.UP)
	return velocity

func check_floor():
	floor_contact = ground_check.is_colliding()

func get_player_controller():
	return player_controller

