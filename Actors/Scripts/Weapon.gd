extends Spatial

export var RATE_OF_FIRE = 1.0
export var DEFAULT_POSITION = Vector3.ZERO setget ,get_default_position
export var ADS_POSITION = Vector3.ZERO setget ,get_ads_position
export var ADS_SPEED = 20 setget ,get_ads_speed
export var ADS_FOV = 50 setget ,get_ads_fov

var is_ads = false

func get_default_position():
	return DEFAULT_POSITION

func get_ads_position():
	return ADS_POSITION

func get_ads_speed():
	return ADS_SPEED

func get_ads_fov():
	return ADS_FOV

func _ready():
	transform.origin = DEFAULT_POSITION

func _process(delta):
	if is_ads:
		transform.origin = transform.origin.linear_interpolate(ADS_POSITION,ADS_SPEED * delta)
	else:
		transform.origin = transform.origin.linear_interpolate(DEFAULT_POSITION,ADS_SPEED * delta)

func ads(value):
	is_ads = value

