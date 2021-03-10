extends Node

var current_level_num = 0


func _ready():
	pass

func start_game_from_level_select(filepath, level_num):
	current_level_num = level_num
	var level_select = get_node("LevelSelect")
	remove_child(level_select)
	level_select.call_deferred("free")
	var level_resource = load("res://scene/Level.tscn")
	var level = level_resource.instance()
	add_child(level)
	
	load_level(filepath)
	return
	
func continue_to_next_level():
	if(Global.level_directory.size() == current_level_num+1):
		print("Last level completed!")
		return_to_level_select()
	else:
		var level = get_node("Level")
		remove_child(level)
		level.queue_free()
		var level_resource = load("res://scene/Level.tscn")
		level = level_resource.instance()
		add_child(level)	
		current_level_num += 1
		load_level(Global.level_directory[current_level_num])
	return

func reset_level():
	var level = get_node("Level")
	remove_child(level)
	level.queue_free()
	var level_resource = load("res://scene/Level.tscn")
	level = level_resource.instance()
	add_child(level)	
	load_level(Global.level_directory[current_level_num])
	return
	
func return_to_level_select():
	var level = get_node("Level")
	remove_child(level)
	level.queue_free()
	var level_select_resource = load("res://scene/LevelSelect.tscn")
	var level_select = level_select_resource.instance()
	add_child(level_select)
	return

func load_level(filepath : String):	
	var level = get_node("Level")
	var playable_hex_grid = level.get_node("PlayHexGrid")
	
	#load in the file from a specific path as the function argument
	
	var save_file = File.new()
	if !save_file.file_exists(filepath):
		return
	
	#delete anything we need to from the existing level
	
	save_file.open(filepath, File.READ)
	#get row and column numbers first
	var grid_size_line = save_file.get_line()
	
	#get playable tiles
	var playable_tiles = parse_json(save_file.get_line())
	for i in playable_tiles:
		level.add_placeable_hex(i)
	
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
	
	level.record_game_state()
	return


func str_to_vec2(string : String):
	#Assumption is that the string looks like: "(5,3)"
	var left_stripped_string = string.lstrip("(")
	var stripped_string = left_stripped_string.rstrip(")")
	var vec2 = Array(stripped_string.split(","))
	return Vector2(vec2.front(),vec2.back())
