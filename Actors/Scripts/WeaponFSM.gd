extends StateMachine

onready var rof_timer: Timer = $Firing/ROFTimer
onready var pulse_timer: Timer = $Firing/PulseTimer

var can_fire = true setget set_can_fire
var sprint = false

func set_can_fire(value):
	can_fire = value

func initialize(first_state,actor_controller):
	.initialize(first_state,actor_controller)
	calculate_rof(actor.RATE_OF_FIRE)

func is_weapon_ready():
	if actor.has_ammo() and can_fire and states[current_state].CAN_FIRE:
		return true
	return false

func can_swap():
	return states[current_state].CAN_STOW

func is_busy():
	return states[current_state].CAN_MELEE

func set_sprint(value):
	sprint = value
	if current_state == "Idle":
		states[current_state].set_sprint(value)

func is_sprinting():
	return sprint

func calculate_rof(rate_of_fire):
	var rof = float(60.0) / rate_of_fire
	rof_timer.wait_time = rof
	if actor.PULSE:
		var pulse = float(60.0) / actor.PULSE_RATE
		pulse_timer.wait_time = pulse

remotesync func fire(is_firing):
	if current_state != "Stowed":
		if !is_firing:
			actor.fire(false)
			if current_state == "Firing":
				states[current_state].on_fire_released()
		elif actor.has_ammo():
			if can_fire:
				set_state("Firing")
		else:
			actor.play_no_ammo_sound()

remotesync func reload():
	if actor.can_reload():
		set_state("Reloading")

func stow_weapon():
	if states[current_state].CAN_STOW:
		set_state("Stowed")
		return true
	return false

func _on_ROFTimer_timeout():
	if owner.has_ammo():
		can_fire = true
		if current_state == "Firing":
			states[current_state].next_fire()
		elif actor.DEBUG_FIRE and actor.PULSE:
			set_state("Firing")

func _on_PulseTimer_timeout():
	if current_state == "Firing":
		states[current_state].pulse_fire()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == controller.OUT_OF_AMMO:
		set_state("Idle")
		return
