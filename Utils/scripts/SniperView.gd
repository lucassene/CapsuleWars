extends ViewportContainer

onready var sniper_view = $SniperView

func get_texture():
	return sniper_view.get_texture()
