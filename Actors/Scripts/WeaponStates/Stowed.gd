extends State

export var CAN_STOW = false

func enter(_delta = 0.0):
	print(actor.name + " STOWED")
	actor.set_physics_process(false)
	controller.play_animation(controller.STOW)
	controller.set_ads(false)
