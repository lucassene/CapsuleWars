extends Control
class_name DialogBody

export var TITLE = ""
export var CONFIRM_TEXT = ""
export var CANCEL_TEXT = ""

func get_title():
	return TITLE
	
func get_confirm_text():
	return CONFIRM_TEXT

func get_cancel_text():
	return CANCEL_TEXT

func confirm_pressed():
	pass

func cancel_pressed():
	pass
