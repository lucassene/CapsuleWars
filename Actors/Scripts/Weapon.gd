extends Spatial

onready var anim_player = $AnimationPlayer
onready var shoot_player = $Model/Muzzle/ShootPlayer
onready var audio_player = $AudioPlayer

enum type {
	PRIMARY,
	SECONDARY
}

export(type) var TYPE = type.PRIMARY setget ,get_type
export var AUTO = false
export var RATE_OF_FIRE = 1.0
export var MAGAZINE = 10 setget ,get_magazine
export var DAMAGE = 5 setget ,get_damage

export var ADS_POSITION = Vector3.ZERO setget ,get_ads_position
export var DEFAULT_POSITION = Vector3.ZERO
export var ADS_SPEED = 20 setget ,get_ads_speed
export var ADS_FOV = 50 setget ,get_ads_fov
export var SWAY = 40
export var ADS_SWAY = 100
export var SPRINT_ANGLE = 45 setget ,get_sprint_angle
export var MIN_X_RECOIL = 1.0
export var MAX_X_RECOIL = 2.0
export var MIN_Y_RECOIL = 1.0
export var MAX_Y_RECOIL = 1.0
export var Y_MULTI = 1

export(AudioStream) var fire_sound

var player
var is_ads = false
var is_stowed = true
var can_swap = true setget ,get_can_swap
var current_ammo setget ,get_current_ammo
var can_fire = true setget ,get_can_fire
var can_ads = true setget ,get_can_ads

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

func get_damage():
	return DAMAGE

func get_can_fire():
	return can_fire

func get_can_swap():
	return can_swap

func get_can_ads():
	return can_ads

func _ready():
	set_process(false)
	transform.origin = DEFAULT_POSITION
	current_ammo = MAGAZINE
	connect_signals()

func _process(delta):
	if is_ads:
		transform.origin = transform.origin.linear_interpolate(ADS_POSITION,ADS_SPEED * delta)
	else:
		transform.origin = transform.origin.linear_interpolate(DEFAULT_POSITION,ADS_SPEED * delta)

func set_owner(actor):
	player = actor

func ads(value):
	is_ads = value

func fire(value,target = null):
	if value and can_fire:
		current_ammo -= 1
		can_fire = false
		anim_player.playback_speed = 1.0 * RATE_OF_FIRE
		if current_ammo > 0:
			anim_player.play("firing")
		else:
			anim_player.play("out_of_ammo")
		if target and target.is_in_group("Enemy"):
			target.add_damage(DAMAGE)
	else:
		if AUTO: 
			anim_player.play("idle")
			can_fire = true

func reload():
	if current_ammo < MAGAZINE:
		is_ads = false
		can_fire = false
		can_ads = false
		emit_signal("on_out_of_ads")
		anim_player.playback_speed = 1.0
		anim_player.play("reload")

func set_full_magazine():
	current_ammo = MAGAZINE
	can_fire = true
	can_ads = true
	emit_signal("on_reloaded")

func jump():
	if anim_player.get_current_animation() == "idle":
		anim_player.play("jump")

func connect_signals():
	connect("on_out_of_ads",player,"_on_weapon_out_of_ads")
	connect("on_reloaded",player,"_on_weapon_reloaded")

func stow_weapon():
	can_fire = false
	can_ads = false
	anim_player.play("stow")

func draw_weapon():
	can_fire = false
	can_ads = false
	anim_player.play("draw")

func on_stowed():
	is_stowed = true
	can_fire = false
	can_ads = false
	set_process(false)
	emit_signal("on_stowed",self)

func on_draw_complete():
	set_process(true)
	can_fire = true
	can_ads = true
	transform.origin = DEFAULT_POSITION
	is_stowed = false
	emit_signal("on_draw_completed")

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"firing":
			if current_ammo > 0:
				if AUTO:
					anim_player.play("firing")
					can_fire = true
					player.get_aimcast_collider()
					return
				can_fire = true
	anim_player.play("idle")

func _on_AnimationPlayer_animation_started(anim_name):
	if anim_name == "idle":
		anim_player.playback_speed = 1.0
		can_swap = true
		return
	if anim_name == "firing" or anim_name == "out_of_ammo":
		if shoot_player.stream == fire_sound:
			shoot_player.seek(0.0)
		else:
			shoot_player.set_stream(fire_sound)
		shoot_player.play()
		anim_player.playback_speed = 1.0 * RATE_OF_FIRE
		Global.player.shake_camera(MAX_X_RECOIL,MIN_X_RECOIL,MAX_Y_RECOIL,MIN_Y_RECOIL,Y_MULTI)
	can_swap = false

