extends Node

signal escape_pressed

func _ready():
	connect("escape_pressed", get_parent(), "load_main_menu")
	return
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("escape_pressed")
	return
