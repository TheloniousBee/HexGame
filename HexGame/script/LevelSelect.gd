extends Node

signal level_selected(file_path)
signal escape_pressed
signal credits_button_pressed

var button_resource = load("res://scene/LevelButton.tscn")
var last_pos = Vector2.ZERO

func _ready():
	connect("level_selected", get_parent(), "start_game_from_level_select")
	setup_level_buttons()
	connect("escape_pressed", get_parent(), "return_to_main_menu")
	connect("credits_button_pressed", get_parent(), "goto_credits")
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
	
func set_total_star_count(levels_completed):
	$TotalStarCount.text = (levels_completed as String)+"×"
	return
	
func disable_hubs(levels_completed):
	var hubs = get_tree().get_nodes_in_group("level_hub")
	for hub in hubs:
		if hub.unlock_threshold > levels_completed:
			hub.disable_hub()
		else:
			hub.enable_hub()
			if(hub.unlock_threshold == 54):
				hub.enable_all()
	return

func _on_Quit_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("escape_pressed")
	return

func show_credits_button():
	$Credits.visible = true
	return

func _on_Credits_pressed():
	emit_signal("credits_button_pressed")
	return
