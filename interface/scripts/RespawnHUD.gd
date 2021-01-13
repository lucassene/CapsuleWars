extends Control

export var DEFAULT_MESSAGE = "Respawning in: "
export var CAN_RESPAWN_MESSAGE = "Press 'R' to respawn."

onready var respawn_label = $CenterContainer/MarginContainer/VContainer/RespawnContainer/RespawnLabel
onready var countdown_label = $CenterContainer/MarginContainer/VContainer/RespawnContainer/CountdownLabel
onready var primary_option = $CenterContainer/MarginContainer/VContainer/LoadoutContainer/Container/PrimaryContainer/PrimaryOption
onready var secondary_option = $CenterContainer/MarginContainer/VContainer/LoadoutContainer/Container/SecondaryContainer/SecondaryOption
onready var timer: Timer = $Timer

export var SPAWN_TIME = 4.0

var actor
var primary_index = 0
var secondary_index = 0
var current_primary = 0
var current_secondary = 0
var can_respawn = false

signal on_spawn_time_reached(actor)

func _ready():
	timer.wait_time = SPAWN_TIME
	set_process(false)
	set_weapon_options()

func _process(_delta):
	countdown_label.text = String(stepify(timer.time_left,0.01))

func _unhandled_input(event):
	if event.is_action_pressed("reload") and can_respawn and visible:
		respawn()

func set_weapon_options():
	primary_option.add_item("Assault Rifle",0)
	primary_option.add_item("Scout Rifle",1)
	primary_option.add_item("Pulse Rifle",2)
	primary_option.add_item("Sniper Rifle",3)
	primary_option.selected = Network.self_data.primary
	
	secondary_option.add_item("Pistol",0)
	secondary_option.add_item("SMG",1)
	secondary_option.selected = 0
	secondary_option.selected = Network.self_data.secondary

func set_respawn_possible(value):
	can_respawn = value
	set_process(!value)
	if value: 
		respawn_label.text = CAN_RESPAWN_MESSAGE
	else:
		respawn_label.text = DEFAULT_MESSAGE
	countdown_label.visible = !value

func start_countdown():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	timer.start()
	set_process(true)

func on_player_death(player):
	actor = player
	visible = true
	current_primary = Network.self_data.primary
	primary_option.selected = current_primary
	current_secondary = Network.self_data.secondary
	secondary_option.selected = current_secondary
	set_respawn_possible(false)
	start_countdown()

func respawn():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if primary_index != current_primary or secondary_index != current_secondary:
		actor.rpc("change_loadout",primary_index,secondary_index)
	emit_signal("on_spawn_time_reached",actor)
	visible = false

func _on_PrimaryOption_item_selected(index):
	Network.self_data.primary = index
	primary_index = index

func _on_SecondaryOption_item_selected(index):
	Network.self_data.secondary = index
	secondary_index = index

func _on_Timer_timeout():
	can_respawn = true
	set_process(false)
	set_respawn_possible(true)
