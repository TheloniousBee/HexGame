extends HBoxContainer

var playing = false

signal reverse_step_pressed
signal play_pressed
signal pause_pressed
signal forward_step_pressed

func _ready():
	connect("reverse_step_pressed", get_parent(), "reverse_turn")
	connect("play_pressed", get_parent(), "start_play_timer")
	connect("pause_pressed", get_parent(), "stop_play_timer")
	connect("forward_step_pressed", get_parent(), "record_and_advance")
	return

func _on_Reverse_Step_pressed():
	Global.sound_mgr.playUndoButton()
	emit_signal("reverse_step_pressed")
	if playing:
		get_node("Play").text = "Play"
		playing = false
	return

func _on_Play_pressed():
	Global.sound_mgr.playPauseButton()
	if playing:
		emit_signal("pause_pressed")
		get_node("Play").text = "Play"
		playing = false
	else:
		emit_signal("play_pressed")
		get_node("Play").text = "Pause"
		playing = true
	return

func _on_Forward_Step_pressed():
	Global.sound_mgr.playForwardStep()
	emit_signal("forward_step_pressed")
	return
