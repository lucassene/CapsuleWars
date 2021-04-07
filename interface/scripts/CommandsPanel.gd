extends Panel

onready var forward_label = $MarginContainer/VBoxContainer/VBoxContainer/ForwardLabel
onready var backwards_label = $MarginContainer/VBoxContainer/VBoxContainer/BackwardsLabel
onready var left_label = $MarginContainer/VBoxContainer/VBoxContainer/LeftLabel
onready var right_label = $MarginContainer/VBoxContainer/VBoxContainer/RightLabel
onready var jump_label = $MarginContainer/VBoxContainer/VBoxContainer2/JumpLabel
onready var sprint_label = $MarginContainer/VBoxContainer/VBoxContainer2/SprintLabel
onready var reload_label = $MarginContainer/VBoxContainer/VBoxContainer3/ReloadLabel
onready var melee_label = $MarginContainer/VBoxContainer/VBoxContainer3/MeleeLabel
onready var fire_label = $MarginContainer/VBoxContainer/VBoxContainer4/FireLabel
onready var aim_label = $MarginContainer/VBoxContainer/VBoxContainer4/AimLabel
onready var swap_label = $MarginContainer/VBoxContainer/VBoxContainer5/SwapLabel
onready var primary_label = $MarginContainer/VBoxContainer/VBoxContainer5/PrimaryLabel
onready var secondary_label = $MarginContainer/VBoxContainer/VBoxContainer5/SecondaryLabel
onready var score_label = $MarginContainer/VBoxContainer/VBoxContainer6/ScoreLabel
onready var sacrifice_label = $MarginContainer/VBoxContainer/VBoxContainer6/SacrificeLabel

const JOY_LEFT_STICK = "Left Stick"
const JOY_SPRINT = "L3"
const JOY_MELEE = "R1"
const JOY_FIRE = "R2"
const JOY_AIM = "L2"
const JOY_SCORE = "L1"
const JOY_PRIMARY = "D-Pad Left"
const JOY_SECONDARY = "D-Pad Right"
const KEY_FORWARD = "W or P"
const KEY_LEFT = "A or L"
const KEY_JUMP = "Spacebar"
const KEY_SPRINT = "Shift"
const KEY_RELOAD = "R or I"
const KEY_MELEE = "E or O"
const KEY_FIRE = "Left Mouse Click"
const KEY_AIM = "Right Mouse Click"
const KEY_PRIMARY = "1 or -"
const KEY_SECONDARY = "2 or ="
const KEY_SCORE = "Capslock or Enter"
const KEY_SACRIFICE = "Backspace"
const PT_BACKWARDS = "S or Ç"
const EN_BACKWARDS = "S or ;"
const PT_RIGHT = "Right: D or ~"
const EN_RIGHT = "Right: D or '"
const PT_SWAP = "Tab or ["
const EN_SWAP = "Tab or ]"

func _ready():
	Input.connect("joy_connection_changed",self,"_on_gamepad_changed")
	update_commands()

func update_commands():
	if GameSettings.is_gamepad_mode():
		set_gamepad_commands()
	else:
		set_keyboard_commands()

func set_gamepad_commands():
	forward_label.text = "Forward: %s" % JOY_LEFT_STICK
	backwards_label.text = "Backwards: %s" % JOY_LEFT_STICK
	left_label.text = "Left: %s" % JOY_LEFT_STICK
	right_label.text = "Right: %s" % JOY_LEFT_STICK
	sprint_label.text = "Sprint: %s" % JOY_SPRINT
	melee_label.text = "Melee: %s" % JOY_MELEE
	fire_label.text = "Fire: %s" % JOY_FIRE
	aim_label.text = "Aim: %s" % JOY_AIM
	score_label.text = "Scoreboard: %s" % JOY_SCORE
	reload_label.text = "Reload: %s" % get_reload_button()
	jump_label.text = "Jump: %s" % get_jump_button()
	swap_label.text = "Swap weapons: %s" % get_swap_button()
	sacrifice_label.text = "Sacrifice: %s" % get_sacrifice_button()
	primary_label.text = "Equip Primary: %s" % JOY_PRIMARY
	secondary_label.text = "Equip Secondary: %s" % JOY_SECONDARY

func set_keyboard_commands():
	forward_label.text = "Forward: %s" % KEY_FORWARD
	left_label.text = "Left: %s" % KEY_LEFT
	sprint_label.text = "Sprint: %s" % KEY_SPRINT
	jump_label.text = "Jump: %s" % KEY_JUMP
	reload_label.text = "Reload: %s" % KEY_RELOAD
	melee_label.text = "Melee: %s" % KEY_MELEE
	fire_label.text = "Fire: %s" % KEY_FIRE
	aim_label.text = "Aim: %s" % KEY_AIM
	primary_label.text = "Equip Primary: %s" % KEY_PRIMARY
	secondary_label.text = "Equip Secondary: %s" % KEY_SECONDARY
	score_label.text = "Scoreboard: %s" % KEY_SCORE
	sacrifice_label.text = "Sacrifice: %s" % KEY_SACRIFICE
	if OS.keyboard_get_layout_language(OS.keyboard_get_current_layout()) == "pt":
		backwards_label.text = "Backwards: %s" % PT_BACKWARDS
		right_label.text = "Right: %s" % PT_RIGHT
		swap_label.text = swap_label.text % PT_SWAP
	else:
		backwards_label.text = "Backwards: %s" % EN_BACKWARDS
		right_label.text = "Right: %s" % EN_RIGHT
		swap_label.text = "Swap weapons: %s" % EN_SWAP
	
func get_reload_button():
	match Input.get_joy_name(GameSettings.gamepad_id):
		"PS4 Controller":
			return "Square"
		_:
			return "Cross"

func get_jump_button():
	match Input.get_joy_name(GameSettings.gamepad_id):
		"PS4 Controller":
			return "X"
		_:
			return "A"

func get_swap_button():
	match Input.get_joy_name(GameSettings.gamepad_id):
		"PS4 Controller":
			return "Triangle"
		_:
			return "Y"

func get_sacrifice_button():
	match Input.get_joy_name(GameSettings.gamepad_id):
		"PS4 Controller":
			return "Share"
		_:
			return "Select"

func _on_gamepad_changed(_device_id,_connected):
	update_commands()

