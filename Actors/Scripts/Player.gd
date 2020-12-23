extends KinematicBody

onready var bullet_decal = preload("res://Utils/scenes/BulletDecal.tscn")

onready var head: Spatial = $Head
onready var player_controller = $PlayerController
onready var state_machine = $StateMachine
onready var ground_check = $GroundCheck
onready var aim_cast = $Head/Camera/AimCast
onready var weapon = $Head/Camera/Hand/Weapon
onready var camera = $Head/Camera

export var DEFAULT_FOV = 70

var is_ads = false

var velocity = Vector3.ZERO
var floor_contact = true setget ,get_floor_contact

func get_floor_contact():
	return floor_contact

func _ready():
	player_controller._initialize(state_machine)
	state_machine.initialize("Idle")

func _unhandled_input(event):
	state_machine.handle_input(event)
	player_controller.handle_input(event)

func _process(delta):
	if is_ads and camera.fov > weapon.get_ads_fov():
		camera.fov = lerp(camera.fov,weapon.get_ads_fov(), weapon.get_ads_speed() * delta)
	elif !is_ads and camera.fov < DEFAULT_FOV:
		camera.fov = lerp(camera.fov,DEFAULT_FOV,weapon.get_ads_speed() * delta)

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
	weapon.ads(value)

func get_aimcast_collider():
	var target = null
	if aim_cast.is_colliding():
		var bullet = bullet_decal.instance()
		target = aim_cast.get_collider()
		if target.is_in_group("World"):
			target.add_child(bullet)
			bullet.global_transform.origin = aim_cast.get_collision_point()
			print(aim_cast.get_collision_normal().abs())
			if aim_cast.get_collision_normal().is_equal_approx(Vector3.UP):
				bullet.rotation_degrees.x = 90
			else:
				bullet.look_at(aim_cast.get_collision_point() + aim_cast.get_collision_normal(),Vector3.UP)
	return target

func get_player_controller():
	return player_controller

