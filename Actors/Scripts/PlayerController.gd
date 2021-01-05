extends Node

onready var actor = owner

export var GRAVITY = 20
export var JUMP_IMPULSE = 10

var state_machine
var mouse_sensitivity = 0.05
var current_speed = 0.0 setget set_current_speed,get_current_speed
var current_acceleration = 0.0 setget set_current_acceleration

var h_velocity = Vector3.ZERO
var movement = Vector3.ZERO setget ,get_movement
var gravity_vector = Vector3.ZERO

func set_current_speed(value):
	current_speed = value

func get_current_speed():
	return current_speed

func set_current_acceleration(value):
	current_acceleration = value

func get_movement():
	return movement

func _initialize(fsm):
	state_machine = fsm
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_input(event):
	if state_machine.get_current_state() != "Menu":
		handle_mouse_movement(event)

func check_input_pressed(event,input,method = null,param = null):
	if event.is_action_pressed(input):
		if method: call_deferred(method,param)
		return true
	return false

func check_input_released(event,input,method = null,param = null):
	if event.is_action_released(input):
		if method: call_deferred(method,param)
		return true
	return false

func check_if_ads_still_pressed():
	if Input.is_action_pressed("aim"):
		return true
	else:
		return false

func handle_mouse_movement(event):
	if event is InputEventMouseMotion:
		actor.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		actor.head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		actor.head.rotation.x = clamp(actor.head.rotation.x,deg2rad(-58),deg2rad(80))

func calculate_movement(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction -= actor.transform.basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += actor.transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= actor.transform.basis.x
	elif Input.is_action_pressed("move_right"):
		direction += actor.transform.basis.x
	
	direction = direction.normalized()
	h_velocity = h_velocity.linear_interpolate(direction * current_speed, current_acceleration * delta)
	movement.z = h_velocity.z + gravity_vector.z
	movement.x = h_velocity.x + gravity_vector.x
	movement.y = gravity_vector.y
	
	return movement

func actor_on_floor():
	if actor.is_on_floor() and actor.get_floor_contact():
		gravity_vector = -actor.get_floor_normal() * GRAVITY
	else:
		state_machine.set_state("Falling")
		gravity_vector = -actor.get_floor_normal()

func jump(_param):
	if actor.is_on_floor() or actor.get_floor_contact():
		actor.jump()
		state_machine.set_state("Jumping")
		gravity_vector = Vector3.UP * JUMP_IMPULSE

func fire(param):
	if param:
		if is_sprinting() and actor.get_is_moving():
			state_machine.set_state("Running")
			yield(get_tree().create_timer(0.1),"timeout")
		elif is_sprinting():
			state_machine.enter_air_state()
			current_speed = state_machine.states.Running.SPEED
			yield(get_tree().create_timer(0.15),"timeout")
		actor.rpc("fire")
	else:
		actor.rpc("stop_firing")

func aim(param):
	if param and actor.get_is_moving():
		state_machine.set_state("Running")
		yield(get_tree().create_timer(0.15),"timeout")
	actor.ads(param)

func sprint(param):
	if param:
		state_machine.set_state("Sprinting")
	else:
		state_machine.set_state("Idle")
		reset_speed()

func reload(_param):
	actor.rpc("reload_weapon")

func equip_slot_1(_param):
	actor.rpc("equip_slot",0)

func equip_slot_2(_param):
	actor.rpc("equip_slot",1)

func swap_equip(_param):
	actor.rpc("swap_equip")

func show_menu(_param):
	state_machine.set_state("Menu")
	actor.show_menu(true)

func exit_menu():
	set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_mouse_mode(mode):
	Input.set_mouse_mode(mode)

func reset_speed():
	current_speed = state_machine.states.Running.SPEED

func is_sprinting():
	if current_speed == state_machine.states.Sprinting.SPEED:
		return true
	return false

func actor_in_air(delta):
	gravity_vector += Vector3.DOWN * GRAVITY * delta
	return movement
