extends Sprite3D

onready var regular_font = preload("res://interface/resources/DMGLabelRegularFont.tres")
onready var crit_font = preload("res://interface/resources/DMGLabelCritFont.tres")

onready var damage_label: Label = $Viewport/Label
onready var tween: Tween = $Tween
onready var viewport: Viewport = $Viewport

var velocity = Vector3.ZERO

func _physics_process(delta):
	global_transform.origin += velocity * delta

func _ready():
	randomize()
	var y_speed = randi() % 4 + 2
	var x_speed = randi() % 8 - 2
	velocity = Vector3(x_speed,y_speed,0)
	
func initialize(damage,shot_type):
	damage_label.text = str(int(round(damage)))
	_set_label_by_type(shot_type)
	tween.interpolate_property(self,"scale",0.2,1.2,0.5,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	tween.start()
	texture = viewport.get_texture()

func _set_label_by_type(shot_type):
	if shot_type == Scores.HEADSHOT or shot_type == Scores.TAILSHOT:
		damage_label.set("custom_fonts/font",crit_font)
		damage_label.set("custom_colors/font_color",Color.yellow)
	else:
		damage_label.set("custom_fonts/font",regular_font)
		damage_label.set("custom_colors/font_color",Color.white)

func _on_Tween_tween_all_completed():
	queue_free()
