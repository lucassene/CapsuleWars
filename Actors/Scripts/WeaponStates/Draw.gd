extends State

export var CAN_STOW = false

func enter(_delta = 0.0):
	print(actor.name + " DRAW")
	actor.set_physics_process(true)
	controller.play_animation(controller.DRAW)
	controller.set_ads(false)
