extends Control

signal new_game_pressed
signal continue_pressed
signal options_pressed
signal editor_pressed(load_playtest_data)

func _ready():
	connect("new_game_pressed", get_parent(), "load_game")
	connect("continue_pressed", get_parent(), "load_game")
	connect("options_pressed", get_parent(), "load_options")
	connect("editor_pressed", get_parent(), "load_level_editor")
	
	if OS.is_debug_build():
		$"MainMenuButtons/Level Editor".visible = true
	return


func _on_New_Game_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("new_game_pressed")
	return

func _on_Continue_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("continue_pressed")
	return


func _on_Options_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("options_pressed")
	return


func _on_Level_Editor_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("editor_pressed", false)
	return


func _on_Exit_pressed():
	Global.sound_mgr.playMainMenuClick()
	get_tree().quit()
	return
