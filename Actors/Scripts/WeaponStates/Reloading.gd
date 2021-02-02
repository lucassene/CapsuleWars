extends State

export var CAN_STOW = false

func enter(_delta = 0.0):
	print(actor.name + " RELOADING")
	actor.reload()
	controller.play_animation(controller.RELOAD)

func handle_input(event):
	if controller.check_input_released(event,"aim","aim",false): return

func update(delta):
	if controller.is_ads() and actor.transform.origin != actor.ADS_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.ADS_POSITION,actor.ADS_SPEED * delta)
	elif actor.transform.origin != actor.DEFAULT_POSITION:
		actor.transform.origin = actor.transform.origin.linear_interpolate(actor.DEFAULT_POSITION,actor.ADS_SPEED * delta)
