extends Node

export var DEFAULT_MOUSE_SENSITITY = 0.05
export var MIN_MOUSE_SENSITIVITY = 0.01
export var MAX_MOUSE_SENSITIVITY = 0.20
export var DEFAULT_CONTROLLER_SENSITIVITY = 0.08
export var MIN_CONTROLLER_SENSITIVITY = 0.04
export var MAX_CONTROLLER_SENSITIVITY = 0.25

const CONFIG_PATH = "res://config/GameConfig.tres"

var current_sensitivity = DEFAULT_MOUSE_SENSITITY
var ads_modifier = 1.0
var gamepad_mode = false
var gamepad_id = -1
var config

func _ready():
	Input.connect("joy_connection_changed",self,"_on_gamepad_changed")
	load_config()
	update_mode()

func get_current_sensitivity():
	return current_sensitivity

func get_sensitivity_with_ads():
	return current_sensitivity * ads_modifier

func get_min_sensitivity():
	if gamepad_mode:
		return MIN_CONTROLLER_SENSITIVITY
	return MIN_MOUSE_SENSITIVITY

func get_max_sensitivity():
	if gamepad_mode:
		return MAX_CONTROLLER_SENSITIVITY
	return MAX_MOUSE_SENSITIVITY

func set_current_sensitivity(value):
	current_sensitivity = value
	save_config()

func set_ads_modifier(value):
	ads_modifier = value

func reset_sensitivity():
	if gamepad_mode:
		current_sensitivity = DEFAULT_CONTROLLER_SENSITIVITY
		return
	current_sensitivity = DEFAULT_MOUSE_SENSITITY

func update_mode():
	if Input.get_connected_joypads().size() > 0:
		gamepad_id = Input.get_connected_joypads()[0]
		gamepad_mode = true
		current_sensitivity = config.controller_sensitivity
	else:
		gamepad_mode = false
		gamepad_id = -1
		current_sensitivity = config.mouse_sensitivity

func is_gamepad_mode():
	return gamepad_mode

func get_gamepad_respawn_button():
	match Input.get_joy_name(gamepad_id):
		"PS4 Controller":
			return "Square"
		"XInput Gamepad":
			return "Cross"
		_:
			return "Reload"

func load_config():
	config = load(CONFIG_PATH)

func save_config():
	if gamepad_mode:
		config.controller_sensitivity = clamp(current_sensitivity,MIN_CONTROLLER_SENSITIVITY,MAX_CONTROLLER_SENSITIVITY)
	else:
		config.mouse_sensitivity = clamp(current_sensitivity,MIN_MOUSE_SENSITIVITY,MAX_MOUSE_SENSITIVITY)
	ResourceSaver.save(CONFIG_PATH,config)

func _on_gamepad_changed(device_id,connected):
	if connected:
		gamepad_mode = true
		gamepad_id = device_id
		current_sensitivity = config.controller_sensitivity
		print(device_id," - ",Input.get_joy_name(device_id))
	else:
		gamepad_mode = false
		gamepad_id = -1
		current_sensitivity = config.mouse_sensitivity
