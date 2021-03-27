extends Node

const MainMenu = preload("res://scene/MainMenu.tscn")

var current_scene
var playtest_cache

func _ready():
	Global.sound_mgr = $SoundManager
	import_level_list()
	load_main_menu()
	return
	
func remove_current_scene():
	if current_scene != null:
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
