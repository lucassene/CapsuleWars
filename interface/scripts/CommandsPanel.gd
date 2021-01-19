extends Panel

onready var backwards_label = $MarginContainer/VBoxContainer/VBoxContainer/BackwardsLabel
onready var right_label = $MarginContainer/VBoxContainer/VBoxContainer/RightLabel
onready var swap_label = $MarginContainer/VBoxContainer/VBoxContainer5/SwapLabel

const PT_BACKWARDS = "Backwards: S or Ç"
const EN_BACKWARDS = "Backwards: S or ;"
const PT_RIGHT = "Right: D or ~"
const EN_RIGHT = "Right: D or '"
const PT_SWAP = "Swap: Tab or ["
const EN_SWAP = "Swap: Tab or ]"

func _ready():
	if OS.keyboard_get_layout_language(OS.keyboard_get_current_layout()) == "pt":
		backwards_label.text = PT_BACKWARDS
		right_label.text = PT_RIGHT
		swap_label.text = PT_SWAP
	else:
		backwards_label.text = EN_BACKWARDS
		right_label.text = EN_RIGHT
		swap_label.text = EN_SWAP
