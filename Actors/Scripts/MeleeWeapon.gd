extends Spatial

onready var area : Area = $Area
onready var timer : Timer = $Timer
onready var anim_player : AnimationPlayer = $AnimationPlayer
onready var ray_cast : RayCast = $RayCast
onready var mesh: MeshInstance = $knife/knife

export var DAMAGE = 25 setget ,get_damage
export var COOLDOWN = 2.0
export var HOLSTER_POSITION = Vector3(-1.461,-1.949,2.002)
export var MIN_X_RECOIL = 1.0
export var MAX_X_RECOIL = 2.0
export var MIN_Y_RECOIL = 1.0
export var MAX_Y_RECOIL = 1.0

var can_attack = true
var player

func get_damage():
	return DAMAGE

func is_ready():
	return can_attack

func set_owner(actor):
	player = actor

func activate_area(value):
	area.monitoring = value

func stow():
	translation = Vector3.ZERO
	player.stow_melee_weapon()

func attack():
	player.shake_camera(MIN_X_RECOIL,MAX_X_RECOIL,MIN_Y_RECOIL,MAX_Y_RECOIL)
	anim_player.play("attack")

func set_remote_layer():
	mesh.set_layer_mask_bit(1,false)
	mesh.set_layer_mask_bit(2,true)

func _on_Timer_timeout():
	can_attack = true

func _on_AnimationPlayer_animation_started(_anim_name):
	can_attack = false
	timer.start()

func _on_AnimationPlayer_animation_finished(_anim_name):
	stow()

func _on_Area_body_entered(body):
	if body.is_in_group("Player") and body != player:
		player.melee_hit(body,ray_cast.get_collision_point())
		return
	if body.is_in_group("Enemy"):
		print("acertou o inimigo!")
