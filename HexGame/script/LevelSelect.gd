extends Node

signal level_selected(file_path)
signal escape_pressed

var button_resource = load("res://scene/LevelButton.tscn")
#var button_resource = load("res://scene/LevelButtonDir.tscn")
var last_pos = Vector2.ZERO

func _ready():
	connect("level_selected", get_parent(), "start_game_from_level_select")
	create_level_buttons_by_number()
	connect("escape_pressed", get_parent(), "return_to_main_menu")
	return
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("escape_pressed")
	return
	

func level_selected(level_num):
	emit_signal("level_selected", Global.level_directory[level_num], level_num)
	return
	
func level_dir_selected(filepath):
	emit_signal("level_selected", filepath, 1)
	return
	
func create_level_buttons_by_number():
	for i in range(Global.level_directory.size()):
		var button = button_resource.instance()
		#button.rect_position = last_pos + Vector2(button.rect_size.x + 5,0) 
		button.text = (i+1) as String
		button.level_num = i
		#last_pos = button.rect_position
		
		#yeah i know this is ugly but I can't be bothered coming up with something more elegant
		if i >= 0 and i < 12:
			$VBoxContainer/HBoxContainer.add_child(button)
		elif i >= 12 and i < 24:
			$VBoxContainer/HBoxContainer2.add_child(button)
		elif i >= 24 and i < 36:
			$VBoxContainer/HBoxContainer3.add_child(button)
		elif i >= 36 and i < 48:
			$VBoxContainer/HBoxContainer4.add_child(button)
		elif i >= 48 and i < 60:
			$VBoxContainer/HBoxContainer5.add_child(button)
			
	return
	
#func create_level_buttons_by_dir():
#	var level_dir = "res://levels/"
#	var dir = Directory.new()
#	if dir.open(level_dir) == OK:
#		dir.list_dir_begin()
#		var file_name = dir.get_next()
#		while file_name != "":
#			if dir.current_is_dir():
#				print("Found directory: " + file_name)
#			else:
#				print("Found file: " + file_name)
#				if(file_name.ends_with(".lvl")):
#					print("level okay!")
#					create_level_button(level_dir,file_name)
#			file_name = dir.get_next()
#	else:
#		print("An error occured when trying to access the path.")
#	return

#func create_level_button(level_dir, file_name):
#	var button = button_resource.instance()
#	button.rect_position = last_pos + Vector2(0,button.rect_size.y + 3) 
#	button.text = file_name
#	button.filepath = level_dir+file_name
#	last_pos = button.rect_position
#	add_child(button)
#	return
