extends ActorController

const IDLE = "idle"
const FIRING = "firing"
const OUT_OF_AMMO = "out_of_ammo"
const RELOAD = "reload"
const DRAW = "draw"
const STOW = "stow"
const SPRINT = "sprint"
const SPRINTING = "sprinting"

onready var anim_player: AnimationPlayer = get_node("../AnimationPlayer")

var ads = false setget set_ads,is_ads

func set_ads(value):
	ads = value

func is_ads():
	return ads

func check_input_pressed(event,input,method = null,param = null):
	if event.is_action_pressed(input):
		if method: call_deferred(method,param)
		return true
	return false

func check_input_released(event,input,method = null,param = null):
	if event.is_action_released(input):
		if method: call_deferred(method,param)
		return true
	return false

func fire(param):
	state_machine.rpc("fire",param)

func reload(_param):
	state_machine.rpc("reload")

func aim(param):
	set_ads(param)
	owner.ads(param)

func play_animation(animation,queue = false,anim_speed = 1.0,backwards = false):
	if anim_speed > 1.0:
		anim_player.playback_speed = anim_speed
	else:
		anim_player.playback_speed = 1.0
	if queue:
		anim_player.queue(animation)
	else:
		if not backwards:
			anim_player.play(animation)
		else:
			anim_player.play_backwards(animation)
