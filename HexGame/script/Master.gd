extends Node

const MainMenu = preload("res://scene/MainMenu.tscn")
const Spark = preload("res://scene/Particle/Clicksparks.tscn")

var current_scene
var playtest_cache

func _ready():
	Global.sound_mgr = $SoundManager
	load_option_settings()
	import_level_list()
	load_main_menu()
	return
	
func remove_current_scene():
	if current_scene != null:
		Global.is_level_editor = false
		remove_child(current_scene)
		current_scene.call_deferred("free")
	return
	
func load_main_menu():
	remove_current_scene()
	var menu = MainMenu.instance()
	add_child(menu)
	current_scene = menu
	return
	
func load_game():
	remove_current_scene()
	var game_resource = load("res://scene/Game.tscn")
	var game = game_resource.instance()
	add_child(game)
	current_scene = game
	game.init_level_select_scene()
	return
	
func load_options():
	remove_current_scene()
	var option_resource = load("res://scene/Options.tscn")
	var option = option_resource.instance()
	add_child(option)
	current_scene = option
	return

func load_level_editor(load_playtest_data):
	remove_current_scene()
	var editor_resource = load("res://scene/LevelEditor.tscn")
	var editor = editor_resource.instance()
	add_child(editor)
	current_scene = editor
	if load_playtest_data and playtest_cache != null:
		editor.load_playtesting_level(playtest_cache)
		playtest_cache = null
	else:
		editor.init_level_editor()
	return
	
func load_playtest(level_data):
	playtest_cache = level_data
	remove_current_scene()
	var game_resource = load("res://scene/Game.tscn")
	var game = game_resource.instance()
	add_child(game)
	current_scene = game
	game.load_level_from_playtest(level_data)
	return

func import_level_list():
	var levels = File.new()
	if !levels.file_exists(Global.level_directory_file):
		printerr("Level directory could not be found")
		return
	
	levels.open(Global.level_directory_file, File.READ)
	while levels.get_position() < levels.get_len():
		var level = levels.get_line()
		if level.begins_with("res://levels/"):
			Global.level_directory.append(level)
	
	levels.close()
	return

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var spark = Spark.instance()
			spark.position = event.position
			spark.emitting = true
			add_child(spark)
	return

func load_option_settings():
	var saved_options = File.new()
	if not saved_options.file_exists("user://options.dat"):
		return
	saved_options.open("user://options.dat", File.READ)
	while saved_options.get_position() < saved_options.get_len():
		
		var saved_sfx_volume = parse_json(saved_options.get_line())
		var SFX_bus = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_volume_db(SFX_bus,saved_sfx_volume)
		
		var saved_music_volume = parse_json(saved_options.get_line())
		var Music_bus = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_volume_db(Music_bus,saved_music_volume)
		
		OS.window_fullscreen = parse_json(saved_options.get_line())
		var width = parse_json(saved_options.get_line())
		var height = parse_json(saved_options.get_line())
		OS.window_size = Vector2(width, height)
	saved_options.close()
	return
