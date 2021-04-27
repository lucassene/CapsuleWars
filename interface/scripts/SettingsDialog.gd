extends DialogBody

onready var camera_slider: HSlider = $CameraContainer/HBoxContainer/CameraSlider
onready var camera_label: Label = $CameraContainer/HBoxContainer/CameraLabel

func _ready():
	camera_slider.min_value = GameSettings.get_min_sensitivity()
	camera_slider.max_value = GameSettings.get_max_sensitivity()
	camera_slider.value = GameSettings.get_current_sensitivity()
	camera_label.text = str(stepify(GameSettings.get_current_sensitivity(),0.01))

func confirm_pressed():
	GameSettings.set_current_sensitivity(camera_slider.value)
	.confirm_pressed()

func _on_CameraSlider_value_changed(value):
	camera_label.text = str(stepify(value,0.01))
