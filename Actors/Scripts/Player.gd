extends KinematicBody
class_name Player

onready var bullet_decal = preload("res://Utils/scenes/BulletDecal.tscn")

onready var head: Spatial = $Head
onready var player_controller = $PlayerController
onready var state_machine = $StateMachine
onready var ground_check = $GroundCheck
onready var aim_cast = $Head/Camera/AimCast
onready var camera = $Head/Camera
onready var camera_anim_player = $Head/Camera/CameraAnimPlayer
onready var hand = $Head/Hand
onready var hand_loc = $Head/HandLoc
onready var primary_holster = $PrimaryHolster
onready var secondary_holster = $SecondaryHolster

export var HEALTH = 100 setget ,get_max_health
export var DEFAULT_FOV = 70
export(PoolStringArray) var weapons = []

signal on_weapon_equipped(clip_size)
signal on_weapon_changed(current_ammo,clip_size)
signal on_shot_fired()
signal on_reload()
signal on_damage_suffered(current_health)

var is_ads = false setget ,get_is_ads
var is_moving = false setget set_is_moving,get_is_moving
var is_firing = false
var current_anim = "headbob"
var current_weapon
var current_health

var velocity = Vector3.ZERO setget ,get_velocity
var floor_contact = true setget ,get_floor_contact

func get_player_controller():
	return player_controller

func get_max_health():
	return HEALTH

func get_velocity():
	return velocity

func get_floor_contact():
	return floor_contact

func set_is_moving(value):
	is_moving = value

func get_is_moving():
	if is_on_floor():
		return is_moving
	return false

func get_is_ads():
	return is_ads

func _ready():
	randomize()
	current_health = HEALTH
	Global.player = self
	hand.set_as_toplevel(true)
	hand.initialize(weapons)
	current_weapon = hand.get_current_weapon()
	emit_signal("on_weapon_equipped",current_weapon.get_magazine())
	player_controller._initialize(state_machine)
	state_machine.initialize("Idle")

func _unhandled_input(event):
	state_machine.handle_input(event)
	player_controller.handle_input(event)

func _process(delta):
	if is_ads and camera.fov > current_weapon.get_ads_fov():
		camera.fov = lerp(camera.fov,current_weapon.get_ads_fov(), current_weapon.get_ads_speed() * delta)
	elif !is_ads and camera.fov < DEFAULT_FOV:
		camera.fov = lerp(camera.fov,DEFAULT_FOV,current_weapon.get_ads_speed() * delta)
	weapon_sway(delta)
	if Input.is_action_just_pressed("dmg_test"):
		add_damage(10)

func _physics_process(delta):
	check_floor()
	state_machine.update(delta)

func move(delta):
	var movement = player_controller.calculate_movement(delta)
	velocity = move_and_slide(movement,Vector3.UP)
	return velocity

func jump():
	current_weapon.jump()

func check_floor():
	floor_contact = ground_check.is_colliding()

func ads(value):
	is_ads = value
	if is_ads:
		current_anim = "ads-headbob"
	else:
		current_anim = "headbob"
	if is_moving:
		play_camera_anim(true)
	current_weapon.ads(value)

func get_aimcast_collider():
	var target = null
	if current_weapon.get_can_fire():
		is_firing = true
		emit_signal("on_shot_fired")
		if aim_cast.is_colliding():
			target = aim_cast.get_collider()
			place_decal(target)
		current_weapon.fire(true,target)

func place_decal(target):
	if target.is_in_group("World"):
		var bullet = bullet_decal.instance()
		target.add_child(bullet)
		bullet.global_transform.origin = aim_cast.get_collision_point()
		if aim_cast.get_collision_normal().is_equal_approx(Vector3.UP):
			bullet.rotation_degrees.x = 90
		else:
			bullet.look_at(aim_cast.get_collision_point() + aim_cast.get_collision_normal(),Vector3.UP)

func play_camera_anim(value):
	if value:
		camera_anim_player.play(current_anim)
	else:
		camera_anim_player.stop()

func weapon_sway(delta):
	hand.global_transform.origin = hand_loc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y,rotation.y,current_weapon.get_sway() * delta)
	hand.rotation.z = lerp_angle(hand.rotation.z,head.rotation.z,current_weapon.get_sway() * delta)
	if player_controller.is_sprinting() and !is_ads and !is_firing:
		hand.rotation.x = lerp_angle(hand.rotation.x,head.rotation.x + current_weapon.get_sprint_angle(),current_weapon.get_sway() * delta)
	else:
		hand.rotation.x = lerp_angle(hand.rotation.x,head.rotation.x,current_weapon.get_sway() * delta)

func reload_weapon():
	current_weapon.reload()

func equip_slot(index):
	current_weapon = hand.equip_weapon(index)

func swap_equip():
	var new_weapon = hand.swap_weapon()
	if new_weapon:
		current_weapon = new_weapon
		emit_signal("on_weapon_changed",current_weapon.get_current_ammo(),current_weapon.get_magazine())

func stop_firing():
	is_firing = false
	current_weapon.fire(false)

func shake_camera(min_x,max_x,min_y,max_y,y_multi):
	var x_value = rand_range(min_x,max_x)
	var y_value = rand_range(min_y,max_y) * y_multi
	head.rotation_degrees.x = lerp(head.rotation_degrees.x,head.rotation_degrees.x + x_value,0.25)
	rotation_degrees.y = lerp(rotation_degrees.y,rotation_degrees.y + y_value,0.25)

func stow_weapon(weapon):
	if weapon.get_parent():
		weapon.get_parent().remove_child(weapon)
	if weapon.get_type() == Armory.type.PRIMARY:
		primary_holster.add_child(weapon)
	else:
		secondary_holster.add_child(weapon)
	weapon.transform.origin = Vector3.ZERO

func add_damage(damage):
	current_health -= damage
	emit_signal("on_damage_suffered",current_health)

func _on_weapon_out_of_ads():
	is_ads = false

func _on_weapon_reloaded():
	emit_signal("on_reload")
	if player_controller.check_if_ads_still_pressed(): 
		ads(true)
