extends Control

signal new_game_pressed
signal continue_pressed
signal options_pressed
signal editor_pressed

func _ready():
	self.connect("new_game_pressed", get_parent(), "load_game")
	self.connect("continue_pressed", get_parent(), "load_game")
	self.connect("options_pressed", get_parent(), "load_options")
	self.connect("editor_pressed", get_parent(), "load_level_editor")
	return


func _on_New_Game_pressed():
	emit_signal("new_game_pressed")
	return

func _on_Continue_pressed():
	emit_signal("continue_pressed")
	return


func _on_Options_pressed():
	emit_signal("options_pressed")
	return


func _on_Level_Editor_pressed():
	emit_signal("editor_pressed")
	return


func _on_Exit_pressed():
	get_tree().quit()
	return
