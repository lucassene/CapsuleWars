extends Sprite3D

onready var viewport = $Viewport
onready var floating_hud = $Viewport/FloatingHUD
onready var name_label = $Viewport/FloatingHUD/NameLabel
onready var progress_bar = $Viewport/FloatingHUD/ProgressBar

func _ready():
	texture = viewport.get_texture()

func set_name(name):
	name_label.text = name

func set_progress(health):
	progress_bar.value = health
