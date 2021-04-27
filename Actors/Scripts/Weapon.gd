extends Spatial

onready var bullet = preload("res://particles/scenes/BulletEmitter.tscn")
onready var no_ammo_sound = preload("res://assets/audio/out-of-ammo.wav")

onready var anim_player = $AnimationPlayer
onready var shoot_player = $Model/Muzzle/ShootPlayer
onready var audio_player = $AudioPlayer
onready var front_muzzle_sprite = $Model/Muzzle/MuzzleFront
onready var side_muzzle_sprite = $Model/Muzzle/MuzzleSide
onready var bullet_emitter = $BulletEmitter
onready var mesh : MeshInstance = $Model
onready var rate_of_fire_timer = $StateMachine/Firing/ROFTimer
onready var pulse_timer: Timer = $StateMachine/Firing/PulseTimer
onready var state_machine: StateMachine = $StateMachine
onready var weapon_controller = $WeaponController

enum types {
	PRIMARY,
	SECONDARY
}

export var DEBUG_FIRE = false
export(types) var TYPE = types.PRIMARY setget ,get_type
export var HAS_SCOPE = false setget ,get_has_scope
export var AUTO = false
export var PULSE = false
export var PULSE_RATE = 300
export var PULSE_SHOTS = 3
export var RATE_OF_FIRE = 300
export var MAGAZINE = 10 setget ,get_magazine
export var DAMAGE = 5
export var SHOT_DAMAGE_MULTI = 1.5
export var MAX_RANGE = 100
export var ADS_RANGE_MULTI = 1.2
export var FALLOFF_RANGE = 50
export var FALLOFF_DAMAGE_MULTI = 0.75

export var ADS_SENSITIVITY = 1.0 setget ,get_ads_sensitivity
export var ADS_POSITION = Vector3.ZERO setget ,get_ads_position
export var DEFAULT_POSITION = Vector3.ZERO
export var STOWED_POSITION = Vector3.ZERO
export var ADS_SPEED = 20 setget ,get_ads_speed
export var ADS_FOV = 50 setget ,get_ads_fov
export var SWAY = 40
export var ADS_SWAY = 100
export var SPRINT_ANGLE = 45 setget ,get_sprint_angle
export var MIN_X_RECOIL = 1.0
export var MAX_X_RECOIL = 2.0
export var MIN_Y_RECOIL = 1.0
export var MAX_Y_RECOIL = 1.0
export var ADS_RECOIL_MULTI = 0.5
export var MIN_X_FLINCH = 0.5
export var MAX_X_FLINCH = 1.5
export var MIN_Y_FLINCH = 0.5
export var MAX_Y_FLINCH = 1.5

export(AudioStream) var fire_sound

var player
var is_ads = false
var was_ads = false setget ,get_was_ads
var current_ammo setget ,get_current_ammo

signal on_out_of_ads()
signal on_reloaded()
signal on_draw_completed()
signal on_stowed(weapon)

func get_type():
	return TYPE

func get_magazine():
	return MAGAZINE

func get_current_ammo():
	return current_ammo

func get_default_position():
	return DEFAULT_POSITION

func get_ads_position():
	return ADS_POSITION

func get_ads_speed():
	return ADS_SPEED

func get_ads_fov():
	return ADS_FOV

func get_sway():
	return SWAY if !is_ads else ADS_SWAY

func get_sprint_angle():
	return SPRINT_ANGLE

func get_range():
	if is_ads:
		return MAX_RANGE * ADS_RANGE_MULTI
	else:
		return MAX_RANGE

func get_ads_sensitivity():
	return ADS_SENSITIVITY

func get_has_scope():
	return HAS_SCOPE

func get_was_ads():
	return was_ads

func get_damage(distance,shot_type):
	var dmg = DAMAGE
	if shot_type != Scores.REGULAR_SHOT:
		dmg *= SHOT_DAMAGE_MULTI
	if is_ads and distance > (FALLOFF_RANGE * ADS_RANGE_MULTI):
		return dmg * FALLOFF_DAMAGE_MULTI
	elif distance > FALLOFF_RANGE:
		return dmg * FALLOFF_DAMAGE_MULTI
	return dmg

func is_busy():
	var busy = true
	if state_machine.get_current_state() == "Idle" or state_machine.get_current_state() == "Firing":
		busy = false
	return busy

func _ready():
	state_machine.initialize("Stowed",weapon_controller)
	shoot_player.set_stream(fire_sound)
	set_physics_process(false)
	transform.origin = DEFAULT_POSITION
	current_ammo = MAGAZINE
	calculate_rof()
	connect_signals()

func _physics_process(delta):
	state_machine.update(delta)

func _unhandled_input(event):
	if is_owner_master(): state_machine.handle_input(event)

func is_owner_master():
	return player.is_network_master()

func calculate_rof():
	var rof = float(60.0) / RATE_OF_FIRE
	rate_of_fire_timer.wait_time = rof
	if PULSE:
		var pulse = float(60.0) / PULSE_RATE
		pulse_timer.wait_time = pulse

func set_player_firing(value):
	player.set_is_firing(value)

func can_fire():
	return state_machine.is_weapon_ready()

func can_swap():
	return state_machine.can_swap()

func is_player_firing():
	return player.get_is_firing()

func next_fire():
	current_ammo -= 1
	player.get_shot_victim()

func set_owner(actor):
	player = actor

func ads(value):
	is_ads = value
	player.set_is_ads(value)
	if !value: was_ads = false

func out_of_ads():
	if is_ads: was_ads = true
	weapon_controller.set_ads(false)
	player.set_is_ads(false)

func back_to_ads():
	if was_ads:
		weapon_controller.set_ads(true)
		player.set_is_ads(true)
		was_ads = false

func fire(is_firing):
	if is_firing:
		weapon_recoil()
		if is_ads:
			was_ads = true
	player.fire(is_firing)

func weapon_recoil():
	var recoil_multi = 1
	if is_ads: recoil_multi = ADS_RECOIL_MULTI
	player.shake_camera(MAX_X_RECOIL * recoil_multi,MIN_X_RECOIL * recoil_multi,MAX_Y_RECOIL * recoil_multi,MIN_Y_RECOIL * recoil_multi)

func reload():
	out_of_ads()
	emit_signal("on_out_of_ads")

func can_reload():
	if current_ammo < MAGAZINE:
		return true
	return false

func on_reload_ended():
	state_machine.set_can_fire(true)
	state_machine.set_state("Idle")
	back_to_ads()

func set_full_magazine(was_actor_dead = false):
	current_ammo = MAGAZINE
	if was_actor_dead: state_machine.set_can_fire(true)
	emit_signal("on_reloaded")

func sprint(value):
	front_muzzle_sprite.hide()
	side_muzzle_sprite.hide()
	state_machine.set_sprint(value)

func to_stowed_position():
	transform.origin = STOWED_POSITION

func connect_signals():
	connect("on_out_of_ads",player,"_on_weapon_out_of_ads")
	connect("on_reloaded",player,"_on_weapon_reloaded")
	player.connect("on_player_death",self,"_on_player_dead")

func stow_weapon():
	if state_machine.stow_weapon():
		emit_signal("on_out_of_ads")

func draw_weapon():
	emit_signal("on_out_of_ads")
	state_machine.set_state("Draw")

func play_shot_sound():
	shoot_player.play()

func stop_shot_sound():
	shoot_player.stop()

func play_no_ammo_sound():
	audio_player.set_stream(no_ammo_sound)
	audio_player.play()

func emit_bullet():
	var shell = bullet.instance()
	bullet_emitter.add_child(shell)
	shell.emitting = true

func has_ammo():
	return true if current_ammo > 0 else false

func set_remote_layer():
	mesh.set_layer_mask_bit(1,false)
	mesh.set_layer_mask_bit(2,true)
	for model in mesh.get_children():
		if model.has_method("set_layer_mask_bit"):
			model.set_layer_mask_bit(1,false)
			model.set_layer_mask_bit(2,true)

func set_player_dead():
	state_machine.set_can_fire(false)

func on_stowed():
	emit_signal("on_stowed",self)

func on_draw_complete():
	transform.origin = DEFAULT_POSITION
	state_machine.set_state("Idle")
	emit_signal("on_draw_completed")

func _on_AnimationPlayer_animation_finished(_anim_name):
	front_muzzle_sprite.hide()
	side_muzzle_sprite.hide()

func _on_player_dead(_actor):
	is_ads = false
	state_machine.set_state("Stowed")
	weapon_controller.set_ads(false)

func _on_AnimationPlayer_animation_started(_anim_name):
	front_muzzle_sprite.hide()
	side_muzzle_sprite.hide()
