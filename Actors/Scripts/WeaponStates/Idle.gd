extends State

export var CAN_STOW = true
export var CAN_ADS = true

var sprinting = false

func enter(_delta = 0.0):
	print(actor.name + " IDLE")
	if not state_machine.is_sprinting():
		controller.play_animation(controller.IDLE,true)
		sprinting = false
	else:
		sprinting = true
		controller.play_animation(controller.SPRINT)
		#controller.play_animation(controller.SPRINTING,true)

func handle_input(event):
	if controller.check_input_pressed(event,"fire","fire",true): return
	if controller.check_input_pressed(event,"reload","reload"): return
	if controller.check_input_pressed(event,"aim","aim",true): return
	if controller.check_input_released(event,"aim","aim",false): return

func update(delta):
	if controller.is_ads() and actor.transform.origin != actor.ADS_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.ADS_POSITION,actor.ADS_SPEED * delta)
	elif actor.transform.origin != actor.DEFAULT_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.DEFAULT_POSITION,actor.ADS_SPEED * delta)

func set_sprint(value):
	if sprinting != value:
		if value:
			controller.play_animation(controller.SPRINT)
			#controller.play_animation(controller.SPRINTING,true)
		else:
			controller.play_animation(controller.SPRINT,false,1.0,true)
			controller.play_animation(controller.IDLE,true)
	sprinting = value
