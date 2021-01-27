extends Node

signal level_selected(file_path)

func _ready():
	connect("level_selected", get_parent(), "start_game_from_level_select")
	
	var button_resource = load("res://scene/LevelButton.tscn")
	
	for i in range(Global.level_directory.size()):
		var button = button_resource.instance()
		button.text = (i+1) as String
		button.level_num = i
		add_child(button)
	return

func level_selected(level_num):
	emit_signal("level_selected", Global.level_directory[level_num], level_num)
	return
	
