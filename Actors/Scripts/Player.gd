extends KinematicBody

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

export var DEFAULT_FOV = 70
export(PoolStringArray) var weapons = []

var is_ads = false setget ,get_is_ads
var is_moving = false setget set_is_moving,get_is_moving
var current_anim = "headbob"
var current_weapon

var velocity = Vector3.ZERO
var floor_contact = true setget ,get_floor_contact

func get_player_controller():
	return player_controller

func get_floor_contact():
	return floor_contact

func set_is_moving(value):
	is_moving = value

func get_is_moving():
	return is_moving

func get_is_ads():
	return is_ads

func _ready():
	Global.player = self
	hand.set_as_toplevel(true)
	hand.initialize(weapons)
	current_weapon = hand.get_current_weapon()
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

func _physics_process(delta):
	check_floor()
	state_machine.update(delta)

func move(delta):
	var movement = player_controller.calculate_movement(delta)
	velocity = move_and_slide(movement,Vector3.UP)
	return velocity

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
	if state_machine.get_current_state() == "Sprinting" and !is_ads:
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

func stop_firing():
	current_weapon.fire(false)
	shake_reset()

func shake_camera(x_recoil,y_recoil):
	var vector = get_shake_vector(aim_cast,x_recoil,y_recoil)
	#camera.translation = lerp(camera.translation,vector,0.5)
	aim_cast.translation = lerp(aim_cast.translation,vector,0.5)

func shake_reset():
	aim_cast.translation = lerp(aim_cast.translation,Vector3.ZERO,1)
	#camera.translation = lerp(camera.translation,Vector3.ZERO,1)

func get_shake_vector(node,x_recoil,y_recoil):
	return Vector3(rand_range(x_recoil,-x_recoil),rand_range(y_recoil + node.translation.y,y_recoil),0)
