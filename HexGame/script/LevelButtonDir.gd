extends Button

var filepath : String

signal level_button_pressed

func _ready():
	connect("level_button_pressed", get_parent(), "level_dir_selected")
	return


func _on_LevelButton_pressed():
	emit_signal("level_button_pressed", filepath)
	return
