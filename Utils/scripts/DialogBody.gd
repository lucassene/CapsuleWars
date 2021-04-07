extends Control
class_name DialogBody

export var TITLE = ""
export var CONFIRM_TEXT = ""
export var CANCEL_TEXT = ""
export var NEED_FOCUS = false
export(NodePath) var FIRST_NODE

signal exited
signal no_focus_needed

func initialize():
	if NEED_FOCUS:
		get_node(FIRST_NODE).grab_focus()
		return
	emit_signal("no_focus_needed")

func get_title():
	return TITLE
	
func get_confirm_text():
	return CONFIRM_TEXT

func get_cancel_text():
	return CANCEL_TEXT

func confirm_pressed():
	emit_signal("exited")

func cancel_pressed():
	emit_signal("exited")
