extends ActorController

onready var actor = owner

export var GRAVITY = 20
export var JUMP_IMPULSE = 11

export var CONTROLLER_DEADZONE = 0.01

var current_speed = 0.0 setget set_current_speed,get_current_speed
var current_acceleration = 0.0 setget set_current_acceleration,get_current_acceleration
var h_velocity = Vector3.ZERO
var movement = Vector3.ZERO setget ,get_movement
var gravity_vector = Vector3.DOWN setget ,get_gravity_vector
var on_sprint = false setget ,is_sprinting
var was_sprinting = false

func set_current_speed(value):
	current_speed = value

func get_current_speed():
	return current_speed

func set_current_acceleration(value):
	current_acceleration = value

func get_current_acceleration():
	return current_acceleration

func get_movement():
	return movement

func get_gravity_vector():
	return gravity_vector

func reset_sprint():
	on_sprint = false
	was_sprinting = false

func is_sprinting():
	return on_sprint

func reset_sensitivity():
	GameSettings.reset_sensitivity()

func _initialize(fsm):
	.initialize(fsm)
	set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func handle_input(event):
	if state_machine.get_current_state() != "Menu" and not GameSettings.is_gamepad_mode():
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

func _physics_process(_delta):
	if GameSettings.is_gamepad_mode():
		handle_controller_movement()

func handle_mouse_movement(event):
	if event is InputEventMouseMotion:
		actor.rotate_y(deg2rad(-event.relative.x * GameSettings.get_sensitivity_with_ads()))
		actor.head.rotate_x(deg2rad(-event.relative.y * GameSettings.get_sensitivity_with_ads()))
		actor.head.rotation.x = clamp(actor.head.rotation.x,deg2rad(-68),deg2rad(80))

func handle_controller_movement():
	var axis_vector = get_axis_vector()
	actor.rotate_y(-axis_vector.x * GameSettings.get_sensitivity_with_ads())
	actor.head.rotate_x(-axis_vector.y * GameSettings.get_sensitivity_with_ads())
	actor.head.rotation.x = clamp(actor.head.rotation.x,deg2rad(-68),deg2rad(80))

func get_axis_vector():
	var up_down = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	var right_left = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var vector = Vector2(right_left,up_down)
	if vector.length() < CONTROLLER_DEADZONE:
		vector = Vector2.ZERO
	return vector

func calculate_movement(delta):
	var direction = Vector3.ZERO
	
	if state_machine.get_current_state() != "Menu":
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
		return true
	else:
		gravity_vector = -actor.get_floor_normal()
		return false

func jump(_param):
	if actor.is_on_floor() or actor.get_floor_contact():
		state_machine.set_state("Jumping")
		gravity_vector = Vector3.UP * JUMP_IMPULSE

func fire(param):
	if param:
		if is_sprinting() and actor.get_is_moving():
			was_sprinting = true
			state_machine.set_state("Running")
		elif is_sprinting():
			actor.sprint(false)
			state_machine.enter_air_state()
			current_speed = state_machine.states.Running.SPEED
	elif was_sprinting and actor.is_on_floor() and not actor.get_is_ads():
		was_sprinting = false
		state_machine.set_state("Sprinting")

func melee(_param):
	actor.rpc("melee_attack")

func ads(is_ads,weapon_sensitivity = null):
	if is_ads:
		GameSettings.set_ads_modifier(weapon_sensitivity)
		if state_machine.get_current_state() == "Sprinting":
			state_machine.set_state("Running")
		if on_sprint:
			was_sprinting = true
		on_sprint = false
		actor.sprint(false)
	else:
		if was_sprinting:
			was_sprinting = false
			sprint(true)
		GameSettings.set_ads_modifier(1.0)

func sprint(param):
	if param and !actor.get_is_ads():
		state_machine.set_state("Sprinting")
		on_sprint = true
	else:
		was_sprinting = false
		on_sprint = false
		reset_speed()
		actor.sprint(false)
		if actor.is_on_floor():
			state_machine.set_state("Idle")

func reload(_param):
	return

func equip_slot_1(_param):
	actor.rpc("equip_slot",0)

func equip_slot_2(_param):
	actor.rpc("equip_slot",1)

func swap_equip(_param):
	actor.rpc("swap_equip")

func show_menu(param):
	print("is dead: ",actor.is_dead())
	if param:
		state_machine.set_state("Menu")
	else:
		if actor.is_dead():
			state_machine.set_state("Dead")
		else:
			state_machine.set_state("Idle")
	actor.show_menu(param)

func sacrifice(_param):
	actor.sacrifice()

func exit_menu():
	if actor.is_dead():
		state_machine.set_state("Dead")
	state_machine.set_state("Idle")

func set_mouse_mode(mode):
	Input.set_mouse_mode(mode)

func reset_speed():
	current_speed = state_machine.states.Running.SPEED

func actor_in_air(delta):
	gravity_vector += Vector3.DOWN * GRAVITY * delta
	return movement
