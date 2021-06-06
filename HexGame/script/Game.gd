extends Node

var current_level_num = 0
signal nav_to_editor(load_playtest_data)
signal return_to_main_menu

var level_scene
var level_select_scene
var max_level_completed = 0

#Variables for playtesting data
var time_start
var undo_presses = 0
var reset_presses = 0
var playtest_filepath : String
var playtest_file

func _ready():
	connect("nav_to_editor", get_parent(), "load_level_editor")
	connect("return_to_main_menu", get_parent(), "load_main_menu")
	init_playtest_recording()
	return
	
func init_level_select_scene():
	var ls_resource = load("res://scene/LevelSelect.tscn")
	level_select_scene = ls_resource.instance()
	add_child(level_select_scene)
	
	var levels_completed = load_game_progress()
	max_level_completed = levels_completed
	var all_buttons = get_tree().get_nodes_in_group("level_buttons")
	for button in all_buttons:
		if button.level_num <= levels_completed+1:
			button.disabled = false
		else:
			button.disabled = true
	return
	
func init_level_scene():
	var level_resource = load("res://scene/Level.tscn")
	level_scene = level_resource.instance()
	add_child(level_scene)
	return
	
func destroy_level_scene():
	remove_child(level_scene)
	level_scene.call_deferred("free")
	return
	
func destroy_level_select_scene():
	remove_child(level_select_scene)
	level_select_scene.call_deferred("free")
	return

func start_game_from_level_select(filepath, level_num):
	current_level_num = level_num
	destroy_level_select_scene()
	init_level_scene()
	load_level(filepath)
	init_playtest_data()
	return
	
func return_to_main_menu():
	emit_signal("return_to_main_menu")
	return
	
func continue_to_next_level():
	record_playtest_data()
	if(Global.level_directory.size() == current_level_num+1):
		print("Last level completed!")
		return_to_level_select()
	else:
		destroy_level_scene()
		init_level_scene()
		current_level_num += 1
		load_level(Global.level_directory[current_level_num])
		init_playtest_data()
	return
	
func load_level_from_playtest(level_data):
	#Copy the whole level_data array, so we don't pop things off we need if we reset
	var duped_ldata = level_data.duplicate(true)
	init_level_scene()
	level_scene.playtest = true
	
	#Load level scene with our cached data
	var playable_hex_grid = level_scene.get_node("PlayHexGrid")
	
	#get row and column numbers first
	var _grid_size_line = duped_ldata.pop_front()
	
	#get playable tiles
	var playable_tiles = parse_json(duped_ldata.pop_front())
	for i in playable_tiles:
		level_scene.add_placeable_hex(i)
	
	#get playable grid
	var playable_grid_line = duped_ldata.pop_front()
	if playable_grid_line == "PlayableGrid:":
		for line in duped_ldata:
			var parsed_line = parse_json(line)
			#Create the row
			var row = []
			while(parsed_line.size() >= 2):
				#Add hex to row, and set coordinate and flavour here
				var coordinate = parsed_line.pop_front()
				var flavour = parsed_line.pop_front()
				var new_hex = playable_hex_grid.create_empty_hex(str_to_vec2(coordinate))
				if flavour != "Empty":
					new_hex.change_hex_type(flavour)
				row.append(new_hex)
			playable_hex_grid.columns.append(row)
		playable_hex_grid.recenter_grid()
	
	level_scene.record_game_state()
	return
	
func reset_level():
	reset_presses += 1
	destroy_level_scene()
	init_level_scene()
	load_level(Global.level_directory[current_level_num])
	return
	
func reset_playtest_level():
	destroy_level_scene()
	if get_parent().playtest_cache != null:
		load_level_from_playtest(get_parent().playtest_cache)
	else:
		printerr("Playtest cache is null")
	return 
	
func return_to_level_select():
	record_playtest_data()
	destroy_level_scene()
	init_level_select_scene()
	return
	
func nav_to_editor():
	emit_signal("nav_to_editor", true)
	return

func load_level(filepath : String):	
	var playable_hex_grid = level_scene.get_node("PlayHexGrid")
	
	#load in the file from a specific path as the function argument
	
	var save_file = File.new()
	if !save_file.file_exists(filepath):
		return
	
	#delete anything we need to from the existing level
	
	save_file.open(filepath, File.READ)
	#get row and column numbers first
	var _grid_size_line = save_file.get_line()
	
	#get playable tiles
	var playable_tiles = parse_json(save_file.get_line())
	for i in playable_tiles:
		level_scene.add_placeable_hex(i)
	
	#get playable grid
	var playable_grid_line = save_file.get_line()
	if playable_grid_line == "PlayableGrid:":
		while(save_file.get_position() < save_file.get_len()):
			var line = save_file.get_line()
			var parsed_line = parse_json(line)
			#Create the row
			var row = []
			while(parsed_line.size() >= 2):
				#Add hex to row, and set coordinate and flavour here
				var coordinate = parsed_line.pop_front()
				var flavour = parsed_line.pop_front()
				var new_hex = playable_hex_grid.create_empty_hex(str_to_vec2(coordinate))
				if flavour != "Empty":
					new_hex.change_hex_type(flavour)
				row.append(new_hex)
			playable_hex_grid.columns.append(row)
		playable_hex_grid.recenter_grid()
	save_file.close()
	
	level_scene.record_game_state()
	display_tutorial()
	level_scene.get_node("LevelCount").text = (current_level_num+1) as String
	return


func str_to_vec2(string : String):
	#Assumption is that the string looks like: "(5,3)"
	var left_stripped_string = string.lstrip("(")
	var stripped_string = left_stripped_string.rstrip(")")
	var vec2 = Array(stripped_string.split(","))
	return Vector2(vec2.front(),vec2.back())

func init_playtest_recording():
	var playtests_folder_path = "Playtests"
	var dir = Directory.new()
	if dir.open("user://") == OK:
		if !dir.dir_exists(playtests_folder_path):
			dir.make_dir(playtests_folder_path)
		
		if dir.change_dir(playtests_folder_path) == OK:
			dir.list_dir_begin(true, false)
			
			var file_name = dir.get_next()
			var count = 0
			while file_name != "":
				count += 1
				file_name = dir.get_next()
		
			playtest_file = File.new()
			playtest_filepath = "user://" + playtests_folder_path + "/Playtest_" + (count as String)
			playtest_file.open(playtest_filepath, File.WRITE)
			playtest_file.store_line("Initial Test Start:" + (OS.get_unix_time() as String))
			playtest_file.close()
	return

func record_playtest_data():
	if playtest_filepath != null:
		playtest_file.open(playtest_filepath, File.READ_WRITE)
		playtest_file.seek_end()
		playtest_file.store_line(Global.level_directory[current_level_num])
		playtest_file.store_line("Time Taken:"+level_completion_time())
		playtest_file.store_line("Undos:" + (undo_presses as String))
		playtest_file.store_line("Resets:" + (reset_presses as String))
		playtest_file.close()
	return
	
func init_playtest_data():
	time_start = OS.get_unix_time()
	undo_presses = 0
	reset_presses = 0
	return	

func level_completion_time():
	var time_end = OS.get_unix_time()
	var elapsed_time = time_end - time_start
	var time_string = (elapsed_time as String)
	return time_string

func undo_pressed():
	undo_presses += 1
	return

func save_game_progress():
	if (current_level_num > max_level_completed):
		var dir = Directory.new()
		if dir.open("user://") == OK:
			var save_game_file = File.new()
			var file_path = "user://savegame.dat"
			save_game_file.open(file_path, File.WRITE)
			save_game_file.store_16(current_level_num)
			save_game_file.close()
	return
	
func load_game_progress():
	var dir = Directory.new()
	if dir.open("user://") == OK:
		var save_game_file = File.new()
		var file_path = "user://savegame.dat"
		if save_game_file.file_exists(file_path):
			save_game_file.open(file_path, File.READ)
			var last_level_completed = save_game_file.get_16()
			save_game_file.close()
			return last_level_completed
	return -1

func display_tutorial():
	var tut = level_scene.get_node("Tutorial")
	
	#Disable time controls at the start to make the game simpler.
	if(current_level_num <= 1):
		level_scene.get_node("TimeControls").visible = false
	
	#Display a hint
	match current_level_num:
		0:
			tut.text = "Complete the land."
		2:
			tut.text = "Time flows."
		6:
			tut.text = "March on."
		12:
			tut.text = "Chop chop."
		18:
			tut.text = "Turn around."
		30:
			tut.text = "Unlock."
		36:
			tut.text = "Copy the land."
		48:
			tut.text = "It's fast."
		54:
			tut.text = "Good luck."
		_:
			tut.text = ""
	return
