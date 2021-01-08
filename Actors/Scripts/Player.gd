extends KinematicBody
class_name Player

onready var bullet_decal = preload("res://Utils/scenes/BulletDecal.tscn")
onready var blood_emitter = preload("res://particles/scenes/BloodEmitter.tscn")
onready var death_emitter = preload("res://particles/scenes/DeathEmitter.tscn")
onready var weapon_camera = preload("res://Utils/scenes/WeaponCamera.tscn")
onready var sniper_view = preload("res://Utils/scenes/SniperView.tscn")

onready var head: Spatial = $Head
onready var player_controller = $PlayerController
onready var state_machine = $StateMachine
onready var ground_check = $GroundCheck
onready var aim_cast: RayCast = $Head/Camera/AimCast
onready var camera = $Head/Camera
onready var camera_anim_player = $Head/Camera/CameraAnimPlayer
onready var audio_player = $AudioPlayer
onready var footstep_player = $FootstepPlayer
onready var hand = $Head/Hand
onready var hand_loc = $Head/HandLoc
onready var primary_holster = $PrimaryHolster
onready var secondary_holster = $SecondaryHolster
onready var crosshair = $Head/Camera/Container/Crosshair
onready var sniper_overlay = $Head/Camera/Container/SniperOverlay
onready var player_hud = $PlayerHUD
onready var mesh = $Mesh
onready var weapon_view = $WeaponView

export var HEALTH = 100 setget ,get_max_health
export var RECOVER_DELAY = 3.0
export var RECOVER_RATE = 1.0
export var DEFAULT_FOV = 70
export var MIN_X_FLINCH = 0.5
export var MAX_X_FLINCH = 1.0
export var MIN_Y_FLINCH = 0.5
export var MAX_Y_FLINCH = 1.0

signal on_weapon_equipped(clip_size)
signal on_weapon_changed(current_ammo,clip_size)
signal on_shot_fired()
signal on_reload()
signal on_health_changed(current_health)
signal on_player_death(actor)
signal on_player_killed(id,is_headshot)
signal on_player_spawned()
signal on_menu_pressed(value)
signal on_score_changed(item)

var is_ads = false setget set_is_ads,get_is_ads
var is_moving = false setget set_is_moving,get_is_moving
var is_firing = false setget set_is_firing,get_is_firing
var current_anim = "headbob"
var current_weapon
var current_health
var last_player_spotted
var last_spawn setget set_last_spawn,get_last_spawn
var velocity = Vector3.ZERO setget ,get_velocity
var floor_contact = true setget ,get_floor_contact
var recover_timer = 0.0
var is_recovering = false
var weapons = [-1,-1]

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

func set_is_ads(value):
	is_ads = value
	if is_ads:
		player_controller.set_mouse_sensitivity(current_weapon.get_ads_sensitivity())
		current_anim = "ads-headbob"
	else:
		player_controller.set_mouse_sensitivity()
		current_anim = "headbob"
	if is_moving:
			play_camera_anim(true)
	if current_weapon:
		if current_weapon.get_has_scope():
			if is_ads == true:
				sniper_overlay.show()
				weapon_view.hide()
			else:
				sniper_overlay.hide()
				weapon_view.show()
		current_weapon.ads(value)
		aim_cast.cast_to.z = current_weapon.get_range() * -1

func get_is_ads():
	return is_ads

remotesync func set_is_firing(value):
	if value:
		is_firing = true
		current_weapon.fire()
		if is_network_master(): emit_signal("on_shot_fired")
	else:
		is_firing = false

func get_is_firing():
	return is_firing

func set_last_spawn(value):
	last_spawn = value

func get_last_spawn():
	return last_spawn

func set_weapons(primary):
	weapons[0] = Armory.primaries[primary]
	weapons[1] = Armory.secondaries[0]

func initialize():
	current_health = HEALTH
	player_hud.set_progress(current_health)
	state_machine.set_state("Idle")
	if is_network_master(): camera.current = true
	emit_signal("on_player_spawned")

func initialize_hand():
	if !is_network_master():
		var remote_weapons = []
		for weapon in weapons:
			var new_weapon = "Remote " + weapon
			remote_weapons.append(new_weapon)
		weapons = remote_weapons
	hand.initialize(self,weapons)

func _ready():
	randomize()
	if is_network_master():
		print("Meu unique id: " + str(get_tree().get_network_unique_id()))
		print("Meu nome é: " + name)
		Global.player = self
	get_node("/root/Game").connect_player_signals(self)
	instance_weapon_camera()
	instance_sniper_overlay()
	hand.set_as_toplevel(true)
	initialize_hand()
	equip_weapon(hand.get_current_weapon())
	emit_signal("on_weapon_equipped",current_weapon.get_magazine())
	player_controller._initialize(state_machine)
	state_machine.initialize("Idle")

func _unhandled_input(event):
	if is_network_master() and state_machine.get_current_state() != "Dead":
		state_machine.handle_input(event)
		player_controller.handle_input(event)

func _process(delta):
	recover_health(delta)
	weapon_sway(delta)
	if is_network_master():
		if is_ads and camera.fov > current_weapon.get_ads_fov():
			camera.fov = lerp(camera.fov,current_weapon.get_ads_fov(), current_weapon.get_ads_speed() * delta)
		elif !is_ads and camera.fov < DEFAULT_FOV:
			camera.fov = lerp(camera.fov,DEFAULT_FOV,current_weapon.get_ads_speed() * delta)
		if Input.is_action_just_pressed("dmg_test"):
			add_damage(int(name),Vector3.ZERO,10,false)

func _physics_process(delta):
	if is_network_master():
		check_for_player()
		check_floor()
		state_machine.update(delta)
		if velocity != Vector3.ZERO:
			rpc_unreliable("update_position",global_transform.origin,rotation.y,head.rotation.x)

func move(delta):
	var movement = player_controller.calculate_movement(delta)
	velocity = move_and_slide(movement,Vector3.UP)
	return velocity

remote func update_position(position,body_rotation,head_rotation):
	global_transform.origin = position
	rotation.y = body_rotation
	head.rotation.x = head_rotation

func weapon_sway(delta):
	hand.global_transform.origin = hand_loc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y,rotation.y,current_weapon.get_sway() * delta)
	hand.rotation.z = lerp_angle(hand.rotation.z,head.rotation.z,current_weapon.get_sway() * delta)
	if player_controller.is_sprinting() and !is_ads and !is_firing:
		hand.rotation.x = lerp_angle(hand.rotation.x,head.rotation.x + current_weapon.get_sprint_angle(),current_weapon.get_sway() * delta)
	else:
		hand.rotation.x = lerp_angle(hand.rotation.x,head.rotation.x,current_weapon.get_sway() * delta)

func recover_health(delta):
	if is_recovering:
		recover_timer += delta
		if recover_timer >= RECOVER_DELAY:
			current_health += RECOVER_RATE
			player_hud.set_progress(current_health)
			if is_network_master(): 
				emit_signal("on_health_changed",current_health)
			if current_health == HEALTH:
				is_recovering = false

func jump():
	current_weapon.jump()

func check_floor():
	floor_contact = ground_check.is_colliding()

func ads(value):
	if current_weapon.get_can_ads():
		set_is_ads(value)

func check_for_player():
	if aim_cast.is_colliding():
		var collision = aim_cast.get_collider()
		if collision.is_in_group("Player"):
			collision.show_player_hud(true)
			last_player_spotted = collision
		elif last_player_spotted:
			last_player_spotted.show_player_hud(false)
			last_player_spotted = null
	elif last_player_spotted:
		last_player_spotted.show_player_hud(false)
		last_player_spotted = null

func show_player_hud(value):
	player_hud.visible = value

func set_hud_name(player_name):
	player_hud.set_name(player_name)

remotesync func fire():
	print("apertou e: " + str(current_weapon.get_can_fire()))
	if current_weapon.get_can_fire():
		get_shot_victim()

func get_shot_victim():
		var target = null
		var distance = 0.0
		var point = Vector3.ZERO
		set_is_firing(true)
		if is_network_master():
			if aim_cast.is_colliding():
				target = aim_cast.get_collider()
				point = aim_cast.get_collision_point()
				distance = transform.origin.distance_to(point)
			if target and target != self:
				var is_headshot = check_if_is_headshot(aim_cast.get_collider_shape())
				hit_target(target,point,distance,is_headshot)

remotesync func stop_firing():
	set_is_firing(false)

func check_if_is_headshot(shape_id):
	if shape_id == 1:
		return true
	else:
		return false

func hit_target(target,point,distance,is_headshot):
	var damage = current_weapon.get_damage(distance,is_headshot)
	if target.is_in_group("World"):
		place_decal(target)
		return
	if target.is_in_group("Player"):
		rpc("update_score","damage",damage,is_headshot)
		target.rpc("add_damage",int(name),point,damage,is_headshot)
		return
	if target.is_in_group("Enemy"):
		var is_dead = target.add_damage(point,damage)
		rpc("update_score","damage",damage,is_headshot)
		if is_dead:
			rpc("update_score","kills",1,is_headshot)
		return

remotesync func add_damage(attacker_id,point,damage,is_headshot):
	create_blood_splash(point)
	current_health -= damage
	print("player health: " + str(current_health))
	play_hurt_sound()
	player_hud.set_progress(current_health)
	is_recovering = true
	recover_timer = 0.0
	if is_network_master():
		shake_camera(MIN_X_FLINCH,MAX_X_FLINCH,MIN_Y_FLINCH,MAX_Y_FLINCH)
		emit_signal("on_health_changed",current_health)
	if current_health <= 0:
		is_recovering = false
		emit_signal("on_player_killed",attacker_id,is_headshot,int(name))
		if is_network_master(): rpc("update_score","deaths",1)
		rpc_id(int(name),"set_dead_state",true,attacker_id,point)
		return true
	return false

func create_blood_splash(point):
	var blood = blood_emitter.instance()
	add_child(blood)
	blood.global_transform.origin = point
	blood.emitting = true

func play_hurt_sound():
	var random = rand_range(0,3)
	if !audio_player.playing:
		if random > 1 and random <= 2:
			audio_player.set_stream(Mixer.hurt_sound_1)
			audio_player.play()
		elif random > 2 and random <= 3:
			audio_player.set_stream(Mixer.hurt_sound_2)
			audio_player.play()

func create_death_splash(point):
	var death = death_emitter.instance()
	add_child(death)
	death.global_transform.origin = point
	death.emitting = true

remotesync func set_dead_state(value,attacker_id = null,point = null):
	if !value:
		rpc("deactivate_player",value,point)
		state_machine.set_state("Idle")
		if is_network_master(): camera.current = !value
	else:
		is_firing = false
		is_ads = false
		rpc("deactivate_player",value,point)
		state_machine.set_state("Dead")
		audio_player.set_stream(Mixer.death_scream)
		audio_player.play()
		camera_anim_player.stop()
		yield(get_tree().create_timer(1.0),"timeout")
		emit_signal("on_player_death",self)
		if is_network_master():
			if attacker_id:
				get_node("/root/Game/Players/" + str(attacker_id)).camera.current = true
			else:
				camera.current = false

remotesync func deactivate_player(value,point = null):
	if !value: initialize()
	elif point: create_death_splash(point)
	set_process(!value)
	set_physics_process(!value)
	crosshair.visible = !value
	set_collision_layer_bit(0,!value)
	set_collision_mask_bit(0,!value)
	if value and point: yield(get_tree().create_timer(1),"timeout")
	visible = !value

func place_decal(target):
	if target.is_in_group("World"):
		var bullet = bullet_decal.instance()
		target.add_child(bullet)
		bullet.global_transform.origin = aim_cast.get_collision_point()
		if aim_cast.get_collision_normal().is_equal_approx(Vector3.UP):
			bullet.rotation_degrees.x = 90
		else:
			bullet.look_at(aim_cast.get_collision_point() + aim_cast.get_collision_normal(),Vector3.UP)

remotesync func update_score(item,value,is_headshot = false):
	Scores.update_score(int(name),item,value,is_headshot)
	emit_signal("on_score_changed",int(name),item)

func play_camera_anim(value):
	if value:
		camera_anim_player.play(current_anim)
	else:
		camera_anim_player.stop()

remotesync func reload_weapon():
	current_weapon.reload()

remotesync func equip_weapon(weapon):
	if weapon:
		current_weapon = hand.get_current_weapon()
		aim_cast.cast_to.z = weapon.get_range() * -1

remotesync func equip_slot(index):
	equip_weapon(hand.equip_weapon(index))

remotesync func swap_equip():
	var new_weapon = hand.swap_weapon()
	if new_weapon:
		equip_weapon(new_weapon)
		if is_network_master():
			emit_signal("on_weapon_changed",current_weapon.get_current_ammo(),current_weapon.get_magazine())

func shake_camera(min_x,max_x,min_y,max_y):
	if is_network_master():
		var dir_value = randi()%4-2
		var x_value = rand_range(min_x,max_x)
		var y_value = rand_range(min_y,max_y) * dir_value
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

func play_footsteps():
	var random = rand_range(0,3)
	if !footstep_player.playing:
		if random > 0 and random <= 1.6:
			footstep_player.set_stream(Mixer.footsteps_1)
		elif random > 1.6 and random <= 2.8:
			footstep_player.set_stream(Mixer.footsteps_2)
		else:
			footstep_player.set_stream(Mixer.footsteps_3)
	footstep_player.play()

func show_menu(value):
	if value:
		set_is_firing(false)
		set_is_ads(false)
	emit_signal("on_menu_pressed",value)

func exit_menu():
	player_controller.exit_menu()

func set_material(color):
	mesh.set_material_override(load(Global.color_materials[color]))

func instance_weapon_camera():
	if is_network_master():
		var cam = weapon_camera.instance()
		cam.initialize(camera)
		add_child(cam)
		weapon_view.texture = cam.get_texture()

func instance_sniper_overlay():
	if is_network_master():
		var view = sniper_view.instance()
		add_child(view)
		sniper_overlay.texture = view.get_texture()

func _on_weapon_out_of_ads():
	set_is_ads(false)

func _on_weapon_reloaded():
	if is_network_master():
		emit_signal("on_reload")

func _on_Player_tree_exiting():
	player_controller.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
