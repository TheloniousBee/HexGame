extends Node

signal options_concluded


var SFX_bus = AudioServer.get_bus_index("SFX")
var Music_bus = AudioServer.get_bus_index("Music")

var original_sfx_db : float
var original_music_db : float
var original_fullscreen : bool
var original_resolution : Vector2

var previous_resolution : Vector2

#So we can filter resolution to numbers only
onready var regex = RegEx.new()

func _ready():
	load_options()
	connect("options_concluded", get_parent(), "load_main_menu")
	regex.compile("[0-9]+")
	return
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ESCAPE and event.pressed:
			emit_signal("options_concluded")
	return


func _on_Fullscreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	set_initial_resolution()
	Global.sound_mgr.playOptionClick()
	return


func _on_SFXVolume_value_changed(value):
	var max_value = get_node("VBoxContainer/SFXContainer/SFXVolume").max_value
	var db_value = (value / (max_value / 60)) - 60
	AudioServer.set_bus_volume_db(SFX_bus,db_value)
	Global.sound_mgr.playOptionClick()
	return


func _on_MusicVolume_value_changed(value):
	var max_value = get_node("VBoxContainer/MusicContainer/MusicVolume").max_value
	var db_value = (value / (max_value / 60)) - 60
	AudioServer.set_bus_volume_db(Music_bus,db_value)
	return


func _on_Width_text_changed(new_text):
	var line_edit = get_node("VBoxContainer/ResolutionContainer/Width")
	var original_caret_pos = line_edit.caret_position
	line_edit.text = remove_non_numbers(new_text)
	line_edit.caret_position = original_caret_pos
	return


func _on_Height_text_changed(new_text):
	var line_edit = get_node("VBoxContainer/ResolutionContainer/Height")
	var original_caret_pos = line_edit.caret_position
	line_edit.text = remove_non_numbers(new_text)
	line_edit.caret_position = original_caret_pos
	return

func remove_non_numbers(field_text):
	var matches = regex.search_all(field_text)
	var text = ""
	if matches:
		for r_match in matches:
			text += r_match.get_string()
			
	return text

func _on_Accept_pressed():
	Global.sound_mgr.playOptionClick()
	change_resolution()
	save_options()
	emit_signal("options_concluded")
	return


func _on_Cancel_pressed():
	Global.sound_mgr.playOptionClick()
	emit_signal("options_concluded")
	return

func change_resolution():
	var width = get_node("VBoxContainer/ResolutionContainer/Width").text
	var height = get_node("VBoxContainer/ResolutionContainer/Height").text
	var resolution = Vector2(width, height)
	if(resolution.x > OS.get_screen_size().x or resolution.y > OS.get_screen_size().y):
		printerr("Resolution set is larger than screen size")
	else:
		OS.window_size = resolution
	return
	
func set_initial_resolution():
	#Set resolution initial value
	original_resolution = OS.window_size
	var width_text_box = get_node("VBoxContainer/ResolutionContainer/Width")
	var height_text_box = get_node("VBoxContainer/ResolutionContainer/Height")
	width_text_box.text = original_resolution.x as String
	height_text_box.text = original_resolution.y as String
	return

func save_options():
	var options = File.new()
	options.open("user://options.dat", File.WRITE)
	options.store_line(to_json(AudioServer.get_bus_volume_db(SFX_bus)))
	options.store_line(to_json(AudioServer.get_bus_volume_db(Music_bus)))
	options.store_line(to_json(OS.window_fullscreen))
	options.store_line(to_json(OS.window_size.x))
	options.store_line(to_json(OS.window_size.y))
	options.close()
	return

func load_options():
	#Set sfx slider initial value
	var sfx_slider = get_node("VBoxContainer/SFXContainer/SFXVolume")
	var sfx_db_value = AudioServer.get_bus_volume_db(SFX_bus)
	original_sfx_db = sfx_db_value
	var sfx_slider_value = (sfx_db_value + 60) * (sfx_slider.max_value / 60)
	sfx_slider.value = sfx_slider_value
	
	#Set music slider initial value
	var music_slider = get_node("VBoxContainer/MusicContainer/MusicVolume")
	var mus_db_value = AudioServer.get_bus_volume_db(Music_bus)
	original_music_db = mus_db_value
	var mus_slider_value = (mus_db_value + 60) * (music_slider.max_value / 60)
	music_slider.value = mus_slider_value
	
	#Set fullscreen initial value
	original_fullscreen = OS.window_fullscreen
	var fullscreen_checkbox = get_node("VBoxContainer/Fullscreen")
	fullscreen_checkbox.pressed = OS.window_fullscreen
	
	set_initial_resolution()
	return


func _on_Width_text_entered(_new_text):
	change_resolution()
	Global.sound_mgr.playOptionClick()
	return


func _on_Height_text_entered(new_text):
	change_resolution()
	Global.sound_mgr.playOptionClick()
	return

func _on_ResolutionTimer_timeout():
	if(previous_resolution != OS.window_size):
		previous_resolution = OS.window_size
		set_initial_resolution()
	return
