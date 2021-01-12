extends Viewport

onready var camera : Camera = $Camera

onready var player_camera

func _process(_delta):
	size = get_viewport().size
	camera.global_transform = player_camera.global_transform
	camera.fov = player_camera.fov

func initialize(player_cam):
	player_camera = player_cam
