extends Button

export var level_num : int

var completed : bool = false

signal level_button_pressed

func _ready():
	connect("level_button_pressed", get_parent().get_parent(), "level_selected")
	return


func _on_LevelButton_pressed():
	Global.sound_mgr.playMainMenuClick()
	emit_signal("level_button_pressed", level_num)
	return

func assign_level_num(num):
	text = (num+1) as String
	level_num = num
	return

func set_complete(is_complete):
	completed = is_complete
	if completed:
		$Star.visible = true
	else:
		$Star.visible = false
	return
