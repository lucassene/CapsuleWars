extends Control

const MAX_CHILD_COUNT = 6

onready var entry_scene = preload("res://interface/scenes/ChatEntry.tscn")
onready var container = $Container

func create_entry(text):
	var new_entry = entry_scene.instance()
	new_entry.bbcode_text = text
	container.add_child(new_entry)
	erase_child()

func erase_child():
	if container.get_child_count() > MAX_CHILD_COUNT:
		container.get_child(0).queue_free()
