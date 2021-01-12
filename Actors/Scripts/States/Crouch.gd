extends "res://Utils/scripts/State.gd"

export var SPEED = 6
export var FOOTSTEP_DELAY = 0.70
export var CROUCH_SIZE = 0.8
export var CROUCH_HEAD_HEIGHT = 4
export var DEFAULT_HEAD_HEIGHT = 


var player_controller
var timer = 0

func enter(actor,_delta = 0.0):
	player_controller = actor.get_player_controller()
	player_controller.set_current_speed(SPEED)
	actor.set_is_moving(true)
	actor.play_camera_anim(true)
	timer = 0
	print("Crouch")

func handle_input(event):
	if player_controller.check_input_pressed(event,"escape","show_menu",true): return
	if player_controller.check_input_pressed(event,"jump","jump"): return
	if player_controller.check_input_pressed(event,"fire","fire",true): return
	if player_controller.check_input_released(event,"fire","fire",false): return
	if player_controller.check_input_pressed(event,"aim","aim",true): return
	if player_controller.check_input_released(event,"aim","aim",false): return
	if player_controller.check_input_pressed(event,"reload","reload"): return
	if player_controller.check_input_pressed(event,"slot_1","equip_slot_1"): return
	if player_controller.check_input_pressed(event,"slot_2","equip_slot_2"): return
	if player_controller.check_input_pressed(event,"swap","swap_equip"): return
	if player_controller.check_input_released(event,"sprint","sprint",false): return
	if player_controller.check_input_pressed(event,"crouch","crouch",true): return
