extends State

onready var rof_timer: Timer = $ROFTimer
onready var pulse_timer: Timer = $PulseTimer

export var CAN_STOW = false

var pulse_count = 0

func enter(_delta = 0.0):
	print(actor.name + " FIRING")
	pulse_count = 0
	state_machine.set_can_fire(false)
	if actor.get_has_scope(): actor.out_of_ads()
	if not actor.PULSE:
		fire()
	else:
		pulse_fire()

func handle_input(event):
	if controller.check_input_released(event,"fire","fire",false): return
	if not actor.get_has_scope():
		if controller.check_input_pressed(event,"aim","aim",true): return
	if controller.check_input_released(event,"aim","aim",false): return

func update(delta):
	if controller.is_ads() and actor.transform.origin != actor.ADS_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.ADS_POSITION,actor.ADS_SPEED * delta)
	elif actor.transform.origin != actor.DEFAULT_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.DEFAULT_POSITION,actor.ADS_SPEED * delta)
	
func fire():
	actor.current_ammo -= 1
	play_animation()
	actor.fire(true)
	if !actor.PULSE:
		rof_timer.start()
	else:
		pulse_timer.start()

func next_fire():
	if actor.DEBUG_FIRE:
		fire()
		return
	else:
		if not actor.AUTO and not actor.PULSE:
			state_machine.set_state("Idle")
			return
		if actor.AUTO and actor.is_player_firing():
			fire()

func pulse_fire():
	pulse_count += 1
	if pulse_count <= actor.PULSE_SHOTS:
		fire()
	else:
		actor.set_player_firing(false)
		rof_timer.start()
		state_machine.set_state("Idle")

func play_animation():
	var anim_speed = float(actor.RATE_OF_FIRE) / 600.0
	if actor.has_ammo():
		controller.play_animation(controller.FIRING,false,anim_speed)
	else:
		controller.play_animation(controller.OUT_OF_AMMO,false,anim_speed)

func on_fire_released():
	if actor.PULSE or actor.get_has_scope() or actor.DEBUG_FIRE:
		return
	state_machine.set_state("Idle")

func exit():
	if actor.get_has_scope() and actor.get_was_ads():
		actor.back_to_ads()
