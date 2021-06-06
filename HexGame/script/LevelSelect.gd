extends Node

signal level_selected(file_path)
signal escape_pressed

var button_resource = load("res://scene/LevelButton.tscn")
var last_pos = Vector2.ZERO

func _ready():
	connect("level_selected", get_parent(), "start_game_from_level_select")
	setup_level_buttons()
	connect("escape_pressed", get_parent(), "return_to_main_menu")
	return
	
func level_selected(level_num):
	emit_signal("level_selected", Global.level_directory[level_num], level_num)
	return
	
func setup_level_buttons():
	$Hub1.assign_level_nums(0)
	$Hub2.assign_level_nums(6)
	$Hub3.assign_level_nums(12)
	$Hub4.assign_level_nums(18)
	$Hub5.assign_level_nums(24)
	$Hub6.assign_level_nums(30)
	$Hub7.assign_level_nums(36)
	$Hub8.assign_level_nums(42)
	$Hub9.assign_level_nums(48)
	$Hub10.assign_level_nums(54)
	return

func _on_Quit_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("escape_pressed")
	return
