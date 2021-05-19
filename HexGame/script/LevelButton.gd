extends Button

export var level_num : int

signal level_button_pressed

func _ready():
	connect("level_button_pressed", get_parent().get_parent().get_parent(), "level_selected")
	return


func _on_LevelButton_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("level_button_pressed", level_num)
	return
