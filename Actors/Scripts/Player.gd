extends KinematicBody
class_name Player

onready var bullet_decal = preload("res://Utils/scenes/BulletDecal.tscn")
onready var blood_emitter = preload("res://particles/scenes/BloodEmitter.tscn")
onready var melee_splash = preload("res://particles/scenes/MeleeSplash.tscn")
onready var death_emitter = preload("res://particles/scenes/DeathEmitter.tscn")
onready var weapon_camera = preload("res://Utils/scenes/WeaponCamera.tscn")
onready var sniper_view = preload("res://Utils/scenes/SniperView.tscn")
onready var floating_damage = preload("res://interface/scenes/FloatingDamage.tscn")

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
onready var melee_holster = $MeleeHolster
onready var crosshair = $Head/Camera/Container/Crosshair
onready var player_hud = $PlayerHUD
onready var mesh = $Mesh
onready var weapon_view = $CenterContainer/WeaponView
onready var container = $Head/Camera/Container
onready var hit_feedback = $CanvasLayer/HitFeedback
onready var hit_marker = $CanvasLayer/HitMarker
onready var float_dmg_container = $FloatDmgContainer

const HEAD_COLLISION_ID = 1
const BUTT_COLLISION_ID = 3
const VERTICAL_SWAY = 0.05
const ADS_SWAY_MULTIPLIER = 0.15

export var HEALTH = 100 setget ,get_max_health
export var RECOVER_DELAY = 3.0
export var RECOVER_RATE = 1.0
export var DEFAULT_FOV = 70
export var HIT_COLOR = Color()
export var MELEE_COLOR = Color()
export var DEFAULT_HAND_Y = -0.301

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
var current_weapon setget ,get_current_weapon
var melee_weapon
var current_health
var last_player_spotted
var last_spawn setget set_last_spawn,get_last_spawn
var velocity = Vector3.ZERO setget ,get_velocity
var floor_contact = true setget ,get_floor_contact
var recover_timer = 0.0
var is_recovering = false
var weapons = [-1,-1]
var sniper_overlay
var dead = false
var last_attacker_id = -1
var remote_states = []

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

func get_current_weapon():
	return current_weapon

func is_dead():
	return dead

func set_is_ads(value):
	is_ads = value
	if is_ads:
		player_controller.ads(true,current_weapon.get_ads_sensitivity())
		current_anim = "ads-headbob"
		if current_weapon and is_network_master() and current_weapon.get_has_scope():
			sniper_overlay.show()
			weapon_view.hide()
			crosshair.hide()
	else:
		player_controller.ads(false)
		current_anim = "headbob"
		if player_controller.is_sprinting():
			state_machine.set_state("Sprinting")
		if current_weapon and is_network_master() and current_weapon.get_has_scope():
			sniper_overlay.hide()
			weapon_view.show()
			crosshair.hide()
	if is_moving:
			play_camera_anim(true)
	if current_weapon:
		aim_cast.cast_to.z = current_weapon.get_range() * -1

func get_is_ads():
	return is_ads

func set_is_firing(value):
	is_firing = value
	if value and is_network_master(): emit_signal("on_shot_fired")

func get_is_firing():
	return is_firing

func set_last_spawn(value):
	last_spawn = value

func get_last_spawn():
	return last_spawn

func set_weapons(primary,secondary):
	var primary_weapon = Armory.primaries[primary]
	if primary_weapon: 
		weapons[0] = primary_weapon
	else:
		print("Null primary weapon")
		weapons[0] = Armory.primaries[0]
	var secondary_weapon = Armory.secondaries[secondary]
	if secondary_weapon:
		weapons[1] = secondary_weapon
	else:
		print("Null secondary weapon")
		weapons[1] = Armory.secondaries[0]

remotesync func change_loadout(primary,secondary):
	set_weapons(primary,secondary)
	hand.change_loadout(weapons)
	equip_weapon(hand.get_current_weapon())

func initialize_hand():
	hand.initialize(self,weapons)

func initialize():
	current_health = HEALTH
	player_hud.set_progress(current_health)
	state_machine.set_state("Idle")
	update_position(OS.get_system_time_msecs(),last_spawn.global_transform.origin,rotation.y,head.rotation.x)
	hand.reload_weapons()
	if is_network_master(): 
		weapon_view.show()
		camera.current = true
		hit_marker.show()
		emit_signal("on_player_spawned")
	current_weapon.draw_weapon()
	GameSettings.update_mode()
	set_process(true)
	set_physics_process(true)

func _ready():
	randomize()
	set_process(false)
	set_physics_process(false)
	if is_network_master():
		print("Unique id: " + str(get_tree().get_network_unique_id()))
		Global.player = self
		hand.set_as_toplevel(true)
	get_node("/root/Game").connect_player_signals(self)
	instance_weapon_camera()
	instance_sniper_overlay()
	initialize_hand()
	equip_weapon(hand.get_current_weapon())
	player_controller._initialize(state_machine)
	state_machine.initialize("Dead",player_controller)

func _unhandled_input(event):
	if is_network_master():
		state_machine.handle_input(event)
		player_controller.handle_input(event)
		if player_controller.check_input_pressed(event,"sacrifice","sacrifice"): return

func _process(delta):
	recover_health(delta)
	if is_network_master():
		hand.global_transform.origin = hand_loc.global_transform.origin

func _physics_process(delta):
	if is_network_master():
		set_camera_fov(delta)
		weapon_sway(delta)
		check_for_player()
		check_floor()
		state_machine.update(delta)
		rpc_unreliable("update_position",OS.get_system_time_msecs(),global_transform.origin,rotation.y,head.rotation.x)
	else:
		move_puppet(delta)

func set_camera_fov(delta):
	if is_ads and camera.fov > current_weapon.get_ads_fov():
		camera.fov = lerp(camera.fov,current_weapon.get_ads_fov(), current_weapon.get_ads_speed() * delta)
	elif !is_ads and camera.fov < DEFAULT_FOV:
		camera.fov = lerp(camera.fov,DEFAULT_FOV,current_weapon.get_ads_speed() * delta)

func get_camera():
	return camera

func move(delta):
	var movement = player_controller.calculate_movement(delta)
	velocity = move_and_slide(movement,Vector3.UP)
	return velocity

func move_puppet(delta):
	var last_state
	if remote_states.size() == 1:
		last_state = remote_states[0]
	else:
		last_state = remote_states[1]
	var time_delta = OS.get_system_time_msecs() - last_state.time
	time_delta = clamp(time_delta,20,60)
	global_transform.origin = global_transform.origin.linear_interpolate(last_state.body_position, delta * time_delta)
	rotation.y = lerp_angle(rotation.y,last_state.body_rotation,delta * time_delta)
	head.rotation.x = lerp_angle(head.rotation.x,last_state.head_rotation,delta * time_delta)

remote func update_position(time,position,body_rotation,head_rotation):
	var player_state = create_state(time,position,body_rotation,head_rotation)
	if remote_states.size() > 1:
		remote_states.remove(0)
	remote_states.append(player_state)

func create_state(state_time,position,body_rot,head_rot):
	var state = {
		time = state_time,
		body_position = position,
		body_rotation = body_rot,
		head_rotation = head_rot
	}
	return state

func weapon_sway(delta):
	hand.rotation.y = lerp_angle(hand.rotation.y,rotation.y,current_weapon.get_sway() * delta)
	hand.rotation.z = lerp_angle(hand.rotation.z,head.rotation.z,current_weapon.get_sway() * delta)
	hand.rotation.x = lerp_angle(hand.rotation.x,head.rotation.x,current_weapon.get_sway() * delta)

func jump_sway(delta):
	var sway = VERTICAL_SWAY
	if is_ads: sway = VERTICAL_SWAY * ADS_SWAY_MULTIPLIER
	var sway_target = current_weapon.translation.y - sway
	current_weapon.translation.y = lerp(current_weapon.translation.y,sway_target,current_weapon.get_sway() * delta)

func falling_sway(delta):
	var sway = VERTICAL_SWAY
	if is_ads: sway = VERTICAL_SWAY * ADS_SWAY_MULTIPLIER
	current_weapon.translation.y = lerp(current_weapon.translation.y,current_weapon.translation.y + sway,current_weapon.get_sway() * delta)

func recover_health(delta):
	if is_recovering:
		recover_timer += delta
		if recover_timer >= RECOVER_DELAY:
			current_health += RECOVER_RATE
			player_hud.set_progress(current_health)
			if is_network_master(): 
				emit_signal("on_health_changed",current_health)
			if current_health >= HEALTH:
				current_health = HEALTH
				is_recovering = false

func sprint(value):
	if value:
		current_weapon.sprint(value)
	elif not value and not player_controller.is_sprinting():
		current_weapon.sprint(value)

func check_floor():
	floor_contact = ground_check.is_colliding()

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

func fire(firing):
	if not dead and firing:
		player_controller.fire(true)
		set_is_firing(true)
		get_shot_victim()
	else:
		player_controller.fire(false)
		set_is_firing(false)

func get_shot_victim():
		var target = null
		var distance = 0.0
		var point = Vector3.ZERO
		if is_network_master():
			if aim_cast.is_colliding():
				target = aim_cast.get_collider()
				point = aim_cast.get_collision_point()
				distance = transform.origin.distance_to(point)
			if target and target != self:
				var shot_type = check_shot_type(aim_cast.get_collider_shape())
				hit_target(target,point,distance,shot_type)

remotesync func stop_firing():
	set_is_firing(false)

func check_shot_type(shape_id):
	var type = Scores.REGULAR_SHOT
	if shape_id == HEAD_COLLISION_ID:
		type = Scores.HEADSHOT
	elif shape_id == BUTT_COLLISION_ID:
		type = Scores.TAILSHOT
	return type

func hit_target(target,point,distance,shot_type):
	var damage = current_weapon.get_damage(distance,shot_type)
	if target.is_in_group("World"):
		rpc("place_decal")
		return
	if target.is_in_group("Player") and is_network_master():
		rpc("update_score","damage",damage,shot_type)
		target.rpc("add_damage",int(name),point,damage,shot_type,false)
		target.show_floating_damage(damage,shot_type)
		return
	if target.is_in_group("Enemy"):
		var is_enemy_dead = target.add_damage(point,damage)
		rpc("update_score","damage",damage,shot_type)
		if is_enemy_dead:
			rpc("update_score","kills",1,shot_type)
		return

func get_target_screen_position(target):
	return camera.unproject_position(target.global_transform.origin)

remotesync func add_damage(attacker_id,point,damage,shot_type,is_melee):
	last_attacker_id = attacker_id
	create_blood_splash(point,is_melee)
	current_health -= damage
	play_hurt_sound()
	player_hud.set_progress(current_health)
	is_recovering = true
	recover_timer = 0.0
	if is_network_master():
		show_hit_marker(attacker_id)
		var weapon = get_player_by_id(attacker_id).get_current_weapon()
		show_hit_feedback(HIT_COLOR)
		shake_camera(weapon.MIN_X_FLINCH,weapon.MAX_X_FLINCH,weapon.MIN_Y_FLINCH,weapon.MAX_Y_FLINCH)
		emit_signal("on_health_changed",current_health)
	if current_health <= 0 and !dead:
		dead = true
		is_recovering = false
		current_weapon.set_player_dead()
		emit_signal("on_player_killed",attacker_id,shot_type,int(name))
		if is_network_master(): rpc("update_score","deaths",1)
		rpc_id(int(name),"set_dead_state",true,attacker_id,point)
		return true
	return false

func show_floating_damage(damage,shot_type):
	if not is_network_master():
		var label = floating_damage.instance()
		float_dmg_container.add_child(label)
		label.initialize(damage,shot_type)

func show_hit_marker(id):
	var attacker = get_node("../" + str(id))
	if attacker:
		hit_marker.show_hit_marker(self,attacker)

func show_hit_feedback(color):
	hit_feedback.modulate = color
	hit_feedback.show()
	yield(get_tree().create_timer(0.05),"timeout")
	hit_feedback.hide()

func get_player_by_id(id):
	for actor in get_parent().get_children():
		if actor.name == str(id):
			return actor

remotesync func melee_attack():
	if melee_weapon.is_ready() and !hand.is_busy():
		melee_holster.remove_child(melee_weapon)
		hand.add_child(melee_weapon)
		melee_weapon.attack()

func melee_hit(target,point):
	if is_network_master():
		target.show_floating_damage(melee_weapon.get_damage(),Scores.REGULAR_SHOT)
		target.rpc("add_damage",int(name),point,melee_weapon.get_damage(),Scores.REGULAR_SHOT,true)
		show_hit_feedback(MELEE_COLOR)

func create_blood_splash(point,is_melee):
	var blood
	if is_melee:
		blood = melee_splash.instance()
	else:
		blood = blood_emitter.instance()
	add_child(blood)
	blood.global_transform.origin = point
	blood.emitting = true

func play_hurt_sound():
	var random = rand_range(0,1)
	if !audio_player.playing:
		if random < 0.5:
			audio_player.set_stream(Mixer.hurt_sound_1)
			audio_player.play()
		else:
			audio_player.set_stream(Mixer.hurt_sound_2)
			audio_player.play()

func sacrifice():
	rpc_id(int(name),"set_dead_state",true)

remotesync func set_dead_state(value,attacker_id = null,point = null):
	if !value:
		dead = false
		rpc("deactivate_player",value,point)
	else:
		dead = true
		is_firing = false
		is_ads = false
		player_controller.reset_sprint()
		rpc("deactivate_player",value,point)
		state_machine.set_state("Dead")
		audio_player.set_stream(Mixer.death_scream)
		audio_player.play()
		camera_anim_player.stop()
		yield(get_tree().create_timer(1.0),"timeout")
		emit_signal("on_player_death",self)
		if is_network_master(): 
			sniper_overlay.hide()
			hit_marker.hide()
			if attacker_id:
				get_node("/root/Game/Players/" + str(attacker_id)).camera.current = true
			else:
				camera.current = false

remotesync func deactivate_player(value,point = null):
	if !value: 
		initialize()
	elif point: 
		create_death_splash(point)
		set_process(false)
		set_physics_process(false)
	current_weapon = hand.back_to_primary()
	if is_network_master():
		emit_signal("on_weapon_equipped",current_weapon.get_magazine())
	set_collision_layer_bit(0,!value)
	set_collision_mask_bit(0,!value)
	visible = !value

remotesync func place_decal():
	var bullet = bullet_decal.instance()
	var normal = aim_cast.get_collision_normal()
	get_node("/root/Game").add_child(bullet)
	bullet.global_transform.origin = aim_cast.get_collision_point()
	if normal.is_equal_approx(Vector3.UP):
		bullet.rotation_degrees.x = 90
	elif normal.is_equal_approx(Vector3.DOWN):
		bullet.rotation_degrees.x = -90
	else:
		bullet.look_at(aim_cast.get_collision_point() + aim_cast.get_collision_normal(),Vector3.UP)

func create_death_splash(point):
	var death = death_emitter.instance()
	get_parent().add_child(death)
	death.global_transform.origin = point
	death.emitting = true

remotesync func update_score(item,value,type_shot = Scores.REGULAR_SHOT):
	Scores.update_score(int(name),item,value,type_shot)
	emit_signal("on_score_changed",int(name),item)

func play_camera_anim(value):
	if value:
		camera_anim_player.play(current_anim)
	else:
		camera_anim_player.stop()

remotesync func equip_weapon(weapon):
	if weapon:
		current_weapon = hand.get_current_weapon()
		aim_cast.cast_to.z = weapon.get_range() * -1
		if is_network_master(): 
			emit_signal("on_weapon_equipped",current_weapon.get_magazine())
			if current_weapon.get_has_scope():
				crosshair.hide()
			else:
				crosshair.show()

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

func add_weapon(weapon):
	if weapon.TYPE == weapon.types.PRIMARY:
		primary_holster.add_child(weapon)
	else:
		secondary_holster.add_child(weapon)
	if not is_network_master(): weapon.set_remote_layer()

func add_melee_weapon(weapon):
	melee_weapon = weapon
	melee_holster.add_child(weapon)
	if not is_network_master(): melee_weapon.set_remote_layer()
	weapon.translation = Vector3.ZERO

remotesync func stow_melee_weapon():
	hand.remove_child(melee_weapon)
	melee_holster.add_child(melee_weapon)

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
		play_camera_anim(false)
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
		view.hide()
		add_child(view)
		sniper_overlay = view

func _on_weapon_out_of_ads():
	set_is_ads(false)

func _on_weapon_reloaded():
	if is_network_master():
		emit_signal("on_reload")

func _on_Player_tree_exiting():
	if is_network_master():
		player_controller.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
