extends Spatial

onready var bullet = preload("res://particles/scenes/BulletEmitter.tscn")

onready var anim_player = $AnimationPlayer
onready var shoot_player = $Model/Muzzle/ShootPlayer
onready var audio_player = $AudioPlayer
onready var front_muzzle_sprite = $Model/Muzzle/MuzzleFront
onready var side_muzzle_sprite = $Model/Muzzle/MuzzleSide
onready var bullet_emitter = $BulletEmitter

enum type {
	PRIMARY,
	SECONDARY
}

export(type) var TYPE = type.PRIMARY setget ,get_type
export var AUTO = false
export var RATE_OF_FIRE = 1.0
export var MAGAZINE = 10 setget ,get_magazine
export var DAMAGE = 5
export var HEADSHOT_DAMAGE_MULTI = 1.5
export var MAX_RANGE = 100
export var ADS_RANGE_MULTI = 1.2
export var FALLOFF_RANGE = 50
export var FALLOFF_DAMAGE_MULTI = 0.75

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

export(AudioStream) var fire_sound

var player
var is_ads = false
var is_stowed = true
var is_draw = false
var is_reloading = false
var can_swap = true setget ,get_can_swap
var can_reload = false
var current_ammo setget ,get_current_ammo
var can_fire = false setget ,get_can_fire
var can_ads = false setget ,get_can_ads

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

func get_can_fire():
	if can_fire and !is_stowed and is_draw:
		return true
	else:
		return false

func get_can_swap():
	return can_swap

func get_can_ads():
	return can_ads

func get_range():
	if is_ads:
		return MAX_RANGE * ADS_RANGE_MULTI
	else:
		return MAX_RANGE

func get_damage(distance,is_headshot):
	var dmg = DAMAGE
	if is_headshot:
		dmg *= HEADSHOT_DAMAGE_MULTI
	if is_ads and distance > (FALLOFF_RANGE * ADS_RANGE_MULTI):
		return dmg * FALLOFF_DAMAGE_MULTI
	elif distance > FALLOFF_RANGE:
		return dmg * FALLOFF_DAMAGE_MULTI
	return dmg

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

func fire():
	if get_can_fire():
		current_ammo -= 1
		anim_player.playback_speed = 1.0 * RATE_OF_FIRE
		if current_ammo > 0:
			anim_player.play("firing")
		else:
			anim_player.play("out_of_ammo")

func reload():
	if current_ammo < MAGAZINE and can_reload and !is_stowed:
		is_ads = false
		emit_signal("on_out_of_ads")
		anim_player.playback_speed = 1.0
		anim_player.play("reload")

func set_full_magazine():
	current_ammo = MAGAZINE
	emit_signal("on_reloaded")

func jump():
	if anim_player.get_current_animation() == "idle":
		anim_player.play("jump")

func to_stowed_position():
	transform.origin = STOWED_POSITION

func connect_signals():
	connect("on_out_of_ads",player,"_on_weapon_out_of_ads")
	connect("on_reloaded",player,"_on_weapon_reloaded")
	player.connect("on_player_death",self,"_on_player_dead")

func stow_weapon():
	emit_signal("on_out_of_ads")
	anim_player.play("stow")

func draw_weapon():
	emit_signal("on_out_of_ads")
	anim_player.play("draw")

func emit_bullet():
	var shell = bullet.instance()
	bullet_emitter.add_child(shell)
	#shell.transform.origin = bullet_emmiter.global_transform.origin
	shell.emitting = true

func on_stowed():
	set_process(false)
	is_stowed = true
	is_draw = false
	emit_signal("on_stowed",self)

func on_draw_complete():
	transform.origin = DEFAULT_POSITION
	is_draw = true
	is_stowed = false
	emit_signal("on_draw_completed")
	set_process(true)

func _on_AnimationPlayer_animation_started(anim_name):
	anim_player.playback_speed = 1.0
	match anim_name:
		"reload":
			is_reloading = true
			can_ads = false
			can_swap = false
			can_fire = false
			return
		"idle":
			can_ads = true
			can_swap = true
			if current_ammo > 0: can_fire = true
			return
		"draw":
			is_ads = false
			can_ads = false
			can_swap = false
			can_fire = false
			can_reload = false
			return
		"stow":
			is_ads = false
			is_stowed = true
			is_draw = false
			can_ads = false
			can_swap = false
			can_fire = false
			can_reload = false
			return
		"firing","out_of_ammo":
			can_swap = false
			if !AUTO: can_fire = false
			if shoot_player.stream == fire_sound:
				shoot_player.seek(0.0)
			else:
				shoot_player.set_stream(fire_sound)
			shoot_player.play()
			anim_player.playback_speed = 1.0 * RATE_OF_FIRE
			if is_network_master(): player.shake_camera(MAX_X_RECOIL,MIN_X_RECOIL,MAX_Y_RECOIL,MIN_Y_RECOIL)
			return

func _on_AnimationPlayer_animation_finished(anim_name):
	anim_player.play("idle")
	match anim_name:
		"firing":
			can_swap = true
			can_ads = true
			if current_ammo > 0:
				if AUTO and player.get_is_firing():
					anim_player.play("firing")
					player.fire()
					return
				can_fire = true
			else:
				can_fire = false
			return
		"out_of_ammo":
			can_ads = true
			can_swap = true
			can_fire = false
			return
		"reload":
			is_reloading = false
			can_ads = true
			can_swap = true
			can_fire = true
			return
		"draw":
			is_stowed = false
			is_draw = true
			can_ads = true
			can_fire = true
			can_swap = true
			can_reload = true
			return
		"stow":
			is_stowed = true
			is_draw = false
			can_ads = false
			can_fire = false
			can_swap = false
			can_reload = true
			return

func _on_player_dead(_actor):
	is_ads = false
#	is_reloading = false
#	can_ads = false
#	can_fire = false
#	can_swap = false
#	can_reload = false

