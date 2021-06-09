extends Control

signal return_to_main_menu

func _ready():
	connect("return_to_main_menu", get_parent(), "load_main_menu")
	return

func _on_Quit_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("return_to_main_menu")
	return
