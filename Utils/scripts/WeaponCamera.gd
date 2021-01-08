extends Viewport

onready var camera : Camera = $Camera

onready var player_camera

func _process(_delta):
	camera.global_transform = player_camera.global_transform

func initialize(player_cam):
	player_camera = player_cam
