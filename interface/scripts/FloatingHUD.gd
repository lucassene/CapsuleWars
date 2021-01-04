extends VBoxContainer

onready var name_label = $NameLabel
onready var progress_bar = $ProgressBar

func set_name(name):
	name_label.text = name
